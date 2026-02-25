// Mapped to GetGyroscopeStreamUsecase because ChangeThemeUsecase is not implemented yet.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/features/sensor/domain/entities/sensor_vector_entity.dart';
import 'package:pairup/features/sensor/domain/usecases/get_motion_sensor_streams_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockMotionSensorRepository repository;
  late GetGyroscopeStreamUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockMotionSensorRepository();
    usecase = GetGyroscopeStreamUsecase(repository: repository);
  });

  test('returns gyroscope stream when source succeeds', () async {
    when(
      () => repository.gyroscopeStream(),
    ).thenAnswer((_) => Stream.value(sampleGyroscope));

    final stream = usecase();

    await expectLater(stream, emits(sampleGyroscope));
    verify(() => repository.gyroscopeStream()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('forwards stream error when source fails', () async {
    final exception = Exception('sensor failed');
    when(
      () => repository.gyroscopeStream(),
    ).thenAnswer((_) => Stream<SensorVectorEntity>.error(exception));

    final stream = usecase();

    await expectLater(stream, emitsError(exception));
    verify(() => repository.gyroscopeStream()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
