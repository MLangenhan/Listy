//
//  ShoppingList.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import Foundation

struct ShoppingList: Identifiable, Codable {
    var id: UUID = UUID()
    var items: [Item] = []

    // Gruppiert nach Rezept-Herkunft
    var checkedItems: [Item]   { items.filter { $0.isChecked } }
    var uncheckedItems: [Item] { items.filter { !$0.isChecked } }
}
