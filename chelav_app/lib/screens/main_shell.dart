import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'categories/categories_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'reports/category_report_screen.dart';
import 'reports/daily_report_screen.dart';
import 'reports/monthly_report_screen.dart';
import 'settings/settings_screen.dart';
import 'transactions/transactions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DailyReportScreen(),
    CategoryReportScreen(),
    MonthlyReportScreen(),
    TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                'CL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Chelavu',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProv.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () => themeProv.toggleTheme(),
            tooltip: 'Toggle Dark/Light Mode',
          ),
          IconButton(
            icon: const Icon(Icons.sell_outlined, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
            tooltip: 'Categories',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          selectedItemColor: isDark ? Colors.white : Colors.black,
          unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Daily',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Monthly',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
