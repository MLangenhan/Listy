//
//  ShoppingListView.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI
import Combine

struct ShoppingListView: View {
    @ObservedObject var vm: ShoppingListViewModel
    @ObservedObject var sortingVM: SortingViewModel
    @ObservedObject var marketVM: MarketViewModel

    @State private var showMarketPicker = false
    @State private var showSortingEditor = false
    @State private var showAddItem = false
    @State private var newName = ""
    @State private var newQty = 1
    @State private var newUnit = "Stk"
    let units = ["Stk", "g", "kg", "ml", "l", "EL", "TL"]

    var body: some View {
        NavigationStack {
            Group {
                if vm.list.items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("Einkaufsliste")
            .toolbar { toolbar }
            .safeAreaInset(edge: .bottom) {
                addItemBar
            }
            .sheet(isPresented: $showMarketPicker) {
                MarketPickerView(marketVM: marketVM, sortingVM: sortingVM, listVM: vm)
            }
            .sheet(isPresented: $showSortingEditor) {
                SortingEditorView(sortingVM: sortingVM, listVM: vm, marketVM: marketVM)
            }
            .onChange(of: vm.list.items.count) { _, _ in
                guard sortingVM.hasMarket && !sortingVM.isCustom else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1)
                    sortingVM.autoSort(items: vm.list.items)
                }
            }
        }
    }

    // MARK: – Sub-Views

    private var itemList: some View {
        List {
            if sortingVM.hasMarket {
                // Sortierte Ansicht mit Kategorien
                ForEach(sortingVM.profile.categories) { category in
                    let catItems = sortingVM.items(in: category, allItems: vm.list.items)
                    let unchecked = catItems.filter { !$0.isChecked }
                    let checked   = catItems.filter { $0.isChecked }

                    if !unchecked.isEmpty || !checked.isEmpty {
                        Section {
                            ForEach(unchecked) { item in itemRow(item) }
                            ForEach(checked)   { item in itemRow(item) }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Theme.primary)
                                Text(category.name.uppercased())
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.sublabel)
                            }
                        }
                    }
                }

                // Unsortierte Items
                let unsorted = sortingVM.unsortedItems(allItems: vm.list.items)
                if !unsorted.isEmpty {
                    Section {
                        ForEach(unsorted) { item in itemRow(item) }
                    } header: {
                        Text("SONSTIGES")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.sublabel)
                    }
                }

            } else {
                // Keine Sortierung: einfache Liste
                Section {
                    ForEach(vm.list.uncheckedItems) { item in itemRow(item) }
                } header: { sectionHeader("Offen", count: vm.list.uncheckedItems.count) }

                if !vm.list.checkedItems.isEmpty {
                    Section {
                        ForEach(vm.list.checkedItems) { item in itemRow(item) }
                    } header: { sectionHeader("Erledigt", count: vm.list.checkedItems.count) }
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func itemRow(_ item: Item) -> some View {
        ShoppingItemRow(
            item: item,
            onToggle:         { vm.toggle(item) },
            onQuantityChange: { vm.updateQuantity(of: item, to: $0) },
            onDelete:         { vm.delete(item) }
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(Theme.primary.opacity(0.4))
            Text("Noch nichts drin")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.label)
            Text("Füge Artikel hinzu oder lade\nein Rezept in die Liste.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.sublabel)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            HStack(spacing: 4) {
                // Sortierungs-Editor (nur wenn Markt gewählt)
                if sortingVM.hasMarket {
                    Button {
                        showSortingEditor = true
                    } label: {
                        Image(systemName: sortingVM.isCustom ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                            .foregroundStyle(Theme.primary)
                    }
                }
                // Markt-Picker
                Button {
                    showMarketPicker = true
                } label: {
                    Image(systemName: "storefront")
                        .foregroundStyle(Theme.primary)
                }

                if !vm.list.checkedItems.isEmpty {
                    Button {
                        vm.deleteChecked()
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(Theme.sublabel)
                    }
                }
            }
        }
    }

    // Bottom-Bar: neues Item
    private var addItemBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                TextField("Artikel hinzufügen", text: $newName)
                    .font(.system(size: 15, design: .rounded))
                    .padding(10)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))

                // Qty
                QuantityStepper(quantity: $newQty)
                    .frame(width: 110)

                Picker("", selection: $newUnit) {
                    ForEach(units, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .tint(Theme.primary)
                .padding(.horizontal, 4)
                .frame(width: 74)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))

                Button(action: addManualItem) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 36, height: 36)
                        .background(newName.isEmpty ? Theme.surface : Theme.primary,
                                    in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(newName.isEmpty ? Theme.sublabel : .white)
                }
                .buttonStyle(.plain)
                .disabled(newName.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.sublabel)
            Text("\(count)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Theme.primary, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private func addManualItem() {
        guard !newName.isEmpty else { return }
        vm.addItem(Item(name: newName, quantity: newQty, unit: newUnit))
        newName = ""
        newQty = 1
    }
}
