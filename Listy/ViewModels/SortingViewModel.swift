//
//  SortingViewModel.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation
import SwiftUI
import Combine

private struct KeywordRule {
    let keyword: String
    let fragment: String   // Kategoriename-Fragment
}


class SortingViewModel: ObservableObject {
    @Published var profile: SortingProfile = Storage.load(SortingProfile.self, key: "sortingProfile") ?? SortingProfile() {
        didSet { Storage.save(profile, key: "sortingProfile") }
    }

    /// Wird von außen gesetzt (z.B. in ContentView), damit Custom-Änderungen
    /// automatisch im MarketViewModel persistiert werden.
    var onCustomCategoriesChanged: (([StoreCategory], UUID) -> Void)?

    private func persistCustomCategoriesIfNeeded() {
        guard let marketID = profile.selectedMarketID else { return }
        // Nur die Struktur (Reihenfolge, Name, Icon) persistieren,
        // nicht die itemIDs — die gehören zur aktuellen Einkaufsliste, nicht zum Markt.
        let structureOnly = profile.categories.map {
            StoreCategory(id: $0.id, name: $0.name, icon: $0.icon, itemIDs: [],
                          isCatchAll: $0.isCatchAll, colorIndex: $0.colorIndex)
        }
        onCustomCategoriesChanged?(structureOnly, marketID)
    }

    // MARK: – Markt wählen
    func selectMarket(_ market: Market, marketVM: MarketViewModel) {
        profile.selectedMarketID = market.id
        let cats = marketVM.effectiveCategories(for: market)
        profile.categories = cats
        profile.mode = .auto
    }

    // MARK: – Auto-Sortierung (alles neu, expliziter "Auto"-Button)
    func autoSort(items: [Item]) {
        guard !profile.categories.isEmpty else { return }

        var updated = profile.categories
        for i in updated.indices {
            updated[i].itemIDs = []
        }

        let catchAllIdx = updated.firstIndex(where: { $0.isCatchAll }) ?? updated.indices.last

        for item in items {
            let cat = bestCategory(for: item.name)
            if let idx = updated.firstIndex(where: { $0.id == cat?.id }) {
                updated[idx].itemIDs.append(item.id)
            } else if let fallbackIdx = catchAllIdx {
                updated[fallbackIdx].itemIDs.append(item.id)
            }
        }

        profile.categories = updated
        profile.mode = .auto
    }

    // MARK: – Keyword-Matching

    // Einmal aufgebaut statt bei jedem Aufruf von bestCategory neu.
    private static let keywordCategoryMap: [KeywordRule] = [
        // Obst & Gemüse
        ("apfel","Obst"), ("banane","Obst"), ("tomate","Obst"), ("gurke","Obst"),
        ("salat","Obst"), ("karotte","Obst"), ("zwiebel","Obst"), ("knoblauch","Obst"),
        ("paprika","Obst"), ("zitrone","Obst"), ("orange","Obst"), ("gemüse","Obst"),
        ("obst","Obst"), ("beere","Obst"), ("pilz","Obst"), ("kartoffel","Obst"),

        // Brot & Backwaren
        ("brot","Brot"), ("brötchen","Brot"), ("toast","Brot"), ("backwaren","Brot"),
        ("kuchen","Brot"), ("croissant","Brot"),

        // Musli
        ("müsli","Musli"), ("musli","Musli"), ("cornflakes","Musli"),
        ("haferflocken","Musli"), ("granola","Musli"),

        // Backzeug
        ("mehl","Backzeug"), ("hefe","Backzeug"), ("backpulver","Backzeug"),
        ("vanillezucker","Backzeug"), ("puderzucker","Backzeug"),

        // Nudeln
        ("nudel","Nudeln"), ("pasta","Nudeln"), ("spaghetti","Nudeln"),
        ("penne","Nudeln"), ("lasagne","Nudeln"),

        // Konserven & Trocken
        ("dose","Konserven"), ("konserve","Konserven"), ("reis","Konserven"),
        ("zucker","Konserven"), ("öl","Konserven"), ("essig","Konserven"),
        ("linsen","Konserven"), ("kichererbsen","Konserven"), ("tomaten","Konserven"),

        // Saucen
        ("soße","Saucen"), ("sauce","Saucen"), ("ketchup","Saucen"),
        ("senf","Saucen"), ("mayonnaise","Saucen"), ("pesto","Saucen"),

        // Süßigkeiten
        ("schokolade","Süßigkeiten"), ("gummibär","Süßigkeiten"), ("keks","Süßigkeiten"),
        ("chips","Süßigkeiten"), ("bonbon","Süßigkeiten"), ("praline","Süßigkeiten"),

        // Molkerei
        ("milch","Molkerei"), ("käse","Molkerei"), ("joghurt","Molkerei"),
        ("butter","Molkerei"), ("sahne","Molkerei"), ("quark","Molkerei"),
        ("eier","Molkerei"), ("ei","Molkerei"),

        // Fleisch & Fisch
        ("fleisch","Fleisch"), ("hack","Fleisch"), ("wurst","Fleisch"),
        ("schinken","Fleisch"), ("huhn","Fleisch"), ("hähnchen","Fleisch"),
        ("fisch","Fleisch"), ("lachs","Fleisch"), ("thunfisch","Fleisch"),

        // Gewürze
        ("gewürz","Gewürze"), ("salz","Gewürze"), ("pfeffer","Gewürze"),
        ("curry","Gewürze"), ("zimt","Gewürze"), ("paprikapulver","Gewürze"),

        // Tiefkühl
        ("tiefkühl","Tiefkühl"), ("pizza","Tiefkühl"), ("eis","Tiefkühl"), ("pommes","Tiefkühl"),

        // Getränke
        ("wasser","Getränke"), ("saft","Getränke"), ("bier","Getränke"),
        ("wein","Getränke"), ("cola","Getränke"), ("limonade","Getränke"),
        ("kaffee","Getränke"), ("tee","Getränke"),

        // Haushalt & Pflege
        ("seife","Haushalt"), ("shampoo","Haushalt"), ("spülmittel","Haushalt"),
        ("waschmittel","Haushalt"), ("toilettenpapier","Haushalt"),
        ("zahnbürste","Haushalt"), ("zahnpasta","Haushalt"),
    ].map { KeywordRule(keyword: $0.0, fragment: $0.1) }

    /// Wählt die spezifischste (längste) Keyword-Übereinstimmung statt der ersten
    /// in Listenreihenfolge — verhindert, dass kurze Keywords wie "ei" längere,
    /// eindeutigere Treffer wie "fleisch" (das ebenfalls "ei" enthält) verdecken.
    private func bestCategory(for name: String) -> StoreCategory? {
        let n = name.lowercased()

        let bestMatch = Self.keywordCategoryMap
            .filter { n.contains($0.keyword) }
            .max { $0.keyword.count < $1.keyword.count }

        guard let match = bestMatch else { return nil }
        return profile.categories.first { $0.name.contains(match.fragment) }
    }

    func moveCategoryItems(in categoryID: UUID, from source: IndexSet, to destination: Int) {
        guard let idx = profile.categories.firstIndex(where: { $0.id == categoryID }) else { return }
        profile.categories[idx].itemIDs.move(fromOffsets: source, toOffset: destination)
        profile.mode = .custom
        persistCustomCategoriesIfNeeded()
    }

    func moveCategories(from source: IndexSet, to destination: Int) {
        profile.categories.move(fromOffsets: source, toOffset: destination)
        profile.mode = .custom
        persistCustomCategoriesIfNeeded()
    }

    func move(itemID: UUID, to targetCategoryID: UUID) {
        for i in profile.categories.indices {
            profile.categories[i].itemIDs.removeAll { $0 == itemID }
        }
        guard let idx = profile.categories.firstIndex(where: { $0.id == targetCategoryID }) else { return }
        profile.categories[idx].itemIDs.append(itemID)
        profile.mode = .custom
        // Hier NICHT persistCustomCategoriesIfNeeded() aufrufen — das ist nur eine
        // Item-Zuordnung, keine Strukturänderung.
    }

    // MARK: – Hilfsfunktionen für Views
    func category(for item: Item) -> StoreCategory? {
        profile.categories.first { $0.itemIDs.contains(item.id) }
    }

    /// Gibt Items einer Kategorie in richtiger Reihenfolge zurück
    func items(in category: StoreCategory, allItems: [Item]) -> [Item] {
        category.itemIDs.compactMap { id in allItems.first { $0.id == id } }
    }

    // MARK: – Hybrid-Autosort (nur neue/unzugeordnete Items)
    /// Ordnet nur Items zu, die noch in keiner Kategorie stecken.
    /// Bestehende manuelle Zuordnungen bleiben unangetastet.
    func autoSortNewItems(items: [Item]) {
        guard !profile.categories.isEmpty else { return }

        let currentIDs = Set(items.map { $0.id })
        var updated = profile.categories

        // Verwaiste itemIDs entfernen (z.B. gelöschte/abgehakte-und-entfernte Items)
        for i in updated.indices {
            updated[i].itemIDs.removeAll { !currentIDs.contains($0) }
        }

        let assignedIDs = Set(updated.flatMap { $0.itemIDs })
        let newItems = items.filter { !assignedIDs.contains($0.id) }
        guard !newItems.isEmpty else {
            profile.categories = updated
            return
        }

        let catchAllIdx = updated.firstIndex(where: { $0.isCatchAll }) ?? updated.indices.last

        for item in newItems {
            let cat = bestCategory(for: item.name)
            if let idx = updated.firstIndex(where: { $0.id == cat?.id }) {
                updated[idx].itemIDs.append(item.id)
            } else if let fallbackIdx = catchAllIdx {
                updated[fallbackIdx].itemIDs.append(item.id)
            }
        }

        profile.categories = updated
        // mode bleibt bewusst unverändert – automatisches Einsortieren neuer
        // Items ist kein "custom"-Eingriff des Nutzers.
    }

    /// Items ohne Kategorie (noch nicht zugeordnet)
    func unsortedItems(allItems: [Item]) -> [Item] {
        let assignedIDs = Set(profile.categories.flatMap { $0.itemIDs })
        return allItems.filter { !assignedIDs.contains($0.id) }
    }

    var hasMarket: Bool { profile.selectedMarketID != nil }
    var isCustom: Bool { profile.mode == .custom }
}
