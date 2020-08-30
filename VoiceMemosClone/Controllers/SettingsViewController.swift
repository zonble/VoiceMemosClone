//
//  SettingsViewController.swift
//  VoiceMemosClone
//
//  Created by zonble on 8/30/20.
//  Copyright © 2020 Hassan El Desouky. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension AVAudioSession.Mode {
    var title: String? {
        switch self {
        case .default:
            return "Default"
        case .voiceChat:
            return "Voice Chat"
        case .videoChat:
            return "Video Chat"
        case .videoRecording:
            return "Video Recording"
        case .measurement:
            return "Measurement"
        case .moviePlayback:
            return "Movie Playback"
        case .spokenAudio:
            return "Spoken Audio"
        case .voicePrompt:
            return "Voice Prompt"
        case .gameChat:
            return "Game Chat"
        default:
            return ""
        }
    }
}

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.title = "Settings"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Audio Mode"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AVAudioSession.sharedInstance().availableModes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let mode = AVAudioSession.sharedInstance().availableModes[indexPath.row]
        cell.textLabel?.text = mode.title
        let isCurrentMode = mode == Settings.shared.currentMode
        cell.accessoryType = isCurrentMode ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mode = AVAudioSession.sharedInstance().availableModes[indexPath.row]
        Settings.shared.currentMode = mode
        tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) {
            tableView.reloadData()
        }
    }
}
