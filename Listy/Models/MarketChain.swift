//
//  MarketChain.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation

struct MarketChain: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String                          // "REWE", "EDEKA", …
    var categoryOrder: [StoreCategory]        // Default-Reihenfolge der Kette
}

extension MarketChain {
    // Ein paar vordefinierte Ketten
    static let presets: [MarketChain] = [
        MarketChain(name: "REWE",    categoryOrder: StoreCategory.defaults),
        MarketChain(name: "EDEKA",   categoryOrder: StoreCategory.defaults),
        MarketChain(name: "Lidl",    categoryOrder: {
            // Lidl: Tiefkühl früher
            var cats = StoreCategory.defaults
            let ti = cats.remove(at: 4)
            cats.insert(ti, at: 1)
            return cats
        }()),
        MarketChain(name: "Aldi",    categoryOrder: StoreCategory.defaults),
        MarketChain(name: "Kaufland", categoryOrder: StoreCategory.defaults),
        MarketChain(name: "Penny",   categoryOrder: StoreCategory.defaults),
        MarketChain(name: "Sonstige", categoryOrder: StoreCategory.defaults),
    ]
}
