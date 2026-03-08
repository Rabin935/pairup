// Mapped to GetAccelerometerStreamUsecase because ChangeLanguageUsecase is not implemented yet.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/domain/usecases/get_motion_sensor_streams_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockMotionSensorRepository repository;
  late GetAccelerometerStreamUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockMotionSensorRepository();
    usecase = GetAccelerometerStreamUsecase(repository: repository);
  });

  test('returns accelerometer stream when source succeeds', () async {
    when(
      () => repository.accelerometerStream(),
    ).thenAnswer((_) => Stream.value(sampleAccelerometer));

    final stream = usecase();

    await expectLater(stream, emits(sampleAccelerometer));
    verify(() => repository.accelerometerStream()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('forwards stream error when source fails', () async {
    final exception = Exception('sensor failed');
    when(
      () => repository.accelerometerStream(),
    ).thenAnswer((_) => Stream<SensorVectorEntity>.error(exception));

    final stream = usecase();

    await expectLater(stream, emitsError(exception));
    verify(() => repository.accelerometerStream()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
