import 'package:dartway_toolkit/src/core/dw_toolkit.dart';
import 'package:dartway_toolkit/src/ui_extensions/dw_async_value_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension DwAsyncValueListX<T> on AsyncValue<List<T>> {
  Widget dwBuildListAsync({
    required Widget Function(List<T> value) childBuilder,
    int loadingItemsCount = 3,
    T? loadingItem,
    Widget? loadingWidget,
    Widget errorWidget = const SizedBox.shrink(),
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
  }) {
    assert(
      loadingItem != null || DwToolkit.isDefaultModelsGetterSetUp,
      'Can not handle loading value for dwBuildListAsync'
      'Either loadingItem must be provided or DwToolkitConfig.defaultModelGetter must be set.',
    );

    final items = List.generate(
      loadingItemsCount,
      (_) =>
          loadingItem ??
          (null is T ? null as T : DwToolkit.getDefaultModel<T>()),
    );

    return dwBuildAsync(
      childBuilder: childBuilder,
      loadingValue: items,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
    );
  }
}
