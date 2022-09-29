import 'dart:typed_data';

import 'package:byte_extensions/src/helpers.dart';

/// Number of bytes for a 64-bit int
const _int64Size = Int64List.bytesPerElement;

/// Number of bytes for a 32-bit int
const _int32Size = Int32List.bytesPerElement;

/// Number of bytes for a 16-bit int
const _int16Size = Int16List.bytesPerElement;

/// Numbers of bytes for an 8-bit int
const _int8Size = Int8List.bytesPerElement;

/// A generator that converts an Integer to a Uint8List with a given Endianness
class IntegerByteListGenerator {
  IntegerByteListGenerator._(this._data, this._endian);

  /// The integer we are acting upon
  final int _data;

  /// The Endianness of the converstion
  final Endian _endian;

  /// Helper function to convert out ByteData to a Uint8List
  Uint8ClampedList _clamp(ByteData bytes) => bytes.buffer.asUint8ClampedList();

  /// Generate the list of bytes treating this as a 64-bit integer
  Uint8ClampedList asInt64() =>
      _clamp(ByteData(_int64Size)..setUint64(0, _data, _endian));

  /// Generate the list of bytes treating this as a 32-bit integer
  Uint8ClampedList asInt32() =>
      _clamp(ByteData(_int32Size)..setUint32(0, _data, _endian));

  /// Generate the list of bytes treating this as a 16-bit integer
  Uint8ClampedList asInt16() =>
      _clamp(ByteData(_int16Size)..setUint16(0, _data, _endian));

  /// Generate the list of bytes treating this as an 8-bit integer
  Uint8ClampedList asInt8() => _clamp(ByteData(_int8Size)..setUint8(0, _data));
}

/// Extention to add byte helpers to the native integer class
extension IntegerToBytesExtensions on int {
  /// Prepare the integer to be converted to a byte list.
  /// The endianness of the resulting byte list can be changed using [endian].
  IntegerByteListGenerator toBytes([Endian endian = Endian.big]) {
    return IntegerByteListGenerator._(this, endian);
  }
}

/// A generator that converts a List<int> to an integer with the given endianness
class ByteListIntegerGenerator {
  ByteListIntegerGenerator._(this._data, this._endian);

  /// The integer list we are acting upon
  final List<int> _data;

  /// The Endianness of the converstion
  final Endian _endian;

  /// Converts our backing list to ByteData while ensuring that we are
  /// handling the correct number of bytes.
  ByteData _toByteData(int bytesPerElement) {
    final bytes =
        Uint8List.fromList(endianFixedLength(_data, bytesPerElement, _endian));
    return bytes.buffer.asByteData();
  }

  /// Generate a signed 64-bit integer from the integer list
  int asInt64() => _toByteData(_int64Size).getInt64(0, _endian);

  /// Generate a unsigned 64-bit integer from the integer list
  /// NOTE: dart doesn't natively support unsigned 64-bit integers, so this is the same as `asInt64`
  int asUint64() => _toByteData(_int64Size).getUint64(0, _endian);

  /// Generate a signed 32-bit integer from the integer list
  int asInt32() => _toByteData(_int32Size).getInt32(0, _endian);

  /// Generate a unsigned 32-bit integer from the integer list
  int asUint32() => _toByteData(_int32Size).getUint32(0, _endian);

  /// Generate a signed 16-bit integer from the integer list
  int asInt16() => _toByteData(_int16Size).getInt16(0, _endian);

  /// Generate a unsigned 16-bit integer from the integer list
  int asUint16() => _toByteData(_int16Size).getUint16(0, _endian);

  /// Generate a signed 8-bit integer from the integer list
  int asInt8() => _toByteData(_int8Size).getInt8(0);

  /// Generate a unsigned 16-bit integer from the integer list
  int asUint8() => _toByteData(_int8Size).getUint8(0);
}

/// Extension for adding byte helpers to lists of integers
extension IntListToIntegerExtension on List<int> {
  /// Prepare the presumed byte list to be converted to an integer.
  /// The endianness we should treat the byte list with can be changed using [endian].
  ///
  /// All values in the list are assumed to be valid bytes, so only the first byte worth
  /// of data for any given value is used. Negative values have the first byte of their
  /// two's compliment used as the value.
  ///
  /// For example:
  ///   256 (0x100) is truncated to 0x00
  ///   300 (0x12C) is truncated to 0x2C
  ///   -300 (0xED4) is truncated to 0xD4
  ByteListIntegerGenerator toInt([Endian endian = Endian.big]) {
    return ByteListIntegerGenerator._(this, endian);
  }
}
