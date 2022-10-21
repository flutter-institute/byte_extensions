import 'dart:typed_data';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  /** Integer Manipulation */

  // Transform an integer into various byte representations
  final integer = 0xFEDCBA9876543210; // Max bytes for 64-bit value

  // Big endian representation
  // 64-bit: [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
  integer.asBytes(type: IntType.int64);
  // 32-bit [0x76, 0x54, 0x32, 0x10]
  integer.asBytes(type: IntType.int32);
  // 16-bit [0x32, 0x10]
  integer.asBytes(type: IntType.int16);
  // 8-bit [0x10]
  integer.asBytes(type: IntType.int8);

  // Little endian representation
  // 64-bit: [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]
  integer.asBytes(endian: Endian.little, type: IntType.int64);
  // 32-bit: [0x10, 0x32, 0x54, 0x76]
  integer.asBytes(endian: Endian.little, type: IntType.int32);
  // 16-bit: [0x10, 0x32]
  integer.asBytes(endian: Endian.little, type: IntType.int16);
  // 8-bit: [0x10]
  integer.asBytes(endian: Endian.little, type: IntType.int8);

  /** Big Int Manipulation */

  // Transform a BigInt into various byte representations
  final bigint = BigInt.parse('FEDCBA9876543210FEDCBA9876543210', radix: 16);

  // Big endian representation
  // All bits: [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
  bigint.asBytes();
  // 32-bit: [0x76, 0x54, 0x32, 0x10]
  bigint.asBytes(maxBytes: 4);

  // Little endian representation
  // All bits: [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE, 0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]
  bigint.asBytes(endian: Endian.little);
  // 32-bit: [0x10, 0x32, 0x54, 0x76]
  bigint.asBytes(endian: Endian.little, maxBytes: 4);

  /** Double Manipulation (IEEE 754) */

  // Big endian
  final number = 85.125;
  // 64-bit double: [0x40, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00]
  number.asBytes(precision: Precision.double);
  // 32-bit float: [0x42, 0xAA, 0x40, 0x00]
  number.asBytes(precision: Precision.float);

  // Little endian
  // 64-bit double: [0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0x40]
  number.asBytes(endian: Endian.little, precision: Precision.double);
  // 32-bit double: [0x00, 0x40, 0xAA, 0x42]
  number.asBytes(endian: Endian.little, precision: Precision.float);
}
