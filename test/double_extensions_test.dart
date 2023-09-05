import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('double extensions', () {
    // 00111110001000000000000000000000
    test('identity', () {
      var sut = pi;
      expect(sut.asBytes().asDouble(), sut);

      sut = 0.15625;
      expect(sut.asBytes().asDouble(), sut);
      expect(
          sut
              .asBytes(precision: Precision.float)
              .asDouble(precision: Precision.float),
          sut);
    });

    group('asBytes', () {
      test('converts 64-bit double', () {
        expect(
          0.15625.asBytes(endian: Endian.big, precision: Precision.double),
          [0x3F, 0xC4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
        expect(
          0.15625.asBytes(endian: Endian.little, precision: Precision.double),
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC4, 0x3F],
        );

        expect(
          85.125.asBytes(endian: Endian.big, precision: Precision.double),
          [0x40, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
        expect(
          85.125.asBytes(endian: Endian.little, precision: Precision.double),
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0x40],
        );

        expect(
          (-85.125).asBytes(endian: Endian.big, precision: Precision.double),
          [0xC0, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
        expect(
          (-85.125).asBytes(endian: Endian.little, precision: Precision.double),
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0xC0],
        );
      });

      test('64-bit double boundaries', () {
        // +/-infinity
        // 0b0111 1111 1111 00000000...
        expect(
          double.infinity
              .asBytes(endian: Endian.big, precision: Precision.double),
          [0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
        // 0b1111 1111 1111 00000000...
        expect(
          double.negativeInfinity
              .asBytes(endian: Endian.big, precision: Precision.double),
          [0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );

        // +/-0
        expect(
          0.0.asBytes(endian: Endian.big, precision: Precision.double),
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );
        expect(
          (-0.0).asBytes(endian: Endian.big, precision: Precision.double),
          [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        );

        // nan
        expect(
          double.nan.asBytes(endian: Endian.big, precision: Precision.double),
          anyOf(
            // Sign bit 1
            equals([0xFF, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
            // Sign bit 0
            equals([0x7F, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
          ),
        );

        // min/max
        expect(
          double.minPositive
              .asBytes(endian: Endian.big, precision: Precision.double),
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01],
        );
        expect(
          double.maxFinite
              .asBytes(endian: Endian.big, precision: Precision.double),
          [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
        );
      });

      test('converts 32-bit float', () {
        expect(
          0.15625.asBytes(endian: Endian.big, precision: Precision.float),
          [0x3E, 0x20, 0x00, 0x00],
        );
        expect(
          0.15625.asBytes(endian: Endian.little, precision: Precision.float),
          [0x00, 0x00, 0x20, 0x3E],
        );

        expect(
          85.125.asBytes(endian: Endian.big, precision: Precision.float),
          [0x42, 0xAA, 0x40, 0x00],
        );
        expect(
          85.125.asBytes(endian: Endian.little, precision: Precision.float),
          [0x00, 0x40, 0xAA, 0x42],
        );

        expect(
          (-85.125).asBytes(endian: Endian.big, precision: Precision.float),
          [0xC2, 0xAA, 0x40, 0x00],
        );
        expect(
          (-85.125).asBytes(endian: Endian.little, precision: Precision.float),
          [0x00, 0x40, 0xAA, 0xC2],
        );
      });

      test('32-bit float boundaries', () {
        // +/-infinity
        // 0b0111 1111 1000 00000...
        expect(
          double.infinity
              .asBytes(endian: Endian.big, precision: Precision.float),
          [0x7F, 0x80, 0x00, 0x00],
        );
        // 0b1111 1111 1000 00000...
        expect(
          double.negativeInfinity
              .asBytes(endian: Endian.big, precision: Precision.float),
          [0xFF, 0x80, 0x00, 0x00],
        );

        // +/-0
        expect(
          0.0.asBytes(endian: Endian.big, precision: Precision.float),
          [0x00, 0x00, 0x00, 0x00],
        );
        expect(
          (-0.0).asBytes(endian: Endian.big, precision: Precision.float),
          [0x80, 0x00, 0x00, 0x00],
        );

        // nan
        expect(
          double.nan.asBytes(endian: Endian.big, precision: Precision.float),
          anyOf(
            // Sign bit 1
            equals([0xFF, 0xC0, 0x00, 0x00]),
            // Sign bit 0
            equals([0x7F, 0xC0, 0x00, 0x00]),
          ),
        );

        // min/max
        expect(
          (1.4e-45).asBytes(endian: Endian.big, precision: Precision.float),
          [0x00, 0x00, 0x00, 0x01],
        );
        expect(
          (3.4028234e38)
              .asBytes(endian: Endian.big, precision: Precision.float),
          [0x7F, 0x7F, 0xFF, 0xFF],
        );
      });
    });
  });

  group('list<int> extensions', () {
    group('asDouble', () {
      test('converts 64-bit double', () {
        expect(
          [0x3F, 0xC4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          0.15625,
        );
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC4, 0x3F]
              .asDouble(endian: Endian.little, precision: Precision.double),
          0.15625,
        );

        expect(
          [0x40, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          85.125,
        );
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0x40]
              .asDouble(endian: Endian.little, precision: Precision.double),
          85.125,
        );

        expect(
          [0xC0, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          -85.125,
        );
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0xC0]
              .asDouble(endian: Endian.little, precision: Precision.double),
          -85.125,
        );
      });

      test('64-bit double boundaries', () {
        // +/-infinity
        // 0b0111 1111 1111 00000000...
        expect(
          [0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          double.infinity,
        );
        // 0b1111 1111 1111 00000000...
        expect(
          [0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          double.negativeInfinity,
        );

        // +/-0
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          0.0,
        );
        expect(
          [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          -0.0,
        );

        // nan
        expect(
          [0xFF, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.double),
          isNaN,
        );

        // min/max
        expect(
          [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]
              .asDouble(endian: Endian.big, precision: Precision.double),
          double.minPositive,
        );
        expect(
          [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
              .asDouble(endian: Endian.big, precision: Precision.double),
          double.maxFinite,
        );
      });

      test('64-bit errors', () {
        expect(() => <int>[].asDouble(), throwsArgumentError);
        expect(() => <int>[1, 2, 3, 4].asDouble(), throwsArgumentError);
        expect(() => <int>[1, 2, 3, 4, 5, 6, 7, 8, 9].asDouble(),
            throwsArgumentError);
      });

      test('converts 32-bit float', () {
        expect(
          [0x3E, 0x20, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          0.15625,
        );
        expect(
          [0x00, 0x00, 0x20, 0x3E]
              .asDouble(endian: Endian.little, precision: Precision.float),
          0.15625,
        );

        expect(
          [0x42, 0xAA, 0x40, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          85.125,
        );
        expect(
          [0x00, 0x40, 0xAA, 0x42]
              .asDouble(endian: Endian.little, precision: Precision.float),
          85.125,
        );

        expect(
          [0xC2, 0xAA, 0x40, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          -85.125,
        );
        expect(
          [0x00, 0x40, 0xAA, 0xC2]
              .asDouble(endian: Endian.little, precision: Precision.float),
          -85.125,
        );
      });

      test('32-bit float boundaries', () {
        // +/-infinity
        // 0b0111 1111 1000 00000...
        expect(
          [0x7F, 0x80, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          double.infinity,
        );
        // 0b1111 1111 1000 00000...
        expect(
          [0xFF, 0x80, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          double.negativeInfinity,
        );

        // +/-0
        expect(
          [0x00, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          0.0,
        );
        expect(
          [0x80, 0x00, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          -0.0,
        );

        // nan
        expect(
          [0xFF, 0xC0, 0x00, 0x00]
              .asDouble(endian: Endian.big, precision: Precision.float),
          isNaN,
        );

        // min/max
        expect(
          [0x00, 0x00, 0x00, 0x01]
              .asDouble(endian: Endian.big, precision: Precision.float),
          closeTo(1.4e-45, 1e-46),
        );
        expect(
          [0x7F, 0x7F, 0xFF, 0xFF]
              .asDouble(endian: Endian.big, precision: Precision.float),
          closeTo(3.4028234e38, 1e31),
        );
      });

      test('32-bit errors', () {
        expect(() => <int>[].asDouble(precision: Precision.float),
            throwsArgumentError);
        expect(() => <int>[1, 2].asDouble(precision: Precision.float),
            throwsArgumentError);
        expect(() => <int>[1, 2, 3, 4, 5].asDouble(precision: Precision.float),
            throwsArgumentError);
      });
    });
  });
}
