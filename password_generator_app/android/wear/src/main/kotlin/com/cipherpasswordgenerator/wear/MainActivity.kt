package com.cipherpasswordgenerator.wear

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.ScalingLazyColumn
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                CipherWatchApp()
            }
        }
    }
}

@Composable
fun CipherWatchApp() {
    val context = LocalContext.current
    val historyManager = remember { HistoryManager(context) }
    val entries by historyManager.entries.collectAsState(initial = emptyList())
    val scope = rememberCoroutineScope()

    var password by remember { mutableStateOf("") }
    var length by remember { mutableStateOf(12f) }
    var useLowercase by remember { mutableStateOf(true) }
    var useUppercase by remember { mutableStateOf(true) }
    var useDigits by remember { mutableStateOf(true) }
    var useSpecial by remember { mutableStateOf(true) }
    var showHistory by remember { mutableStateOf(false) }

    val strength = if (password.isNotEmpty()) PasswordGenerator.strength(password) else null
    val strengthColor = strength?.let { Color(it.colorHex) } ?: Color.Gray

    Scaffold(
        timeText = { if (!showHistory) TimeText() }
    ) {
        if (showHistory) {
            HistoryScreen(
                entries = entries,
                onDismiss = { showHistory = false },
                onClear = {
                    vibrate(context, 50)
                    scope.launch { historyManager.clear() }
                },
                onCopy = { pwd ->
                    vibrate(context, 30)
                    copyToClipboard(context, pwd)
                }
            )
        } else {
            MainScreen(
                password = password,
                strength = strength,
                strengthColor = strengthColor,
                length = length,
                useLowercase = useLowercase,
                useUppercase = useUppercase,
                useDigits = useDigits,
                useSpecial = useSpecial,
                historyCount = entries.size,
                onLengthChange = { length = it },
                onLowercaseChange = { useLowercase = it },
                onUppercaseChange = { useUppercase = it },
                onDigitsChange = { useDigits = it },
                onSpecialChange = { useSpecial = it },
                onGenerate = {
                    vibrate(context, 80)
                    password = PasswordGenerator.generate(
                        length = length.toInt(),
                        useLowercase = useLowercase,
                        useUppercase = useUppercase,
                        useDigits = useDigits,
                        useSpecial = useSpecial
                    )
                    scope.launch { historyManager.add(password, strength?.label ?: "") }
                },
                onCopy = {
                    vibrate(context, 30)
                    copyToClipboard(context, password)
                },
                onShowHistory = { showHistory = true }
            )
        }
    }
}

@Composable
fun MainScreen(
    password: String,
    strength: PasswordGenerator.StrengthResult?,
    strengthColor: Color,
    length: Float,
    useLowercase: Boolean,
    useUppercase: Boolean,
    useDigits: Boolean,
    useSpecial: Boolean,
    historyCount: Int,
    onLengthChange: (Float) -> Unit,
    onLowercaseChange: (Boolean) -> Unit,
    onUppercaseChange: (Boolean) -> Unit,
    onDigitsChange: (Boolean) -> Unit,
    onSpecialChange: (Boolean) -> Unit,
    onGenerate: () -> Unit,
    onCopy: () -> Unit,
    onShowHistory: () -> Unit
) {
    ScalingLazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        item {
            Text(
                text = "Cipher",
                fontSize = 16.sp,
                color = Color(0xFFBB86FC)
            )
        }

        item {
            PasswordCard(password, strength, strengthColor, onCopy)
        }

        item {
            Button(
                onClick = onGenerate,
                modifier = Modifier.size(48.dp),
                shape = CircleShape,
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = Color(0xFFBB86FC)
                )
            ) {
                Text("Gen", fontSize = 10.sp)
            }
        }

        item {
            LengthSlider(length, onLengthChange)
        }

        item { ToggleRow("a-z", useLowercase, onLowercaseChange) }
        item { ToggleRow("A-Z", useUppercase, onUppercaseChange) }
        item { ToggleRow("0-9", useDigits, onDigitsChange) }
        item { ToggleRow("!@#", useSpecial, onSpecialChange) }

        item {
            Button(
                onClick = onShowHistory,
                modifier = Modifier.fillMaxWidth(0.7f),
                enabled = historyCount > 0,
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = Color(0xFF333333)
                )
            ) {
                Text("History ($historyCount)", fontSize = 10.sp)
            }
        }
    }
}

@Composable
fun PasswordCard(
    password: String,
    strength: PasswordGenerator.StrengthResult?,
    strengthColor: Color,
    onCopy: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth(0.85f)
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFF1E1E1E))
            .padding(8.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = password.ifEmpty { "Tap Gen" },
                fontSize = 11.sp,
                fontFamily = FontFamily.Monospace,
                color = if (password.isEmpty()) Color.Gray else strengthColor,
                textAlign = TextAlign.Center,
                maxLines = 3,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.fillMaxWidth()
            )

            if (strength != null) {
                Spacer(modifier = Modifier.height(4.dp))

                val animatedProgress by animateFloatAsState(targetValue = strength.percent)
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(4.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(Color(0xFF333333))
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth(animatedProgress)
                            .fillMaxSize()
                            .clip(RoundedCornerShape(2.dp))
                            .background(strengthColor)
                    )
                }

                Spacer(modifier = Modifier.height(2.dp))

                Text(
                    text = strength.label,
                    fontSize = 8.sp,
                    color = strengthColor
                )

                Spacer(modifier = Modifier.height(4.dp))

                Button(
                    onClick = onCopy,
                    modifier = Modifier.height(28.dp),
                    colors = ButtonDefaults.buttonColors(
                        backgroundColor = strengthColor
                    )
                ) {
                    Text("Copy", fontSize = 9.sp, color = Color.Black)
                }
            }
        }
    }
}

@Composable
fun LengthSlider(value: Float, onValueChange: (Float) -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = "Length: ${value.toInt()}",
            fontSize = 10.sp,
            color = Color.White
        )
        Slider(value = value, onValueChange = onValueChange)
    }
}

@Composable
fun Slider(value: Float, onValueChange: (Float) -> Unit) {
    val steps = listOf(4f, 8f, 12f, 16f, 20f, 24f, 28f, 32f)
    val closestStep = steps.minByOrNull { kotlin.math.abs(it - value) } ?: 12f

    Row(
        modifier = Modifier.fillMaxWidth(0.7f),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Button(
            onClick = {
                val idx = steps.indexOf(closestStep)
                if (idx > 0) onValueChange(steps[idx - 1])
            },
            modifier = Modifier.size(28.dp),
            enabled = closestStep > 4f,
            colors = ButtonDefaults.buttonColors(backgroundColor = Color(0xFF333333))
        ) {
            Text("-", fontSize = 12.sp)
        }

        Text(
            text = "${closestStep.toInt()}",
            fontSize = 12.sp,
            color = Color(0xFFBB86FC),
            modifier = Modifier.padding(horizontal = 8.dp)
        )

        Button(
            onClick = {
                val idx = steps.indexOf(closestStep)
                if (idx < steps.lastIndex) onValueChange(steps[idx + 1])
            },
            modifier = Modifier.size(28.dp),
            enabled = closestStep < 32f,
            colors = ButtonDefaults.buttonColors(backgroundColor = Color(0xFF333333))
        ) {
            Text("+", fontSize = 12.sp)
        }
    }
}

@Composable
fun ToggleRow(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth(0.75f)
            .clip(RoundedCornerShape(8.dp))
            .background(if (checked) Color(0xFF2A2A2A) else Color(0xFF1A1A1A))
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = label, fontSize = 10.sp, color = Color.White)
        Button(
            onClick = { onCheckedChange(!checked) },
            modifier = Modifier.size(28.dp),
            colors = ButtonDefaults.buttonColors(
                backgroundColor = if (checked) Color(0xFFBB86FC) else Color(0xFF333333)
            )
        ) {
            Text(
                text = if (checked) "ON" else "OFF",
                fontSize = 7.sp,
                color = if (checked) Color.Black else Color.Gray
            )
        }
    }
}

@Composable
fun HistoryScreen(
    entries: List<HistoryEntry>,
    onDismiss: () -> Unit,
    onClear: () -> Unit,
    onCopy: (String) -> Unit
) {
    ScalingLazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Button(
                    onClick = onDismiss,
                    modifier = Modifier.size(32.dp),
                    colors = ButtonDefaults.buttonColors(backgroundColor = Color(0xFF333333))
                ) {
                    Text("X", fontSize = 8.sp)
                }
                if (entries.isNotEmpty()) {
                    Button(
                        onClick = onClear,
                        modifier = Modifier.size(32.dp),
                        colors = ButtonDefaults.buttonColors(backgroundColor = Color(0xFF5C1A1A))
                    ) {
                        Text("Del", fontSize = 8.sp)
                    }
                }
            }
        }

        items(entries.size) { index ->
            val entry = entries[index]
            Button(
                onClick = { onCopy(entry.password) },
                modifier = Modifier
                    .fillMaxWidth(0.85f)
                    .clip(RoundedCornerShape(8.dp)),
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = Color(0xFF1E1E1E)
                )
            ) {
                Column(
                    modifier = Modifier.padding(4.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = entry.password,
                        fontSize = 9.sp,
                        fontFamily = FontFamily.Monospace,
                        color = Color.White,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = entry.strengthLabel,
                        fontSize = 7.sp,
                        color = Color.Gray
                    )
                }
            }
        }
    }
}

private fun copyToClipboard(context: Context, text: String) {
    if (text.isEmpty()) return
    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    val clip = ClipData.newPlainText("password", text)
    clipboard.setPrimaryClip(clip)
}

private fun vibrate(context: Context, durationMs: Long) {
    val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
}
