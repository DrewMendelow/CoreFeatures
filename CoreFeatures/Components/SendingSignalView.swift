//
//  SendingSignalView.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//
import SwiftUI

struct SendingSignalView: View {
    @State private var animate = false
    @State var size: CGFloat
    
    init(size: CGFloat) {
        self.size = size
    }

    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Image(systemName: "wifi")
                    .font(.system(size: size))
                    .opacity(animate ? 0 : 0.8)
                    .scaleEffect(animate ? 1.8 : 0.8)
                    .animation(
                        .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
