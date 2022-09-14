import 'package:flutter/material.dart';
import 'type_def.dart';

/// Wrapper around [StreamBuilder] add the ability to selectively determine
/// whether to rebuild or not.
///
///```dart
///class StreamBuilderWidget extends StatelessWidget {
///   const StreamBuilderWidget({Key? key, required this.controller})
///       : super(key: key);
///   final StreamController<StreamState> controller;
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilderX<StreamState>(
///       stream: controller.stream,
///       asyncBuildWhen: (prev, curr) {
///         return curr.data?.number != curr.data?.number;
///       },
///       builder: (context, snapshot) {
///         debugPrint("built StreamBuilderWidget");
///         final state = snapshot.data;
///         return Text('${state?.text}/${state?.number}');
///       },
///     );
///   }
/// }
///```
class StreamBuilderX<T> extends StatefulWidget {
  const StreamBuilderX({
    Key? key,
    required this.builder,
    this.initialData,
    this.stream,
    this.asyncBuildWhen,
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

  /// Signature function of [StreamBuilderX], return true (or not specified)
  /// to rebuild when a new value is emitted by the [stream].
  final AsyncBuildWhen<T>? asyncBuildWhen;

  @override
  State<StreamBuilderX> createState() => _StreamBuilderXState();
}

class _StreamBuilderXState<T> extends State<StreamBuilderX<T>> {
  Widget? _cached;
  AsyncSnapshot<T>? _cachedSnapshot;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        initialData: widget.initialData,
        stream: widget.stream,
        builder: (context, snapshot) {
          if (_cached == null ||
              (widget.asyncBuildWhen?.call(_cachedSnapshot!, snapshot) ??
                  true)) {
            _cached = widget.builder(context, snapshot);
            _cachedSnapshot = snapshot;
          }
          return _cached!;
        });
  }
}
