//
//  ShoppingItemRow.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI

struct ShoppingItemRow: View {
    let item: Item
    var onToggle: () -> Void
    var onQuantityChange: (Int) -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(item.isChecked ? Theme.primary : Theme.sublabel.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 26, height: 26)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(item.isChecked ? Theme.primary : Color.clear)
                        )
                    if item.isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Name
            Text(item.name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(item.isChecked ? Theme.sublabel : Theme.label)
                .strikethrough(item.isChecked, color: Theme.sublabel)
                .animation(.easeInOut(duration: 0.2), value: item.isChecked)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Stückzahl-Stepper
            // Statt QuantityStepper:
            HStack(spacing: 0) {
                Button {
                    onQuantityChange(max(1, item.quantity - 1))
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 30, height: 34)
                        .foregroundStyle(Theme.primary)
                }
                .buttonStyle(.plain)

                Text("\(item.quantity) \(item.unit)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.medium)
                    .frame(minWidth: 54)
                    .multilineTextAlignment(.center)

                Button {
                    onQuantityChange(item.quantity + 1)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 30, height: 34)
                        .foregroundStyle(Theme.primary)
                }
                .buttonStyle(.plain)
            }
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.background)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}
