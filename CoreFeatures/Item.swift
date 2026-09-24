//
//  Item.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
