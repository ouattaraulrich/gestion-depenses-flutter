import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/expense_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/recurring_provider.dart';
import 'screens/startup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..loadExpenses()..loadBudgets()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => RecurringProvider()..loadRecurring()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Gestion Dépenses',
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              primarySwatch: Colors.orange,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF7F7F9),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.orange,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              brightness: Brightness.dark,
              cardColor: const Color(0xFF1E1E1E),
            ),
            home: const StartupScreen(),
          );
        },
      ),
    );
  }
}