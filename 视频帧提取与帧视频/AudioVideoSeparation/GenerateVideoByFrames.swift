
import AVFoundation
import UIKit
extension ViewController{
    
    func generateVideo(){
        let assetWriter = try? AVAssetWriter.init(outputURL: getVideoExportURL(), fileType: AVFileType.mov)
        
        let outputSetting = [AVVideoCodecKey:AVVideoCodecType.h264,AVVideoWidthKey:300,AVVideoHeightKey:300] as [String : Any]
        
        let videoWriteInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: outputSetting)
        
        let sourcePixelBufferAttrubutes = [kCVPixelBufferPixelFormatTypeKey:kCVPixelFormatType_32RGBA]
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: videoWriteInput, sourcePixelBufferAttributes: sourcePixelBufferAttrubutes as [String : Any])
        if assetWriter?.canAdd(videoWriteInput) == true{
            assetWriter?.add(videoWriteInput)
            assetWriter?.startWriting()
            assetWriter?.startSession(atSourceTime: .zero)
        }
        
        let path = "/Users/quinn/Documents/GitHub/Learn_AVFoundation/视频帧提取与帧视频/AudioVideoSeparation/SaveImages"
        
        let paths = findFiles(path: path, filterTypes: ["png"])
        var images:[UIImage] = []

        for i in paths{
            print("i path ···",i)
            if let img = UIImage.init(contentsOfFile: path+"/"+i){
                images.append(img)
            }
        }
        
        var index = 0
        videoWriteInput.requestMediaDataWhenReady(on: DispatchQueue.init(label: "video generator")) {
            while videoWriteInput.isReadyForMoreMediaData{
                index = index + 1
                if index >= images.count*30{
                    videoWriteInput.markAsFinished()
                    assetWriter?.finishWriting(completionHandler: {
                        DispatchQueue.main.async {
                            print("had finished")
                        }
                    })
                    break
                }
                let idx = index/30
                print("idx",idx)
                let img = images[idx]
                let pixelBuffer = img.pixelBuffer(width: 300, height: 300)
                if let _pixelBuffer = pixelBuffer{
                    let time = CMTime.init(value: CMTimeValue(index), timescale: 30);
                    if adaptor.append(_pixelBuffer, withPresentationTime: time){
                        print("ok",index)
                    }else{
                        print("failed",index)
                    }
                }
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
        let fileName = "Quinn_images_video" + ".mp4"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
}
func findFiles(path: String, filterTypes: [String]) -> [String] {
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        if filterTypes.count == 0 {
            return files
        }
        else {
            let filteredfiles = NSArray(array: files).pathsMatchingExtensions(filterTypes)
            return filteredfiles
        }
    }
    catch {
        return []
    }
}

