import 'dart:typed_data';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
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

  // bigint handling
  // 32-bit unsigned BigInt: [0xFEDCBA98, 0x76543210]
  byteStream.asBigIntStream(4).take(2);
  // 32-bit signed BigInt: [BigInt(-19088744), BigInt(1985229328)]
  byteStream.asBigIntStream(4, signed: true).take(2);

  // double handling
  // 64-bit double precision: [-1.2313300687736946e+303]
  byteStream.asDoubleStream().take(1);
  // 32-bit single precision [-1.4669950460731436e+38, 1.0759592989650061e+33]
  byteStream.asDoubleStream(precision: Precision.float).take(2);

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

  // See the ByteStream example above for more API examples, it's the same
}
