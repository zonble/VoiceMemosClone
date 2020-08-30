import Foundation
import AVFoundation

class Settings {
    static let shared = Settings()

    var currentMode: AVAudioSession.Mode {
        get {
            let index = UserDefaults.standard.integer(forKey: "current_mode")
            return AVAudioSession.sharedInstance().availableModes[index]
        }
        set {
            let index = AVAudioSession.sharedInstance().availableModes.firstIndex(of: newValue)
            UserDefaults.standard.set(index, forKey: "current_mode")
        }
    }

    var desiredOptions: AVAudioSession.CategoryOptions {
        return [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
    }
}
