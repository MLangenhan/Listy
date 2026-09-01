//
//  MarketPickerView.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import SwiftUI

struct MarketPickerView: View {
    @ObservedObject var marketVM: MarketViewModel
    @ObservedObject var sortingVM: SortingViewModel
    @ObservedObject var listVM: ShoppingListViewModel
    @Environment(\.dismiss) var dismiss

    @State private var newMarketName = ""
    @State private var selectedChain: MarketChain = MarketChain.presets[0]

    var body: some View {
        NavigationStack {
            List {
                if !marketVM.markets.isEmpty {
                    Section {
                        ForEach(marketVM.markets) { market in
                            Button {
                                sortingVM.selectMarket(market, marketVM: marketVM)
                                sortingVM.autoSort(items: listVM.list.items)
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(market.name)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(Theme.label)
                                        if let chain = marketVM.chain(for: market) {
                                            Text(chain.name)
                                                .font(.system(size: 13, design: .rounded))
                                                .foregroundStyle(Theme.sublabel)
                                        }
                                    }
                                    Spacer()
                                    if sortingVM.profile.selectedMarketID == market.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.accent)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    marketVM.deleteMarket(market)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("Meine Märkte")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Marktname (z.B. REWE City)", text: $newMarketName)
                            .font(.system(size: 15, design: .rounded))
                            .padding(12)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

                        Picker("Kette", selection: $selectedChain) {
                            ForEach(marketVM.chains) { chain in
                                Text(chain.name).tag(chain)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.accent)

                        Button {
                            guard !newMarketName.isEmpty else { return }
                            marketVM.addMarket(name: newMarketName, chain: selectedChain)
                            newMarketName = ""
                        } label: {
                            Text("Markt hinzufügen")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    newMarketName.isEmpty ? Theme.surface : Theme.accent,
                                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                )
                        }
                        .disabled(newMarketName.isEmpty)
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Neuer Markt")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(0.6)
                }
            }
            .navigationTitle("Markt wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }
}
