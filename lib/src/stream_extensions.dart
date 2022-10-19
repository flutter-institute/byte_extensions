import 'dart:typed_data';

import 'enums.dart';
import 'integer_extensions.dart';
import 'bigint_extensions.dart';
import 'double_extensions.dart';

/// Extension to add our helper methods onto int streams
extension StreamReadIntExtension on Stream<int> {
  /// Read a list of bytes from the stream and convert them to an integer respecting [endian]ness.
  Future<int> readInt({
    Endian endian = Endian.big,
    IntType type = IntType.int64,
  }) async {
    final bytes = <int>[];
    await for (var b in take(type.bytesPerElement)) {
      bytes.add(b);
    }

    return bytes.asInt(endian: endian, type: type);
  }

  /// Read a list of bytes from the stream and convert them to a BigInt respecting [endian]ness.
  /// Treated as an unsigned value by default, to change set [signed] to `true`.
  Future<BigInt> readBigInt(
    int maxBytes, {
    Endian endian = Endian.big,
    bool signed = false,
  }) async {
    final bytes = <int>[];
    await for (var b in take(maxBytes)) {
      bytes.add(b);
    }

    return bytes.asBigInt(endian: endian, signed: signed);
  }

  /// Read a list of bytes from the stream and convert them to a double respecting [endian]ness.
  Future<double> readDouble({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
  }) async {
    final bytes = <int>[];
    await for (var b in take(precision.bytesPerElement)) {
      bytes.add(b);
    }

    return bytes.asDouble(endian: endian, precision: precision);
  }
}
