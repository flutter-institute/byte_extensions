part of 'stream_transformers.dart';

/// Base class to handle buffering and transforming Stream<List<int>>
abstract class _ByteListStreamTransformer<R>
    extends _BaseStreamTransformer<List<int>, R> {
  _ByteListStreamTransformer(super.endian, super.bytesPerElement,
      {required super.transformer,
      super.sync = false,
      super.cancelOnError = false});

  _ByteListStreamTransformer.broadcast(super.endian, super.bytesPerElement,
      {required super.transformer,
      super.sync = false,
      super.cancelOnError = false})
      : super.broadcast();

  @override
  void onData(List<int> data) {
    _buffer.addAll(data);
    while (_buffer.length >= bytesPerElement) {
      final bytes = _buffer.take(bytesPerElement).toList();
      _controller.add(_transformer(bytes));

      _buffer.removeRange(0, bytesPerElement);
    }
  }
}

/// Transform a stream of bytes lists into an integer stream
class IntegerByteListStreamTransformer extends _ByteListStreamTransformer<int> {
  /// A class that transforms a stream of byte lists into a stream of the
  /// integer equivalents for the bytes.
  /// This is useful if your stream contains ints that are less than 64 bits
  /// or you need to control the endianness of the bytes.
  IntegerByteListStreamTransformer(Endian endian, this.type,
      {super.sync, super.cancelOnError})
      : super(endian, type.bytesPerElement,
            transformer: _intTransformer(endian, type));

  /// A class that transforms a stream of byte lists into a broadcast stream
  /// of the integer equivalents for the bytes.
  /// This is useful if your stream contains ints that are less than 64 bits
  /// or you need to control the endianness of the bytes.
  IntegerByteListStreamTransformer.broadcast(Endian endian, this.type,
      {super.sync, super.cancelOnError})
      : super.broadcast(endian, type.bytesPerElement,
            transformer: _intTransformer(endian, type));

  final IntType type;
}

/// Transform a byte list stream into a stream of doubles
class DoubleByteListStreamTransformer
    extends _ByteListStreamTransformer<double> {
  /// A class that transforms a stream of byte lists into a stream of the
  /// IEEE 754 equivalents for the bytes.
  /// This is useful if your stream contains 32-bit floats or you need
  /// to control the endianness of the bytes.
  DoubleByteListStreamTransformer(Endian endian, this.precision,
      {super.sync, super.cancelOnError})
      : super(endian, precision.bytesPerElement,
            transformer: _doubleTransformer(endian, precision));

  /// A class that transforms a stream of byte lists into a broadcast stream
  /// of the IEEE 754 equivalents for the bytes.
  /// This is useful if your stream contains 32-bit floats or you need
  /// to control the endianness of the bytes.
  DoubleByteListStreamTransformer.broadcast(Endian endian, this.precision,
      {super.sync, super.cancelOnError})
      : super.broadcast(endian, precision.bytesPerElement,
            transformer: _doubleTransformer(endian, precision));

  final Precision precision;
}

/// Transform a byte list stream into a stream of BigInts
class BigIntByteListStreamTransformer
    extends _ByteListStreamTransformer<BigInt> {
  /// A class that transforms a stream of byte lists into a stream of BigInts.
  /// Use [bytesPerElement] to control how many bytes per BigInt.
  BigIntByteListStreamTransformer(super.endian, super.bytesPerElement,
      {bool signed = false, super.sync, super.cancelOnError})
      : super(transformer: _bigIntTransformer(endian, signed));

  /// A class that transforms a stream of byte lists into a broadcast stream of BigInts.
  /// Use [bytesPerElement] to control how many bytes per BigInt.
  BigIntByteListStreamTransformer.broadcast(super.endian, super.bytesPerElement,
      {bool signed = false, super.sync, super.cancelOnError})
      : super.broadcast(transformer: _bigIntTransformer(endian, signed));
}
