//
//  ViewController.swift
//  AudioVideoSeparation
//
//  Created by Quinn on 2018/10/13.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var playerItem :AVPlayerItem?
    var player:AVPlayer?
    var playerlayer:AVPlayerLayer?
    var videoExport:AVAssetExportSession?
    var audioExport:AVAssetExportSession?
    var mutableExport:AVAssetExportSession?

    var audioComposition:AVMutableComposition?
    var videoComposition:AVMutableComposition?
    var mutableComposition:AVMutableComposition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        initAsset()
    }
    
    
}
extension ViewController{
    
    func initAsset(){
        //先提取视频帧,再用视频帧合成视频
//        initAssetAndGeneratorImgs()
//        generateVideo()
    }
}
//播放资源
extension ViewController{
    func play(asset:AVAsset){
        playerItem = AVPlayerItem.init(asset: asset)
        
        player = AVPlayer.init(playerItem: playerItem)
        
        playerlayer = AVPlayerLayer.init(player: player!)
        playerlayer?.frame = view.bounds
        self.view.layer.addSublayer(playerlayer!)
        player?.play()
    }
}

extension ViewController{
    //公共函数
    //设置裁剪参数
    func getTimeRange(asset:AVAsset)->CMTimeRange{
        print(asset.duration.timescale)
        let start = CMTimeMake(value: Int64(asset.duration.timescale * 10), timescale: asset.duration.timescale)
        let end = CMTimeMake(value: Int64(asset.duration.timescale * 30), timescale: asset.duration.timescale)
        let range = CMTimeRange.init(start: start, end: end)
        return range
    }
}
