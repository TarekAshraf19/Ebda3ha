import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../models/order_model.dart';
import '../../../../services/reviews_service.dart';

class RateProductScreen extends StatefulWidget {
  final OrderModel order;

  const RateProductScreen({
    super.key,
    required this.order,
  });

  @override
  State<RateProductScreen> createState() => _RateProductScreenState();
}

class _RateProductScreenState extends State<RateProductScreen> {
  int rating = 4;
  final TextEditingController reviewController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final notRatedItems =
    widget.order.items.where((e) => !e.isRated).toList();

    if (notRatedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.tr('already_rated'))),
      );
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.tr('write_review'))),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await ReviewsService.instance.submitReview(
        order: widget.order,
        rating: rating,
        comment: reviewController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.tr('review_success'))),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr.tr('error')}: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildStar(int index) {
    final selected = index < rating;

    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index + 1;
        });
      },
      child: Icon(
        Icons.star,
        size: 46,
        color: selected
            ? Colors.amber
            : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg =
    isDark ? AppColors.darkScaffold : AppColors.kPageBg;

    final cardBg =
    isDark ? AppColors.darkCard : AppColors.whiteColor;

    final primaryText =
    isDark ? AppColors.darkTextPrimary : Colors.black87;

    final secondaryText =
    isDark ? AppColors.darkTextSecondary : Colors.grey;

    final borderColor =
    isDark ? AppColors.darkBorder : Colors.grey.shade300;

    final notRatedItems =
    widget.order.items.where((e) => !e.isRated).toList();

    final alreadyRated = notRatedItems.isEmpty;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr.tr('rate_product'),
          style: const TextStyle(
            color: AppColors.kPrimaryPink,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.kPrimaryPink),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          /// Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.kPrimaryPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr.tr('review_reward'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Already rated
          if (alreadyRated)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                context.tr.tr('already_rated'),
                style: TextStyle(
                  fontSize: 16,
                  color: primaryText,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr.tr('products_to_review'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.kPrimaryPink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...notRatedItems.map(
                        (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• ${item.title}',
                        style: TextStyle(
                          fontSize: 15,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 26),

          /// Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, _buildStar),
          ),

          const SizedBox(height: 24),

          /// Review box
          Container(
            height: 270,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: reviewController,
                    maxLines: null,
                    expands: true,
                    maxLength: 200,
                    style: TextStyle(color: primaryText),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: context.tr.tr('write_something'),
                      hintStyle: TextStyle(color: secondaryText),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${reviewController.text.length}/200',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Upload
          Row(
            children: [
              _uploadBox(Icons.image_outlined),
              const SizedBox(width: 16),
              _uploadBox(Icons.camera_alt_outlined),
            ],
          ),

          const SizedBox(height: 34),

          /// Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: (loading || alreadyRated) ? null : _submitReview,
              child: Text(
                loading
                    ? context.tr.tr('loading')
                    : context.tr.tr('submit_review'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadBox(IconData icon) {
    return Container(
      width: 68,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.kPrimaryPink.withOpacity(.45),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.kPrimaryPink),
    );
  }
}