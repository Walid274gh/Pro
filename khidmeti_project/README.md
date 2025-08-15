# Khidmeti Project

Un écosystème complet de services à domicile avec deux applications Flutter : **khidmeti_users** (clients) et **khidmeti_workers** (prestataires).

## 🏗️ Architecture

### Structure Monorepo
```
khidmeti_project/
├── khidmeti_users/          # Application clients
├── khidmeti_workers/        # Application prestataires
└── shared_assets/           # Assets partagés
    ├── animations/          # Animations Lottie
    ├── avatars/            # Avatars SVG
    └── fonts/              # Polices Paytone One & Inter
```

### Design System Paytone One
- **Palette de couleurs** : Jaune (#FCDC73), Rouge (#FF6B6B), Bleu foncé (#2C3E50), Turquoise (#1ABC9C)
- **Typographie** : Paytone One (titres), Inter (corps de texte)
- **Composants** : Cartes arrondies (20px), boutons bulles, headers personnalisés
- **Animations** : Lottie pour les transitions et micro-interactions

## 🚀 Fonctionnalités

### Application Clients (khidmeti_users)

#### 🔐 Authentification & Profil
- Inscription/Connexion Firebase Auth
- Gestion des profils utilisateurs
- Sélection d'avatars SVG personnalisés
- Upload de photos de profil

#### 📍 Services & Localisation
- Recherche de services par catégorie
- Géolocalisation en temps réel
- Cartes OpenStreetMap avec Flutter Map
- Calcul d'itinéraires avec OpenRouteService
- Rayon de recherche configurable

#### 💬 Communication
- Chat en temps réel avec les prestataires
- Notifications push Firebase
- Historique des conversations
- Appels vocaux (placeholder)

#### 💳 Paiements
- Intégration BaridiMob
- Paiements par carte bancaire
- Paiement en espèces
- Historique des transactions

#### 📊 Analytics & Paramètres
- Tableau de bord analytique
- Statistiques d'utilisation
- Paramètres de notifications
- Préférences de localisation
- Mode sombre (placeholder)

### Application Prestataires (khidmeti_workers)

#### 🏢 Gestion Professionnelle
- Tableau de bord avec revenus en temps réel
- Suivi des performances
- Gestion des disponibilités
- Système de vérification d'identité

#### 💰 Finances & Facturation
- Suivi des gains (total, mensuel, hebdomadaire)
- Création de factures
- Génération de devis
- Historique des paiements

#### 📈 Analytics Avancées
- Métriques de performance
- Taux de complétion
- Temps de réponse moyen
- Répartition des services
- Taux d'annulation

#### 🛠️ Outils Professionnels
- Gestion de portfolio
- Planning de disponibilité
- Demandes de congés
- Rapports détaillés

## 🔧 Technologies

### Frontend
- **Flutter** 3.3.0+
- **Provider** pour la gestion d'état
- **Google Fonts** pour la typographie
- **Flutter SVG** pour les avatars
- **Lottie** pour les animations

### Backend & Services
- **Firebase Auth** pour l'authentification
- **Cloud Firestore** pour la base de données
- **Firebase Storage** pour les médias
- **Firebase Messaging** pour les notifications
- **OpenStreetMap** pour les cartes
- **OpenRouteService** pour les itinéraires

### Géolocalisation
- **Geolocator** pour la localisation
- **Geocoding** pour la géocodification inverse
- **Flutter Map** pour l'affichage des cartes
- **LatLong2** pour les coordonnées

### Utilitaires
- **Shared Preferences** pour les paramètres
- **HTTP** pour les API externes
- **Image Picker** pour la sélection de photos
- **Dart:io** pour la gestion des fichiers

## 📱 Écrans Principaux

### Application Clients
1. **Splash Screen** - Animation de démarrage
2. **Auth Screen** - Connexion/Inscription
3. **Home Screen** - Tableau de bord principal
4. **Search Screen** - Recherche de services
5. **Map Screen** - Carte interactive
6. **Requests Screen** - Historique des demandes
7. **Chat Screen** - Messagerie en temps réel
8. **Profile Screen** - Gestion du profil
9. **Analytics Screen** - Statistiques personnelles
10. **Settings Screen** - Paramètres utilisateur

### Application Prestataires
1. **Splash Screen** - Animation de démarrage
2. **Auth Screen** - Connexion/Inscription
3. **Dashboard Screen** - Tableau de bord professionnel
4. **Map Screen** - Gestion des interventions
5. **Requests Screen** - Demandes de services
6. **Performance Screen** - Analytics détaillées
7. **Profile Screen** - Profil professionnel

## 🏛️ Architecture SOLID

### Principes Appliqués
- **Single Responsibility** : Chaque service a une responsabilité unique
- **Open/Closed** : Services extensibles sans modification
- **Liskov Substitution** : Interfaces abstraites avec implémentations concrètes
- **Interface Segregation** : Interfaces spécialisées par domaine
- **Dependency Inversion** : Dépendances injectées via constructeurs

### Services Principaux
```dart
// Authentification
abstract class AuthenticationService
class AuthService implements AuthenticationService

// Base de données
abstract class DatabaseService
class FirestoreDatabaseService implements DatabaseService

// Localisation
abstract class LocationService
class OpenStreetMapLocationService implements LocationService

// Notifications
abstract class NotificationSender
class FCMNotificationService implements NotificationSender
```

## 🎨 Design System

### Couleurs
```dart
const Color kPrimaryYellow = Color(0xFFFCDC73);
const Color kPrimaryRed = Color(0xFFFF6B6B);
const Color kPrimaryDark = Color(0xFF2C3E50);
const Color kPrimaryTeal = Color(0xFF1ABC9C);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kSurfaceColor = Color(0xFFFFFFFF);
```

### Typographie
```dart
const TextStyle kHeadingStyle = TextStyle(
  fontFamily: 'Paytone One',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kPrimaryDark,
);

const TextStyle kBodyStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextColor,
);
```

### Composants
- **ModernHeader** : Header personnalisé sans AppBar
- **ModernCard** : Cartes avec ombres et coins arrondis
- **BubbleButton** : Boutons avec effet 3D
- **ProfessionalDashboardCard** : Cartes pour le tableau de bord

## 🔐 Sécurité

### Authentification
- Firebase Auth avec email/mot de passe
- Gestion des tokens FCM
- Validation des données côté client

### Base de Données
- Règles Firestore sécurisées
- Validation des données
- Indexation optimisée

### Paiements
- Simulation sécurisée des paiements
- Validation des transactions
- Historique des paiements

## 📊 Analytics & Performance

### Métriques Utilisateurs
- Nombre de demandes créées
- Services les plus utilisés
- Taux de complétion
- Montant total dépensé

### Métriques Prestataires
- Revenus totaux et périodiques
- Taux de complétion des jobs
- Temps de réponse moyen
- Répartition des services

## 🚀 Déploiement

### Prérequis
- Flutter SDK 3.3.0+
- Firebase project configuré
- Clés API OpenRouteService
- Assets (fonts, animations, avatars)

### Configuration Firebase
1. Créer un projet Firebase
2. Configurer Authentication
3. Configurer Firestore
4. Configurer Storage
5. Configurer Messaging
6. Ajouter les clés API dans `DefaultFirebaseOptions`

### Build & Deploy
```bash
# Application Clients
cd khidmeti_users
flutter build apk --release
flutter build ios --release

# Application Prestataires
cd khidmeti_workers
flutter build apk --release
flutter build ios --release
```

## 📈 Roadmap

### Phase 1 (Actuelle)
- ✅ Authentification complète
- ✅ Interface utilisateur Paytone One
- ✅ Géolocalisation et cartes
- ✅ Chat en temps réel
- ✅ Système de paiements
- ✅ Analytics de base

### Phase 2 (Futur)
- 🔄 Mode sombre
- 🔄 Notifications locales
- 🔄 Appels vocaux
- 🔄 Évaluations et avis
- 🔄 Système de fidélité
- 🔄 Intégration IA pour le matching

### Phase 3 (Avancé)
- 🔄 Marketplace de services
- 🔄 Système de sous-traitance
- 🔄 API publique
- 🔄 Intégration IoT
- 🔄 Réalité augmentée
- 🔄 Blockchain pour les paiements

## 🤝 Contribution

Ce projet suit les standards Flutter et utilise l'architecture SOLID. Pour contribuer :

1. Fork le projet
2. Créer une branche feature
3. Suivre les conventions de code
4. Tester les fonctionnalités
5. Soumettre une pull request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

**Khidmeti** - Connecter les talents aux besoins, un service à la fois. 🛠️✨
