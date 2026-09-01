//
//  StoreCategory.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation
import SwiftUI

struct StoreCategory: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var itemIDs: [UUID] = []
    var isCatchAll: Bool = false
    var colorIndex: Int = 0   // Index in Theme.categoryPalette — an der Kategorie
                               // festgemacht, nicht an ihrer Position im Array.

    /// Die tatsächliche Farbe dieser Kategorie. Modulo gegen die Palettengröße,
    /// damit ein späteres Ändern der Palettenlänge nie zu einem Index-Crash
    /// führt — schlimmstenfalls wiederholen sich Farben, statt dass es abstürzt.
    var color: Color {
        guard !Theme.categoryPalette.isEmpty else { return Theme.sublabel }
        let safeIndex = ((colorIndex % Theme.categoryPalette.count) + Theme.categoryPalette.count) % Theme.categoryPalette.count
        return Theme.categoryPalette[safeIndex]
    }

    enum CodingKeys: String, CodingKey {
        case id, name, icon, itemIDs, isCatchAll, colorIndex
    }

    init(id: UUID = UUID(), name: String, icon: String, itemIDs: [UUID] = [],
         isCatchAll: Bool = false, colorIndex: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.itemIDs = itemIDs
        self.isCatchAll = isCatchAll
        self.colorIndex = colorIndex
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        icon = try c.decode(String.self, forKey: .icon)
        itemIDs = try c.decodeIfPresent([UUID].self, forKey: .itemIDs) ?? []
        isCatchAll = try c.decodeIfPresent(Bool.self, forKey: .isCatchAll) ?? false

        // Alte, vor diesem Update gespeicherte Kategorien haben kein colorIndex.
        // Statt hart auf 0 zu fallen (wodurch plötzlich alle dieselbe Farbe
        // hätten), wird ein stabiler, vom Namen abgeleiteter Index vergeben —
        // dieselbe Kategorie bekommt so bei jedem App-Start dieselbe Farbe,
        // auch bevor sie einmal neu gespeichert wurde.
        if let stored = try c.decodeIfPresent(Int.self, forKey: .colorIndex) {
            colorIndex = stored
        } else {
            colorIndex = abs(name.hashValue) % max(Theme.categoryPalette.count, 1)
        }
    }
}

extension StoreCategory {
    static let defaults: [StoreCategory] = [
        StoreCategory(name: "Obst & Gemüse",       icon: "leaf",                      colorIndex: 0),
        StoreCategory(name: "Brot & Backwaren",    icon: "birthday.cake",             colorIndex: 1),
        StoreCategory(name: "Musli",               icon: "person.2.fill",             colorIndex: 2),
        StoreCategory(name: "Backzeug",             icon: "drop",                      colorIndex: 3),
        StoreCategory(name: "Nudeln",               icon: "drop",                      colorIndex: 4),
        StoreCategory(name: "Konserven & Trocken",  icon: "shippingbox",               colorIndex: 5),
        StoreCategory(name: "Saucen",                icon: "shippingbox",               colorIndex: 6),
        StoreCategory(name: "Süßigkeiten",           icon: "shippingbox",               colorIndex: 7),
        StoreCategory(name: "Molkerei",              icon: "shippingbox",               colorIndex: 8),
        StoreCategory(name: "Fleisch & Fisch",       icon: "fork.knife",                colorIndex: 9),
        StoreCategory(name: "Gewürze",               icon: "fork.knife",                colorIndex: 10),
        StoreCategory(name: "Tiefkühl",              icon: "snowflake",                 colorIndex: 11),
        StoreCategory(name: "Haushalt & Pflege",     icon: "bubbles.and.sparkles",      colorIndex: 12),
        StoreCategory(name: "Getränke",              icon: "wineglass",                 colorIndex: 13),
        StoreCategory(name: "Sonstiges",             icon: "ellipsis.circle",
                      isCatchAll: true,               colorIndex: 14),
    ]
}
