//
//  RecipeViewModel.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import Foundation
import Combine
import SwiftUI

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = Storage.load([Recipe].self, key: "recipes") ?? [] {
        didSet { Storage.save(recipes, key: "recipes") }
    }

    // MARK: – CRUD
    func add(_ recipe: Recipe) {
        recipes.append(recipe)
    }

    func delete(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
    }

    func update(_ recipe: Recipe) {
        guard let idx = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[idx] = recipe
    }
}
    
