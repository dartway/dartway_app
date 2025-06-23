import 'package:dartway_toolkit/src/core/dw_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

extension DwAsyncValueX<T> on AsyncValue<T> {
  Widget dwBuildAsync({
    required Widget Function(T value) childBuilder,
    Widget errorWidget = const SizedBox.shrink(),
    T? loadingValue,
    Widget? loadingWidget,

    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    // bool skipError = false,
  }) => when(
    skipLoadingOnReload: skipLoadingOnReload,
    skipLoadingOnRefresh: skipLoadingOnRefresh,
    // skipError: skipError,
    data: (data) => childBuilder(data),
    error: (error, stackTrace) {
      DwToolkit.handleError(error, stackTrace);
      return errorWidget;
    },
    loading: () {
      if (loadingWidget != null) return loadingWidget;

      if (loadingValue == null && !DwToolkit.isDefaultModelsGetterSetUp) {
        return const SizedBox.shrink();
      }
      return Skeletonizer(
        child: childBuilder(
          loadingValue ??
              (null is T ? null as T : DwToolkit.getDefaultModel<T>()),
        ),
      );
    },
  );
}
