//
//  TiledView.swift
//  PDFReader
//
//  Created by ALUA KINZHEBAYEVA on 4/22/15.
//  Copyright (c) 2015 AK. All rights reserved.
//

import UIKit
import QuartzCore

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

/// Tiled representation of a portion of a rendered pdf page
internal final class TiledView: UIView {
    /// Page of the PDF to be tiled
    private var leftPdfPage: CGPDFPage?
    
    /// Current PDF scale
    private let myScale: CGFloat
   
    /// Initializes a fresh tiled view
    ///
    /// - parameter frame:   desired frame of the tiled view
    /// - parameter scale:   scale factor
    /// - parameter newPage: new page representation
    init(frame: CGRect, scale: CGFloat, newPage: CGPDFPage) {
        myScale = scale
        leftPdfPage = newPage
        super.init(frame: frame)
        
        // levelsOfDetail and levelsOfDetailBias determine how the layer is
        // rendered at different zoom levels. This only matters while the view 
        // is zooming, because once the the view is done zooming a new TiledPDFView
        // is created at the correct size and scale.
        let tiledLayer = self.layer as? CATiledLayer
        tiledLayer?.levelsOfDetail = 16
        tiledLayer?.levelsOfDetailBias = 15
        tiledLayer?.tileSize = CGSize(width: 1024, height: 1024)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass : AnyClass {
        return CATiledLayer.self
    }
    
    // Draw the CGPDFPage into the layer at the correct scale.
    override func draw(_ layer: CALayer, in con: CGContext) {
        guard let leftPdfPage = leftPdfPage else { return }
        
        // Fill the background with white.
        con.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        con.fill(layer.bounds)
    
        con.saveGState()
        
        // Flip the context so that the PDF page is rendered right side up.
        con.translateBy(x: 0.0, y: layer.bounds.height)
        con.scaleBy(x: 1.0, y: -1.0)
        let transform = leftPdfPage.getDrawingTransform(CGPDFBox.mediaBox, rect: layer.bounds, rotate: 0, preserveAspectRatio: true)
        con.concatenate(transform)
        
        con.drawPDFPage(leftPdfPage)
        con.restoreGState()
    }
    
    // Stops drawLayer
    deinit {
        leftPdfPage = nil
        layer.contents = nil
        layer.delegate = nil
        layer.removeFromSuperlayer()
    }
}
