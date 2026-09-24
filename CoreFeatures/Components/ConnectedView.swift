//
//  SendingSignalView.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import SwiftUI

struct ConnectedView: View {
    @State private var animate = false
    @State var size: CGFloat

    init(size: CGFloat) {
        self.size = size
    }

    var body: some View {
        Image(systemName: "link.circle.fill")
            .font(.system(size: size))
            .scaleEffect(animate ? 1.08 : 1.0)
            .opacity(animate ? 0.7 : 1.0)
            .animation(
                .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}
