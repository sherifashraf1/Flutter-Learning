import 'package:flutter/material.dart';
import '../../shared-enums/shared_enums.dart';

class DataState<T> {
  final ViewState state;
  final T? data;
  final String? title;
  final String? description;
  final LoadingType? loadingType;
  final VoidCallback? onRetry;

  DataState._({
    required this.state,
    this.data,
    this.title,
    this.description,
    this.loadingType,
    this.onRetry,
  });

  factory DataState.loading([LoadingType type = LoadingType.defaultLoading]) =>
      DataState._(state: ViewState.loading, loadingType: type);

  factory DataState.success(T data) =>
      DataState._(state: ViewState.success, data: data);

  factory DataState.empty({String? title, String? description}) => DataState._(
    state: ViewState.empty,
    title: title,
    description: description,
  );

  factory DataState.error({
    String? title,
    String? description,
    VoidCallback? onRetry,
  }) => DataState._(
    state: ViewState.error,
    title: title,
    description: description,
    onRetry: onRetry,
  );

  DataState<R> map<R>(R Function(T data) transform) {
    switch (state) {
      case ViewState.success:
        return DataState.success(transform(data as T));
      case ViewState.loading:
        return DataState.loading(loadingType ?? LoadingType.defaultLoading);
      case ViewState.empty:
        return DataState.empty(title: title, description: description);
      case ViewState.error:
        return DataState.error(
          title: title,
          description: description,
          onRetry: onRetry,
        );
    }
  }
}
