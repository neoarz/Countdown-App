import SwiftUI

struct CountdownView: View {
    @State private var timeRemaining: TimeInterval
    @State private var timer: Timer?
    @State private var showNotification: Bool = false

    init() {
        let savedTimeRemaining = UserDefaults.standard.double(forKey: "timeRemaining")
        let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date ?? Date()

        let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        UserDefaults.standard.set(launchCount + 1, forKey: "launchCount")

        if (launchCount + 1) % 5 == 0 {
            _showNotification = State(initialValue: true)
        }

        if savedTimeRemaining == 0 {
            let randomTimeRemaining = CountdownView.generateWeightedRandomTime()
            UserDefaults.standard.set(randomTimeRemaining, forKey: "timeRemaining")
            UserDefaults.standard.set(Date(), forKey: "lastSavedDate")
            timeRemaining = randomTimeRemaining
        } else {
            let elapsedTime = Date().timeIntervalSince(lastSavedDate)
            timeRemaining = max(0, savedTimeRemaining - elapsedTime)
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 16) {
                CountdownUnitView(
                    value: timeRemaining.convertToYears(),
                    label: "YRS",
                    color: timeRemaining.convertToYears() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                CountdownUnitView(
                    value: timeRemaining.convertToDays() % 365,
                    label: "DAY",
                    color: timeRemaining.convertToDays() % 365 == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                CountdownUnitView(
                    value: timeRemaining.convertToHours(),
                    label: "HRS",
                    color: timeRemaining.convertToHours() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                CountdownUnitView(
                    value: timeRemaining.convertToMinutes(),
                    label: "MIN",
                    color: timeRemaining.convertToMinutes() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                CountdownUnitView(
                    value: timeRemaining.convertToSeconds(),
                    label: "SEC",
                    color: timeRemaining.convertToSeconds() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
            }
            .onAppear {
                startTimer()
            }
            .padding()

            if showNotification {
                NotificationView(isVisible: $showNotification)
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                saveTimeRemaining()
            }
        }
    }

    private func saveTimeRemaining() {
        UserDefaults.standard.set(timeRemaining, forKey: "timeRemaining")
        UserDefaults.standard.set(Date(), forKey: "lastSavedDate")
    }

    static func generateWeightedRandomTime() -> TimeInterval {
        let randomValue = Double.random(in: 0...100)
        if randomValue < 75 {
            return TimeInterval(Int.random(in: 1...604_800))
        } else {
            return TimeInterval(Int.random(in: 604_801...788_400_000))
        }
    }
}

struct CountdownUnitView: View {
    var value: Int
    var label: String
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(String(format: "%02d", value))
                .font(.system(size: 95, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 54, weight: .semibold))
                .foregroundColor(color)
                .padding(.leading, 20.0)
        }
    }
}

struct NotificationView: View {
    @Binding var isVisible: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image("hi") 
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)
                VStack(alignment: .leading) {
                    Text("Countdown")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("User Agreement broken")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()
            .onTapGesture {
                isVisible = false
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5).ignoresSafeArea())
        .transition(.scale)
        .animation(.spring(), value: isVisible)
    }
}

extension TimeInterval {
    func convertToYears() -> Int { Int(self) / (365 * 24 * 60 * 60) }
    func convertToDays() -> Int { Int(self) / (24 * 60 * 60) }
    func convertToHours() -> Int { (Int(self) / (60 * 60)) % 24 }
    func convertToMinutes() -> Int { (Int(self) / 60) % 60 }
    func convertToSeconds() -> Int { Int(self) % 60 }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView()
    }
}
