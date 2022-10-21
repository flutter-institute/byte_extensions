import 'package:byte_extensions/byte_extensions.dart';

void main() {
  /** Signed Integer conversion */
  // use `endian: Endian.little` for little endian conversion

  // 64-bit: 0x00DCBA9876543210
  [0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10].asInt(type: IntType.int64);
  // 32-bit: 0x76543210
  [0x98, 0x76, 0x54, 0x32, 0x10].asInt(type: IntType.int32);
  // 16-bit: -26608 (0x9810)
  [0x98, 0x10].asInt(type: IntType.int16);
  // 8-bit: -104 (0x98)
  [0x98, 0x10, 0x76].asInt(type: IntType.int8);

  /** Unsigned Integer conversion */
  // use `endian: Endian.little` for little endian conversion

  // IntType: uint64, uint32, uint16, uint8
  // 16-bit: 38928 (0x9810)
  [0x98, 0x10].asInt(type: IntType.uint16);
  // 8-bit: 152 (0x98)
  [0x98, 0x10, 0x76].asInt(type: IntType.uint8);

  /** Unigned BigInt conversion */
  // use `endian: Endian.little` for little endian conversion

  // 64-bit: 18364758544493064720 (0xFEDCBA9876543210)
  [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10].asBigInt();
  // 32-bit: 4275878552 (0xFEDCBA98)
  [0xFE, 0xDC, 0xBA, 0x98].asBigInt();

  /** Signed BigInt conversion */
  // use `endian: Endian.little` for little endian conversion

  // 64-bit: -81985529216486896 (0xFEDCBA9876543210)
  [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10].asBigInt(signed: true);
  // 32-bit: -19088744 (0xFEDCBA98)
  [0xFE, 0xDC, 0xBA, 0x98].asBigInt(signed: true);

  /** Double conversion (IEEE 754) */
  // use `endian: Endian.little` for little endian conversion

  // 64-bit double precision: 0.15625
  [0x3F, 0xC4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00].asDouble();
  // 32-bit single precision: 85.125
  [0x42, 0xAA, 0x40, 0x00].asDouble(precision: Precision.float);
}
