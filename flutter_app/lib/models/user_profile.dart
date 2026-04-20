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

  UserProfile copyWith({
    String? uid,
    String? phoneNumber,
    String? languageCode,
    String? displayName,
    String? state,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      languageCode: languageCode ?? this.languageCode,
      displayName: displayName ?? this.displayName,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'languageCode': languageCode,
        'displayName': displayName,
        'state': state,
      };
}
