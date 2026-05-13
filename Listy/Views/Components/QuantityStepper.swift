//
//  QuantityStepper.swift
//  Listy
//
//  Created by Moritz Langenhan on 13.05.26.
//

import SwiftUI

struct QuantityStepper: View {
    @Binding var quantity: Int
    var unit: String = ""

    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 0) {
            Button { change(-1) } label: {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 30, height: 34)
                    .foregroundStyle(Theme.primary)
            }
            .buttonStyle(.plain)

            TextField("", text: $text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.medium)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($focused)
                .frame(minWidth: unit.isEmpty ? 36 : 54)
                .onChange(of: text) { _, newVal in
                    let filtered = newVal.filter { $0.isNumber }
                    if filtered != newVal { text = filtered }
                    if let n = Int(filtered), n > 0, n != quantity {
                        quantity = n
                    }
                }
                .onChange(of: quantity) { _, newVal in
                    if !focused {
                        let expected = unitString(newVal)
                        if text != expected {
                            text = expected
                        }
                    }
                }
                .onChange(of: focused) { _, isFocused in
                    text = isFocused ? "\(quantity)" : unitString(quantity)
                }
                .onAppear { text = unitString(quantity) }

            Button { change(1) } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 30, height: 34)
                    .foregroundStyle(Theme.primary)
            }
            .buttonStyle(.plain)
        }
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func change(_ delta: Int) {
        quantity = max(1, quantity + delta)
        text = unitString(quantity)
    }

    private func unitString(_ n: Int) -> String {
        unit.isEmpty ? "\(n)" : "\(n) \(unit)"
    }
}
