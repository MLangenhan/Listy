//
//  SortingEditorView.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import SwiftUI

struct SortingEditorView: View {
    @ObservedObject var sortingVM: SortingViewModel
    @ObservedObject var listVM: ShoppingListViewModel
    @ObservedObject var marketVM: MarketViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortingVM.profile.categories) { category in
                    let catItems = sortingVM.items(in: category, allItems: listVM.list.items)
                    if !catItems.isEmpty {
                        Section {
                            ForEach(catItems) { item in
                                categoryItemRow(item: item, category: category)
                            }
                            .onMove { source, destination in
                                sortingVM.moveCategoryItems(in: category.id, from: source, to: destination)
                            }
                        } header: {
                            categoryHeader(category)
                        }
                    }
                }
                .onMove { source, destination in
                    sortingVM.moveCategories(from: source, to: destination)
                }

                let unsorted = sortingVM.unsortedItems(allItems: listVM.list.items)
                if !unsorted.isEmpty {
                    Section {
                        ForEach(unsorted) { item in
                            unsortedItemRow(item: item)
                        }
                    } header: {
                        Text("Nicht zugeordnet")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Sortierung bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showResetConfirmation = true
                    } label: {
                        Label("Auto", systemImage: "sparkles")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .confirmationDialog(
                "Automatisch sortieren?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Ja, automatisch sortieren", role: .destructive) {
                    sortingVM.autoSort(items: listVM.list.items)
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Deine manuelle Sortierung wird dabei überschrieben.")
            }
        }
    }

    // War Icon + Text — jetzt derselbe Farbpunkt-Stil wie in ShoppingListView,
    // damit dieselbe Kategorie in beiden Screens gleich aussieht.
    private func categoryHeader(_ category: StoreCategory) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(category.color)
                .frame(width: 6, height: 6)
            Text(category.name.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.sublabel)
        }
    }

    private func categoryItemRow(item: Item, category: StoreCategory) -> some View {
        HStack {
            Text(item.name)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.label)
            Spacer()
            Menu {
                ForEach(sortingVM.profile.categories) { cat in
                    Button {
                        sortingVM.move(itemID: item.id, to: cat.id)
                    } label: {
                        Label(cat.name, systemImage: cat.icon)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.sublabel)
            }
        }
    }

    private func unsortedItemRow(item: Item) -> some View {
        HStack {
            Text(item.name)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.label)
            Spacer()
            Menu {
                ForEach(sortingVM.profile.categories) { cat in
                    Button {
                        sortingVM.move(itemID: item.id, to: cat.id)
                    } label: {
                        Label(cat.name, systemImage: cat.icon)
                    }
                }
            } label: {
                Text("Zuordnen")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Theme.accent)
            }
        }
    }
}
