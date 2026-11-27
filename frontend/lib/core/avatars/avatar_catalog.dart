import 'package:flutter/material.dart';

class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.assetPath,
    required this.fallbackIcon,
    required this.backgroundColor,
    required this.labelEn,
    required this.labelFr,
  });

  final String id;
  final String assetPath;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final String labelEn;
  final String labelFr;

  String labelFor(String languageCode) =>
      languageCode == 'fr' ? labelFr : labelEn;
}

/// Maps backend `avatarId` strings to local assets and fallback icons.
class AvatarCatalog {
  const AvatarCatalog._();

  static const String defaultAvatarId = 'avatar_robot_blue';

  static const List<AvatarOption> options = [
    AvatarOption(
      id: 'avatar_robot_blue',
      assetPath: 'assets/avatars/avatar_robot_blue.png',
      fallbackIcon: Icons.smart_toy_rounded,
      backgroundColor: Color(0xFF2B67D9),
      labelEn: 'Blue Bot',
      labelFr: 'Robot Bleu',
    ),
    AvatarOption(
      id: 'avatar_astronaut_boy',
      assetPath: 'assets/avatars/avatar_astronaut_boy.png',
      fallbackIcon: Icons.face_rounded,
      backgroundColor: Color(0xFF5B4BD6),
      labelEn: 'Astro Boy',
      labelFr: 'Astronaute',
    ),
    AvatarOption(
      id: 'avatar_astronaut_girl',
      assetPath: 'assets/avatars/avatar_astronaut_girl.png',
      fallbackIcon: Icons.face_3_rounded,
      backgroundColor: Color(0xFF8338EC),
      labelEn: 'Astro Girl',
      labelFr: 'Exploratrice',
    ),
    AvatarOption(
      id: 'avatar_robot_purple',
      assetPath: 'assets/avatars/avatar_robot_purple.png',
      fallbackIcon: Icons.precision_manufacturing_rounded,
      backgroundColor: Color(0xFF6A4C93),
      labelEn: 'Nova Bot',
      labelFr: 'Robot Nova',
    ),
    AvatarOption(
      id: 'avatar_alien_green',
      assetPath: 'assets/avatars/avatar_alien_green.png',
      fallbackIcon: Icons.adb_rounded,
      backgroundColor: Color(0xFF2B9348),
      labelEn: 'Pixel Alien',
      labelFr: 'Alien Pixel',
    ),
    AvatarOption(
      id: 'avatar_cat_space',
      assetPath: 'assets/avatars/avatar_cat_space.png',
      fallbackIcon: Icons.pets_rounded,
      backgroundColor: Color(0xFFD97706),
      labelEn: 'Astro Cat',
      labelFr: 'Chat Spatial',
    ),
  ];

  static AvatarOption resolve(String? avatarId) {
    if (avatarId == null || avatarId.isEmpty) return options.first;
    return options.firstWhere(
      (option) => option.id == avatarId,
      orElse: () => options.first,
    );
  }
}
