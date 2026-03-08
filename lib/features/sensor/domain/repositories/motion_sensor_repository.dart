import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';

abstract interface class IMotionSensorRepository {
  Stream<SensorVectorEntity> gyroscopeStream();

  Stream<SensorVectorEntity> accelerometerStream();
}
