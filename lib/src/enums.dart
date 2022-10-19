import 'dart:typed_data';

/// Enum to denote the type of double that we are working with
enum Precision {
  /// 32-bit single precision
  float,

  /// 64-bit double precision
  double,
}

/// Extension to add bytesPerElement to Precision
extension PrecisionBytesPerElement on Precision {
  /// The number of bytes the value's data uses
  int get bytesPerElement {
    switch (this) {
      case Precision.float:
        return Float32List.bytesPerElement;
      case Precision.double:
        return Float64List.bytesPerElement;
    }
  }
}

/// Enum to denote the type of integers that we are working with
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

/// Extension to add bytesPerElement to IntType
extension IntTypeBytesPerElement on IntType {
  /// The number of bytes the value's data uses
  int get bytesPerElement {
    switch (this) {
      case IntType.int64:
      case IntType.uint64:
        return Int64List.bytesPerElement;
      case IntType.int32:
      case IntType.uint32:
        return Int32List.bytesPerElement;
      case IntType.int16:
      case IntType.uint16:
        return Int16List.bytesPerElement;
      case IntType.int8:
      case IntType.uint8:
        return Int8List.bytesPerElement;
    }
  }
}
