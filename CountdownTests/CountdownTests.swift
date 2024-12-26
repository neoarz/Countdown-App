//
//  CountdownTests.swift
//  CountdownTests
//
//  Created by neoarz on 12/25/24.
//

import SwiftUI

struct CountdownView: View {
    @State private var timeRemaining = TimeInterval(141928800) // example time in seconds
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 16) { // Spacing between each unit
            // Years
            CountdownUnitView(value: timeRemaining.convertToYears(), label: "YRS", color: .white)

            // Days
            CountdownUnitView(value: timeRemaining.convertToDays() % 365, label: "DAY", color: .white)

            // Hours
            CountdownUnitView(value: timeRemaining.convertToHours(), label: "HRS", color: .white)

            // Minutes
            CountdownUnitView(value: timeRemaining.convertToMinutes(), label: "MIN", color: .white)

            // Seconds
            CountdownUnitView(value: timeRemaining.convertToSeconds(), label: "SEC", color: .white)
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            startTimer()
        }
    }

    // Start timer to update countdown
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
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
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

extension TimeInterval {
    // Convert seconds to years
    func convertToYears() -> Int {
        return Int(self) / (365 * 24 * 60 * 60)
    }

    // Convert seconds to days
    func convertToDays() -> Int {
        return Int(self) / (24 * 60 * 60)
    }

    // Convert seconds to hours
    func convertToHours() -> Int {
        return (Int(self) / (60 * 60)) % 24
    }

    // Convert seconds to minutes
    func convertToMinutes() -> Int {
        return (Int(self) / 60) % 60
    }

    // Convert seconds to seconds
    func convertToSeconds() -> Int {
        return Int(self) % 60
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView()
    }
}
