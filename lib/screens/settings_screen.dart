import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- Mode sombre ----
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Mode sombre'),
                  subtitle: const Text('Activer le thème sombre'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: settings.isDarkMode,
                  activeColor: Colors.orange,
                  onChanged: (value) => settings.toggleDarkMode(value),
                ),
              ),

              const SizedBox(height: 16),

              // ---- Devise ----
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: const Text('Devise'),
                      subtitle: Text('Devise actuelle : ${settings.currency}'),
                    ),
                    ...SettingsProvider.availableCurrencies.map((c) {
                      return RadioListTile<String>(
                        title: Text(c),
                        value: c,
                        groupValue: settings.currency,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          if (value != null) settings.setCurrency(value);
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- À propos ----
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('À propos'),
                  subtitle: Text('Gestion Dépenses v1.0 — Sauvegarde locale SQLite'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}