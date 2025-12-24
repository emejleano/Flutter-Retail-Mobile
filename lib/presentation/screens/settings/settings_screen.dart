import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/language_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final l = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(context, theme, authProvider, l),
        const SizedBox(height: 16),
        _buildSectionTitle(context, l.appearance),
        _buildAppearanceCard(context, themeProvider, l),
        const SizedBox(height: 16),
        _buildSectionTitle(context, l.language),
        _buildLanguageCard(context, languageProvider, l),
        const SizedBox(height: 16),
        _buildSectionTitle(context, l.account),
        _buildAccountCard(context, authProvider, l),
        const SizedBox(height: 16),
        _buildSectionTitle(context, l.about),
        _buildAboutCard(context, l),
        const SizedBox(height: 24),
        _buildLogoutCard(context, theme, l),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme, AuthProvider authProvider, AppLocalizations l) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 40, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.userName.isNotEmpty ? authProvider.userName : 'User',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: authProvider.isAdmin ? Colors.purple.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authProvider.isAdmin ? l.admin : l.customer,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: authProvider.isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context, ThemeProvider themeProvider, AppLocalizations l) {
    final isDark = themeProvider.isDarkMode;
    return Card(
      child: ListTile(
        leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
        title: Text(isDark ? l.darkMode : l.lightMode),
        subtitle: Text(l.toggleTheme),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => themeProvider.toggleTheme(),
        ),
        onTap: () => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, LanguageProvider languageProvider, AppLocalizations l) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.selectLanguage),
            subtitle: Text(languageProvider.languageName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, languageProvider, l),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context: context,
              languageProvider: languageProvider,
              language: AppLanguage.indonesian,
              title: 'Bahasa Indonesia',
              subtitle: 'Indonesian',
              flag: '🇮🇩',
              dialogContext: ctx,
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              context: context,
              languageProvider: languageProvider,
              language: AppLanguage.english,
              title: 'English',
              subtitle: 'English',
              flag: '🇺🇸',
              dialogContext: ctx,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required LanguageProvider languageProvider,
    required AppLanguage language,
    required String title,
    required String subtitle,
    required String flag,
    required BuildContext dialogContext,
  }) {
    final isSelected = languageProvider.currentLanguage == language;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        languageProvider.setLanguage(language);
        Navigator.pop(dialogContext);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AuthProvider authProvider, AppLocalizations l) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                authProvider.userName.isNotEmpty 
                    ? authProvider.userName[0].toUpperCase() 
                    : 'U',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            title: Text(authProvider.userName.isNotEmpty ? authProvider.userName : 'User'),
            subtitle: Text(authProvider.userEmail.isNotEmpty ? authProvider.userEmail : 'No email'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations l) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.appVersion),
            subtitle: Text(AppConstants.appVersion),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.about),
            subtitle: Text(l.appName),
            onTap: () => _showAboutDialog(context, l),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, ThemeData theme, AppLocalizations l) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.logout, color: theme.colorScheme.onErrorContainer),
        title: Text(l.logout, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
        subtitle: Text(
          l.signOutAccount,
          style: TextStyle(color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.7)),
        ),
        onTap: () => _handleLogout(context, l),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/logo.png',
          width: 64,
          height: 64,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.store, 
            size: 64, 
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      children: [
        Text(
          l.isIndonesian
              ? 'Super Store Sales - Aplikasi dashboard komprehensif untuk mengelola produk, pelanggan, penjualan, dan wilayah. '
                'Fitur termasuk grafik interaktif, pemindai barcode, dan kontrol akses berbasis peran.'
              : 'Super Store Sales - A comprehensive dashboard app for managing products, customers, sales, and regions. '
                'Features include interactive charts, barcode scanning, and role-based access control.',
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.logout),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }
}
