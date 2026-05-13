//
//  AddRecipeView.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI

struct AddRecipeView: View {
    @ObservedObject var vm: RecipeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var servings: Int = 2
    @State private var ingredients: [Item] = []

    // Eingabe für neue Zutat
    @State private var ingName: String = ""
    @State private var ingQty: Int = 1
    @State private var ingUnit: String = "Stk"

    let units = ["Stk", "g", "kg", "ml", "l", "EL", "TL"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Rezeptname
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Rezeptname", systemImage: "fork.knife")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.sublabel)

                        TextField("z.B. Pasta Bolognese", text: $name)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .padding(14)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Portionen
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Portionen", systemImage: "person.2")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.sublabel)

                        HStack {
                            Button { if servings > 1 { servings -= 1 } } label: {
                                Image(systemName: "minus")
                                    .frame(width: 36, height: 36)
                                    .background(Theme.surface, in: Circle())
                                    .foregroundStyle(Theme.primary)
                            }
                            .buttonStyle(.plain)

                            Text("\(servings)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .frame(width: 50)
                                .foregroundStyle(Theme.label)

                            Button { servings += 1 } label: {
                                Image(systemName: "plus")
                                    .frame(width: 36, height: 36)
                                    .background(Theme.primary, in: Circle())
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Zutaten
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Zutaten", systemImage: "list.bullet")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.sublabel)

                        // Neue Zutat eingeben
                        VStack(spacing: 10) {
                            TextField("Zutatname", text: $ingName)
                                .font(.system(size: 15, design: .rounded))
                                .padding(12)
                                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                            HStack(spacing: 10) {
                                // Menge
                                QuantityStepper(quantity: $ingQty)
                                    .frame(width: 110)

                                // Einheit
                                Picker("Einheit", selection: $ingUnit) {
                                    ForEach(units, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.menu)
                                .tint(Theme.primary)
                                .padding(.horizontal, 10)
                                .frame(height: 36)
                                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))

                                Spacer()

                                Button(action: addIngredient) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .bold))
                                        .frame(width: 36, height: 36)
                                        .background(ingName.isEmpty ? Theme.surface : Theme.primary,
                                                    in: RoundedRectangle(cornerRadius: 10))
                                        .foregroundStyle(ingName.isEmpty ? Theme.sublabel : .white)
                                }
                                .buttonStyle(.plain)
                                .disabled(ingName.isEmpty)
                            }
                        }

                        // Liste der Zutaten
                        ForEach(ingredients) { ing in
                            HStack {
                                Text(ing.name)
                                    .font(.system(size: 15, design: .rounded))
                                Spacer()
                                Text("\(ing.quantity) \(ing.unit)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.medium)
                                Button {
                                    ingredients.removeAll { $0.id == ing.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Theme.sublabel)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Rezept hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundStyle(Theme.sublabel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(name.isEmpty ? Theme.sublabel : Theme.primary)
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addIngredient() {
        guard !ingName.isEmpty else { return }
        ingredients.append(Item(name: ingName, quantity: ingQty, unit: ingUnit))
        ingName = ""
        ingQty = 1
    }

    private func save() {
        let recipe = Recipe(name: name, servings: servings, ingredients: ingredients)
        vm.add(recipe)
        dismiss()
    }
}
