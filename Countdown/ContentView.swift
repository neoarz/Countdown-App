//
//  CountdownApp.swift
//  Countdown
//
//  Created neoarz on 12/25/24.
import SwiftUI

struct CountdownView: View {
    @State private var timeRemaining: TimeInterval
    @State private var timer: Timer?
    @State private var showNotification: Bool = false
    @State private var showTermsAndConditions: Bool = false

    init() {
        let savedTimeRemaining = UserDefaults.standard.double(forKey: "timeRemaining")
        let lastSavedDate = UserDefaults.standard.object(forKey: "lastSavedDate") as? Date ?? Date()

        let hasAcceptedTerms = UserDefaults.standard.bool(forKey: "hasAcceptedTerms")
        if !hasAcceptedTerms {
            _showTermsAndConditions = State(initialValue: true)
        }

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
                TimeUnitRow(
                    value: timeRemaining.convertToYears(),
                    label: "YRS",
                    color: timeRemaining.convertToYears() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToDays() % 365,
                    label: "DAY",
                    color: timeRemaining.convertToDays() % 365 == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToHours(),
                    label: "HRS",
                    color: timeRemaining.convertToHours() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToMinutes(),
                    label: "MIN",
                    color: timeRemaining.convertToMinutes() == 0 ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
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

            if showTermsAndConditions {
                FullScreenTermsView(isVisible: $showTermsAndConditions) {
                    UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
                }
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

struct TimeUnitRow: View {
    var value: Int
    var label: String
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(String(format: "%02d", value))
                .font(.system(size: 95, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
                .padding(.top, 35) 
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

struct FullScreenTermsView: View {
    @Binding var isVisible: Bool
    var onAccept: () -> Void
    @State private var showAcceptPopup: Bool = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("User Agreement")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 50)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Copyright (c) Countdown Fate Systems, LLC")
                            .font(.callout)
                            .foregroundColor(.black)

                        Text("IMPORTANT: PLEASE READ THIS LICENSE CAREFULLY BEFORE USING THIS SOFTWARE.")
                            .foregroundColor(.black)
                            .font(.callout)

                        Text("+LICENSE ++++++++++++++++++++")
                            .foregroundColor(.black)
                            .font(.callout)

                        Text("""
                        +++ By downloading and using the Countdown app, you agree to the following terms and conditions.
                        
                        Acceptance of Fate: The countdown timer presented is final and binding, and the App is not liable for any consequences resulting from the time displayed.

                        Irrevocability: Once the countdown timer begins, it cannot be altered, reset, or stopped, and attempts to tamper with it may result in undefined and irreversible consequences.

                        Forbidden Actions: You agree not to modify, reverse-engineer, or tamper with the App's code or features, and you will not hold the developers liable for any outcomes related to the timer, your life, and supernatural or inexplicable occurrences linked to the App.

                        Limitation of Liability: The creators and developers of the App are not responsible for emotional distress, physical harm, or unforeseen events caused by reliance on the countdown timer.

                        Updates and Modifications: The developers reserve the right to update these terms and the App's functionality at any time without prior notice, and continued use of the App constitutes acceptance of such changes.

                        Legal Disclaimer: By downloading the App, you enter into this agreement willingly and accept all potential risks associated with its use.

                        Contact Information: For inquiries or concerns, please contact...
                        """)
                        .foregroundColor(.black)
                        .font(.callout)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .background(Color.white)

            if showAcceptPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        Text("I have read the user agreement and accept the terms and conditions.")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        HStack(spacing: 16) {
                            Button("Cancel") {
                            }
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                            Button("Accept") {
                                onAccept()
                                isVisible = false
                            }
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal, 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale)
                }
                .transition(.opacity)
                .animation(.spring(), value: isVisible)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                showAcceptPopup = true
            }
        }
        .transition(.opacity)
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
