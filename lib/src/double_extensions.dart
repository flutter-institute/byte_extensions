import 'dart:typed_data';

/// Number of bytes for a 32-bit float
const _floatSize = Float32List.bytesPerElement;

/// Number of bytes for a 64-bit double
const _doubleSize = Float64List.bytesPerElement;

/// Enum to denote the type of double that we are working with
enum Precision {
  /// 32-bit single precision
  float,

  /// 64-bit double precision
  double,
}

/// Extension to add `asBytes` handling to double
extension DoubleToBytesExtension on double {
  Uint8ClampedList asBytes({
    Endian endian = Endian.big,
    Precision precision = Precision.double,
  }) {
    /// Helper function to convert our ByteData to a Uint8List
    Uint8ClampedList clamp(ByteData bytes) {
      return bytes.buffer.asUint8ClampedList();
    }

    switch (precision) {
      case Precision.float:
        return clamp(ByteData(_floatSize)..setFloat32(0, this, endian));
      case Precision.double:
        return clamp(ByteData(_doubleSize)..setFloat64(0, this, endian));
    }
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
    /// Converts our backing list to ByteData
    ByteData toBytesData() =>
        Uint8ClampedList.fromList(this).buffer.asByteData();

    switch (precision) {
      case Precision.float:
        if (length != 4) {
          throw ArgumentError(
              'Invalid Argument: List must be exactly 4 bytes long');
        }
        return toBytesData().getFloat32(0, endian);
      case Precision.double:
        if (length != 8) {
          throw ArgumentError(
              'Invalid Argument: List must be exactly 8 bytes long');
        }
        return toBytesData().getFloat64(0, endian);
    }
  }
}
