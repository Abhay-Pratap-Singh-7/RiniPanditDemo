import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/pandit/pandit_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const RiniPanditApp(),
    ),
  );
}

class RiniPanditApp extends StatelessWidget {
  const RiniPanditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rini Pandit Astro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isPandit) {
      return const PanditDashboardScreen();
    }

    return const HomeScreen();
  }
}
