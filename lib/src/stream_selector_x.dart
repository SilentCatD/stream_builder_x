import 'package:flutter/material.dart';
import 'type_def.dart';

/// Wrapper around [StreamBuilder] add the ability to selectively determine
/// whether to rebuild or not.
///
/// ```dart
/// class StreamSelectorWidget extends StatelessWidget {
///   const StreamSelectorWidget({Key? key, required this.controller})
///       : super(key: key);
///   final StreamController<StreamState> controller;
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamSelectorX<StreamState, int?>(
///       stream: controller.stream,
///       asyncSelector: (snapshot) {
///         return snapshot.data?.number;
///       },
///       builder: (context, snapshot) {
///         debugPrint("built StreamSelectorWidget");
///         return ElevatedButton(
///             onPressed: () {
///               if (snapshot.data == null) {
///                 controller.add(const StreamState(text: '', number: 0));
///               } else {
///                 final data = snapshot.data!;
///                 controller.add(data.copyWith(number: data.number + 1));
///               }
///             },
///             child: Text(snapshot.data?.number.toString() ?? 0.toString()));
///       },
///     );
///   }
/// }
/// ```
class StreamSelectorX<T, K> extends StatefulWidget {
  const StreamSelectorX({
    Key? key,
    required this.builder,
    this.initialData,
    this.stream,
    this.asyncSelector,
  }) : super(key: key);

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<T> builder;

  /// The data that will be used to create the initial snapshot.
  ///
  /// Providing this value (presumably obtained synchronously somehow when the
  /// [Stream] was created) ensures that the first frame will show useful data.
  /// Otherwise, the first frame will be built with the value null, regardless
  /// of whether a value is available on the stream: since streams are
  /// asynchronous, no events from the stream can be obtained before the initial
  /// build.
  final T? initialData;

  /// The asynchronous computation to which this builder is currently connected,
  /// possibly null. When changed, the current summary is updated using
  /// [afterDisconnected], if the previous stream was not null, followed by
  /// [afterConnected], if the new stream is not null.
  final Stream<T>? stream;

  /// Signature function of [StreamSelectorX], return the selected property of
  /// a snapshot. If this value is changed between builds, [builder] function
  /// will be called.
  final AsyncSelector<T, K>? asyncSelector;

  @override
  State<StreamSelectorX<T, K>> createState() => _StreamSelectorXState<T, K>();
}

class _StreamSelectorXState<T, K> extends State<StreamSelectorX<T, K>> {
  Widget? _cached;
  K? _cachedValue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: widget.initialData,
      stream: widget.stream,
      builder: (context, snapshot) {
        final newValue = widget.asyncSelector?.call(snapshot);
        if (_cached == null || (newValue != _cachedValue)) {
          _cached = widget.builder(context, snapshot);
          _cachedValue = newValue;
        }
        return _cached!;
      },
    );
  }
}
