import SwiftUI
import AVFoundation
import UIKit
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            if let path = Bundle.main.path(forResource: "CountdownLoad", ofType: "mp4") {
                let url = URL(fileURLWithPath: path)
                VideoPlayer(player: AVPlayer(url: url).apply { player in
                    player.play()
                    
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                         object: player.currentItem, queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                })

                .frame(width: UIScreen.main.bounds.width * 0.64,    
                      height: UIScreen.main.bounds.height * 0.24)   
                .cornerRadius(12)                                  
                .shadow(radius: 10)       
                .offset(y: -UIScreen.main.bounds.height * 0.02)            
                .overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                )
            } else {
                Text("Video not found")
            }
        }
    }
}

extension AVPlayer {
    func apply(_ closure: (AVPlayer) -> Void) -> AVPlayer {
        closure(self)
        return self
    }
}

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

    private enum TimeUnit {
        case years, days, hours, minutes, seconds
    }

    private func shouldBeRed(unit: TimeUnit) -> Bool {
        if timeRemaining == 0 {
            return true
        }
        
        switch unit {
        case .years:
            return timeRemaining.convertToYears() == 0
        case .days:
            return timeRemaining.convertToYears() == 0 && timeRemaining.convertToDays() % 365 == 0
        case .hours:
            return timeRemaining.convertToDays() == 0 && timeRemaining.convertToHours() == 0
        case .minutes:
            return timeRemaining.convertToHours() == 0 && timeRemaining.convertToMinutes() == 0
        case .seconds:
            return timeRemaining.convertToMinutes() == 0 && timeRemaining.convertToSeconds() == 0
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .statusBar(hidden: true)
                .hideHomeIndicator()
            
            VStack(spacing: 40) {
                TimeUnitRow(
                    value: timeRemaining.convertToYears(),
                    label: "YRS",
                    color: shouldBeRed(unit: .years) ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToDays() % 365,
                    label: "DAY",
                    color: shouldBeRed(unit: .days) ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToHours(),
                    label: "HRS",
                    color: shouldBeRed(unit: .hours) ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToMinutes(),
                    label: "MIN",
                    color: shouldBeRed(unit: .minutes) ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
                )
                TimeUnitRow(
                    value: timeRemaining.convertToSeconds(),
                    label: "SEC",
                    color: shouldBeRed(unit: .seconds) ? Color(red: 0.5, green: 0.0, blue: 0.0) : Color.white
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
            return TimeInterval(Int.random(in: 100...604_801))
        } else {
            return TimeInterval(Int.random(in: 604_801...788_400_000))
            //604_801
        }
    }
}









struct TimeUnitRow: View {
    var value: Int
    var label: String
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let baseWidth: CGFloat = 393
            let baseIPadWidth: CGFloat = 834
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            
            let scale: CGFloat = isIPad
                ? max(1.3, geometry.size.width / baseIPadWidth * 1.5)
                : geometry.size.width / baseWidth
            
            ZStack {
                HStack(alignment: .center, spacing: 4 * scale) {
                    if !isIPad {
                        Spacer()
                    }
                    
                    Text(String(format: value >= 100 ? "%03d" : "%02d", value))
                        .font(.system(size: isIPad ? 115 * scale : 115 * scale, weight: .bold))
                        .foregroundColor(color)
                        .frame(minWidth: isIPad ? geometry.size.width * 0.3 : 0, alignment: .trailing)
                        .layoutPriority(1)
                    
                    Text(label)
                        .font(.system(size: isIPad ? 28 * scale : 28 * scale, weight: .semibold))
                        .foregroundColor(color)
                        .padding(.top, isIPad ? 45 * scale : 55 * scale)
                        .frame(width: geometry.size.width * (isIPad ? 0.15 : 0.2), alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: isIPad ? .center : .trailing)
                .padding(.trailing, isIPad ? 0 : 49 * scale)
                .padding(.leading, isIPad ? 0 : 0)
            }
        }
        .frame(height: 100 * (UIDevice.current.userInterfaceIdiom == .pad
            ? max(1.3, UIScreen.main.bounds.width / 834 * 1.5)
            : UIScreen.main.bounds.width / 393))
        .offset(y: -16 * min(max(UIScreen.main.bounds.width / 393, 0.8), 1.2))
    }
}




class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()
    var audioPlayer: AVAudioPlayer?
    
    func playSound() {
        if audioPlayer?.isPlaying == true {
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            
            if let path = Bundle.main.path(forResource: "CountdownSoundEffect", ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.volume = 1.0
                audioPlayer?.numberOfLoops = 0
                if audioPlayer?.prepareToPlay() == true {
                    audioPlayer?.play()
                }
            }
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
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
                        .foregroundColor(.black)
                    Text("User Agreement Broken")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(1)
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
        .onAppear {
            SoundManager.shared.playSound()
        }
    }
}








struct FullScreenTermsView: View {
    @Binding var isVisible: Bool
    var onAccept: () -> Void
    @State private var showAcceptPopup: Bool = false
    @State private var isAcceptPressed: Bool = false
    @State private var isCancelPressed: Bool = false
    @State private var showVideo: Bool = false

    var body: some View {
        ZStack {
            if !showVideo {
                Color.white.ignoresSafeArea()
            }
            
            if showVideo {
                VideoPlayerView(videoName: "CountdownLoad")
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            withAnimation {
                                showVideo = false
                                isVisible = false
                                onAccept()
                            }
                        }
                    }
            }
            
            VStack(spacing: 24) {
                Text("End User Agreement")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Copyright")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Copyright (c) Neo Fate Systems, LLC")
                            .font(.body)
                            .foregroundColor(.black)

                        Text("Important Notice")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            
                        Text("IMPORTANT: PLEASE READ THIS LICENSE CAREFULLY BEFORE USING THIS SOFTWARE.")
                            .foregroundColor(.black)
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            TermsSection(title: "1. Acceptance of Fate",
                                       content: "The countdown timer presented is final and binding, and the App is not liable for any consequences resulting from the time displayed.")
                            
                            TermsSection(title: "2. Irrevocability",
                                       content: "Once the countdown timer begins, it cannot be altered, reset, or stopped, and attempts to tamper with it may result in undefined and irreversible consequences.")
                            
                            TermsSection(title: "3. Forbidden Actions",
                                       content: "You agree not to modify, reverse-engineer, or tamper with the App's code or features, and you will not hold the developers liable for any outcomes related to the timer, your life, and supernatural or inexplicable occurrences linked to the App.")
                            
                            TermsSection(title: "4. Limitation of Liability",
                                       content: "The creators and developers of the App are not responsible for emotional distress, physical harm, or unforeseen events caused by reliance on the countdown timer.")
                            
                            TermsSection(title: "5. Updates and Modifications",
                                       content: "The developers reserve the right to update these terms and the App's functionality at any time without prior notice, and continued use of the App constitutes acceptance of such changes.")
                            
                            TermsSection(title: "6. Legal Disclaimer",
                                       content: "By downloading the App, you enter into this agreement willingly and accept all potential risks associated with its use.")
                            
                            TermsSection(title: "7. Contact Information",
                                       content: "For inquiries or concerns, please contact...")
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .background(Color.white)
            .opacity(showVideo ? 0 : 1)

            if showAcceptPopup && !showVideo {
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
                            .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Text("Cancel")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(isCancelPressed ? .white : .red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isCancelPressed ? Color.red : Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .pressEvents {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isCancelPressed = true
                                }
                            } onRelease: {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isCancelPressed = false
                                }
                            }

                            Button(action: {
                                showVideo = true
                            }) {
                                Text("Accept")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(isAcceptPressed ? .white : .green)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isAcceptPressed ? Color.green : Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .pressEvents {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isAcceptPressed = true
                                }
                            } onRelease: {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isAcceptPressed = false
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
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
        .onChange(of: showVideo) { newValue in
            if !newValue {
                isVisible = false
            }
        }
    }
}








struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text(content)
                .font(.body)
                .foregroundColor(.black)
        }
    }
}








struct PressActionsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActionsModifier(onPress: onPress, onRelease: onRelease))
    }
}


extension View {
    func hideHomeIndicator() -> some View {
        if #available(iOS 16.0, *) {
            return self.persistentSystemOverlays(.hidden)
        } else {
            return self
        }
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
