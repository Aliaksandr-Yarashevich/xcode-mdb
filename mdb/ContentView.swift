//
//  ContentView.swift
//  mdb
//
//  Created by Aliaksandr Yarashevich on 17/03/2025.
//

import SwiftUI
import MetalKit

struct ContentView: UIViewRepresentable {
    var mtkView: MTKView!
    @Binding var zoom: Float
    @Binding var center: SIMD2<Float>
    @Binding var depth: Float
    
    func makeCoordinator() -> MandelbrotRenderer {
        MandelbrotRenderer(self, center: center, depth: depth)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice(){
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
    
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<ContentView>) {
//        print("in updateUIView")
        context.coordinator.moveCenter(center: self.center)
        context.coordinator.changeZoom(zoom: self.zoom)
        context.coordinator.changeDepth(depth: self.depth)
    }

}
