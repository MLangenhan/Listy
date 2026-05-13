//
//  ShoppingListViewModel.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import Foundation
import Combine

class ShoppingListViewModel: ObservableObject {
    @Published var list: ShoppingList = Storage.load(ShoppingList.self, key: "shoppingList") ?? ShoppingList() {
        didSet { Storage.save(list, key: "shoppingList") }
    }

    // MARK: – Items hinzufügen
    func addItem(_ item: Item) {
        // Gleiche Name+Unit zusammenführen
        if let idx = list.items.firstIndex(where: {
            $0.name.lowercased() == item.name.lowercased() && $0.unit == item.unit
        }) {
            list.items[idx].quantity += item.quantity
        } else {
            list.items.append(item)
        }
    }

    func addFromRecipe(_ recipe: Recipe, servingMultiplier: Double = 1.0) {
        for var ingredient in recipe.ingredients {
            ingredient.recipeOrigin = recipe.id
            ingredient.quantity = Int((Double(ingredient.quantity) * servingMultiplier).rounded())
            addItem(ingredient)
        }
    }

    // MARK: – Bearbeiten
    func toggle(_ item: Item) {
        guard let idx = list.items.firstIndex(where: { $0.id == item.id }) else { return }
        list.items[idx].isChecked.toggle()
    }

    func updateQuantity(of item: Item, to quantity: Int) {
        guard let idx = list.items.firstIndex(where: { $0.id == item.id }) else { return }
        list.items[idx].quantity = max(1, quantity)
    }

    func delete(_ item: Item) {
        list.items.removeAll { $0.id == item.id }
    }

    func deleteChecked() {
        list.items.removeAll { $0.isChecked }
    }

    func clearAll() {
        list.items.removeAll()
    }
}
