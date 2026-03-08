import 'package:equatable/equatable.dart';

class SensorVectorEntity extends Equatable {
  final double x;
  final double y;
  final double z;

  const SensorVectorEntity({required this.x, required this.y, required this.z});

  const SensorVectorEntity.zero() : x = 0, y = 0, z = 0;

  @override
  List<Object?> get props => [x, y, z];
}
