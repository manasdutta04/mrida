class UserProfile {
  const UserProfile({
    required this.uid,
    required this.phoneNumber,
    required this.languageCode,
    this.displayName,
  });
  final String uid;
  final String phoneNumber;
  final String languageCode;
  final String? displayName;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        phoneNumber: json['phoneNumber'] as String,
        languageCode: json['languageCode'] as String,
        displayName: json['displayName'] as String?,
      );
}
