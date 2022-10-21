import 'dart:typed_data';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  // see list_example.dart, number_example.dart, stream_example.dart, and string_example.dart
  // for more detailed examples of the API

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

  /** Stream<int> handling */
  final byteStream =
      Stream.fromIterable([0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]);

  // int handling
  // 32-bit unsigned int: [0xFEDCBA98, 0x76543210]
  byteStream.asIntStream(type: IntType.uint32).take(2);
  // 16-bit signed int: [-292, -17768, 30292, 12816]
  byteStream.asIntStream(type: IntType.int16).take(4);
  // little endian 16-bit signed int: [-8962, -26438, 21622, 4146]
  byteStream.asIntStream(type: IntType.int16, endian: Endian.little);

  /** Stream<List<int>> handling */
  final byteListStream = Stream.fromIterable([
    [0xFE, 0xDC, 0xBA],
    [0x98, 0x76],
    [0x54],
    [0x32, 0x10],
  ]);

  // int handling
  // 32-bit unsigned int: [0xFEDCBA98, 0x76543210]
  byteListStream.asIntStream(type: IntType.uint32).take(2);
  // 16-bit signed int: [-292, -17768, 30292, 12816]
  byteListStream.asIntStream(type: IntType.int16).take(4);
  // little endian 16-bit signed int: [-8962, -26438, 21622, 4146]
  byteListStream.asIntStream(type: IntType.int16, endian: Endian.little);
}
