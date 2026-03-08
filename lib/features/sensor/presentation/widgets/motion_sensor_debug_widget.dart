import 'package:flutter/material.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/presentation/state/motion_sensor_state.dart';

class MotionSensorDebugWidget extends StatelessWidget {
  final MotionSensorState state;

  const MotionSensorDebugWidget({super.key, required this.state});

  String _axisLabel(SensorVectorEntity vector) {
    return 'x:${vector.x.toStringAsFixed(2)}  y:${vector.y.toStringAsFixed(2)}  z:${vector.z.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E5EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sensor Debug',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                state.status.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: state.status == MotionSensorStatus.error
                      ? Colors.redAccent
                      : const Color(0xFF0E7C86),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gyroscope: ${_axisLabel(state.gyroscope)}',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            'Accelerometer: ${_axisLabel(state.accelerometer)}',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            'Shake count: ${state.shakeCount}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
