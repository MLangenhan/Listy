//
//  Market.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation

struct Market: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String                      // "REWE Mitte", "Edeka am Bahnhof"
    var chainID: UUID
    var customCategories: [StoreCategory]? // nil = Ketten-Default verwenden
}
