class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;
  final String address;
  final String payment;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.address,
    required this.payment,
  });

  factory AppUser.fromDoc(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      fullName: (data['fullName'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      photoUrl: (data['photoUrl'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      payment: (data['payment'] ?? '').toString(),
    );
  }
}