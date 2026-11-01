# METACLIENT

Application mobile Flutter pour le suivi client en temps réel, basée sur une interface **Glassmorphisme** haut de gamme et l'architecture éprouvée de **`meta_fleet`**.

---

## 🎨 Design & Charte Graphique

- **Style Visuel** : Glassmorphisme (surfaces dépolies `BackdropFilter`, bordures subtiles, orbes lumineux d'ambiance).
- **Couleur Primaire** : `#2193b0` (Teal Gradient / Lueur)
- **Couleur des Icônes Primaires** : `#22b7ce` (Cyan Luminous)
- **Accents & Dégradés** : `#2193b0` vers `#6dd5ed`

---

## 🚀 Fonctionnalités & Modules

1. **Authentification & Session**
   - Connexion sécurisée avec token personnalisé (`'token': <token>` dans les en-têtes HTTP).
   - Configuration dynamique de l'URL du serveur (port par défaut `1599`).
   - Persistance locale via `SharedPreferences`.

2. **Tableau de Bord (Dashboard)**
   - Bannière d'accueil client personnalisée.
   - 4 Cartes KPI animées (Expéditions en cours, Total expéditions, Factures en instances, Solde total dû).
   - Outil de recherche et de tracking rapide par N° de Déclaration.
   - Raccourcis vers les opérations urgentes et récentes.

3. **Mes Expéditions**
   - Onglet **En cours** et onglet **Historique complet**.
   - Filtres par dates (`du`, `au`), N° Déclaration et statut de livraison (`Tous`, `Livré`, `Non livré`).
   - Vue détaillée avec timeline interactive (étapes d'acheminement) et visualiseur GED pour les documents attachés.

4. **Factures & Règlements**
   - Suivi des **Factures en instance** (impayées) et de l'historique complet.
   - Détail de chaque facture : montant TTC, solde restant, acomptes, avoirs et chèques rattachés.

5. **Retours de Fonds**
   - Suivi physique des retours de **Chèques & Traites** (CC/CT).
   - Suivi des retours de **BL et Factures** physiques émargés.

6. **CRBT (Contre-Remboursement)**
   - Vue unifiée des expéditions sous mandat de remboursement.
   - Suivi des **Chèques CRBT** remis avec détail des déclarations soldées.
   - Suivi des **Virements bancaires et mandats** avec bordereau détaillé.

7. **Profil & Configuration**
   - Visualisation de la fiche client (ICE, Téléphone, Adresse, Ville).
   - Paramétrage de l'adresse du serveur d'API.
   - Déconnexion sécurisée.

---

## 🏗️ Architecture Technique

- **Framework** : Flutter 3.38+ / Dart 3.10+
- **State Management** : [GetX](https://pub.dev/packages/get) (Controllers permanents et réactifs, navigation nommée)
- **Networking** : Client HTTP personnalisé (`ApiService`) avec gestion d'exceptions et logging
- **Icons** : [Lucide Icons](https://pub.dev/packages/lucide_icons) & [Cupertino Icons](https://pub.dev/packages/cupertino_icons)
- **Typographie** : [Google Fonts](https://pub.dev/packages/google_fonts) (Inter)

---

## 📦 Installation & Démarrage

```bash
# Récupérer les dépendances
flutter pub get

# Lancer l'analyse du code
flutter analyze

# Lancer la suite de tests
flutter test

# Exécuter l'application sur émulateur ou appareil
flutter run
```

---

## 📄 Licence
Ce projet est sous licence MIT.
