import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Transactions stream provider
final transactionsStreamProvider = StreamProvider.autoDispose<List<Transaction>>((ref) async* {
  final auth = ref.watch(authNotifierProvider);
  final firestore = ref.watch(firestoreProvider);

  await for (final state in auth.stream) {
    if (state.hasValue && state.value != null) {
      final userId = state.value!.uid;
      yield* firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Transaction.fromJson(doc.data()))
            .toList();
      });
    } else {
      yield [];
    }
  }
});

// Transactions notifier for add/edit/delete
final transactionsNotifierProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<void>>((ref) {
  return TransactionsNotifier(ref);
});

class TransactionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TransactionsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addTransaction({
    required double amount,
    required String label,
    required String category,
    required String categoryEmoji,
    required bool isIncome,
    required DateTime date,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(authNotifierProvider);
      final firestore = ref.read(firestoreProvider);

      if (auth.value == null) throw Exception('User not authenticated');

      final userId = auth.value!.uid;
      final transactionId = const Uuid().v4();
      final now = DateTime.now();

      final transaction = Transaction(
        id: transactionId,
        userId: userId,
        amount: amount,
        label: label,
        category: category,
        categoryEmoji: categoryEmoji,
        isIncome: isIncome,
        date: date,
        note: note,
        createdAt: now,
      );

      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .set(transaction.toJson());

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(authNotifierProvider);
      final firestore = ref.read(firestoreProvider);

      if (auth.value == null) throw Exception('User not authenticated');

      final userId = auth.value!.uid;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTransaction({
    required String transactionId,
    required double amount,
    required String label,
    required String category,
    required String categoryEmoji,
    required bool isIncome,
    required DateTime date,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(authNotifierProvider);
      final firestore = ref.read(firestoreProvider);

      if (auth.value == null) throw Exception('User not authenticated');

      final userId = auth.value!.uid;

      final transaction = Transaction(
        id: transactionId,
        userId: userId,
        amount: amount,
        label: label,
        category: category,
        categoryEmoji: categoryEmoji,
        isIncome: isIncome,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .update(transaction.toJson());

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
