import 'dart:typed_data';

import 'package:byte_extensions/src/helpers.dart';

import 'enums.dart';

/// Extension to add `asBytes` handling to int
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
  Uint8ClampedList asBytes({
    Endian endian = Endian.big,
    IntType type = IntType.int64,
  }) {
    final byteData = ByteData(type.bytesPerElement);
    switch (type) {
      case IntType.int64:
        byteData.setInt64(0, this, endian);
        break;
      case IntType.uint64:
        byteData.setUint64(0, this, endian);
        break;
      case IntType.int32:
        byteData.setInt32(0, this, endian);
        break;
      case IntType.uint32:
        byteData.setUint32(0, this, endian);
        break;
      case IntType.int16:
        byteData.setInt16(0, this, endian);
        break;
      case IntType.uint16:
        byteData.setUint16(0, this, endian);
        break;
      case IntType.int8:
        byteData.setInt8(0, this);
        break;
      case IntType.uint8:
        byteData.setUint8(0, this);
        break;
    }

    return byteData.buffer.asUint8ClampedList();
  }
}

/// Extension to add our `asInt` handling to List<int>
extension IntListToIntegerExtension on List<int> {
  /// Convert a list of bytes to an integer.
  /// The endianness we should treat the byte list with can be changed using [endian].
  ///
  /// All values in the list are assumed to be valid bytes. Any values greater than 0xFF
  /// become 0xFF and any values less than 0 become 0.
  int asInt({Endian endian = Endian.big, IntType type = IntType.int64}) {
    // Convert our backing list to ByteData while ensuring that we are
    // handling the correct number of bytes.
    final bytes = Uint8ClampedList.fromList(
        endianFixedLength(this, type.bytesPerElement, endian));
    final byteData = bytes.buffer.asByteData();

    switch (type) {
      case IntType.int64:
        return byteData.getInt64(0, endian);
      case IntType.uint64:
        return byteData.getUint64(0, endian);
      case IntType.int32:
        return byteData.getInt32(0, endian);
      case IntType.uint32:
        return byteData.getUint32(0, endian);
      case IntType.int16:
        return byteData.getInt16(0, endian);
      case IntType.uint16:
        return byteData.getUint16(0, endian);
      case IntType.int8:
        return byteData.getInt8(0);
      case IntType.uint8:
        return byteData.getUint8(0);
    }
  }
}
