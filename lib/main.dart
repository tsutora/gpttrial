import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const PocketQuestApp());

// A high-contrast, pastel palette: indigo is the action color, while pink,
// mint, and butter yellow give the budgeting experience a friendly character.
const _primary = Color(0xFF6C63E9);
const _pink = Color(0xFFFF6FAE);
const _mint = Color(0xFF42BFA0);
const _butter = Color(0xFFFFD66B);
const _canvas = Color(0xFFFFF8FC);
const _ink = Color(0xFF302E4A);

class Envelope {
  Envelope({
    required this.name,
    required this.emoji,
    required this.budget,
    required this.spent,
    required this.color,
  });

  final String name;
  final String emoji;
  final int budget;
  int spent;
  final Color color;

  int get remaining => budget - spent;
  double get usage => spent / budget;
}

class PocketQuestApp extends StatelessWidget {
  const PocketQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          primary: _primary,
          secondary: _pink,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme().apply(bodyColor: _ink, displayColor: _ink),
        cardTheme: const CardThemeData(
          elevation: 1,
          shadowColor: Color(0x1A6C63E9),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFBFD),
          labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE8E1F1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE8E1F1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _primary, width: 2)),
        ),
      ),
      home: const PocketQuestHome(),
    );
  }
}

class PocketQuestHome extends StatefulWidget {
  const PocketQuestHome({super.key});

  @override
  State<PocketQuestHome> createState() => _PocketQuestHomeState();
}

class _PocketQuestHomeState extends State<PocketQuestHome> {
  int _selectedTab = 0;
  final _envelopes = <Envelope>[
    Envelope(name: 'Makan', emoji: '🍜', budget: 700000, spent: 450000, color: const Color(0xFFFFD98C)),
    Envelope(name: 'Transportasi', emoji: '🚌', budget: 300000, spent: 120000, color: const Color(0xFFBCE8E0)),
    Envelope(name: 'Hiburan', emoji: '🎮', budget: 500000, spent: 450000, color: const Color(0xFFD6C8FF)),
    Envelope(name: 'Tabungan', emoji: '🏦', budget: 1000000, spent: 200000, color: const Color(0xFFAEDBFF)),
  ];

  void _openTransactionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TransactionSheet(
        envelopes: _envelopes,
        onSave: (envelope, amount) {
          setState(() => envelope.spent += amount);
          Navigator.pop(context);
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Transaksi tersimpan! +10 XP')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(envelopes: _envelopes),
      EnvelopesPage(envelopes: _envelopes),
      const QuestsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedTab]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTransactionSheet,
        backgroundColor: _pink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE5E2FF),
        selectedIndex: _selectedTab,
        onDestinationSelected: (value) => setState(() => _selectedTab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Amplop'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Quest'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.envelopes, super.key});

  final List<Envelope> envelopes;

  @override
  Widget build(BuildContext context) {
    final used = envelopes.fold<int>(0, (sum, item) => sum + item.spent);
    final total = envelopes.fold<int>(0, (sum, item) => sum + item.budget);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        Row(children: [
          Expanded(child: Text('Halo, Andi! ✨', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const _CuteBadge(),
        ]),
        const SizedBox(height: 2),
        Text('Level 8 • Budget Explorer', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 18),
        const XpCard(),
        const SizedBox(height: 16),
        BalanceCard(available: total - used, used: used, total: total),
        const SizedBox(height: 24),
        const SectionTitle('Amplop Saya'),
        const SizedBox(height: 10),
        ...envelopes.take(3).map((envelope) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EnvelopeCard(envelope: envelope),
            )),
        const SizedBox(height: 14),
        const SectionTitle('Misi Hari Ini'),
        const SizedBox(height: 10),
        const QuestCard(title: 'Catat satu transaksi hari ini', reward: '10 XP', progress: 1, done: true),
        const SizedBox(height: 10),
        const QuestCard(title: 'Tidak belanja kopi hari ini', reward: '30 XP', progress: .45),
      ],
    );
  }
}

class XpCard extends StatelessWidget {
  const XpCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
        color: _primary,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('🔥 Streak 7 Hari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Level 8', style: TextStyle(color: Colors.white)),
            ]),
            const SizedBox(height: 10),
            const LinearProgressIndicator(value: .76, minHeight: 9, color: _butter, backgroundColor: Color(0x406C63E9), borderRadius: BorderRadius.all(Radius.circular(8))),
            const SizedBox(height: 6),
            Text('760 / 1.000 XP • Catat transaksi untuk menjaga streak!', style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 12)),
          ]),
        ),
      );
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({required this.available, required this.used, required this.total, super.key});

  final int available;
  final int used;
  final int total;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Uang tersedia', style: TextStyle(color: Colors.grey.shade600)),
            Text(formatRupiah(available), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Anggaran bulan ini', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${(used * 100 / total).round()}% terpakai', style: const TextStyle(color: _primary, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: used / total, minHeight: 8, color: _mint, borderRadius: const BorderRadius.all(Radius.circular(8))),
          ]),
        ),
      );
}

class EnvelopeCard extends StatelessWidget {
  const EnvelopeCard({required this.envelope, super.key});

  final Envelope envelope;

  @override
  Widget build(BuildContext context) {
    final isNearLimit = envelope.usage > .8;
    return Card(
      color: const Color(0xFFFFFFFF),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 50, height: 50, alignment: Alignment.center, decoration: BoxDecoration(color: envelope.color, borderRadius: BorderRadius.circular(17)), child: Text(envelope.emoji, style: const TextStyle(fontSize: 24))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(envelope.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah(envelope.remaining), style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 2),
            Text('Sisa dari ${formatRupiah(envelope.budget)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: envelope.usage.clamp(0.0, 1.0) as double, minHeight: 7, color: isNearLimit ? const Color(0xFFFF6B6B) : _mint, borderRadius: const BorderRadius.all(Radius.circular(8))),
          ])),
        ]),
      ),
    );
  }
}

class EnvelopesPage extends StatelessWidget {
  const EnvelopesPage({required this.envelopes, super.key});
  final List<Envelope> envelopes;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        children: [
          const PageHeading(title: 'Amplop Digital', subtitle: 'Atur uangmu sesuai pos pengeluaran.'),
          const SizedBox(height: 20),
          ...envelopes.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: EnvelopeCard(envelope: item))),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Buat Amplop Baru')),
        ],
      );
}

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        children: const [
          PageHeading(title: 'Quest & Reward', subtitle: 'Selesaikan tantangan untuk mendapat XP dan badge.'),
          SizedBox(height: 24),
          SectionTitle('Misi Hari Ini'),
          SizedBox(height: 10),
          QuestCard(title: 'Catat satu transaksi', reward: '10 XP', progress: 1, done: true),
          SizedBox(height: 10),
          QuestCard(title: 'Tidak memakai amplop Hiburan', reward: '30 XP', progress: .45),
          SizedBox(height: 24),
          SectionTitle('Tantangan Mingguan'),
          SizedBox(height: 10),
          QuestCard(title: 'Hemat Rp100.000 untuk Transportasi', reward: '100 XP', progress: .6),
          SizedBox(height: 10),
          QuestCard(title: 'Jaga anggaran Makan selama 7 hari', reward: 'Badge Budget Guardian', progress: .7),
        ],
      );
}

class QuestCard extends StatelessWidget {
  const QuestCard({required this.title, required this.reward, required this.progress, this.done = false, super.key});
  final String title;
  final String reward;
  final double progress;
  final bool done;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(done ? Icons.check_circle : Icons.flag, color: done ? _mint : _primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              LinearProgressIndicator(value: progress, color: done ? _mint : _primary, borderRadius: const BorderRadius.all(Radius.circular(8))),
            ])),
            const SizedBox(width: 10),
            SizedBox(width: 70, child: Text(reward, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, color: _primary))),
          ]),
        ),
      );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 110),
        children: [
          const CircleAvatar(radius: 44, backgroundColor: Color(0xFFD6C8FF), child: Text('👤', style: TextStyle(fontSize: 40))),
          const SizedBox(height: 12),
          const Center(child: Text('Andi Pratama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Center(child: Text('Budget Explorer • Level 8', style: TextStyle(color: Colors.grey.shade600))),
          const SizedBox(height: 28),
          const ProfileOption(icon: Icons.notifications_outlined, label: 'Notifikasi pengingat'),
          const ProfileOption(icon: Icons.currency_exchange, label: 'Mata uang: Rupiah (IDR)'),
          const ProfileOption(icon: Icons.file_upload_outlined, label: 'Ekspor data'),
          const ProfileOption(icon: Icons.info_outline, label: 'Tentang Pocket Quest'),
        ],
      );
}

class ProfileOption extends StatelessWidget {
  const ProfileOption({required this.icon, required this.label, super.key});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(leading: Icon(icon, color: _primary), title: Text(label), trailing: const Icon(Icons.chevron_right)),
      );
}

class PageHeading extends StatelessWidget {
  const PageHeading({required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      ]);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900));
}

class _CuteBadge extends StatelessWidget {
  const _CuteBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFFFE1EE), borderRadius: BorderRadius.circular(16)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('🐷', style: TextStyle(fontSize: 18)),
          SizedBox(width: 4),
          Text('Good job!', style: TextStyle(color: _pink, fontWeight: FontWeight.w900, fontSize: 12)),
        ]),
      );
}

class TransactionSheet extends StatefulWidget {
  const TransactionSheet({required this.envelopes, required this.onSave, super.key});
  final List<Envelope> envelopes;
  final void Function(Envelope envelope, int amount) onSave;

  @override
  State<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends State<TransactionSheet> {
  final _amountController = TextEditingController();
  late Envelope _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.envelopes.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Catat Pengeluaran', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixIcon: Icon(Icons.payments_outlined), border: OutlineInputBorder())),
          const SizedBox(height: 14),
          DropdownButtonFormField<Envelope>(
            value: _selected,
            decoration: const InputDecoration(labelText: 'Pilih amplop', border: OutlineInputBorder()),
            items: widget.envelopes.map((item) => DropdownMenuItem(value: item, child: Text('${item.emoji} ${item.name}'))).toList(),
            onChanged: (value) => setState(() => _selected = value!),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(_amountController.text);
              if (amount != null && amount > 0) widget.onSave(_selected, amount);
            },
            child: const Text('Simpan & dapatkan 10 XP'),
          ),
        ]),
      );
}

String formatRupiah(int value) {
  final digits = value.toString();
  final result = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) result.write('.');
    result.write(digits[i]);
  }
  return 'Rp$result';
}
