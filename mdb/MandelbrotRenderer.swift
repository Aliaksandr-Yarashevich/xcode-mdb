import MetalKit
import SwiftUI

class MandelbrotRenderer: NSObject, MTKViewDelegate {
    var parent: ContentView
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var computePipeline: MTLComputePipelineState!

    var viewportSize = SIMD2<Float>(800, 600)
    var center = SIMD2<Float>(-0.5, 0.0)
    var zoom: Float = 300.0
    var depth: Int

    init(_ parent: ContentView, center: SIMD2<Float>, depth: Float) {
        self.parent = parent
        self.depth = Int(depth)
        
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        self.commandQueue = device.makeCommandQueue()

        let library = device?.makeDefaultLibrary()
        let kernelFunction = library?.makeFunction(name: "mandelbrot")
        computePipeline = try! device?.makeComputePipelineState(function: kernelFunction!)
        
        super.init()
    }

    func draw(in view: MTKView) {
//        print("in draw)")
        
        guard let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }

        let texture = drawable.texture
        computeEncoder.setTexture(texture, index: 0)
        computeEncoder.setComputePipelineState(computePipeline)

        let viewportSizeBuffer = device.makeBuffer(bytes: &viewportSize, length: MemoryLayout<SIMD2<Float>>.size, options: [])
        let centerBuffer = device.makeBuffer(bytes: &center, length: MemoryLayout<SIMD2<Float>>.size, options: [])
        let zoomBuffer = device.makeBuffer(bytes: &zoom, length: MemoryLayout<Float>.size, options: [])
        let depthBuffer = device.makeBuffer(bytes: &depth, length: MemoryLayout<Int>.size, options: [])

        computeEncoder.setBuffer(viewportSizeBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(centerBuffer, offset: 0, index: 2)
        computeEncoder.setBuffer(zoomBuffer, offset: 0, index: 3)
        computeEncoder.setBuffer(depthBuffer, offset: 0, index: 4)

        let threadGroupSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadGroups = MTLSize(width: (Int(viewportSize.x) + 15) / 16,
                                   height: (Int(viewportSize.y) + 15) / 16,
                                   depth: 1)
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        computeEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func moveCenter(center: SIMD2<Float>) {
        self.center = center
    }
    
    func changeZoom(zoom: Float) {
        self.zoom = zoom
    }
    
    func changeDepth(depth: Float) {
        self.depth = Int(depth)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = SIMD2<Float>(Float(size.width), Float(size.height))
    }
}
