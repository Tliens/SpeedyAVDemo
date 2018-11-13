//
//  ViewController.swift
//  PlaybackStateChanges播放状态改变的响应
//
//  Created by Quinn on 2018/11/13.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    let url: URL = URL.init(fileURLWithPath: Bundle.main.path(forResource: "1", ofType: "mp4")!) // Asset URL
    var asset: AVAsset!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    
    // Key-value observing context
    private var playerItemContext = 0
    var timeObserverToken: Any?

    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        prepareToPlay()
        player.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.pause()
    }
    
    func prepareToPlay() {
        // Create the asset to play
        asset = AVAsset(url: url)
        
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        playerItem = AVPlayerItem(asset: asset,
                                  automaticallyLoadedAssetKeys: requiredAssetKeys)
        
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem)
    }

    //间隔监听
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) {
                                                            [weak self] time in
                                                            // update player transport UI
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    //定期监听
    func addBoundaryTimeObserver() {
        
        // Divide the asset's duration into quarters.
        let interval = CMTimeMultiplyByFloat64(asset.duration, multiplier: 0.25)
        var currentTime = CMTime.zero
        var times = [NSValue]()
        
        // Calculate boundary times
        while currentTime < asset.duration {
            currentTime = currentTime + interval
            times.append(NSValue(time:currentTime))
        }
        
        timeObserverToken = player.addBoundaryTimeObserver(forTimes: times,
                                                           queue: .main) {
                                                            // Update UI
        }
    }
    func removeBoundaryTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    //快速跳转
    // Seek to the 2 minute mark
    //let time = CMTime(value: 120, timescale: 1)
    //player.seek(to: time)
    
    //精准跳转
    // Seek to the first frame at 3:25 mark

    //let seekTime = CMTime(seconds: 205, preferredTimescale: Int32(NSEC_PER_SEC))
    //player.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    //调用具有小值或零值容差的方法可能会导致额外的解码延迟，这可能会影响应用程序的搜索行为。seek(to:toleranceBefore:toleranceAfter:)
}

extension ViewController{
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        print("observeValue")

        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
            // Player item is ready to play.
                print("readyToPlay")
                break
            case .failed:
            // Player item failed. See error.
                print("failed")

                break
            case .unknown:
                // Player item is not yet ready.
                print("unknown")

                break
            }
        }
    }
}
