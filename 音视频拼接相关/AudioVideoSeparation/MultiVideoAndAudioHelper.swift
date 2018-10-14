
import AVFoundation
extension ViewController{
    //多音视频拼接
    func exportMultiAsset(){
        
        //video track
        //video asset1
        guard let path = Bundle.main.path(forResource: "小苹果", ofType: "mp4") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let asset = AVAsset.init(url: url)
        let videoTracks = asset.tracks(withMediaType: .video)
        let firstVideoTrack = videoTracks.first
        
        //video asset2
        guard let path1 = Bundle.main.path(forResource: "维多利亚2017", ofType: "mp4") else{
            return
        }
        let url1 = URL.init(fileURLWithPath: path1)
        let asset1 = AVAsset.init(url: url1)
        let videoTracks1 = asset1.tracks(withMediaType: .video)
        let firstVideoTrack1 = videoTracks1.first
        
        
        //audio track
        //audio asset1
        guard let path_audio = Bundle.main.path(forResource: "超级英雄", ofType: "mp3") else{
            return
        }
        let url_audio = URL.init(fileURLWithPath: path_audio)
        let asset_audio = AVAsset.init(url: url_audio)
        let audioTracks_audio = asset_audio.tracks(withMediaType: .audio)
        let firstAudioTrack_audio = audioTracks_audio.first
        //audio asset2
        guard let path_audio1 = Bundle.main.path(forResource: "我要你", ofType: "mp3") else{
            return
        }
        let url_audio1 = URL.init(fileURLWithPath: path_audio1)
        let asset_audio1 = AVAsset.init(url: url_audio1)
        let audioTracks_audio1 = asset_audio1.tracks(withMediaType: .audio)
        let firstAudioTrack_audio1 = audioTracks_audio1.first
        
        //保证总时长一致
        //视频
        mutableComposition = AVMutableComposition.init()
        let timeRange = CMTimeRange.init(start: CMTime.init(value: 0, timescale: 1), end: CMTime.init(value: 12, timescale: 1))

        if let compositionVideoTrack = mutableComposition!.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid){
            
            if firstVideoTrack != nil{
                try? compositionVideoTrack.insertTimeRange(timeRange, of: firstVideoTrack!, at: .zero)
                try? compositionVideoTrack.insertTimeRange(timeRange, of: firstVideoTrack1!, at: .zero)
            }
        }
        if let compositionAudioTrack = mutableComposition!.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid){
            try? compositionAudioTrack.insertTimeRange(timeRange, of: firstAudioTrack_audio!, at: .zero)
            try? compositionAudioTrack.insertTimeRange(timeRange, of: firstAudioTrack_audio1!, at: .zero)
        }
        mutableExportSession(asset: mutableComposition!)
    }
    //导出
    func mutableExportSession(asset:AVAsset){
        // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
        let presetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        //设置 AVAssetExportPreset640x480等可选参数，会导致视频压缩，但还需研究VideoTool,进一步做压缩处理
        mutableExport = AVAssetExportSession.init(asset: asset, presetName: presetNames.first ?? AVAssetExportPresetPassthrough)
        mutableExport?.outputURL = getMutableExportURL()
        if isSimulator(){
            mutableExport?.outputFileType = AVFileType.mov
        }else{
            mutableExport?.outputFileType = AVFileType.mp4
        }
        mutableExport?.exportAsynchronously(completionHandler: {[weak self]in
            print("mutable error",self?.mutableExport?.error)
        })
    }
    //获取url
    func getMutableExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export_mutable_video" + ".mp4"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
    
}
