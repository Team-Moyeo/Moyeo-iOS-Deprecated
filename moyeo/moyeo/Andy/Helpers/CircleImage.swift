/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that clips an image to a circle and adds a stroke and shadow.
*/

import SwiftUI

struct CircleImage: View {
    var image: Image?
    @State var frameSize : CGFloat = 50
    var body: some View {
        if let image = image {
            image
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .overlay {
                    Circle().stroke(.white, lineWidth: 2)
                }
                .frame(width: frameSize, height: frameSize)
              
        } else {
            Circle()
                .fill(Color.gray)
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 2)
                }
                .frame(width: frameSize, height: frameSize)
             
        }
    }
}

#Preview {
    CircleImage(image: Image("FiveTechDong"))
}
