import AVFoundation

extension ViewController{
    //音频拼接
    func setAudioAndExport(){
        
        guard let path = Bundle.main.path(forResource: "超级英雄", ofType: "mp3") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let asset = AVAsset.init(url: url)
        let audioTracks = asset.tracks(withMediaType: .audio)
        let firstAudioTrack = audioTracks.first
        
        guard let path1 = Bundle.main.path(forResource: "我要你", ofType: "mp3") else{
            return
        }
        let url1 = URL.init(fileURLWithPath: path1)
        let asset1 = AVAsset.init(url: url1)
        let audioTracks1 = asset1.tracks(withMediaType: .audio)
        
        let firstAudioTrack1 = audioTracks1.first
        //音频
        audioComposition = AVMutableComposition.init()
        if let compositionAudioTrack = audioComposition?.addMutableTrack(withMediaType: .audio, preferredTrackID: 0){
            try? compositionAudioTrack.insertTimeRanges([firstAudioTrack!.timeRange as NSValue,firstAudioTrack!.timeRange as NSValue], of: [firstAudioTrack1!,firstAudioTrack!], at: .zero)
            audioExportSession(asset: audioComposition!)
        }
        
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
        if isSimulator() {
            audioExport?.outputFileType = AVFileType.mov
        }else{
            audioExport?.outputFileType = AVFileType.m4a
        }
        audioExport?.shouldOptimizeForNetworkUse = true
        audioExport?.exportAsynchronously(completionHandler: {[weak self]in
            print("audio error",self?.audioExport?.error)
        })
    }
    //获取url
    func getAudioExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_export_audio" + ".m4a"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
}

func isSimulator() -> Bool {
    var isSim = false
    #if arch(i386) || arch(x86_64)
    isSim = true
    #endif
    return isSim
}
