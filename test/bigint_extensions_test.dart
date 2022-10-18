import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('BigInt extensions', () {
    test('identity', () {
      final sut = BigInt.parse('FEDCBA98', radix: 16);
      expect(sut.toBytes().toBigInt(), sut);
    });

    group('toBytes', () {
      test('64-bit integer', () {
        var sut = BigInt.from(0xFEDCBA9876543210);
        expect(sut.toBytes(endian: Endian.big),
            [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]);
        expect(sut.toBytes(endian: Endian.little),
            [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]);

        // Same as above number
        sut = BigInt.from(-81985529216486896);
        expect(sut.toBytes(endian: Endian.big),
            [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]);
        expect(sut.toBytes(endian: Endian.little),
            [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]);

        // Not the same as above, but same bytes
        // The hex representation of this ends up being a signed int because
        // of dart's native 64-bit int limit. The BigInt here, though, treats
        // this value as unsigned. So while the bytes are the same as both
        // instances above, comparing the two will return false
        sut = BigInt.parse('FEDCBA9876543210', radix: 16);
        expect(sut.toBytes(endian: Endian.big),
            [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]);
        expect(sut.toBytes(endian: Endian.little),
            [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]);
      });

      test('negative numbers', () {
        // 0x9876 -- -26506
        final sut = BigInt.from(-26506);
        expect(sut.toBytes(endian: Endian.big), [0x98, 0x76]);
      });

      test('extra large number', () {
        final sut = BigInt.parse('FEDCBA9876543210FEDCBA9876543210', radix: 16);
        expect(
          sut.toBytes(endian: Endian.big),
          [
            0xFE,
            0xDC,
            0xBA,
            0x98,
            0x76,
            0x54,
            0x32,
            0x10,
            0xFE,
            0xDC,
            0xBA,
            0x98,
            0x76,
            0x54,
            0x32,
            0x10,
          ],
        );
        expect(
          sut.toBytes(endian: Endian.little),
          [
            0x10,
            0x32,
            0x54,
            0x76,
            0x98,
            0xBA,
            0xDC,
            0xFE,
            0x10,
            0x32,
            0x54,
            0x76,
            0x98,
            0xBA,
            0xDC,
            0xFE,
          ],
        );
      });

      test('maxBytes', () {
        // Truncate
        var sut = BigInt.parse('FEDCBA9876543210FEDCBA9876543210', radix: 16);
        expect(sut.toBytes(endian: Endian.big, maxBytes: 4),
            [0x76, 0x54, 0x32, 0x10]);
        expect(sut.toBytes(endian: Endian.little, maxBytes: 4),
            [0x10, 0x32, 0x54, 0x76]);

        // Pad
        sut = BigInt.parse('76543210', radix: 16);
        expect(
          sut.toBytes(endian: Endian.big, maxBytes: 6),
          [0x00, 0x00, 0x76, 0x54, 0x32, 0x10],
        );
        expect(
          sut.toBytes(endian: Endian.little, maxBytes: 6),
          [0x10, 0x32, 0x54, 0x76, 0x00, 0x00],
        );
      });
    });
  });

  group('list<int> extensions', () {
    group('toBigInt', () {
      test('numbers', () {
        var expected = BigInt.parse('FEDCBA9876543210', radix: 16);
        expect(
            [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
                .toBigInt(endian: Endian.big),
            expected);
        expect(
            [0x00, 0x00, 0x00, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10]
                .toBigInt(endian: Endian.big),
            expected);
        expect(
            [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]
                .toBigInt(endian: Endian.little),
            expected);
        expect(
            [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE, 0x00, 0x00, 0x00]
                .toBigInt(endian: Endian.little),
            expected);
      });

      test('negative numbers', () {
        // 0x9876 -- -26506
        expect([0x98, 0x76].toBigInt(endian: Endian.big, signed: true),
            BigInt.from(-26506));
      });
    });
  });
}
