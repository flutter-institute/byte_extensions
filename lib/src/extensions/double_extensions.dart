import 'dart:typed_data';

import '../enums.dart';

/// Extension to add `asBytes` handling to double
extension DoubleToBytesExtension on double {
  Uint8ClampedList asBytes({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
  }) {
    final byteData = ByteData(precision.bytesPerElement);
    switch (precision) {
      case Precision.float:
        byteData.setFloat32(0, this, endian);
        break;
      case Precision.double:
        byteData.setFloat64(0, this, endian);
        break;
    }

    return byteData.buffer.asUint8ClampedList();
  }
}

/// Extension to add our `asInt` handling to List<int>
extension ListIntToDoubleExtension on List<int> {
  /// Convert a list of bytes to an integer.
  /// The endianness we should treat the byte list with can be changed using [endian].
  ///
  /// All values in the list are assumed to be valid bytes. Any values greater than 0xFF
  /// become 0xFF and any values less than 0 become 0.
  double asDouble({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
  }) {
    // Convert our backing list to ByteData
    final byteData = Uint8ClampedList.fromList(this).buffer.asByteData();

    switch (precision) {
      case Precision.float:
        if (length != 4) {
          throw ArgumentError(
              'Invalid Argument: List must be exactly 4 bytes long');
        }
        return byteData.getFloat32(0, endian);
      case Precision.double:
        if (length != 8) {
          throw ArgumentError(
              'Invalid Argument: List must be exactly 8 bytes long');
        }
        return byteData.getFloat64(0, endian);
    }
  }
}
