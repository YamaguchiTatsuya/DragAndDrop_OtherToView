//
//  DestinationView.swift
//  DragAndDrop_OtherToView
//
//  Created by TATSUYA YAMAGUCHI on 2020/02/07.
//  Copyright © 2020 TATSUYA YAMAGUCHI. All rights reserved.
//

import Cocoa
import AVFoundation

class DestinationView: NSView {
    
    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:
        [NSPasteboard.PasteboardType.png, AVFileType.jpg]] //AVFileType.mov

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
    
        registerForDraggedTypes([.fileURL])
    }
    
    private func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
    }
    
    //MARK: - NSDraggingDestination protocol
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        // called when grab and mouseover on the view
        
        let allow = shouldAllowDrag(sender)

        return allow ? .copy : NSDragOperation()
    }
    
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // called when you drop
        
        return shouldAllowDrag(sender)
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {

        let pasteBoard = draggingInfo.draggingPasteboard
        
        let point = convert(draggingInfo.draggingLocation, from: nil)
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {

            processImageURLs(urls, center: point)
        }
        
        return true
    }
    
    //MARK: - draw dropped images
    
    private func processImageURLs(_ urls: [URL], center: NSPoint) {
        
        for (index,url) in urls.enumerated() {

            if let image = NSImage(contentsOf:url) {
                
                let newCenter = NSPoint(x: center.x+CGFloat(200*index),
                                        y: center.y)
                
                processImage(image, center:newCenter)
            }
        }
    }
    
    private func processImage(_ image: NSImage, center: NSPoint) {

        let constrainedSize = image.aspectFitSizeForMaxDimension(150.0)
        
        let imageView = NSImageView(image: image)
        imageView.frame = NSRect(x: center.x - constrainedSize.width/2, y: center.y - constrainedSize.height/2, width: constrainedSize.width, height: constrainedSize.height)
        self.addSubview(imageView)
    }
}

//MARK: - extension

extension NSImage {
    
    func aspectFitSizeForMaxDimension(_ maxDimension: CGFloat) -> NSSize {
        
        var width =  size.width
        var height = size.height
        if size.width > maxDimension || size.height > maxDimension {
            let aspectRatio = size.width/size.height
            width = aspectRatio > 0 ? maxDimension : maxDimension*aspectRatio
            height = aspectRatio < 0 ? maxDimension : maxDimension/aspectRatio
        }
        
        return NSSize(width: width, height: height)
    }
}
