import 'package:flutter/material.dart';
import '../services/static_avatar_service.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final String? imageUrl;
  final Color? backgroundColor;
  final bool useStaticAvatar;
  final String? userId; // NUEVO: ID del usuario para avatar específico

  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.imageUrl,
    this.backgroundColor,
    this.useStaticAvatar = true, // Por defecto usar avatares estáticos
    this.userId, // NUEVO: Para diferenciar avatares por usuario
  });

  // Obtener iniciales del nombre
  String get initials {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    }

    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  // Generar color basado en el nombre
  Color _getAvatarColor() {
    if (backgroundColor != null) return backgroundColor!;

    // Generar un color basado en las iniciales
    final colorValue =
        name.codeUnits.fold<int>(0, (prev, element) => prev + element);
    return Color.fromARGB(
      255,
      (colorValue * 33) % 255,
      (colorValue * 73) % 255,
      (colorValue * 153) % 255,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si hay URL de imagen, mostrar avatar con imagen (no usar estáticos)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    // Si está habilitado el avatar estático, usarlo
    if (useStaticAvatar) {
      return FutureBuilder<String?>(
        future: StaticAvatarService.getSelectedAvatar(userId: userId),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: AssetImage(snapshot.data!),
              backgroundColor: Colors.transparent,
            );
          }

          // Fallback a iniciales si no hay avatar estático
          return _buildInitialsAvatar();
        },
      );
    }

    // Fallback tradicional con iniciales
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _getAvatarColor(),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
