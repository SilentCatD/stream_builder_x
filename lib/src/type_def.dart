import 'package:flutter/material.dart';

typedef AsyncBuildWhen<T> = bool Function(
    AsyncSnapshot<T> prev, AsyncSnapshot<T> curr);
typedef AsyncSelector<T, K> = K Function(AsyncSnapshot<T> snapshot);
