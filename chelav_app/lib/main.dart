import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/report_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  await apiClient.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient: apiClient)..init()),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiClient: apiClient)),
        ChangeNotifierProvider(create: (_) => ReportProvider(apiClient: apiClient)),
        ChangeNotifierProxyProvider<ReportProvider, TransactionProvider>(
          create: (_) => TransactionProvider(apiClient: apiClient),
          update: (_, reportProv, txProv) {
            txProv!.updateReportProvider(reportProv);
            return txProv;
          },
        ),
      ],
      child: const CheLavApp(),
    ),
  );
}

class CheLavApp extends StatelessWidget {
  const CheLavApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final authProv = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'CheLav Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProv.themeMode,
      home: authProv.isLoading
          ? Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: themeProv.isDarkMode ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CL',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: themeProv.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(strokeWidth: 2),
                  ],
                ),
              ),
            )
          : (authProv.isAuthenticated ? const MainShell() : const AuthScreen()),
    );
  }
}
