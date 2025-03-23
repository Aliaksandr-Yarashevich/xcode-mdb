import SwiftUI

struct TopView: View {
    
    @State private var zoom: Float = 300.0
    @State private var center: SIMD2<Float> = SIMD2<Float>(-0.5, 0.0)
    @State private var depth: Float = 50
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ContentView(zoom: $zoom, center: $center, depth: $depth) // Metal rendering
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
//                            print("in topview, ", gesture.velocity.width, gesture.velocity.height)
                            self.center.x -= Float(gesture.velocity.width) / 100 / pow(zoom, 0.95)
                            self.center.y -= Float(gesture.velocity.height) / 100 / pow(zoom, 0.95)
                            
                        }
                    )
                .gesture(
                    MagnificationGesture()
                        .onChanged { gesture in
                            let scale = Float(gesture.magnitude)
//                            print(scale)
                            self.zoom *= pow(scale, 0.1)
                        }
                )
//                .onReceive(timer) { time in
//                    self.zoom *= 1 + (300 - self.zoom) * 0.00001
//                }
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text(zoom.description) // Overlay text
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .shadow(radius: 5)
                    .padding()

                Spacer()
                Slider(value: $depth, in:1...200, step: 1)
            }
        }
    }
}
