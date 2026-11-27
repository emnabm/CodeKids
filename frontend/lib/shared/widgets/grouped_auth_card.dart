import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Grouped dark glass input container with glowing border & hairline dividers,
/// matching `creerCompte.PNG`.
class GroupedAuthCard extends StatelessWidget {
  const GroupedAuthCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171142).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6B4CF5).withValues(alpha: 0.7),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.border.withValues(alpha: 0.8),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Clean borderless row input inside [GroupedAuthCard].
class GroupedAuthField extends StatelessWidget {
  const GroupedAuthField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onFieldSubmitted,
      enabled: enabled,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colors.mutedText.withValues(alpha: 0.85)),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(
            icon,
            color: const Color(0xFFD0C4FF),
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Astronaut + flanking planets header matching `creerCompte.PNG`.
class AuthCosmicHeader extends StatelessWidget {
  const AuthCosmicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 26,
            child: Image.asset(
              'assets/images/saturne.png',
              width: 82,
            ),
          ),
          Positioned(
            right: 0,
            top: 22,
            child: Image.asset(
              'assets/images/planete_violette.png',
              width: 72,
            ),
          ),
          Positioned(
            left: 84,
            bottom: 18,
            child: Image.asset(
              'assets/images/etoile.png',
              width: 16,
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B4CF5).withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
            child: Image.asset(
              'assets/images/astronaute.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
