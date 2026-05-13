//
//  StoreCategory.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation

struct StoreCategory: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String          // SF Symbol
    var itemIDs: [UUID] = []  // geordnete Item-IDs innerhalb der Kategorie
}

// Standard-Kategorien für jede Kette
extension StoreCategory {
    static let defaults: [StoreCategory] = [
        StoreCategory(name: "Obst & Gemüse",      icon: "leaf"),
        StoreCategory(name: "Brot & Backwaren",   icon: "birthday.cake"),
        StoreCategory(name: "Molkerei & Eier",    icon: "drop"),
        StoreCategory(name: "Fleisch & Fisch",    icon: "fork.knife"),
        StoreCategory(name: "Tiefkühl",           icon: "snowflake"),
        StoreCategory(name: "Konserven & Trocken",icon: "shippingbox"),
        StoreCategory(name: "Getränke",           icon: "wineglass"),
        StoreCategory(name: "Haushalt & Pflege",  icon: "bubbles.and.sparkles"),
        StoreCategory(name: "Sonstiges",          icon: "ellipsis.circle"),
    ]
}
