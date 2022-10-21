import 'dart:async';
import 'dart:typed_data';

import 'enums.dart';
import 'integer_extensions.dart';
import 'double_extensions.dart';
import 'bigint_extensions.dart';

typedef _Transformer<T> = T Function(List<int> buffer);

/// Base class to handle our our stream interactions before data manipulation
abstract class _BaseStreamTransformer<T, R> implements StreamTransformer<T, R> {
  /// Initialize a regular stream transformer
  _BaseStreamTransformer(this.endian, this.bytesPerElement,
      {required _Transformer<R> transformer,
      bool sync = false,
      this.cancelOnError = false})
      : _transformer = transformer {
    _controller = StreamController<R>(
      sync: sync,
      onListen: _onListen,
      onCancel: _onCancel,
      onPause: _onPause,
      onResume: _onResume,
    );
  }

  /// Initialize a broadcast stream transformer
  _BaseStreamTransformer.broadcast(this.endian, this.bytesPerElement,
      {required _Transformer<R> transformer,
      bool sync = false,
      this.cancelOnError = false})
      : _transformer = transformer {
    _controller = StreamController<R>.broadcast(
      sync: sync,
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  final List<int> _buffer = [];
  final Endian endian;
  final int bytesPerElement;
  final bool cancelOnError;

  final _Transformer<R> _transformer;
  late final StreamController<R> _controller;

  Stream<T>? _stream;
  StreamSubscription<T>? _subscription;

  /** Stream Internals */

  /// Handle stream subscription
  void _onListen() {
    if (_subscription != null) {
      _onCancel();
    }

    _subscription = _stream?.listen(
      onData,
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: cancelOnError,
    );
  }

  /// Cancel subscription
  void _onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Pause subscription for non-broadcast streams
  void _onPause() {
    _subscription?.pause();
  }

  /// Resume subscription for non-broadcast streams
  void _onResume() {
    _subscription?.resume();
  }

  /** Transformation */

  /// Receive new data from the parent stream
  ///
  /// Buffer the data until we have enough to emit and int,
  /// then parse and emit said int
  void onData(T data);

  @override
  Stream<R> bind(Stream<T> stream) {
    _buffer.clear();
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw UnsupportedError('Cannot cast this stream');
  }
}

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

/// Create a transformer to convert a byte array to an int
_Transformer<int> _intTransformer(Endian endian, IntType type) =>
    (List<int> buffer) => buffer.asInt(endian: endian, type: type);

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

/// Create a transformer to convert a byte array to a double
_Transformer<double> _doubleTransformer(Endian endian, Precision precision) =>
    (List<int> buffer) => buffer.asDouble(endian: endian, precision: precision);

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

/// Create a transformer to convert a byte array to a BigInt
_Transformer<BigInt> _bigIntTransformer(Endian endian, bool signed) =>
    (List<int> buffer) => buffer.asBigInt(endian: endian, signed: signed);

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
