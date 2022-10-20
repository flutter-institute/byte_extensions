// ignore_for_file: prefer_inlined_adds

import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:byte_extensions/byte_extensions.dart';

void main() {
  group('stream<int> transformers', () {
    group('int transformer', () {
      test('valid 64-bit ints', () async {
        final base = Stream.fromIterable(<int>[]
          ..addAll([0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10])
          ..addAll([0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]));

        // Big Endian
        var sut = base.asIntStream(endian: Endian.big, type: IntType.int64);
        var results = await sut.take(2).toList();
        expect(results, [0xFEDCBA9876543210, 0x1032547698BADCFE]);

        // Little Endian
        sut = base.asIntStream(endian: Endian.little, type: IntType.int64);
        results = await sut.take(2).toList();
        expect(results, [0x1032547698BADCFE, 0xFEDCBA9876543210]);
      });

      test('valid 32-bit ints', () async {
        final base = Stream.fromIterable(<int>[]
          ..addAll([0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10])
          ..addAll([0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]));

        // Big Endian, signed
        var sut = base.asIntStream(endian: Endian.big, type: IntType.int32);
        var results = await sut.take(4).toList();
        expect(results, [-19088744, 1985229328, 271733878, -1732584194]);

        // Big Endian, unsigned
        sut = base.asIntStream(endian: Endian.big, type: IntType.uint32);
        results = await sut.take(4).toList();
        expect(results, [4275878552, 1985229328, 271733878, 2562383102]);

        // Little Endian, signed
        sut = base.asIntStream(endian: Endian.little, type: IntType.int32);
        results = await sut.take(4).toList();
        expect(results, [-1732584194, 271733878, 1985229328, -19088744]);

        // Little Endian, unsigned
        sut = base.asIntStream(endian: Endian.little, type: IntType.uint32);
        results = await sut.take(4).toList();
        expect(results, [2562383102, 271733878, 1985229328, 4275878552]);
      });

      test('valid 16-bit ints', () async {
        final base = Stream.fromIterable(<int>[]
          ..addAll([0xFE, 0xDC, 0xBA, 0x98])
          ..addAll([0x76, 0x54, 0x32, 0x10]));

        // Big Endian, signed
        var sut = base.asIntStream(endian: Endian.big, type: IntType.int16);
        var results = await sut.take(4).toList();
        expect(results, [-292, -17768, 30292, 12816]);

        // Big Endian, unsigned
        sut = base.asIntStream(endian: Endian.big, type: IntType.uint16);
        results = await sut.take(4).toList();
        expect(results, [65244, 47768, 30292, 12816]);

        // Little Endian, signed
        sut = base.asIntStream(endian: Endian.little, type: IntType.int16);
        results = await sut.take(4).toList();
        expect(results, [-8962, -26438, 21622, 4146]);

        // Little Endian, unsigned
        sut = base.asIntStream(endian: Endian.little, type: IntType.uint16);
        results = await sut.take(4).toList();
        expect(results, [56574, 39098, 21622, 4146]);
      });

      test('valid 8-bit ints', () async {
        final base = Stream.fromIterable([0x3FE, 0xDC, 0x32, 0x10]);

        // Big Endian, signed
        var sut = base.asIntStream(endian: Endian.big, type: IntType.int8);
        var results = await sut.take(4).toList();
        expect(results, [-1, -36, 50, 16]);

        // Big Endian, unsigned
        sut = base.asIntStream(endian: Endian.big, type: IntType.uint8);
        results = await sut.take(4).toList();
        expect(results, [255, 220, 50, 16]);

        // Little Endian, signed
        sut = base.asIntStream(endian: Endian.little, type: IntType.int8);
        results = await sut.take(4).toList();
        expect(results, [-1, -36, 50, 16]);

        // Little Endian, unsigned
        sut = base.asIntStream(endian: Endian.little, type: IntType.uint8);
        results = await sut.take(4).toList();
        expect(results, [255, 220, 50, 16]);
      });
    });

    group('double transformer', () {
      test('valid doubles', () async {
        // Big Endian
        var base = Stream.fromIterable(<int>[]
          ..addAll([0x40, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00])
          ..addAll([0x3F, 0xC4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
          ..addAll([0xC0, 0x55, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00]));

        var sut = base.asDoubleStream(
            endian: Endian.big, precision: Precision.double);
        var result = await sut.take(3).toList();
        expect(result, [85.125, 0.15625, -85.125]);

        // Little Endian
        base = Stream.fromIterable(<int>[]
          ..addAll([0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0x40])
          ..addAll([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC4, 0x3F])
          ..addAll([0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x55, 0xC0]));

        sut = base.asDoubleStream(
            endian: Endian.little, precision: Precision.double);
        result = await sut.take(3).toList();
        expect(result, [85.125, 0.15625, -85.125]);
      });

      test('valid floats', () async {
        // Big Endian
        var base = Stream.fromIterable(<int>[]
          ..addAll([0x42, 0xAA, 0x40, 0x00])
          ..addAll([0x3E, 0x20, 0x00, 0x00])
          ..addAll([0xC2, 0xAA, 0x40, 0x00]));

        var sut =
            base.asDoubleStream(endian: Endian.big, precision: Precision.float);
        var result = await sut.take(3).toList();
        expect(result, [85.125, 0.15625, -85.125]);

        // Little Endian
        base = Stream.fromIterable(<int>[]
          ..addAll([0x00, 0x40, 0xAA, 0x42])
          ..addAll([0x00, 0x00, 0x20, 0x3E])
          ..addAll([0x00, 0x40, 0xAA, 0xC2]));

        sut = base.asDoubleStream(
            endian: Endian.little, precision: Precision.float);
        result = await sut.take(3).toList();
        expect(result, [85.125, 0.15625, -85.125]);
      });
    });

    group('BigInt transformer', () {
      test('positive numbers', () async {
        final expected0 = BigInt.parse('FEDCBA9876543210000000', radix: 16);
        final expected1 = BigInt.parse('FEDCBA9876543210', radix: 16);

        // Big Endian
        var base = Stream.fromIterable(<int>[]
          ..addAll(
            [0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10, 0x00, 0x00, 0x00],
          )
          ..addAll(
            [0x00, 0x00, 0x00, 0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10],
          ));

        var sut = base.asBigIntStream(11, endian: Endian.big, signed: false);
        var result = await sut.take(2).toList();
        expect(result, [expected0, expected1]);

        // Little Endian
        base = Stream.fromIterable(<int>[]
          ..addAll(
            [0x00, 0x00, 0x00, 0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE],
          )
          ..addAll(
            [0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE, 0x00, 0x00, 0x00],
          ));

        sut = base.asBigIntStream(11, endian: Endian.little, signed: false);
        result = await sut.take(2).toList();
        expect(result, [expected0, expected1]);
      });

      test('negative numbers', () async {
        final expected0 = BigInt.from(-26506);
        final expected1 = BigInt.from(30292);

        // Big Endian
        var base = Stream.fromIterable(<int>[]
          ..addAll([0x98, 0x76])
          ..addAll([0x76, 0x54]));

        var sut = base.asBigIntStream(2, endian: Endian.big, signed: true);
        var result = await sut.take(2).toList();
        expect(result, [expected0, expected1]);

        // Little Endian
        base = Stream.fromIterable(<int>[]
          ..addAll([0x76, 0x98])
          ..addAll([0x54, 0x76]));

        sut = base.asBigIntStream(2, endian: Endian.little, signed: true);
        result = await sut.take(2).toList();
        expect(result, [expected0, expected1]);
      });
    });
  });
}
