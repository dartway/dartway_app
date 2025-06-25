import 'dart:async';

import 'package:dartway_app/dartway_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../notifications/domain/dw_ui_notification.dart';
import '../notifications/ui/dw_notifications_listener.dart';
import '../notifications/ui/dw_ui_notification_handler.dart';

typedef DwAppInitializer = FutureOr<bool> Function(WidgetRef ref);

class DwApp {
  final String title;
  final ProviderBase<RouterConfig<Object>> routerProvider;

  final List<DwAppInitializer>? appInitializers;

  final DwConfig dwConfig;

  final DwAppLoadingOptions appLoadingOptions;
  final DwFlutterAppOptions flutterAppOptions;
  final DwRoutingConfig routingOptions;

  DwApp({
    this.title = 'Dart Way App',
    required this.routerProvider,
    this.appInitializers,

    this.routingOptions = const DwRoutingConfig(),
    this.dwConfig = const DwConfig(),
    this.appLoadingOptions = const DwAppLoadingOptions.withNativeSplash(),
    DwFlutterAppOptions? flutterAppOptions,
  }) : flutterAppOptions = flutterAppOptions ?? DwFlutterAppOptions();

  void _preInit() {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    if (appLoadingOptions.useNativeSplash) {
      FlutterNativeSplash.preserve(widgetsBinding: binding);
    }

    routingOptions.init();
  }

  void run() {
    _preInit();

    final allInitializers = <DwAppInitializer>[
      (_) async {
        for (final locale in flutterAppOptions.supportedLocales) {
          await initializeDateFormatting(locale.languageCode);
        }
        return true;
      },
      (_) => dw.init(dwConfig),
      ...?appInitializers,
      if (appLoadingOptions.useNativeSplash)
        (_) {
          FlutterNativeSplash.remove();
          return true;
        },
    ];

    runApp(
      ProviderScope(
        child: _DartWayApp(
          title: title,
          routerProvider: routerProvider,
          appInitializers: allInitializers,
          appLoadingOptions: appLoadingOptions,
          flutterAppOptions: flutterAppOptions,
        ),
      ),
    );
  }
}

class _DartWayApp extends ConsumerStatefulWidget {
  final String title;
  final ProviderBase<RouterConfig<Object>> routerProvider;
  final List<DwAppInitializer> appInitializers;

  final DwFlutterAppOptions flutterAppOptions;
  final DwAppLoadingOptions appLoadingOptions;

  const _DartWayApp({
    required this.title,
    required this.routerProvider,
    required this.appInitializers,
    required this.flutterAppOptions,
    required this.appLoadingOptions,
  });

  @override
  ConsumerState<_DartWayApp> createState() => _DartWayAppWidgetState();
}

class _DartWayAppWidgetState extends ConsumerState<_DartWayApp> {
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _runInitializers();
  }

  Future<void> _runInitializers() async {
    try {
      for (final fn in widget.appInitializers) {
        final ok = await fn(ref);
        if (!ok) throw Exception('initializer failed');
      }
      setState(() => _initialized = true);
    } catch (e, s) {
      dw.handleError(e, s);
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.appLoadingOptions.errorScreen;
    if (!_initialized) return widget.appLoadingOptions.loadingScreen;

    final router = ref.watch(widget.routerProvider);

    return DwNotificationsListener(
      handlers: {
        DwUiNotification: DwUiNotificationHandler(),
        // другие типы можно добавлять сюда
      },
      child: MaterialApp.router(
        // scaffoldMessengerKey: DwNotificationsListener.messengerKey,
        routerConfig: router,

        debugShowCheckedModeBanner:
            widget.flutterAppOptions.debugShowCheckedModeBanner,
        title: widget.title,
        theme: widget.flutterAppOptions.theme,
        darkTheme: widget.flutterAppOptions.darkTheme,
        themeMode: widget.flutterAppOptions.themeMode,
        scrollBehavior: widget.flutterAppOptions.scrollBehavior,
        restorationScopeId: widget.flutterAppOptions.restorationScopeId,
        builder: widget.flutterAppOptions.builder,
        supportedLocales: widget.flutterAppOptions.supportedLocales,
        localizationsDelegates: widget.flutterAppOptions.localizationDelegates,
        localeResolutionCallback:
            widget.flutterAppOptions.localeResolutionCallback,
        localeListResolutionCallback:
            widget.flutterAppOptions.localeListResolutionCallback,
      ),
    );
  }
}
