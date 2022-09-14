import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_builder_x/stream_builder_x.dart';

void main() => runApp(const App());

class StreamState {
  final int number;
  final String text;

  const StreamState({required this.text, required this.number});

  StreamState copyWith({int? number, String? text}) {
    return StreamState(number: number ?? this.number, text: text ?? this.text);
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _streamController = StreamController<StreamState>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onSubmitted: (value) {
                _streamController.add(StreamState(number: 0, text: value));
              },
            ),
            StreamBuilderWidget(
              controller: _streamController,
            ),
            StreamSelectorWidget(
              controller: _streamController,
            ),
            StreamListenerWidget(
              controller: _streamController,
            ),
          ],
        ),
      ),
    );
  }
}

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
