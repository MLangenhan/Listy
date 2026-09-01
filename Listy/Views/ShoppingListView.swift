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
    @State private var newName = ""
    @State private var newQty = 1
    @State private var newUnit = "Stk"
    let units = ["Stk", "g", "kg", "ml", "l", "EL", "TL"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if sortingVM.hasMarket && !vm.list.items.isEmpty {
                    CategoryProgressBar(categories: sortingVM.profile.categories, allItems: vm.list.items)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                }

                Group {
                    if vm.list.items.isEmpty {
                        emptyState
                    } else {
                        itemList
                    }
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
                guard sortingVM.hasMarket else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1)
                    sortingVM.autoSortNewItems(items: vm.list.items)
                }
            }
        }
    }

    // MARK: – Sub-Views

    private var itemList: some View {
        List {
            if sortingVM.hasMarket {
                ForEach(sortingVM.profile.categories) { category in
                    let catItems = sortingVM.items(in: category, allItems: vm.list.items)
                    let unchecked = catItems.filter { !$0.isChecked }
                    let checked   = catItems.filter { $0.isChecked }

                    if !unchecked.isEmpty || !checked.isEmpty {
                        Section {
                            ForEach(unchecked) { item in itemRow(item, accent: category.color) }
                            ForEach(checked)   { item in itemRow(item, accent: category.color) }
                        } header: {
                            categoryHeader(name: category.name, color: category.color)
                        }
                    }
                }

                let unsorted = sortingVM.unsortedItems(allItems: vm.list.items)
                if !unsorted.isEmpty {
                    Section {
                        ForEach(unsorted) { item in itemRow(item, accent: Theme.tertiary) }
                    } header: {
                        categoryHeader(name: "Noch nicht zugeordnet", color: Theme.tertiary)
                    }
                }

            } else {
                Section {
                    ForEach(vm.list.uncheckedItems) { item in itemRow(item, accent: Theme.accent) }
                } header: { sectionHeader("Offen", count: vm.list.uncheckedItems.count) }

                if !vm.list.checkedItems.isEmpty {
                    Section {
                        ForEach(vm.list.checkedItems) { item in itemRow(item, accent: Theme.accent) }
                    } header: { sectionHeader("Erledigt", count: vm.list.checkedItems.count) }
                }
            }
        }
        .listStyle(.plain)
        .listRowSeparatorTint(Theme.divider)
    }

    /// Kleiner Farbpunkt statt Icon — dezenter, funktioniert für jede
    /// Kategorie ohne dass wir ein passendes SF Symbol pflegen müssen.
    private func categoryHeader(name: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(name.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.sublabel)
        }
        .padding(.vertical, 2)
    }

    // NOTE: Die eigentliche Zeilen-Optik (Checkbox, Mengen-Stepper, Löschen)
    // steckt in ShoppingItemRow — die kenne ich noch nicht im Detail, daher
    // hier bewusst nur der Aufruf mit einem neuen `accent`-Parameter für den
    // schmalen farbigen Strich links. Schick mir ShoppingItemRow.swift, dann
    // baue ich den Parameter dort sauber ein statt zu raten.
    @ViewBuilder
    private func itemRow(_ item: Item, accent: Color) -> some View {
        ShoppingItemRow(
            item: item,
            accent: accent,
            onToggle:         { vm.toggle(item) },
            onQuantityChange: { vm.updateQuantity(of: item, to: $0) },
            onDelete:         { vm.delete(item) }
        )
        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(Theme.accent.opacity(0.35))
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
                if sortingVM.hasMarket {
                    Button {
                        showSortingEditor = true
                    } label: {
                        Image(systemName: sortingVM.isCustom ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                            .foregroundStyle(Theme.accent)
                    }
                }
                Button {
                    showMarketPicker = true
                } label: {
                    Image(systemName: "storefront")
                        .foregroundStyle(Theme.accent)
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

    private var addItemBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Theme.divider).frame(height: Theme.hairline)
            HStack(spacing: 10) {
                TextField("Artikel hinzufügen", text: $newName)
                    .font(.system(size: 15, design: .rounded))
                    .padding(10)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

                QuantityStepper(quantity: $newQty)
                    .frame(width: 110)

                Picker("", selection: $newUnit) {
                    ForEach(units, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .tint(Theme.accent)
                .padding(.horizontal, 4)
                .frame(width: 74)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

                Button(action: addManualItem) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 36, height: 36)
                        .background(newName.isEmpty ? Theme.surface : Theme.accent,
                                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
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
        HStack(spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(Theme.sublabel)
            Text("\(count)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.sublabel)
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(Theme.surface, in: Capsule())
        }
        .padding(.vertical, 2)
    }

    private func addManualItem() {
        guard !newName.isEmpty else { return }
        vm.addItem(Item(name: newName, quantity: newQty, unit: newUnit))
        newName = ""
        newQty = 1
    }
}
