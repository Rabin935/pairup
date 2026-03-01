import 'package:equatable/equatable.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';

enum MotionSensorStatus { idle, listening, error }

class MotionSensorState extends Equatable {
  final MotionSensorStatus status;
  final SensorVectorEntity gyroscope;
  final SensorVectorEntity accelerometer;
  final int shakeCount;
  final DateTime? lastShakeAt;
  final String? errorMessage;

  const MotionSensorState({
    this.status = MotionSensorStatus.idle,
    this.gyroscope = const SensorVectorEntity.zero(),
    this.accelerometer = const SensorVectorEntity.zero(),
    this.shakeCount = 0,
    this.lastShakeAt,
    this.errorMessage,
  });

  MotionSensorState copyWith({
    MotionSensorStatus? status,
    SensorVectorEntity? gyroscope,
    SensorVectorEntity? accelerometer,
    int? shakeCount,
    DateTime? lastShakeAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MotionSensorState(
      status: status ?? this.status,
      gyroscope: gyroscope ?? this.gyroscope,
      accelerometer: accelerometer ?? this.accelerometer,
      shakeCount: shakeCount ?? this.shakeCount,
      lastShakeAt: lastShakeAt ?? this.lastShakeAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    gyroscope,
    accelerometer,
    shakeCount,
    lastShakeAt,
    errorMessage,
  ];
}
