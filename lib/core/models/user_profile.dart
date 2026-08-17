class UserProfile {
  final String uid;
  final String fullName;
  final String nickname;
  final String email;
  final String phone;
  final String profileImage;
  final String quote;
  final double monthlyBudget;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.quote,
    required this.monthlyBudget,
    required this.createdAt,
  });

  factory UserProfile.defaultUser() {
    return UserProfile(
      uid: 'user_default',
      fullName: 'Alshifa M',
      nickname: 'ali_2004',
      email: 'alshifam2004@gmail.com',
      phone: '+91 79024 66325',
      profileImage: '',
      quote: 'Stay focused and make it happen. ✨',
      monthlyBudget: 15000.0,
      createdAt: DateTime(2025, 5, 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'quote': quote,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? 'Alshifa M',
      nickname: json['nickname'] ?? 'ali_2004',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      quote: json['quote'] ?? 'Stay focused and make it happen. ✨',
      monthlyBudget: (json['monthlyBudget'] ?? 15000.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? fullName,
    String? nickname,
    String? email,
    String? phone,
    String? profileImage,
    String? quote,
    double? monthlyBudget,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      quote: quote ?? this.quote,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
