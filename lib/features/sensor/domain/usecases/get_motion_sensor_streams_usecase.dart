import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/sensor/data/repositories/motion_sensor_repository.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/domain/repositories/motion_sensor_repository.dart';

final getGyroscopeStreamUsecaseProvider = Provider<GetGyroscopeStreamUsecase>((
  ref,
) {
  return GetGyroscopeStreamUsecase(
    repository: ref.read(motionSensorRepositoryProvider),
  );
});

final getAccelerometerStreamUsecaseProvider =
    Provider<GetAccelerometerStreamUsecase>((ref) {
      return GetAccelerometerStreamUsecase(
        repository: ref.read(motionSensorRepositoryProvider),
      );
    });

class GetGyroscopeStreamUsecase {
  final IMotionSensorRepository _repository;

  GetGyroscopeStreamUsecase({required IMotionSensorRepository repository})
    : _repository = repository;

  Stream<SensorVectorEntity> call() {
    return _repository.gyroscopeStream();
  }
}

class GetAccelerometerStreamUsecase {
  final IMotionSensorRepository _repository;

  GetAccelerometerStreamUsecase({required IMotionSensorRepository repository})
    : _repository = repository;

  Stream<SensorVectorEntity> call() {
    return _repository.accelerometerStream();
  }
}
