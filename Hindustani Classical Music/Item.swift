//
//  Item.swift
//  Hindustani Classical Music
//
//  Created by user291866 on 3/21/26.
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
