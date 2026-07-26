import Foundation

struct PasswordGenerator {
    static func generate(length: Int, useLowercase: Bool, useUppercase: Bool, useDigits: Bool, useSpecial: Bool) -> String {
        var chars = ""
        if useLowercase { chars += "abcdefghijklmnopqrstuvwxyz" }
        if useUppercase { chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if useDigits { chars += "0123456789" }
        if useSpecial { chars += "!@#$%^&*()_+-=[]{}|;:,.<>?" }

        guard !chars.isEmpty else { return "Select at least one type" }
        let len = max(4, min(length, 32))
        var result = ""

        var guaranteed: [Character] = []
        if useLowercase { guaranteed.append(chars.first { $0.isLowercase } ?? "a") }
        if useUppercase { guaranteed.append(chars.first { $0.isUppercase } ?? "A") }
        if useDigits { guaranteed.append(chars.first { $0.isNumber } ?? "0") }
        if useSpecial { guaranteed.append("!") }

        for _ in 0..<(len - guaranteed.count) {
            if let c = chars.randomElement() { result.append(c) }
        }
        result.append(contentsOf: guaranteed)
        return String(result.shuffled())
    }

    static func strength(_ password: String) -> (label: String, percent: Float, color: Int) {
        let len = password.count
        var score = 0
        if len >= 8 { score += 25 }
        if len >= 12 { score += 25 }
        if len >= 16 { score += 25 }
        if password.contains(where: { $0.isLowercase }) { score += 6 }
        if password.contains(where: { $0.isUppercase }) { score += 6 }
        if password.contains(where: { $0.isNumber }) { score += 6 }
        if password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) { score += 7 }
        let pct = min(Float(score), 100)
        let label: String
        let color: Int
        if pct < 25 { label = "Very Weak"; color = 0xFF5252 }
        else if pct < 50 { label = "Weak"; color = 0xFF9800 }
        else if pct < 65 { label = "Fair"; color = 0xFBC02D }
        else if pct < 80 { label = "Good"; color = 0x8BC34A }
        else { label = "Strong"; color = 0x4CAF50 }
        return (label, pct / 100, color)
    }
}
