import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:sensors_plus/sensors_plus.dart';

abstract interface class IMotionSensorDatasource {
  Stream<SensorVectorEntity> gyroscopeStream();

  Stream<SensorVectorEntity> accelerometerStream();
}

final motionSensorDatasourceProvider = Provider<IMotionSensorDatasource>((ref) {
  return MotionSensorDatasource();
});

class MotionSensorDatasource implements IMotionSensorDatasource {
  @override
  Stream<SensorVectorEntity> gyroscopeStream() {
    return gyroscopeEventStream().map(
      (event) => SensorVectorEntity(x: event.x, y: event.y, z: event.z),
    );
  }

  @override
  Stream<SensorVectorEntity> accelerometerStream() {
    return accelerometerEventStream().map(
      (event) => SensorVectorEntity(x: event.x, y: event.y, z: event.z),
    );
  }
}
