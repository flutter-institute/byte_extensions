import 'dart:typed_data';

import '../enums.dart';
import 'integer_extensions.dart';
import 'bigint_extensions.dart';
import 'double_extensions.dart';
import '../transformers/stream_transformers.dart';

/// Extension to add our helper methods onto int streams
extension IntStreamTransformExtension on Stream<int> {
  /// Read a list of bytes from the stream and convert them to an integer respecting [endian]ness.
  Future<int> readInt({
    Endian endian = Endian.big,
    IntType type = IntType.int64,
  }) async {
    final bytes = await take(type.bytesPerElement).toList();
    return bytes.asInt(endian: endian, type: type);
  }

  /// Transform this stream into an integer stream
  Stream<int> asIntStream({
    Endian endian = Endian.big,
    IntType type = IntType.int64,
    bool sync = false,
    bool cancelOnError = false,
  }) =>
      transform(IntegerByteStreamTransformer(endian, type,
          sync: sync, cancelOnError: cancelOnError));

  /// Read a list of bytes from the stream and convert them to a BigInt respecting [endian]ness.
  /// Treated as an unsigned value by default, to change set [signed] to `true`.
  Future<BigInt> readBigInt(
    int maxBytes, {
    Endian endian = Endian.big,
    bool signed = false,
  }) async {
    final bytes = await take(maxBytes).toList();
    return bytes.asBigInt(endian: endian, signed: signed);
  }

  /// Transform this stream into a BigInt stream
  Stream<BigInt> asBigIntStream(
    int maxBytes, {
    Endian endian = Endian.big,
    bool signed = false,
    bool sync = false,
    bool cancelOnError = false,
  }) =>
      transform(BigIntByteStreamTransformer(endian, maxBytes,
          signed: signed, sync: sync, cancelOnError: cancelOnError));

  /// Read a list of bytes from the stream and convert them to a double respecting [endian]ness.
  Future<double> readDouble({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
  }) async {
    final bytes = await take(precision.bytesPerElement).toList();
    return bytes.asDouble(endian: endian, precision: precision);
  }

  /// Transform this stream into a double stream
  Stream<double> asDoubleStream({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
    bool sync = false,
    bool cancelOnError = false,
  }) =>
      transform(DoubleByteStreamTransformer(endian, precision,
          sync: sync, cancelOnError: cancelOnError));
}

/// Extension to add our helper methods onto int list streams
extension IntListStreamTransformExtension on Stream<List<int>> {
  /// Transform this stream into an integer stream
  Stream<int> asIntStream({
    Endian endian = Endian.big,
    IntType type = IntType.int64,
    bool sync = false,
    bool cancelOnError = false,
  }) =>
      transform(IntegerByteListStreamTransformer(endian, type,
          sync: sync, cancelOnError: cancelOnError));

  /// Transform this stream into a BigInt stream
  Stream<BigInt> asBigIntStream(
    int maxBytes, {
    Endian endian = Endian.big,
    bool signed = false,
    bool sync = false,
    bool cancelOnError = false,
  }) =>
      transform(BigIntByteListStreamTransformer(endian, maxBytes,
          signed: signed, sync: sync, cancelOnError: cancelOnError));

  /// Transform this stream into a double stream
  Stream<double> asDoubleStream({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
    bool sync = false,
    bool cancelOnError = false,
  }) =>
      transform(DoubleByteListStreamTransformer(endian, precision,
          sync: sync, cancelOnError: cancelOnError));
}
