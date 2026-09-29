# Pocket Quest

**Pocket Quest** adalah contoh aplikasi *money manager* berbasis **Flutter (Dart)**. Satu codebase dapat digunakan untuk **Android dan iOS**, dengan metode *digital envelope budgeting* dan elemen gamifikasi.

## Fitur demo

- Dashboard saldo, penggunaan anggaran, level, XP, dan streak.
- Amplop digital untuk Makan, Transportasi, Hiburan, dan Tabungan.
- Pencatatan pengeluaran yang mengurangi saldo amplop terpilih.
- Quest harian/mingguan dan tampilan profil.
- Navigasi bawah yang adaptif untuk Android maupun iOS.

## Menjalankan di Android dan iOS

1. Instal [Flutter SDK](https://docs.flutter.dev/get-started/install) lalu jalankan `flutter doctor`.
2. Dari folder root proyek, jalankan `flutter create --platforms=android,ios .` **sekali** untuk menghasilkan folder native Android dan iOS. Perintah tersebut tidak menimpa `lib/main.dart` atau `pubspec.yaml`.
3. Jalankan `flutter pub get`.
4. Jalankan aplikasi dengan `flutter run`, atau buka folder proyek dalam Android Studio / VS Code dan pilih emulator Android atau iOS Simulator.

Kode aplikasi berada di `lib/main.dart`. UI menggunakan Material 3 bawaan Flutter dan tidak membutuhkan paket pihak ketiga.
