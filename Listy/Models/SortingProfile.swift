//
//  SortingProfile.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation

enum SortingMode: Codable {
    case auto       // KI-artige Kategorie-Zuordnung
    case custom     // User hat manuell umsortiert
}

struct SortingProfile: Codable {
    var mode: SortingMode = .auto
    var selectedMarketID: UUID?
    var categories: [StoreCategory] = []  // aktive, geordnete Kategorien mit zugeordneten itemIDs
}
