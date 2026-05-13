//
//  RecipeView.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI

struct RecipesView: View {
    @ObservedObject var recipeVM: RecipeViewModel
    @ObservedObject var listVM: ShoppingListViewModel

    @State private var showAdd = false
    @State private var addedRecipeID: UUID? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(recipeVM.recipes) { recipe in
                        RecipeCard(recipe: recipe) {
                            listVM.addFromRecipe(recipe)
                            withAnimation { addedRecipeID = recipe.id }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                addedRecipeID = nil
                            }
                        }
                        .overlay(alignment: .trailing) {
                            if addedRecipeID == recipe.id {
                                Label("Hinzugefügt", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Theme.dark, in: Capsule())
                                    .padding(.trailing, 12)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .animation(.spring(duration: 0.3), value: addedRecipeID)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Rezepte")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddRecipeView(vm: recipeVM)
            }
        }
    }
}
