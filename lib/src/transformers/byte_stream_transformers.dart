part of 'stream_transformers.dart';

/// Base class to handle buffering and transforming Stream<int>
abstract class _ByteStreamTransformer<R>
    extends _BaseStreamTransformer<int, R> {
  _ByteStreamTransformer(super.endian, super.bytesPerElement,
      {required super.transformer,
      super.sync = false,
      super.cancelOnError = false});

  _ByteStreamTransformer.broadcast(super.endian, super.bytesPerElement,
      {required super.transformer,
      super.sync = false,
      super.cancelOnError = false})
      : super.broadcast();

  @override
  void onData(int data) {
    _buffer.add(data);
    if (_buffer.length == bytesPerElement) {
      _controller.add(_transformer(_buffer));
      _buffer.clear();
    }
  }
}

/// Transform a byte stream into an integer stream
class IntegerByteStreamTransformer extends _ByteStreamTransformer<int> {
  /// A class that transforms a stream of bytes into a stream of the
  /// integer equivalents for the bytes.
  /// This is useful if your stream contains ints that are less than 64 bits
  /// or you need to control the endianness of the bytes.
  IntegerByteStreamTransformer(Endian endian, this.type,
      {super.sync, super.cancelOnError})
      : super(endian, type.bytesPerElement,
            transformer: _intTransformer(endian, type));

  /// A class that transforms a stream of byte into a broadcast stream of the
  /// integer equivalents for the bytes.
  /// This is useful if your stream contains ints that are less than 64 bits
  /// or you need to control the endianness of the bytes.
  IntegerByteStreamTransformer.broadcast(Endian endian, this.type,
      {super.sync, super.cancelOnError})
      : super.broadcast(endian, type.bytesPerElement,
            transformer: _intTransformer(endian, type));

  final IntType type;
}

/// Transform a byte stream into a stream of doubles
class DoubleByteStreamTransformer extends _ByteStreamTransformer<double> {
  /// A class that transforms a stream of bytes into a stream of the
  /// IEEE 754 equivalents for the bytes.
  /// This is useful if your stream contains 32-bit floats or you need
  /// to control the endianness of the bytes.
  DoubleByteStreamTransformer(Endian endian, this.precision,
      {super.sync, super.cancelOnError})
      : super(endian, precision.bytesPerElement,
            transformer: _doubleTransformer(endian, precision));

  /// A class that transforms a stream of bytes into a broadcast stream
  /// of the IEEE 754 equivalents for the bytes.
  /// This is useful if your stream contains 32-bit floats or you need
  /// to control the endianness of the bytes.
  DoubleByteStreamTransformer.broadcast(Endian endian, this.precision,
      {super.sync, super.cancelOnError})
      : super.broadcast(endian, precision.bytesPerElement,
            transformer: _doubleTransformer(endian, precision));

  final Precision precision;
}

/// Transform a byte stream into a stream of BigInts
class BigIntByteStreamTransformer extends _ByteStreamTransformer<BigInt> {
  /// A class that transforms a stream of bytes into a stream of BigInts.
  /// Use [bytesPerElement] to control how many bytes per BigInt.
  BigIntByteStreamTransformer(super.endian, super.bytesPerElement,
      {bool signed = false, super.sync, super.cancelOnError})
      : super(transformer: _bigIntTransformer(endian, signed));

  /// A class that transforms a stream of bytes into a broadcast stream of BigInts.
  /// Use [bytesPerElement] to control how many bytes per BigInt.
  BigIntByteStreamTransformer.broadcast(super.endian, super.bytesPerElement,
      {bool signed = false, super.sync, super.cancelOnError})
      : super.broadcast(transformer: _bigIntTransformer(endian, signed));
}
