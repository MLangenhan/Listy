//
//  SortingViewModel.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation
import SwiftUI
import Combine

class SortingViewModel: ObservableObject {
    @Published var profile: SortingProfile = Storage.load(SortingProfile.self, key: "sortingProfile") ?? SortingProfile() {
        didSet { Storage.save(profile, key: "sortingProfile") }
    }

    // MARK: – Markt wählen
    func selectMarket(_ market: Market, marketVM: MarketViewModel) {
        profile.selectedMarketID = market.id
        let cats = marketVM.effectiveCategories(for: market)
        profile.categories = cats
        profile.mode = .auto
    }

    // MARK: – Auto-Sortierung
    /// Weist Items automatisch den Kategorien zu (keyword-basiert)
    func autoSort(items: [Item]) {
        guard !profile.categories.isEmpty else { return }

        // Lokal arbeiten, erst am Ende publishen
        var updated = profile.categories
        for i in updated.indices {
            updated[i].itemIDs = []
        }

        let sonstigesIdx = updated.indices.last!

        for item in items {
            let cat = bestCategory(for: item.name)
            if let idx = updated.firstIndex(where: { $0.id == cat?.id }) {
                updated[idx].itemIDs.append(item.id)
            } else {
                updated[sonstigesIdx].itemIDs.append(item.id)
            }
        }

        // Einmaliges Update → ein einziger SwiftUI Re-render
        profile.categories = updated
        profile.mode = .auto
    }

    /// Einfaches Keyword-Matching
    private func bestCategory(for name: String) -> StoreCategory? {
        let n = name.lowercased()
        let keywords: [(String, String)] = [
            // (Keyword, Kategoriename-Fragment)
            ("apfel","Obst"), ("banane","Obst"), ("tomate","Obst"), ("gurke","Obst"),
            ("salat","Obst"), ("karotte","Obst"), ("zwiebel","Obst"), ("knoblauch","Obst"),
            ("paprika","Obst"), ("zitrone","Obst"), ("orange","Obst"), ("gemüse","Obst"),
            ("obst","Obst"), ("beere","Obst"), ("pilz","Obst"),

            ("brot","Brot"), ("brötchen","Brot"), ("toast","Brot"), ("backwaren","Brot"),
            ("kuchen","Brot"), ("croissant","Brot"),

            ("milch","Molkerei"), ("käse","Molkerei"), ("joghurt","Molkerei"),
            ("butter","Molkerei"), ("sahne","Molkerei"), ("quark","Molkerei"),
            ("ei","Molkerei"), ("eier","Molkerei"),

            ("fleisch","Fleisch"), ("hack","Fleisch"), ("wurst","Fleisch"),
            ("schinken","Fleisch"), ("huhn","Fleisch"), ("hähnchen","Fleisch"),
            ("fisch","Fleisch"), ("lachs","Fleisch"), ("thunfisch","Fleisch"),

            ("tiefkühl","Tiefkühl"), ("pizza","Tiefkühl"), ("eis","Tiefkühl"),
            ("pommes","Tiefkühl"),

            ("dose","Konserven"), ("konserve","Konserven"), ("nudel","Konserven"),
            ("pasta","Konserven"), ("reis","Konserven"), ("mehl","Konserven"),
            ("zucker","Konserven"), ("öl","Konserven"), ("essig","Konserven"),
            ("gewürz","Konserven"), ("salz","Konserven"), ("pfeffer","Konserven"),
            ("soße","Konserven"), ("sauce","Konserven"), ("tomaten","Konserven"),

            ("wasser","Getränke"), ("saft","Getränke"), ("bier","Getränke"),
            ("wein","Getränke"), ("cola","Getränke"), ("limonade","Getränke"),
            ("kaffee","Getränke"), ("tee","Getränke"),

            ("seife","Haushalt"), ("shampoo","Haushalt"), ("spülmittel","Haushalt"),
            ("waschmittel","Haushalt"), ("toilettenpapier","Haushalt"),
            ("zahnbürste","Haushalt"), ("zahnpasta","Haushalt"),
        ]

        for (keyword, catFragment) in keywords {
            if n.contains(keyword) {
                return profile.categories.first { $0.name.contains(catFragment) }
            }
        }
        return nil
    }

    // MARK: – Kategorie-Reihenfolge ändern (Drag & Drop zwischen Kategorien)
    func moveCategoryItems(in categoryID: UUID, from source: IndexSet, to destination: Int) {
        guard let idx = profile.categories.firstIndex(where: { $0.id == categoryID }) else { return }
        profile.categories[idx].itemIDs.move(fromOffsets: source, toOffset: destination)
        profile.mode = .custom
    }

    func moveCategories(from source: IndexSet, to destination: Int) {
        profile.categories.move(fromOffsets: source, toOffset: destination)
        profile.mode = .custom
    }

    // MARK: – Item einer anderen Kategorie zuweisen
    func move(itemID: UUID, to targetCategoryID: UUID) {
        // Aus alter Kategorie entfernen
        for i in profile.categories.indices {
            profile.categories[i].itemIDs.removeAll { $0 == itemID }
        }
        // In neue Kategorie einfügen
        guard let idx = profile.categories.firstIndex(where: { $0.id == targetCategoryID }) else { return }
        profile.categories[idx].itemIDs.append(itemID)
        profile.mode = .custom
    }

    // MARK: – Hilfsfunktionen für Views
    func category(for item: Item) -> StoreCategory? {
        profile.categories.first { $0.itemIDs.contains(item.id) }
    }

    /// Gibt Items einer Kategorie in richtiger Reihenfolge zurück
    func items(in category: StoreCategory, allItems: [Item]) -> [Item] {
        category.itemIDs.compactMap { id in allItems.first { $0.id == id } }
    }

    /// Items ohne Kategorie (noch nicht zugeordnet)
    func unsortedItems(allItems: [Item]) -> [Item] {
        let assignedIDs = Set(profile.categories.flatMap { $0.itemIDs })
        return allItems.filter { !assignedIDs.contains($0.id) }
    }

    var hasMarket: Bool { profile.selectedMarketID != nil }
    var isCustom: Bool { profile.mode == .custom }
}
