import 'dart:async';

import 'package:dartway_toolkit/dartway_toolkit.dart';
import 'package:dartway_toolkit/src/configs/dw_services_config.dart';
import 'package:dartway_toolkit/src/core/dw_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../configs/dw_toolkit_config.dart';

typedef DwAppInitializer = FutureOr<bool> Function(WidgetRef ref);

class DartWayApp {
  final String title;
  final ProviderBase<RouterConfig<Object>> routerProvider;

  final List<DwAppInitializer>? appInitializers;

  final DwRoutingConfig routingConfig;
  final DwLoadingConfig loadingConfig;
  final DwServicesConfig dwServicesConfig;
  final DwToolkitConfig dwToolkitConfig;
  final DwFlutterAppConfig flutterAppConfig;

  DartWayApp({
    this.title = 'Dart Way App',
    required this.routerProvider,
    this.appInitializers,

    this.routingConfig = const DwRoutingConfig(),
    this.dwToolkitConfig = const DwToolkitConfig(),
    this.dwServicesConfig = const DwServicesConfig(),
    this.loadingConfig = const DwLoadingConfig.withNativeSplash(),
    DwFlutterAppConfig? flutterAppConfig,
  }) : flutterAppConfig = flutterAppConfig ?? DwFlutterAppConfig();

  void _preInit() {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    if (loadingConfig.useNativeSplash) {
      FlutterNativeSplash.preserve(widgetsBinding: binding);
    }

    DwToolkit.init(dwToolkitConfig);
  }

  void run() {
    _preInit();

    final allInitializers = <DwAppInitializer>[
      (_) async {
        for (final locale in flutterAppConfig.supportedLocales) {
          await initializeDateFormatting(locale.languageCode);
        }
        return true;
      },
      (_) => DwServices.i.init(dwServicesConfig),
      ...?appInitializers,
      if (loadingConfig.useNativeSplash)
        (_) {
          FlutterNativeSplash.remove();
          return true;
        },
    ];

    runApp(
      ProviderScope(
        child: _DartWayAppWidget(
          title: title,
          routerProvider: routerProvider,
          initializers: allInitializers,
          loadingConfig: loadingConfig,
          flutterAppConfig: flutterAppConfig,
        ),
      ),
    );
  }
}

class _DartWayAppWidget extends ConsumerWidget {
  final String title;
  final ProviderBase<RouterConfig<Object>> routerProvider;
  final List<DwAppInitializer> initializers;

  final DwFlutterAppConfig flutterAppConfig;
  final DwLoadingConfig loadingConfig;

  const _DartWayAppWidget({
    required this.title,
    required this.routerProvider,
    required this.initializers,
    required this.flutterAppConfig,
    required this.loadingConfig,
  });

  Future<bool> _runInitializers(WidgetRef ref) async {
    for (final fn in initializers) {
      final result = await fn(ref);
      if (!result) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _runInitializers(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return loadingConfig.loadingScreen;
        if (snapshot.data != true) return loadingConfig.errorScreen;

        return MaterialApp.router(
          routerConfig: ref.watch(routerProvider),

          debugShowCheckedModeBanner:
              flutterAppConfig.debugShowCheckedModeBanner,
          title: title,
          theme: flutterAppConfig.theme,
          darkTheme: flutterAppConfig.darkTheme,
          themeMode: flutterAppConfig.themeMode,
          scrollBehavior: flutterAppConfig.scrollBehavior,
          restorationScopeId: flutterAppConfig.restorationScopeId,
          builder: flutterAppConfig.builder,
          supportedLocales: flutterAppConfig.supportedLocales,
          localizationsDelegates: flutterAppConfig.localizationDelegates,
          localeResolutionCallback: flutterAppConfig.localeResolutionCallback,
          localeListResolutionCallback:
              flutterAppConfig.localeListResolutionCallback,
        );
      },
    );
  }
}
