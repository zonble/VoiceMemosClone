//
//  RecordingsViewController.swift
//  VoiceMemosClone
//
//  Created by Hassan El Desouky on 1/12/19.
//  Copyright © 2019 Hassan El Desouky. All rights reserved.
//

let cellid = "cell"

import UIKit
import AVFoundation

struct Recording {
    var name: String
    var path: URL
}

protocol RecordingsViewControllerDelegate: class {
    func didStartPlayback()
    func didFinishPlayback()
}

class RecordingsViewController: UIViewController {
    
    //MARK:- Properties
    private var recordings: [Recording] = []
    private var audioPlayer: AVAudioPlayer?
    weak var delegate: RecordingsViewControllerDelegate?

    //MARK:- Outlets
    @IBOutlet var fadeView: UIView!
    @IBOutlet var tableView: UITableView!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRecordings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isPlaying() {
            self.stopPlay()
        }
        super.viewWillDisappear(animated)
    }
    
    //MARK:- Setup Methods
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 180, right: 0)
    }

    // MARK:- Data
    func loadRecordings() {
        self.recordings.removeAll()
        let filemanager = FileManager.default
        let documentsDirectory = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let paths = try filemanager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            for path in paths.sorted(by: { a, b  in
                return a.absoluteString > b.absoluteString
            }) {
                let recording = Recording(name: path.lastPathComponent, path: path)
                self.recordings.append(recording)
            }
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    // MARK:- Playback
    private func play(url: URL) {
        if let d = self.delegate {
            d.didStartPlayback()
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord,
                                    mode: Settings.shared.currentMode,
                                    options: Settings.shared.desiredOptions)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.caf.rawValue)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        if let player = self.audioPlayer {
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        }
    }
    
    func stopPlay() {
        if let d = self.delegate {
            d.didFinishPlayback()
        }
        if let paths = self.tableView.indexPathsForSelectedRows {
            for path in paths {
                self.tableView.deselectRow(at: path, animated: true)
            }
        }
        if let player = self.audioPlayer {
            player.pause()
        }
        self.audioPlayer = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch  let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    private func isPlaying() -> Bool {
        if let player = self.audioPlayer {
            return player.isPlaying
        }
        return false
    }
}

extension RecordingsViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print(e.localizedDescription)
        }
        self.stopPlay()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stopPlay()
    }
}

extension RecordingsViewController: UITableViewDelegate, UITableViewDataSource {


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.numberOfLines = 0
        let route = AVAudioSession.sharedInstance().currentRoute
        let input = "[" + route.inputs.map { $0.portName }.joined(separator: ", ") + "]"
        let output = "[" + route.outputs.map { $0.portName }.joined(separator: ", ") + "]"
        let style = NSMutableParagraphStyle()
        style.headIndent = 10.0
        style.firstLineHeadIndent = 10.0
//        style.tailIndent = 10.0
        label.attributedText =
            NSAttributedString(string: "Input: \(input)\nOutput:\(output)",
                attributes: [.paragraphStyle: style])
        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isPlaying() {
            self.stopPlay()
        }
        let recording = self.recordings[indexPath.row]
        self.play(url: recording.path)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = self.recordings.count
//        if result > 0 {
//            self.tableView.isHidden = false
//        }
//        else {
//            self.tableView.isHidden = true
//        }
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        }
        let recording = self.recordings[indexPath.row]
        cell?.textLabel?.text = recording.name
        cell?.detailTextLabel?.text = recording.path.absoluteString
        cell?.accessoryType = .detailButton
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let filemanager = FileManager.default
            let recording = self.recordings[indexPath.row]
            do {
                try filemanager.removeItem(at: recording.path)
                self.recordings.remove(at: indexPath.row)
                self.tableView.reloadData()
            } catch(let err){
                print("Error while deleteing \(err)")
            }
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let recording = self.recordings[indexPath.row]
        let path = recording.path
        let controller = UIActivityViewController(activityItems: [path], applicationActivities: [])
        self.present(controller, animated: true, completion: nil)
    }
}
