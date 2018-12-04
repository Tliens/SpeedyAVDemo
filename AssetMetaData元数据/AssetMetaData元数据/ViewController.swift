//
//  ViewController.swift
//  AssetMetaData元数据
//
//  Created by Quinn on 2018/11/18.
//  Copyright © 2018 Quinn. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    var imgV:UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imgV = UIImageView.init(frame: view.bounds)
        view.addSubview(imgV!)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        loadAssetMetaData()
    }
    func loadAssetMetaData(){
        let file = Bundle.main.path(forResource: "肖央,黄明志 - 不想上班", ofType: "mp3")
        let url = URL.init(fileURLWithPath: file!)
        let asset = AVAsset.init(url: url)
        
        //加载 asset 的元数据
        
        let formatsKey = "availableMetadataFormats"

        
        /*
         第一种
         Provides access to an array of AVMetadataItems for each common metadata key for which a value is available; items can be filtered according to language via +[AVMetadataItem metadataItemsFromArray:filteredAndSortedAccordingToPreferredLanguages:] and according to identifier via +[AVMetadataItem metadataItemsFromArray:filteredByIdentifier:].
         */
        
        if false{
            let metadata = asset.commonMetadata
            self.processMetaData(metadata)
        }else{
            //获取所有的元数据集合
            asset.loadValuesAsynchronously(forKeys: [formatsKey]) { [unowned self] in
                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: formatsKey, error: &error)
                if status == .loaded {
                    for format in asset.availableMetadataFormats {
                        let metadata = asset.metadata(forFormat: format)
                        self.processMetaData(metadata)
                    }
                }
            }
        }
        
        for characteristic in asset.availableMediaCharacteristicsWithMediaSelectionOptions {
            print("\(characteristic)")
            
            // Retrieve the AVMediaSelectionGroup for the specified characteristic.
            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) {
                // Print its options.
                for option in group.options {
                    print("  Option: \(option.displayName)")
                }
            }
            
            
            
        }
        
       
        
        /*
         第一种 log 信息如下：
         ==================== 4
         all0
         Optional(__C.AVMetadataKey(_rawValue: title)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TIT2))
         all1
         Optional(__C.AVMetadataKey(_rawValue: albumName)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TALB))
         all2
         Optional(__C.AVMetadataKey(_rawValue: artist)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TPE1))
         all3
         Optional(__C.AVMetadataKey(_rawValue: artwork)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/APIC))
         title
         Optional(__C.AVMetadataKey(_rawValue: title)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TIT2)) Optional("不想上班")

         */
        
        
        /*
         
          第二种 log 信息如下
         ==================== 7
         all0
         nil Optional(__C.AVMetadataIdentifier(_rawValue: id3/TSSE))
         all1
         Optional(__C.AVMetadataKey(_rawValue: artwork)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/APIC))
         all2
         Optional(__C.AVMetadataKey(_rawValue: albumName)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TALB))
         all3
         Optional(__C.AVMetadataKey(_rawValue: title)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TIT2))
         all4
         nil Optional(__C.AVMetadataIdentifier(_rawValue: id3/COMM))
         all5
         nil Optional(__C.AVMetadataIdentifier(_rawValue: id3/TPOS))
         all6
         Optional(__C.AVMetadataKey(_rawValue: artist)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TPE1))
         title
         Optional(__C.AVMetadataKey(_rawValue: title)) Optional(__C.AVMetadataIdentifier(_rawValue: id3/TIT2)) Optional("不想上班")

         */
        
        
        
        
        
        
    }

    
    
    func processMetaData(_ metadata:[AVMetadataItem]){
        
        print("====================",metadata.count)
        // process format-specific metadata collection
        //上文我们获取到多个 metadataitem
        
        //打印所有 item 信息
        for (i,item) in metadata.enumerated(){
            print("all\(i)\n",item.commonKey,item.identifier)
            
        }
        //下面对 metadataitem 进行过滤
        //获取特定 metaData
        
        //标题
        let titleID = AVMetadataIdentifier.commonIdentifierTitle
        let titleItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: titleID)
        
        if let item = titleItems.first {
            // process title item
            print("title\n",item.commonKey,item.identifier,item.stringValue)
        }
        
        //封面
        // Filter metadata to find the asset's artwork
        let artworkItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtwork)
        DispatchQueue.main.async {
            if let artworkItem = artworkItems.first {
                // Coerce the value to an NSData using its dataValue property
                if let imageData = artworkItem.dataValue {
                    let image = UIImage(data: imageData)
                    self.imgV?.image = image
                    // process image
                } else {
                    // No image data found
                }
            }
        }
    }

}

