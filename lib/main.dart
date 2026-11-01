import 'package:erp_system/feature/users/presentation/widgets/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/routes_manager/route_generator.dart';
import 'core/routes_manager/routes.dart';
import 'core/theme/base_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Builder(
        builder: (context) {
          final BaseTheme lightTheme = LightTheme();
          final BaseTheme darkTheme = DarkTheme();
          final themeProvider = context.watch<ThemeProvider>();

          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return ValueListenableBuilder<Locale>(
                valueListenable: AppSettings.locale,
                builder: (_, locale, __) {
                  return MaterialApp(
                    theme: lightTheme.themeData,
                    darkTheme: darkTheme.themeData,
                    themeMode: themeProvider.themeMode,
                    locale: locale,
                    supportedLocales: const [Locale('ar'), Locale('en')],
                    localizationsDelegates:  [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    debugShowCheckedModeBanner: false,
                    onGenerateRoute: RouteGenerator.getRoute,
                    initialRoute: Routes.loginScreen,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}