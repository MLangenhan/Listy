//
//  Items.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import Foundation

import Foundation

struct Item: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var quantity: Int
    var unit: String        // "Stk", "g", "ml", "EL", "TL", …
    var isChecked: Bool = false
    var recipeOrigin: UUID? // nil = manuell hinzugefügt
}
