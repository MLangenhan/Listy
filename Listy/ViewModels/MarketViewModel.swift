//
//  MarketViewModel.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import Foundation
import SwiftUI
import Combine

class MarketViewModel: ObservableObject {
    @Published var chains: [MarketChain] = MarketChain.presets

    @Published var markets: [Market] = Storage.load([Market].self, key: "markets") ?? [] {
        didSet { Storage.save(markets, key: "markets") }
    }

    func addMarket(name: String, chain: MarketChain) {
        let market = Market(name: name, chainID: chain.id)
        markets.append(market)
    }

    func deleteMarket(_ market: Market) {
        markets.removeAll { $0.id == market.id }
    }

    func chain(for market: Market) -> MarketChain? {
        chains.first { $0.id == market.chainID }
    }

    func effectiveCategories(for market: Market) -> [StoreCategory] {
        market.customCategories ?? chain(for: market)?.categoryOrder ?? StoreCategory.defaults
    }

    func saveCustomCategories(_ cats: [StoreCategory], for marketID: UUID) {
        guard let idx = markets.firstIndex(where: { $0.id == marketID }) else { return }
        markets[idx].customCategories = cats
    }

    func resetToChainDefault(for marketID: UUID) {
        guard let idx = markets.firstIndex(where: { $0.id == marketID }) else { return }
        markets[idx].customCategories = nil
    }
}
