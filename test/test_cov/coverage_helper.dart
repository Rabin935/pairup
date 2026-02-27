import 'dart:io';

const _defaultInput = 'coverage/lcov.info';
const _defaultOutput = 'coverage/lcov.filtered.info';

final _generatedPatterns = <Pattern>[
  '.g.dart',
  '.freezed.dart',
  'generated/',
  'generated\\',
  '/gen/',
  '\\gen\\',
];

void main(List<String> args) {
  final minCoverage = _readMinCoverage(args) ?? 70.0;
  final inputPath = _readArg(args, '--input=') ?? _defaultInput;
  final outputPath = _readArg(args, '--output=') ?? _defaultOutput;

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Coverage file not found at $inputPath');
    exitCode = 2;
    return;
  }

  final lines = inputFile.readAsLinesSync();

  final filteredLines = <String>[];
  var keepRecord = false;
  var totalLines = 0;
  var coveredLines = 0;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      final source = line.substring(3);
      keepRecord = !_generatedPatterns.any((pattern) => source.contains(pattern));
      if (keepRecord) {
        filteredLines.add(line);
      }
      continue;
    }

    if (!keepRecord) {
      continue;
    }

    if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        totalLines += 1;
        final hits = int.tryParse(parts[1]) ?? 0;
        if (hits > 0) {
          coveredLines += 1;
        }
      }
    }

    filteredLines.add(line);
  }

  final outputFile = File(outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync('${filteredLines.join('\n')}\n');

  final coverage = totalLines == 0 ? 0.0 : (coveredLines / totalLines) * 100;
  stdout.writeln(
    'Filtered coverage: ${coverage.toStringAsFixed(2)}% '
    '($coveredLines/$totalLines lines).',
  );
  stdout.writeln('Filtered report written to: $outputPath');

  if (coverage < minCoverage) {
    stderr.writeln(
      'Coverage gate failed: ${coverage.toStringAsFixed(2)}% '
      '< ${minCoverage.toStringAsFixed(2)}%',
    );
    exitCode = 1;
  } else {
    stdout.writeln(
      'Coverage gate passed: ${coverage.toStringAsFixed(2)}% '
      '>= ${minCoverage.toStringAsFixed(2)}%',
    );
  }
}

double? _readMinCoverage(List<String> args) {
  final raw = _readArg(args, '--min=');
  if (raw == null) {
    return null;
  }
  return double.tryParse(raw);
}

String? _readArg(List<String> args, String prefix) {
  for (final arg in args) {
    if (arg.startsWith(prefix)) {
      return arg.substring(prefix.length);
    }
  }
  return null;
}
