//
//  ContentView.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var recipeVM  = RecipeViewModel()
    @StateObject private var listVM    = ShoppingListViewModel()
    @StateObject private var marketVM  = MarketViewModel()
    @StateObject private var sortingVM = SortingViewModel()

    var body: some View {
        TabView {
            ShoppingListView(vm: listVM, sortingVM: sortingVM, marketVM: marketVM)
                .tabItem { Label("Liste", systemImage: "cart") }

            RecipesView(recipeVM: recipeVM, listVM: listVM)
                .tabItem { Label("Rezepte", systemImage: "fork.knife") }
        }
        .tint(Theme.label)
        .onAppear {
            sortingVM.onCustomCategoriesChanged = { [weak marketVM] categories, marketID in
                marketVM?.saveCustomCategories(categories, for: marketID)
            }
        }
    }
}
