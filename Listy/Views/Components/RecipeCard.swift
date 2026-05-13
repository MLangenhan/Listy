//
//  RecipeCard.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe
    var onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Farbblock-Akzent
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Theme.primary)
                .frame(width: 4)
                .frame(height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.label)
                Text("\(recipe.ingredients.count) Zutaten · \(recipe.servings) Portion\(recipe.servings == 1 ? "" : "en")")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Theme.sublabel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onAdd) {
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Theme.primary)
                    .frame(width: 40, height: 40)
                    .background(Theme.primary.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
