import 'package:flutter/material.dart';

/// Modelo para itens do menu de perfil
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });
}
