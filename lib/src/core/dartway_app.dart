import 'dart:async';

import 'package:dartway_toolkit/dartway_toolkit.dart';
import 'package:dartway_toolkit/src/core/dw_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    routingConfig.init();
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

class _DartWayAppWidget extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<_DartWayAppWidget> createState() => _DartWayAppWidgetState();
}

class _DartWayAppWidgetState extends ConsumerState<_DartWayAppWidget> {
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _runInitializers();
  }

  Future<void> _runInitializers() async {
    try {
      for (final fn in widget.initializers) {
        final ok = await fn(ref);
        if (!ok) throw Exception('initializer failed');
      }
      setState(() => _initialized = true);
    } catch (e, s) {
      DwToolkit.handleError(e, s);
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.loadingConfig.errorScreen;
    if (!_initialized) return widget.loadingConfig.loadingScreen;

    final router = ref.watch(widget.routerProvider);

    return MaterialApp.router(
      routerConfig: router,

      debugShowCheckedModeBanner:
          widget.flutterAppConfig.debugShowCheckedModeBanner,
      title: widget.title,
      theme: widget.flutterAppConfig.theme,
      darkTheme: widget.flutterAppConfig.darkTheme,
      themeMode: widget.flutterAppConfig.themeMode,
      scrollBehavior: widget.flutterAppConfig.scrollBehavior,
      restorationScopeId: widget.flutterAppConfig.restorationScopeId,
      builder: widget.flutterAppConfig.builder,
      supportedLocales: widget.flutterAppConfig.supportedLocales,
      localizationsDelegates: widget.flutterAppConfig.localizationDelegates,
      localeResolutionCallback:
          widget.flutterAppConfig.localeResolutionCallback,
      localeListResolutionCallback:
          widget.flutterAppConfig.localeListResolutionCallback,
    );
  }
}
