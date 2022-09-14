import 'dart:async';

import 'package:flutter/material.dart';

/// Will run callbacks when a new value is emitted from the stream without
/// rebuilding child.
///
/// ```dart
/// class StreamListenerWidget extends StatelessWidget {
///   const StreamListenerWidget({Key? key, required this.controller})
///       : super(key: key);
///   final StreamController<StreamState> controller;
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamListenerX<StreamState>(
///       stream: controller.stream,
///       onData: (data) {
///         debugPrint("onData");
///       },
///       child: const Text("This will not change"),
///     );
///   }
/// }
/// ```
class StreamListenerX<T> extends StatefulWidget {
  const StreamListenerX({
    Key? key,
    required this.child,
    required this.stream,
    this.onData,
    this.cancelOnError,
    this.onDone,
    this.onError,
  }) : super(key: key);

  /// On each data event from this [stream], the subscriber's [onData] handler
  /// is called. If [onData] is `null`, nothing happens.
  final void Function(T event)? onData;

  /// On errors from this [stream], the [onError] handler is called with the
  /// error object and possibly a stack trace.
  /// The [onError] callback must be of type `void Function(Object error)` or
  /// `void Function(Object error, StackTrace)`.
  /// The function type determines whether [onError] is invoked with a stack
  /// trace argument.
  /// The stack trace argument may be [StackTrace.empty] if this [stream] received
  /// an error without a stack trace.
  /// Otherwise it is called with just the error object.
  /// If [onError] is omitted, any errors on this [stream] are considered unhandled,
  /// and will be passed to the current [Zone]'s error handler.
  /// By default unhandled async errors are treated
  /// as if they were uncaught top-level errors.
  final Function? onError;

  /// If this [stream] closes and sends a done event, the [onDone] handler is
  /// called. If [onDone] is `null`, nothing happens.
  final void Function()? onDone;

  /// If [cancelOnError] is `true`, the subscription is automatically canceled
  /// when the first error event is delivered. The default is `false`.
  final bool? cancelOnError;

  /// Widget to be wrapped by this [StreamListenerX], will not be rebuilt when
  /// new value is emitted from the [stream].
  final Widget child;

  /// Input stream of this widget, callback will be called accordingly when
  /// this stream emit values.
  final Stream<T> stream;

  @override
  State<StreamListenerX<T>> createState() => _StreamListenerXState<T>();
}

class _StreamListenerXState<T> extends State<StreamListenerX<T>> {
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _sub(widget.stream);
  }

  @override
  void dispose() {
    _unSub();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StreamListenerX<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream ||
        widget.cancelOnError != oldWidget.cancelOnError) {
      if (_subscription != null) {
        _unSub();
      }
      _sub(widget.stream);
    }
  }

  void _sub(Stream<T> stream) {
    _subscription = stream.listen(
      widget.onData,
      onError: widget.onError,
      onDone: widget.onDone,
      cancelOnError: widget.cancelOnError,
    );
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
