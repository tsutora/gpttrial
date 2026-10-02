# Vibe Check Money Manager

A modern, engaging money management app designed specifically for Gen Z (18-30). Built with Flutter and powered by AI wallet mood insights.

## 🎯 Features

### Core Features
- **Google Sign-In & Cloud Sync** - One-click authentication, automatic backup to Google account
- **AI Wallet Mood** - Real-time analysis of spending patterns with personality-driven messages
- **Transaction Tracking** - Quick entry with emoji categories and voice input support
- **Analytics Dashboard** - AI-powered insights, category breakdown, spending trends
- **Budget Management** - Set limits per category with visual progress tracking
- **Gen Z Aesthetic** - Casual language ("yo wadup", "we feasting"), gradients, emoji integration

### AI Wallet Mood System
The app analyzes your daily spending and assigns a personality:
- 🍽️ **we feasting** (90-100) - Balanced, healthy spending
- 💪 **saving arc** (75-89) - Controlled, goal-oriented
- 🎵 **vibing** (60-74) - Normal day, steady pace
- 🎉 **treat yourself energy** (40-59) - Higher spending, enjoying life
- ⚠️ **financial check needed** (20-39) - Spending above average
- 😰 **big oof** (0-19) - Urgent attention needed

## 🛠️ Tech Stack

- **Framework**: Flutter + Dart
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Cloud Storage)
- **Authentication**: Google Sign-In SDK
- **AI/ML**: TensorFlow Lite (on-device, privacy-first)
- **UI Design**: Material 3 + Custom Design System
- **Analytics**: Firebase Analytics (planned)

## 📁 Project Structure

```
lib/
├── config/
│   └── theme.dart                 # Design system & Material 3 theme
├── models/
│   ├── transaction_model.dart    # Transaction data model
│   └── user_model.dart           # User & WalletMood models
├── providers/
│   ├── auth_provider.dart        # Firebase Auth with Google Sign-In
│   ├── transactions_provider.dart # Transaction CRUD operations
│   └── wallet_mood_provider.dart  # AI mood calculation algorithm
├── screens/
│   ├── auth_screen.dart          # Sign-in with feature showcase
│   ├── home_screen.dart          # Main dashboard & summary
│   ├── add_transaction_screen.dart # Modal for quick transaction entry
│   └── analytics_screen.dart     # Spending insights & trends
├── widgets/                       # Reusable UI components
├── utils/                         # Utilities & helpers
└── main.dart                     # App entry point with Riverpod setup
```

## 🎨 Design System

### Colors
- **Primary**: Neon Pink `#FF006E`
- **Accent**: Cyan `#00D4FF`
- **Success**: Green `#00D400`
- **Warning**: Yellow `#FFD60A`

### Typography
- **Font**: Poppins (via Google Fonts)
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Spacing & Radius
- **Grid**: 8px base unit
- **Border Radius**: 12px default, 16px for cards, 24px for large elements

## 🚀 Getting Started

### Prerequisites
- Flutter 3.13+
- Dart 3.0+
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd vibe_check_money_manager
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in appropriate directories
   - Enable Firestore Database and Google Sign-In

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screens

### 1. Auth Screen
- Feature showcase cards
- One-click Google Sign-In
- Gen Z-friendly messaging

### 2. Home Screen
- AI Wallet Mood Card (today's vibe)
- Monthly summary (income vs expenses)
- Quick action buttons (spend/earn)
- Recent transaction list
- Floating action button for new transaction

### 3. Add Transaction Modal
- Transaction type selector (expense/income)
- Amount input with Rp prefix
- Transaction label/note
- Category selection with emoji
- Smooth form submission

### 4. Analytics Screen
- Period selector (week/month/year)
- Category breakdown with percentages
- Progress bars per category
- AI-generated spending insights
- Daily/trend analysis

## 🧠 AI Mood Algorithm

The mood score (0-100) is calculated using:

```dart
score = baseScore (50)
score += spendingVelocity  // Compare to weekly average (-40 to +0)
score += incomeBonus       // Income multiplier (+0 to +25)
score += balanceBonus      // If income >= spending (+15)
```

Each transaction triggers a mood recalculation, keeping insights fresh throughout the day.

## 🔒 Privacy & Security

- ✅ Google Sign-In for secure authentication
- ✅ Firestore security rules (user data isolation)
- ✅ On-device AI calculations (no data sent to external ML servers)
- ✅ Firebase Cloud Storage for encrypted backups
- ✅ Automatic sync with user's Google account

## 📊 Firestore Schema

```
users/{userId}/
├── transactions/{transactionId}/
│   ├── id: string
│   ├── amount: number
│   ├── label: string
│   ├── category: string
│   ├── categoryEmoji: string
│   ├── isIncome: boolean
│   ├── date: timestamp
│   ├── note: string (optional)
│   └── createdAt: timestamp
└── moods/{moodId}/
    ├── moodScore: number (0-100)
    ├── moodEmoji: string
    ├── moodMessage: string
    ├── calculatedAt: timestamp
    ├── dailySpending: number
    ├── dailyIncome: number
    └── budgetHealth: number
```

## 🚦 Development Roadmap

- [x] Project setup with Flutter & Riverpod
- [x] Firebase Auth integration
- [x] Home dashboard
- [x] Transaction tracking
- [x] Analytics screen
- [x] AI mood algorithm
- [ ] Budget planner & goal tracking
- [ ] Category management
- [ ] Transaction history with filtering
- [ ] Onboarding flow
- [ ] Animations & micro-interactions
- [ ] Push notifications
- [ ] Export functionality (CSV, PDF)
- [ ] Multi-currency support
- [ ] Testing suite
- [ ] App Store release

## 🐛 Known Issues & TODOs

- [ ] Firebase configuration file needed
- [ ] Poppins font files need to be added to assets
- [ ] Google logo image for sign-in button
- [ ] Implement voice input for quick transaction entry
- [ ] Add transaction edit/delete functionality
- [ ] Implement budget spending notifications
- [ ] Add savings goal tracking
- [ ] Implement friend/family sharing features

## 🤝 Contributing

Contributions welcome! Please follow the Flutter style guide and submit PRs for review.

## 📝 License

MIT License - feel free to use for personal or commercial projects.

---

**Built with ❤️ for Gen Z**
