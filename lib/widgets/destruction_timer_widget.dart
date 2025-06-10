import 'package:flutter/material.dart';

/// Widget para seleccionar el tiempo de autodestrucción de mensajes
class DestructionTimerWidget extends StatefulWidget {
  final int? selectedMinutes;
  final Function(int?) onChanged;

  const DestructionTimerWidget({
    super.key,
    this.selectedMinutes,
    required this.onChanged,
  });

  @override
  _DestructionTimerWidgetState createState() => _DestructionTimerWidgetState();
}

class _DestructionTimerWidgetState extends State<DestructionTimerWidget> {
  static const List<Map<String, dynamic>> destructionOptions = [
    {'label': '🔥 Sin autodestrucción', 'minutes': null, 'icon': '♾️'},
    {'label': '🔥 1 minuto', 'minutes': 1, 'icon': '⚡'},
    {'label': '🔥 5 minutos', 'minutes': 5, 'icon': '🔥'},
    {'label': '🔥 30 minutos', 'minutes': 30, 'icon': '⏰'},
    {'label': '🔥 1 hora', 'minutes': 60, 'icon': '🕐'},
    {'label': '🔥 12 horas', 'minutes': 720, 'icon': '🕛'},
    {'label': '🔥 24 horas', 'minutes': 1440, 'icon': '📅'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: widget.selectedMinutes,
          icon: const Icon(Icons.timer, size: 16, color: Colors.orange),
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.red),
          onChanged: widget.onChanged,
          items: destructionOptions.map((option) {
            return DropdownMenuItem<int?>(
              value: option['minutes'],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option['icon'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getShortLabel(option),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getShortLabel(Map<String, dynamic> option) {
    final minutes = option['minutes'] as int?;
    if (minutes == null) return 'Sin límite';
    if (minutes == 1) return '1m';
    if (minutes == 5) return '5m';
    if (minutes == 30) return '30m';
    if (minutes == 60) return '1h';
    if (minutes == 720) return '12h';
    if (minutes == 1440) return '24h';
    return '${minutes}m';
  }
}
