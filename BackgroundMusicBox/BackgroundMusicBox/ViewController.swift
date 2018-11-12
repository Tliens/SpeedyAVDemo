//
//  ViewController.swift
//  BackgroundMusicBox
//
//  Created by Quinn on 2018/11/12.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import MediaPlayer


class ViewController: UIViewController {

    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    
    var music1:URL?
    var music2:URL?
    
    func configureMusicResource(){
        guard let path1 = Bundle.main.path(forResource: "邓超 - 超级英雄", ofType: "mp3") else {
            
            return
        }
        music1 = URL.init(fileURLWithPath: path1)
        
        
        guard let path2 = Bundle.main.path(forResource: "任素汐 - 我要你", ofType: "mp3") else {
            return
        }
        music2 = URL.init(fileURLWithPath: path2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMusicResource()
        configurePlayer()
        setupRemoteTransportControls()
        self.setupNowPlaying(title: "邓超 - 超级英雄", img: "1")
    }
    func configurePlayer(){
        playerItem = AVPlayerItem.init(url: music1!)
        player = AVPlayer.init(playerItem: playerItem)
        player?.play()
    }
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player?.rate == 0.0 {
                self.player?.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player?.rate == 1.0 {
                self.player?.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self](event) -> MPRemoteCommandHandlerStatus in
            self.playerItem? = AVPlayerItem.init(url: self.music2!)
            self.player?.replaceCurrentItem(with: self.playerItem)
            self.setupNowPlaying(title: "任素汐 - 我要你", img: "2")
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self](event) -> MPRemoteCommandHandlerStatus in
            self.playerItem? = AVPlayerItem.init(url: self.music1!)
            self.player?.replaceCurrentItem(with: self.playerItem)
            self.setupNowPlaying(title: "邓超 - 超级英雄", img: "1")
            return .success
        }
    }
    
    func setupNowPlaying(title:String,img:String) {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        if let image = UIImage(named: img) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

}

