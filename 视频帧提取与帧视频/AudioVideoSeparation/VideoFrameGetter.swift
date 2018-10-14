
import AVFoundation
import UIKit
extension ViewController{
    func initAssetAndGeneratorImgs(){
        guard let path = Bundle.main.path(forResource: "小苹果", ofType: "mp4") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let asset = AVAsset.init(url: url)
        
        let assetImageGenerator = AVAssetImageGenerator.init(asset: asset)
        
        //精准度
        assetImageGenerator.requestedTimeToleranceAfter = .zero
        assetImageGenerator.requestedTimeToleranceBefore = .zero
        assetImageGenerator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        
        //最大尺寸
        assetImageGenerator.maximumSize = CGSize.init(width: 300, height: 300)
        for i in 0...60 {
            assetImageGenerator.generateCGImagesAsynchronously(forTimes: [CMTimeMakeWithSeconds(Float64(1*i), preferredTimescale: Int32(NSEC_PER_SEC)) as NSValue]) { (times, cgImg, time, result, error) in
                if let _cgImg = cgImg {
                    let image = UIImage.init(cgImage: _cgImg)
                    let data = UIImage.pngData(image)
                    let path = "/Users/quinn/Documents/GitHub/Learn_AVFoundation/视频帧提取与帧视频/AudioVideoSeparation/SaveImages"
                    let url = URL.init(fileURLWithPath: path)
                    let imagUrl = url.appendingPathComponent("SaveImages\(CFAbsoluteTimeGetCurrent()).png")
                    print(path)
                    do {
                        try data()?.write(to: imagUrl)
                    }catch{
                        print(error)
                    }
                }
            }
        }
        
        
        
    }
}
