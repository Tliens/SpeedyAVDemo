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
//        guard let path = Bundle.main.path(forResource: "小苹果", ofType: "mp4") else{
//            return
//        }
        guard let path = Bundle.main.path(forResource: "34", ofType: "MP4") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let asset = AVAsset.init(url: url)
        play(asset: asset)
        let videoTracks = asset.tracks(withMediaType: .video)
        let audioTracks = asset.tracks(withMediaType: .audio)

        let firstVideoTrack = videoTracks.first
        let firstAudioTrack = audioTracks.first

        //视频
        let videocomposition = AVMutableComposition.init()
        if let compositionVideoTrack = videocomposition.addMutableTrack(withMediaType: .video, preferredTrackID: 0){
            if firstVideoTrack != nil{
                try? compositionVideoTrack.insertTimeRange(firstVideoTrack!.timeRange, of: firstVideoTrack!, at: .zero)
                videoExportSession(asset: videocomposition)
            }
        }
        
        //音频
        let audiocomposition = AVMutableComposition.init()
        if let compositionAudioTrack = audiocomposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0){
            if firstAudioTrack != nil{
                try? compositionAudioTrack.insertTimeRange(firstAudioTrack!.timeRange, of: firstAudioTrack!, at: .zero)
                audioExportSession(asset: audiocomposition)
            }
        }
        
    }
    
    
}
//播放视频
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
    //导出
    func audioExportSession(asset:AVAsset){
        // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
        let presetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        if presetNames.contains(AVAssetExportPresetAppleM4A) {
            audioExport = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetAppleM4A)

        }else{
            audioExport = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetPassthrough)
        }
        audioExport?.outputURL = getAudioExportURL()
        audioExport?.outputFileType = AVFileType.m4a
//        audioExport?.timeRange = getTimeRange(asset:asset)
        audioExport?.shouldOptimizeForNetworkUse = true
        audioExport?.exportAsynchronously(completionHandler: {[weak self]in
            print(self?.audioExport?.error)
        })
    }
    //获取url
    func getAudioExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export" + ".m4a"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
}
/// 视频相关
extension ViewController{
    //导出
    func videoExportSession(asset:AVAsset){
        // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
        let presetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        //设置 AVAssetExportPreset640x480等可选参数，会导致视频压缩，但还需研究VideoTool,进一步做压缩处理
        videoExport = AVAssetExportSession.init(asset: asset, presetName: presetNames.first ?? AVAssetExportPresetPassthrough)
        
        videoExport?.outputURL = getVideoExportURL()
        videoExport?.outputFileType = AVFileType.mp4
        videoExport?.timeRange = getTimeRange(asset:asset)
        videoExport?.exportAsynchronously(completionHandler: {[weak self]in
            print(self?.audioExport?.error)
        })
    }
    //获取url
    func getVideoExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export" + ".mp4"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
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
