import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  String? _testResult;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final client = context.read<ApiClient>();
    _urlController = TextEditingController(text: client.baseUrl);
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final client = context.read<ApiClient>();
    await client.setBaseUrl(_urlController.text.trim());

    try {
      final res = await client.get('/health');
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testResult = res['status'] == 'healthy'
              ? 'Connected successfully to backend!'
              : 'Server responded: ${res.toString()}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testResult = 'Connection failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Account Profile Section
          Text(
            'ACCOUNT & MULTI-DEVICE SYNC',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141414) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      authProv.user?.name ?? 'Guest Account',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: authProv.isDemoMode
                            ? (isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7))
                            : AppColors.semanticGreenSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        authProv.isDemoMode ? 'Demo Mode' : 'Cloud Synced',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: authProv.isDemoMode
                              ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                              : AppColors.semanticGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  authProv.user?.email ?? 'Not logged in',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Currency', style: TextStyle(fontSize: 13)),
                    const Text(
                      'Indian Rupee (₹)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          Text(
            'APPEARANCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141414) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      'Minimal Black & White aesthetic',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: themeProv.isDarkMode,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF3F3F46),
                  onChanged: (_) => themeProv.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Backend API Server Section
          Text(
            'BACKEND SERVER CONFIGURATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141414) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Base URL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: 'http://localhost:5001/api or https://chelav.vercel.app/api',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isTesting ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      child: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test Connection'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        final defaultUrl = ApiClient.defaultBaseUrl;
                        _urlController.text = defaultUrl;
                        context.read<ApiClient>().setBaseUrl(defaultUrl);
                      },
                      child: const Text('Reset to Default'),
                    ),
                  ],
                ),
                if (_testResult != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _testResult!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _testResult!.contains('success')
                          ? AppColors.semanticGreen
                          : AppColors.semanticRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout / Switch Account Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authProv.logout();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out / Switch Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.semanticRed,
                side: const BorderSide(color: AppColors.semanticRedSubtle),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
