import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var length: Double = 12
    @State private var useLowercase = true
    @State private var useUppercase = true
    @State private var useDigits = true
    @State private var useSpecial = true
    @State private var password = ""
    @State private var strengthLabel = ""
    @State private var strengthPercent: Float = 0
    @State private var strengthColor = Color.white
    @State private var showHistory = false
    @State private var showCopied = false
    @EnvironmentObject var history: HistoryManager
    @EnvironmentObject var phoneSync: PhoneSyncManager
    @Environment(\.isLuminanceReduced) private var isDimmed

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    passwordCard
                    if !isDimmed {
                        generateButton
                        optionsSection
                    }
                    historyButton
                }
                .padding()
            }
            .navigationTitle("Cipher")
            .sheet(isPresented: $showHistory) { HistoryView() }
        }
    }

    private var passwordCard: some View {
        VStack(spacing: 6) {
            Text(password.isEmpty ? "Tap Generate" : password)
                .font(.system(.body, design: .monospaced))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(3)
                .padding(.horizontal, 4)
                .opacity(isDimmed && password.isEmpty ? 0.3 : 1.0)

            if !password.isEmpty && !isDimmed {
                ProgressView(value: strengthPercent)
                    .tint(strengthColor)
                Text(strengthLabel)
                    .font(.caption2)
                    .foregroundStyle(strengthColor)

                Button(showCopied ? "Saved!" : "Save") {
                    HapticsManager.shared.copyTap()
                    history.add(password, strengthLabel: strengthLabel)
                    phoneSync.sendPasswordToPhone(password, strengthLabel: strengthLabel)
                    withAnimation { showCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showCopied = false }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(showCopied ? .green : .purple)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.gray.opacity(isDimmed ? 0.05 : 0.15), in: RoundedRectangle(cornerRadius: 12))
    }

    private var generateButton: some View {
        Button("Generate") {
            HapticsManager.shared.generateTap()
            password = PasswordGenerator.generate(
                length: Int(length),
                useLowercase: useLowercase,
                useUppercase: useUppercase,
                useDigits: useDigits,
                useSpecial: useSpecial
            )
            let result = PasswordGenerator.strength(password)
            strengthLabel = result.label
            strengthPercent = result.percent
            strengthColor = colorFromHex(result.color)
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
    }

    private var optionsSection: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text("Length: \(Int(length))")
                    .font(.caption)
                CrownDrivenSlider(value: $length, bounds: 4...32, step: 1)
            }

            Toggle("a-z", isOn: $useLowercase)
                .font(.caption)
                .onChange(of: useLowercase) { HapticsManager.shared.toggleTap() }

            Toggle("A-Z", isOn: $useUppercase)
                .font(.caption)
                .onChange(of: useUppercase) { HapticsManager.shared.toggleTap() }

            Toggle("0-9", isOn: $useDigits)
                .font(.caption)
                .onChange(of: useDigits) { HapticsManager.shared.toggleTap() }

            Toggle("!@#$", isOn: $useSpecial)
                .font(.caption)
                .onChange(of: useSpecial) { HapticsManager.shared.toggleTap() }
        }
    }

    private var historyButton: some View {
        Button("History (\(history.entries.count))") { showHistory = true }
            .buttonStyle(.plain)
            .font(.caption)
            .disabled(history.entries.isEmpty)
    }

    private func colorFromHex(_ hex: Int) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

struct CrownDrivenSlider: View {
    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double

    @State private var crownAccumulator: Double = 0

    var body: some View {
        Slider(value: $value, in: bounds, step: step)
            .focusable()
            .onAppear { crownAccumulator = value }
    }
}

struct CrownDrivenSlider_Previews: PreviewProvider {
    @State static var val: Double = 12
    static var previews: some View {
        CrownDrivenSlider(value: $val, bounds: 4...32, step: 1)
            .frame(width: 150, height: 50)
    }
}
