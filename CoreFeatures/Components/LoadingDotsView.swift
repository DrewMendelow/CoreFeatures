//
//  LoadingDotsView.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import SwiftUI
internal import Combine

struct LoadingDotsView: View {
    @State private var dotCount = 0
    // A timer that ticks every half second on the main thread
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(String(repeating: ".", count: dotCount))
            .font(.title) // Keeps the font size consistent with your title
            .bold()
            .onReceive(timer) { _ in
                // Cycle through 1, 2, and 3 dots continuously
                dotCount = (dotCount % 3) + 1
            }
            .frame(width: 30, alignment: .leading) // Keeps layout stable as dots add up
    }
}
