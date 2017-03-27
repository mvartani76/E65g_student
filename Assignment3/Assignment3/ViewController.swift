//
//  ViewController.swift
//  Assignment3
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var stepButton: UIButton!
    @IBOutlet weak var GridView: GridView!
    @IBOutlet weak var playButton: UIButton!
    
    var buttonSong: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func stepButtonAction(_ sender: Any) {

        GridView.drawGrid = GridView.drawGrid.next()
        GridView.setNeedsDisplay()
        
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        playMySong()
    }
    
    // Function to play music clip
    func playMySong() {
        let path = Bundle.main.path(forResource: "TexasTwoStep.aif", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            buttonSong = sound
            sound.play()
        } catch {
            print("AVAudioPlayer error \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully
        flag: Bool) {
    }

}

