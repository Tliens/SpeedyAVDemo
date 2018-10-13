import AVFoundation
/// 视频相关
extension ViewController{
    //视频拼接
    func setVideoAndExport(){
        guard let path = Bundle.main.path(forResource: "小苹果", ofType: "mp4") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let asset = AVAsset.init(url: url)
        let videoTracks = asset.tracks(withMediaType: .video)
        
        let firstVideoTrack = videoTracks.first
        
        guard let path1 = Bundle.main.path(forResource: "维多利亚2017", ofType: "mp4") else{
            return
        }
        let url1 = URL.init(fileURLWithPath: path1)
        let asset1 = AVAsset.init(url: url1)
        let videoTracks1 = asset1.tracks(withMediaType: .video)
        
        let firstVideoTrack1 = videoTracks1.first
        
        //视频
        videoComposition = AVMutableComposition.init()
        if let compositionVideoTrack = videoComposition!.addMutableTrack(withMediaType: .video, preferredTrackID: 0){
            if firstVideoTrack != nil{
                try? compositionVideoTrack.insertTimeRange(firstVideoTrack!.timeRange, of: firstVideoTrack!, at: .zero)
                try? compositionVideoTrack.insertTimeRange(firstVideoTrack1!.timeRange, of: firstVideoTrack1!, at: .zero)
                videoExportSession(asset: videoComposition!)
            }
        }
    }
    //导出
    func videoExportSession(asset:AVAsset){
        // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
        let presetNames = AVAssetExportSession.exportPresets(compatibleWith: asset)
        //设置 AVAssetExportPreset640x480等可选参数，会导致视频压缩，但还需研究VideoTool,进一步做压缩处理
        videoExport = AVAssetExportSession.init(asset: asset, presetName: presetNames.first ?? AVAssetExportPresetPassthrough)
        
        videoExport?.outputURL = getVideoExportURL()
        videoExport?.outputFileType = AVFileType.mp4
        videoExport?.exportAsynchronously(completionHandler: {[weak self]in
            print("video error",self?.videoExport?.error)
        })
    }
    //获取url
    func getVideoExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export_video" + ".mp4"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
    
}
