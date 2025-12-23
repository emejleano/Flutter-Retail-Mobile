import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/language_provider.dart';
import 'complete_profile_screen.dart';
import '../home/home_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();

  @override
  void dispose() {
    _customerIdController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.customerLogin(
      _customerIdController.text.trim(),
      _customerNameController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Customer login always requires completing profile (set email + password)
        if (authProvider.mustChangePassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.isIndonesian ? 'Login Pelanggan' : 'Customer Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Theme & Language Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => languageProvider.toggleLanguage(),
                      icon: Text(
                        languageProvider.isIndonesian ? '🇮🇩' : '🇺🇸',
                        style: const TextStyle(fontSize: 20),
                      ),
                      label: Text(
                        languageProvider.isIndonesian ? 'ID' : 'EN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () => themeProvider.toggleTheme(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  l.isIndonesian 
                      ? 'Login dengan ID Pelanggan' 
                      : 'Login with Customer ID',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  l.isIndonesian 
                      ? 'Gunakan Customer ID dan nama Anda untuk login pertama kali' 
                      : 'Use your Customer ID and name to login for the first time',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Customer ID Field
                TextFormField(
                  controller: _customerIdController,
                  decoration: InputDecoration(
                    labelText: 'Customer ID',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    hintText: 'e.g. CG-12520',
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l.fieldRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Customer Name Field
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: l.isIndonesian ? 'Nama Pelanggan' : 'Customer Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'e.g. Claire Gute',
                  ),
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (_) => _handleLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l.fieldRequired;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.login),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l.isIndonesian ? 'Informasi' : 'Information',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.isIndonesian
                            ? 'Setelah login, Anda akan diminta untuk mengatur email dan password baru untuk akun Anda.'
                            : 'After login, you will be asked to set up an email and new password for your account.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
