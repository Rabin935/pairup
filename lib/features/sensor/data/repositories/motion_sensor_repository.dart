import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/sensor/data/datasource/motion_sensor_datasource.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/domain/repositories/motion_sensor_repository.dart';

final motionSensorRepositoryProvider = Provider<IMotionSensorRepository>((ref) {
  return MotionSensorRepository(
    datasource: ref.read(motionSensorDatasourceProvider),
  );
});

class MotionSensorRepository implements IMotionSensorRepository {
  final IMotionSensorDatasource _datasource;

  MotionSensorRepository({required IMotionSensorDatasource datasource})
    : _datasource = datasource;

  @override
  Stream<SensorVectorEntity> gyroscopeStream() {
    return _datasource.gyroscopeStream();
  }

  @override
  Stream<SensorVectorEntity> accelerometerStream() {
    return _datasource.accelerometerStream();
  }
}
