import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebad3a_ecommerce/services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_colors.dart';
import '../payment_screen/payment_details_screen.dart';



class ProfileScreen extends StatefulWidget {
  final bool embedded;

  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickAndUpload() async {
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xfile == null) return;

      await ProfileService.instance.uploadProfileImage(File(xfile.path));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile photo updated")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _editField({
    required String title,
    required String initial,
    required Future<void> Function(String newValue) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final c = TextEditingController(text: initial);

    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: c,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.kPrimaryPink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (res == null || res.trim().isEmpty) return;
    await onSave(res.trim());
  }

  Future<void> _changePassword() async {
    final passwordController = TextEditingController();
    bool obscure = true;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                "Change Password",
                style: TextStyle(
                  color: AppColors.kPrimaryPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: "Enter new password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.kPrimaryPink),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setDialogState(() {
                        obscure = !obscure;
                      });
                    },
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.kPrimaryPink,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      passwordController.text.trim(),
                    );
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty) return;

    if (result.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
        ),
      );
      return;
    }

    try {
      await ProfileService.instance.updatePassword(result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Failed to update password";

      if (e.code == 'requires-recent-login') {
        msg = "For security, log in again then try changing the password.";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;

    final body = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ProfileService.instance.userStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.kPrimaryPink));
        }

        final data = snapshot.data?.data() ?? {};
        final fullName =
        (data['fullName'] ?? authUser?.displayName ?? '').toString();
        final email = (data['email'] ?? authUser?.email ?? '').toString();
        final phone = (data['phone'] ?? '').toString();
        final address = (data['address'] ?? '').toString();
        final payment = (data['payment'] ?? '').toString();
        final photoUrl = (data['photoUrl'] ?? '').toString();

        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.kLightPink,
                        border: Border.all(
                          color: AppColors.kBorderPink.withOpacity(.5),
                          width: 1,
                        ),
                        image: photoUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: photoUrl.isEmpty
                          ? const Icon(
                        Icons.person,
                        color: AppColors.kPrimaryPink,
                        size: 34,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: GestureDetector(
                        onTap: _pickAndUpload,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.kPrimaryPink,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    "Welcome, $fullName",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kPrimaryPink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _FieldTile(
              label: "Your full name",
              value: fullName.isEmpty ? "Add your full name" : fullName,
              onEdit: () => _editField(
                title: "Full Name",
                initial: fullName,
                onSave: (v) => ProfileService.instance.updateFields(fullName: v),
              ),
            ),
            const SizedBox(height: 12),

            _FieldTile(
              label: "Your E-mail",
              value: email,
              onEdit: null,
            ),
            const SizedBox(height: 12),

            _FieldTile(
              label: "Your password",
              value: "********************",
              onEdit: _changePassword,
            ),
            const SizedBox(height: 12),

            _FieldTile(
              label: "Your mobile number",
              value: phone.isEmpty ? "Add your mobile number" : phone,
              onEdit: () => _editField(
                title: "Mobile Number",
                initial: phone,
                keyboardType: TextInputType.phone,
                onSave: (v) => ProfileService.instance.updateFields(phone: v),
              ),
            ),
            const SizedBox(height: 12),

            _FieldTile(
              label: "Your Address",
              value: address.isEmpty
                  ? "Add your address"
                  : address,
              onEdit: () => _editField(
                title: "Address",
                initial: address,
                onSave: (v) => ProfileService.instance.updateFields(address: v),
              ),
            ),
            const SizedBox(height: 12),

            _FieldTile(
              label: "Payment",
              value: payment.isEmpty ? "Add Your Information" : payment,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentDetailsScreen(),
                  ),
                );
              },
              trailingIsPlus: payment.isEmpty,
            ),
          ],
        );
      },
    );

    if (widget.embedded) {
      return SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: body),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final bool trailingIsPlus;

  const _FieldTile({
    required this.label,
    required this.value,
    required this.onEdit,
    this.trailingIsPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.kBorderPink, width: 1.15),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: Center(
                      child: Icon(
                        trailingIsPlus
                            ? Icons.add_circle_outline
                            : Icons.edit_outlined,
                        color: AppColors.kPrimaryPink,
                        size: 21,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}