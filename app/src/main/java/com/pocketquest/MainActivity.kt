package com.pocketquest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.text.NumberFormat
import java.util.Locale

private val Indigo = Color(0xFF5B5FEF)
private val Mint = Color(0xFF42C58A)
private val Canvas = Color(0xFFF7F7FC)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { PocketQuestApp() }
    }
}

data class Envelope(
    val name: String,
    val icon: String,
    val budget: Int,
    var spent: Int,
    val color: Color,
)

private enum class Screen(val label: String) { HOME("Beranda"), ENVELOPES("Amplop"), QUESTS("Quest"), PROFILE("Profil") }

@Composable
fun PocketQuestApp() {
    var screen by rememberSaveable { mutableStateOf(Screen.HOME) }
    var showTransaction by rememberSaveable { mutableStateOf(false) }
    val envelopes = remember {
        mutableStateListOf(
            Envelope("Makan", "🍜", 700_000, 450_000, Color(0xFFFFD98C)),
            Envelope("Transportasi", "🚌", 300_000, 120_000, Color(0xFFBCE8E0)),
            Envelope("Hiburan", "🎮", 500_000, 450_000, Color(0xFFD6C8FF)),
            Envelope("Tabungan", "🏦", 1_000_000, 200_000, Color(0xFFAEDBFF)),
        )
    }

    MaterialTheme(colorScheme = lightColorScheme(primary = Indigo, secondary = Mint, background = Canvas)) {
        Scaffold(
            containerColor = Canvas,
            bottomBar = { AppNavigation(screen, onSelect = { screen = it }) },
            floatingActionButton = {
                ExtendedFloatingActionButton(
                    onClick = { showTransaction = true },
                    icon = { Icon(Icons.Default.Add, null) },
                    text = { Text("Transaksi") },
                    containerColor = Indigo,
                    contentColor = Color.White,
                )
            },
        ) { padding ->
            when (screen) {
                Screen.HOME -> HomeScreen(Modifier.padding(padding), envelopes)
                Screen.ENVELOPES -> EnvelopesScreen(Modifier.padding(padding), envelopes)
                Screen.QUESTS -> QuestsScreen(Modifier.padding(padding))
                Screen.PROFILE -> ProfileScreen(Modifier.padding(padding))
            }
        }
        if (showTransaction) {
            AddTransactionSheet(envelopes, onDismiss = { showTransaction = false })
        }
    }
}

@Composable
private fun AppNavigation(current: Screen, onSelect: (Screen) -> Unit) {
    NavigationBar {
        val items = listOf(
            Screen.HOME to Icons.Default.Home,
            Screen.ENVELOPES to Icons.Default.AccountBalanceWallet,
            Screen.QUESTS to Icons.Default.EmojiEvents,
            Screen.PROFILE to Icons.Default.Person,
        )
        items.forEach { (screen, icon) ->
            NavigationBarItem(
                selected = current == screen,
                onClick = { onSelect(screen) },
                icon = { Icon(icon, screen.label) },
                label = { Text(screen.label) },
            )
        }
    }
}

@Composable
private fun HomeScreen(modifier: Modifier, envelopes: List<Envelope>) {
    val used = envelopes.sumOf { it.spent }
    val total = envelopes.sumOf { it.budget }
    LazyColumn(modifier.fillMaxSize(), contentPadding = PaddingValues(20.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Text("Halo, Andi 👋", fontSize = 24.sp, fontWeight = FontWeight.Bold)
            Text("Level 8 • Budget Explorer", color = Color.Gray)
        }
        item { XpCard() }
        item { BalanceCard(total - used, used, total) }
        item { Text("Amplop Saya", fontSize = 19.sp, fontWeight = FontWeight.Bold) }
        items(envelopes.take(3)) { EnvelopeRow(it) }
        item { Text("Misi Hari Ini", fontSize = 19.sp, fontWeight = FontWeight.Bold) }
        item { QuestCard("Catat satu transaksi hari ini", "10 XP", 1f, true) }
        item { QuestCard("Tidak belanja kopi hari ini", "30 XP", .45f, false) }
    }
}

@Composable
private fun XpCard() = Card(colors = CardDefaults.cardColors(containerColor = Indigo), shape = RoundedCornerShape(20.dp)) {
    Column(Modifier.padding(18.dp)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("🔥 Streak 7 Hari", color = Color.White, fontWeight = FontWeight.Bold)
            Text("Level 8", color = Color.White)
        }
        Spacer(Modifier.height(10.dp))
        LinearProgressIndicator(.76f, Modifier.fillMaxWidth().height(8.dp), color = Color(0xFFFFD166), trackColor = Color.White.copy(alpha = .25f))
        Spacer(Modifier.height(6.dp))
        Text("760 / 1.000 XP • Catat transaksi untuk menjaga streak!", color = Color.White.copy(alpha = .9f), fontSize = 12.sp)
    }
}

@Composable
private fun BalanceCard(available: Int, used: Int, total: Int) = Card(shape = RoundedCornerShape(20.dp)) {
    Column(Modifier.padding(18.dp)) {
        Text("Uang tersedia", color = Color.Gray)
        Text(rupiah(available), fontSize = 28.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(14.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("Anggaran bulan ini", fontWeight = FontWeight.Medium)
            Text("${(used * 100 / total)}% terpakai", color = Indigo, fontWeight = FontWeight.Bold)
        }
        LinearProgressIndicator(used.toFloat() / total, Modifier.fillMaxWidth().padding(top = 8.dp), color = Mint)
    }
}

@Composable
private fun EnvelopeRow(envelope: Envelope) = Card(shape = RoundedCornerShape(16.dp)) {
    Row(Modifier.fillMaxWidth().padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(46.dp).background(envelope.color, RoundedCornerShape(14.dp)), contentAlignment = Alignment.Center) { Text(envelope.icon, fontSize = 22.sp) }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(envelope.name, fontWeight = FontWeight.Bold)
                Text(rupiah(envelope.budget - envelope.spent), fontWeight = FontWeight.SemiBold)
            }
            Text("Sisa dari ${rupiah(envelope.budget)}", fontSize = 12.sp, color = Color.Gray)
            LinearProgressIndicator(envelope.spent.toFloat() / envelope.budget, Modifier.fillMaxWidth().padding(top = 7.dp), color = if (envelope.spent.toFloat() / envelope.budget > .8f) Color(0xFFFF6B6B) else Mint)
        }
    }
}

@Composable
private fun EnvelopesScreen(modifier: Modifier, envelopes: List<Envelope>) = LazyColumn(modifier.fillMaxSize(), contentPadding = PaddingValues(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
    item { Text("Amplop Digital", fontSize = 26.sp, fontWeight = FontWeight.Bold) }
    item { Text("Atur uangmu sesuai pos pengeluaran.", color = Color.Gray) }
    items(envelopes) { EnvelopeRow(it) }
    item { OutlinedButton(onClick = {}, modifier = Modifier.fillMaxWidth()) { Icon(Icons.Default.Add, null); Spacer(Modifier.width(8.dp)); Text("Buat Amplop Baru") } }
}

@Composable
private fun QuestsScreen(modifier: Modifier) = LazyColumn(modifier.fillMaxSize(), contentPadding = PaddingValues(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
    item { Text("Quest & Reward", fontSize = 26.sp, fontWeight = FontWeight.Bold) }
    item { Text("Selesaikan tantangan untuk mendapat XP dan badge.", color = Color.Gray) }
    item { Text("Misi Hari Ini", fontWeight = FontWeight.Bold, fontSize = 18.sp) }
    item { QuestCard("Catat satu transaksi", "10 XP", 1f, true) }
    item { QuestCard("Tidak memakai amplop Hiburan", "30 XP", .45f, false) }
    item { Text("Tantangan Mingguan", fontWeight = FontWeight.Bold, fontSize = 18.sp) }
    item { QuestCard("Hemat Rp100.000 untuk Transportasi", "100 XP", .6f, false) }
    item { QuestCard("Jaga anggaran Makan selama 7 hari", "Badge Budget Guardian", .7f, false) }
}

@Composable
private fun QuestCard(title: String, reward: String, progress: Float, done: Boolean) = Card(shape = RoundedCornerShape(16.dp)) {
    Row(Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
        Icon(if (done) Icons.Default.CheckCircle else Icons.Default.Flag, null, tint = if (done) Mint else Indigo)
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, fontWeight = FontWeight.SemiBold)
            LinearProgressIndicator(progress, Modifier.fillMaxWidth().padding(top = 7.dp), color = if (done) Mint else Indigo)
        }
        Spacer(Modifier.width(10.dp)); Text(reward, color = Indigo, fontSize = 12.sp, textAlign = TextAlign.End)
    }
}

@Composable
private fun ProfileScreen(modifier: Modifier) = Column(modifier.fillMaxSize().padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
    Spacer(Modifier.height(18.dp))
    Surface(Modifier.size(88.dp), shape = RoundedCornerShape(44.dp), color = Color(0xFFD6C8FF)) { Box(contentAlignment = Alignment.Center) { Text("👤", fontSize = 42.sp) } }
    Spacer(Modifier.height(12.dp)); Text("Andi Pratama", fontWeight = FontWeight.Bold, fontSize = 22.sp); Text("Budget Explorer • Level 8", color = Color.Gray)
    Spacer(Modifier.height(28.dp))
    listOf("Notifikasi pengingat", "Mata uang: Rupiah (IDR)", "Ekspor data", "Tentang Pocket Quest").forEach { label ->
        ListItem(headlineContent = { Text(label) }, trailingContent = { Icon(Icons.Default.ChevronRight, null) })
        HorizontalDivider()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddTransactionSheet(envelopes: MutableList<Envelope>, onDismiss: () -> Unit) {
    var amount by rememberSaveable { mutableStateOf("") }
    var selected by rememberSaveable { mutableIntStateOf(0) }
    var expanded by remember { mutableStateOf(false) }
    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(Modifier.fillMaxWidth().padding(24.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Text("Catat Pengeluaran", fontSize = 23.sp, fontWeight = FontWeight.Bold)
            OutlinedTextField(value = amount, onValueChange = { amount = it.filter(Char::isDigit) }, label = { Text("Nominal (Rp)") }, leadingIcon = { Icon(Icons.Default.Payments, null) }, modifier = Modifier.fillMaxWidth())
            ExposedDropdownMenuBox(expanded = expanded, onExpandedChange = { expanded = it }) {
                OutlinedTextField(value = "${envelopes[selected].icon} ${envelopes[selected].name}", onValueChange = {}, readOnly = true, label = { Text("Pilih amplop") }, trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) }, modifier = Modifier.menuAnchor().fillMaxWidth())
                ExposedDropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                    envelopes.forEachIndexed { index, envelope -> DropdownMenuItem(text = { Text("${envelope.icon} ${envelope.name}") }, onClick = { selected = index; expanded = false }) }
                }
            }
            Button(onClick = { amount.toIntOrNull()?.let { envelopes[selected] = envelopes[selected].copy(spent = envelopes[selected].spent + it) }; onDismiss() }, enabled = amount.isNotBlank(), modifier = Modifier.fillMaxWidth()) { Text("Simpan & dapatkan 10 XP") }
            Spacer(Modifier.height(12.dp))
        }
    }
}

private fun rupiah(amount: Int): String = NumberFormat.getCurrencyInstance(Locale("id", "ID")).format(amount).replace(",00", "")

@Preview(showBackground = true)
@Composable
private fun PreviewPocketQuest() = PocketQuestApp()
