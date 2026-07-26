package com.cipherpasswordgenerator.wear

import kotlin.random.Random

object PasswordGenerator {

    fun generate(
        length: Int = 12,
        useLowercase: Boolean = true,
        useUppercase: Boolean = true,
        useDigits: Boolean = true,
        useSpecial: Boolean = true
    ): String {
        var chars = ""
        if (useLowercase) chars += "abcdefghijklmnopqrstuvwxyz"
        if (useUppercase) chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        if (useDigits) chars += "0123456789"
        if (useSpecial) chars += "!@#\$%^&*()_+-=[]{}|;:,.<>?"

        if (chars.isEmpty()) return "Select at least one type"

        val len = length.coerceIn(4, 32)
        val guaranteed = mutableListOf<Char>()

        if (useLowercase) guaranteed.add(chars.first { it.isLowerCase() })
        if (useUppercase) guaranteed.add(chars.first { it.isUpperCase() })
        if (useDigits) guaranteed.add(chars.first { it.isDigit() })
        if (useSpecial) guaranteed.add('!')

        val result = StringBuilder()
        val remaining = len - guaranteed.size
        repeat(remaining) {
            result.append(chars[Random.nextInt(chars.length)])
        }
        result.append(guaranteed)

        return result.toString().toCharArray().apply { shuffle() }.concatToString()
    }

    data class StrengthResult(
        val label: String,
        val percent: Float,
        val colorHex: Long
    )

    fun strength(password: String): StrengthResult {
        val len = password.length
        var score = 0

        if (len >= 8) score += 25
        if (len >= 12) score += 25
        if (len >= 16) score += 25
        if (password.any { it.isLowerCase() }) score += 6
        if (password.any { it.isUpperCase() }) score += 6
        if (password.any { it.isDigit() }) score += 6
        if (password.any { "!@#\$%^&*()_+-=[]{}|;:,.<>?".contains(it) }) score += 7

        val pct = score.coerceAtMost(100)

        return when {
            pct < 25  -> StrengthResult("Very Weak", pct / 100f, 0xFFFF5252)
            pct < 50  -> StrengthResult("Weak", pct / 100f, 0xFFFF9800)
            pct < 65  -> StrengthResult("Fair", pct / 100f, 0xFFFBC02D)
            pct < 80  -> StrengthResult("Good", pct / 100f, 0xFF8BC34A)
            else      -> StrengthResult("Strong", pct / 100f, 0xFF4CAF50)
        }
    }
}
