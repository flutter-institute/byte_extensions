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

/// Enum to denote the size of integers that we are working with
enum IntType {
  /// A 64-bit signed integer
  int64,

  /// A 64-bit unsigned integer
  uint64,

  /// A 32-bit signed integer
  int32,

  /// A 32-bit unsigned integer
  uint32,

  /// A 16-bit signed integer
  int16,

  /// A 16-bit unsigned integer
  uint16,

  /// An 8-bit signed integer
  int8,

  /// An 8-bit unsigned integer
  uint8,
}

extension IntegerToBytesExtensions on int {
  /// Convert this integer to a fixed-length byte list
  /// To control the endianness of the resulting list, use the [endian] parameter
  ///
  /// The [type] parameter can be used to limit how many bytes of data are returned.
  /// If [type] is not [IntType.int64] or [IntType.uint64] then the bytes of the number
  /// will be truncated from the most significant bits, just as if integer overflow has
  /// happened. This can have some unexpected results if you aren't careful.
  ///
  /// For example:
  ///   0x109876 which positive when converted to int16 becomes -26608 because the value
  ///     is truncated to 0x9876 before conversion and the sign bit is now 1
  Uint8ClampedList toBytes({
    Endian endian = Endian.big,
    IntType type = IntType.int64,
  }) {
    /// Helper function to convert our ByteData to a Uint8List
    Uint8ClampedList clamp(ByteData bytes) => bytes.buffer.asUint8ClampedList();

    switch (type) {
      case IntType.int64:
        return clamp(ByteData(_int64Size)..setInt64(0, this, endian));
      case IntType.uint64:
        return clamp(ByteData(_int64Size)..setUint64(0, this, endian));
      case IntType.int32:
        return clamp(ByteData(_int32Size)..setInt32(0, this, endian));
      case IntType.uint32:
        return clamp(ByteData(_int32Size)..setUint32(0, this, endian));
      case IntType.int16:
        return clamp(ByteData(_int16Size)..setInt16(0, this, endian));
      case IntType.uint16:
        return clamp(ByteData(_int16Size)..setUint16(0, this, endian));
      case IntType.int8:
        return clamp(ByteData(_int8Size)..setInt8(0, this));
      case IntType.uint8:
        return clamp(ByteData(_int8Size)..setUint8(0, this));
    }
  }
}

extension IntListToIntegerExtension on List<int> {
  /// Convert the presumed-to-be-byte list to an integer.
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
  int toInt({Endian endian = Endian.big, IntType type = IntType.int64}) {
    /// Converts our backing list to ByteData while ensuring that we are
    /// handling the correct number of bytes.
    ByteData toByteData(int bytesPerElement) {
      final bytes =
          Uint8List.fromList(endianFixedLength(this, bytesPerElement, endian));
      return bytes.buffer.asByteData();
    }

    switch (type) {
      case IntType.int64:
        return toByteData(_int64Size).getInt64(0, endian);
      case IntType.uint64:
        return toByteData(_int64Size).getUint64(0, endian);
      case IntType.int32:
        return toByteData(_int32Size).getInt32(0, endian);
      case IntType.uint32:
        return toByteData(_int32Size).getUint32(0, endian);
      case IntType.int16:
        return toByteData(_int16Size).getInt16(0, endian);
      case IntType.uint16:
        return toByteData(_int16Size).getUint16(0, endian);
      case IntType.int8:
        return toByteData(_int8Size).getInt8(0);
      case IntType.uint8:
        return toByteData(_int8Size).getUint8(0);
    }
  }
}
