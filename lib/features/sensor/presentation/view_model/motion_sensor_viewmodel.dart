import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/domain/usecases/get_motion_sensor_streams_usecase.dart';
import 'package:pairup/features/sensor/presentation/state/motion_sensor_state.dart';

final motionSensorViewModelProvider =
    NotifierProvider<MotionSensorViewModel, MotionSensorState>(
      MotionSensorViewModel.new,
    );

class MotionSensorViewModel extends Notifier<MotionSensorState> {
  static const double _shakeThreshold = 18.0;
  static const Duration _shakeCooldown = Duration(milliseconds: 1200);

  late final GetGyroscopeStreamUsecase _getGyroscopeStreamUsecase;
  late final GetAccelerometerStreamUsecase _getAccelerometerStreamUsecase;

  StreamSubscription<SensorVectorEntity>? _gyroscopeSubscription;
  StreamSubscription<SensorVectorEntity>? _accelerometerSubscription;
  DateTime? _lastShakeDetectedAt;

  @override
  MotionSensorState build() {
    _getGyroscopeStreamUsecase = ref.read(getGyroscopeStreamUsecaseProvider);
    _getAccelerometerStreamUsecase = ref.read(
      getAccelerometerStreamUsecaseProvider,
    );

    ref.onDispose(() async {
      await stopListening();
    });

    return const MotionSensorState();
  }

  Future<void> startListening() async {
    if (_gyroscopeSubscription != null || _accelerometerSubscription != null) {
      return;
    }

    state = state.copyWith(
      status: MotionSensorStatus.listening,
      clearError: true,
    );

    _gyroscopeSubscription = _getGyroscopeStreamUsecase().listen(
      (event) {
        state = state.copyWith(gyroscope: event, clearError: true);
      },
      onError: (error) {
        state = state.copyWith(
          status: MotionSensorStatus.error,
          errorMessage: 'Gyroscope stream error: $error',
        );
      },
    );

    _accelerometerSubscription = _getAccelerometerStreamUsecase().listen(
      (event) {
        final updatedShakeCount = _detectShake(event)
            ? state.shakeCount + 1
            : state.shakeCount;

        state = state.copyWith(
          status: MotionSensorStatus.listening,
          accelerometer: event,
          shakeCount: updatedShakeCount,
          lastShakeAt: updatedShakeCount != state.shakeCount
              ? _lastShakeDetectedAt
              : state.lastShakeAt,
          clearError: true,
        );
      },
      onError: (error) {
        state = state.copyWith(
          status: MotionSensorStatus.error,
          errorMessage: 'Accelerometer stream error: $error',
        );
      },
    );
  }

  Future<void> stopListening() async {
    await _gyroscopeSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    _gyroscopeSubscription = null;
    _accelerometerSubscription = null;

    state = state.copyWith(status: MotionSensorStatus.idle, clearError: true);
  }

  bool _detectShake(SensorVectorEntity event) {
    final magnitude = sqrt(
      (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
    );
    if (magnitude < _shakeThreshold) return false;

    final now = DateTime.now();
    final recentShake =
        _lastShakeDetectedAt != null &&
        now.difference(_lastShakeDetectedAt!) < _shakeCooldown;
    if (recentShake) return false;

    _lastShakeDetectedAt = now;
    return true;
  }
}
