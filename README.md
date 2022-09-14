<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Simple wrapper around StreamBuilder for selectively rebuild, optimize rebuild operations of widgets.

## Usage

### StreamBuilderX

Wrapper around StreamBuilder add the ability to selectively determine
whether to rebuild or not.

```dart
class StreamBuilderWidget extends StatelessWidget {
  const StreamBuilderWidget({Key? key, required this.controller})
      : super(key: key);
  final StreamController<StreamState> controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilderX<StreamState>(
      stream: controller.stream,
      asyncBuildWhen: (prev, curr) {
        return curr.data?.number != curr.data?.number;
      },
      builder: (context, snapshot) {
        debugPrint("built StreamBuilderWidget");
        final state = snapshot.data;
        return Text('${state?.text}/${state?.number}');
      },
    );
  }
}
```

### StreamSelectorX

Wrapper around [StreamBuilder] add the ability to selectively determine
whether to rebuild or not.

```dart
class StreamSelectorWidget extends StatelessWidget {
  const StreamSelectorWidget({Key? key, required this.controller})
      : super(key: key);
  final StreamController<StreamState> controller;

  @override
  Widget build(BuildContext context) {
    return StreamSelectorX<StreamState, int?>(
      stream: controller.stream,
      asyncSelector: (snapshot) {
        return snapshot.data?.number;
      },
      builder: (context, snapshot) {
        debugPrint("built StreamSelectorWidget");
        return ElevatedButton(
            onPressed: () {
              if (snapshot.data == null) {
                controller.add(const StreamState(text: '', number: 0));
              } else {
                final data = snapshot.data!;
                controller.add(data.copyWith(number: data.number + 1));
              }
            },
            child: Text(snapshot.data?.number.toString() ?? 0.toString()));
      },
    );
  }
}
```

### StreamListenerX

Will run callbacks when a new value is emitted from the stream without
rebuilding child.

```dart
class StreamListenerWidget extends StatelessWidget {
  const StreamListenerWidget({Key? key, required this.controller})
      : super(key: key);
  final StreamController<StreamState> controller;

  @override
  Widget build(BuildContext context) {
    return StreamListenerX<StreamState>(
      stream: controller.stream,
      onData: (data) {
        debugPrint("onData");
      },
      child: const Text("This will not change"),
    );
  }
}
 ```

