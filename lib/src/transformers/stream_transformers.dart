library stream_transformers;

import 'dart:async';
import 'dart:typed_data';

import '../enums.dart';
import '../extensions/integer_extensions.dart';
import '../extensions/double_extensions.dart';
import '../extensions/bigint_extensions.dart';

part 'byte_stream_transformers.dart';
part 'byte_list_stream_transformer.dart';

typedef _Transformer<T> = T Function(List<int> buffer);

/// Create a transformer to convert a byte array to an int
_Transformer<int> _intTransformer(Endian endian, IntType type) =>
    (List<int> buffer) => buffer.asInt(endian: endian, type: type);

/// Create a transformer to convert a byte array to a double
_Transformer<double> _doubleTransformer(Endian endian, Precision precision) =>
    (List<int> buffer) => buffer.asDouble(endian: endian, precision: precision);

/// Create a transformer to convert a byte array to a BigInt
_Transformer<BigInt> _bigIntTransformer(Endian endian, bool signed) =>
    (List<int> buffer) => buffer.asBigInt(endian: endian, signed: signed);

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
