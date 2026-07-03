# 💰 Gestion Dépenses

Application mobile Flutter de gestion de dépenses personnelles, avec suivi de budget, statistiques visuelles, dépenses récurrentes et export PDF. Toutes les données sont stockées localement via SQLite — aucune connexion internet requise.

## 📱 Fonctionnalités

- **Gestion complète des dépenses** : ajouter, modifier, supprimer, consulter
- **Recherche** et **filtrage par catégorie**
- **10 catégories prédéfinies** (Nourriture, Transport, Maison, Études, Internet, Factures, Loisirs, Santé, Vêtements, Autres)
- **Statistiques visuelles** : diagramme circulaire par catégorie, diagramme en barres sur 6 mois
- **Budget mensuel** avec barre de progression et alertes (80% et dépassement)
- **Dépenses récurrentes** (loyer, abonnements) générées automatiquement chaque mois
- **Export PDF** détaillé (mois en cours ou historique complet)
- **Mode sombre** et **choix de devise** (FCFA, €, $)
- **Onboarding** au premier lancement
- **Sauvegarde 100% locale** via SQLite — aucune donnée envoyée en ligne

## 🛠️ Stack technique

| Composant | Technologie |
|---|---|
| Framework | Flutter (Dart) |
| Base de données | SQLite (`sqflite`) |
| Gestion d'état | `provider` |
| Graphiques | `fl_chart` |
| Export PDF | `pdf` + `printing` |
| Préférences | `shared_preferences` |
| Dates | `intl` |

## 📂 Structure du projet

```
lib/
├── main.dart
├── models/              # Expense, RecurringExpense
├── database/            # DatabaseHelper (SQLite)
├── providers/           # ExpenseProvider, SettingsProvider, RecurringProvider
├── screens/              # Écrans (accueil, ajout, stats, paramètres, récurrentes, onboarding)
├── widgets/              # Composants réutilisables (cartes, chips, dialogues)
└── utils/                # Constantes, export PDF
```

## 🗄️ Base de données

**Table `expenses`**

| Champ | Type |
|---|---|
| id | INTEGER (PK) |
| description | TEXT |
| amount | REAL |
| category | TEXT |
| date | TEXT |

**Table `budgets`** — budget mensuel global ou par catégorie
**Table `recurring_expenses`** — dépenses générées automatiquement chaque mois

## 🚀 Installation

```bash
git clone https://github.com/ouattaraulrich/gestion-depenses-flutter.git
cd gestion-depenses-flutter
flutter pub get
flutter run
```

### Prérequis
- Flutter SDK installé ([guide officiel](https://docs.flutter.dev/get-started/install))
- Un émulateur Android/iOS ou un appareil physique connecté


## 📸 Captures d'écran

<p align="center">
  <img src="screenshots\Acceuil.jpeg" width="250">
   <img src="screenshots\Stat.jpeg" width="250">
  <img src="screenshots\Ajout.jpeg" width="250">
</p>


## 📄 Licence

Projet personnel made by Marvin à but éducatif et de démonstration.