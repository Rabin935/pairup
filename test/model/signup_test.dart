import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Arithmetic test1', () {
    test('add two number', () {
      final firstname = Arithmetic();
      int expectedValue = 7;
      arithmetic.first = 3;
      arithmetic.second = 4;
      int? actualValue = arithmetic.add();

      expect(expectedValue, actualValue);
    });
  });
}
