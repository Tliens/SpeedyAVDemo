//
//  ViewController.swift
//  AssetFormatChange视频格式转换
//
//  Created by Quinn on 2018/11/13.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        export()
    }
    
    func export(){
        
        guard let path = Bundle.main.path(forResource: "1", ofType: "mp4") else {
            return
        }
        let url = URL.init(fileURLWithPath: path)
        let anAsset = AVAsset.init(url: url)


        let outputURL = getVideoExportURL()
        
        let preset = AVAssetExportPresetHighestQuality
        let outFileType = AVFileType.mov
        
        print("确定兼容性")
        AVAssetExportSession.determineCompatibility(ofExportPreset: preset, with: anAsset, outputFileType: outFileType, completionHandler: { (isCompatible) in
            if !isCompatible {
                return
            }})
        print("可以兼容")

        guard let export = AVAssetExportSession(asset: anAsset, presetName: preset) else {
            return
        }
        
        export.outputFileType = outFileType
        export.outputURL = outputURL
        export.exportAsynchronously { () -> Void in
            // Handle export results.
            
            print("转换完成\(export.status.rawValue)")
        }
    }
    //获取url
    func getVideoExportURL()->URL{
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "Quinn_fromat_video" + ".mov"
        let url = path.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path){
            try? FileManager.default.removeItem(at: url)
        }
        print("quinn",url)
        return url
    }
 

}

