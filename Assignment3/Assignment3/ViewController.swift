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
    // Additional play button added for fun per discussion on canvas
    // I thought the song might get annoying after a while when testing the "step" functionality so I separated it into another button.
    @IBAction func playButtonAction(_ sender: Any) {
        playMySong()
    }
    
    // Function to play music clip, "Texas Two Step"
    // The clip is only a few seconds long. I thought adding the entire song would have been excessive... :)
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

