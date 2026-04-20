class UserProfile {
  const UserProfile({
    required this.uid,
    required this.phoneNumber,
    required this.languageCode,
    this.displayName,
    this.state,
  });
  final String uid;
  final String phoneNumber;
  final String languageCode;
  final String? displayName;
  final String? state;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '+91 XXXXX XXXXX',
        languageCode: json['languageCode'] as String? ?? 'en',
        displayName: json['displayName'] as String?,
        state: json['state'] as String?,
      );
}
