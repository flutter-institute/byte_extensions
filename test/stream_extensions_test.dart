import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('Stream extensions', () {
    group('readInt', () {
      test('valid ints', () async {
        final sut = Stream.fromIterable(
            [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]);

        var result = await sut.readInt(endian: Endian.big, type: IntType.int64);
        expect(result, 0xFEDCBA9876543210);

        result = await sut.readInt(endian: Endian.big, type: IntType.uint32);
        expect(result, 0xFEDCBA98);

        result = await sut.readInt(endian: Endian.big, type: IntType.int32);
        expect(result, 0xFEDCBA98.toSigned(32));

        result = await sut.readInt(endian: Endian.little, type: IntType.uint32);
        expect(result, 0x98BADCFE);
      });
    });

    group('readBigInt', () {
      test('valid big ints', () async {
        final sut = Stream.fromIterable(
            [0xFF, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]);

        var result = await sut.readBigInt(9, endian: Endian.big, signed: false);
        expect(result, BigInt.parse('FFFEDCBA9876543210', radix: 16));

        result = await sut.readBigInt(2, endian: Endian.big, signed: false);
        expect(result, BigInt.from(0xFFFE));

        result = await sut.readBigInt(2, endian: Endian.big, signed: true);
        expect(result, BigInt.from(0xFFFE.toSigned(16)));

        result = await sut.readBigInt(4, endian: Endian.little, signed: false);
        expect(result, BigInt.from(0xBADCFEFF));
      });
    });

    group('readDouble', () {
      test('valid double', () async {
        final sut = Stream.fromIterable(
            [0x40, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00]);
        final result = await sut.readDouble(
            endian: Endian.big, precision: Precision.double);
        expect(result, 85.125);
      });

      test('valid float', () async {
        final sut = Stream.fromIterable([0x42, 0xAA, 0x40, 0x00]);
        final result = await sut.readDouble(
            endian: Endian.big, precision: Precision.float);
        expect(result, 85.125);
      });
    });
  });
}
