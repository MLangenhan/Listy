//
//  Recipe.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import Foundation

struct Recipe: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var servings: Int
    var ingredients: [Item]
}
