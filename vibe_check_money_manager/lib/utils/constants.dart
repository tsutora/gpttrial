// Categories with emoji mappings
const Map<String, String> expenseCategories = {
  'food & drinks': '🍔',
  'transportation': '🚗',
  'entertainment': '🎮',
  'shopping': '🛍️',
  'utilities': '💡',
  'health': '🏥',
  'work': '💼',
  'other': '📌',
};

const Map<String, String> incomeCategories = {
  'salary': '💰',
  'freelance': '💻',
  'investments': '📈',
  'bonus': '🎁',
};

const Map<String, String> allCategories = {
  ...expenseCategories,
  ...incomeCategories,
};

// Mood messages
const List<String> moodMessages = [
  'we feasting',
  'saving arc',
  'vibing',
  'treat yourself energy',
  'financial check needed',
  'big oof',
];

// Color constants (matching theme)
const String primaryColorHex = '#FF006E';
const String accentColorHex = '#00D4FF';
const String successColorHex = '#00D400';
const String warningColorHex = '#FFD60A';
