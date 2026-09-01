//
//  CategoryProgessBar.swift
//  Listy
//
//  Created by Moritz Langenhan on 01.09.26.
//

import SwiftUI

/// Segmentierter Fortschrittsbalken: ein Segment pro Kategorie mit Items,
/// Segmentbreite proportional zur Anzahl Items, Füllung proportional zum
/// Abhak-Fortschritt in dieser Kategorie. Macht den "Weg durch den Laden"
/// abstrakt sichtbar, statt nur eine generische "7/15"-Zahl zu zeigen.
struct CategoryProgressBar: View {
    let categories: [StoreCategory]
    let allItems: [Item]

    private struct Segment: Identifiable {
        let id: UUID
        let color: Color
        let total: Int
        let checked: Int
        var fraction: Double { total == 0 ? 0 : Double(checked) / Double(total) }
    }

    private var segments: [Segment] {
        categories.compactMap { cat in
            let items = cat.itemIDs.compactMap { id in allItems.first { $0.id == id } }
            guard !items.isEmpty else { return nil }
            return Segment(
                id: cat.id,
                color: cat.color,
                total: items.count,
                checked: items.filter { $0.isChecked }.count
            )
        }
    }

    private var totalCount: Int { segments.reduce(0) { $0 + $1.total } }
    private var checkedCount: Int { segments.reduce(0) { $0 + $1.checked } }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                HStack(spacing: 3) {
                    ForEach(segments) { segment in
                        let widthFraction = totalCount > 0 ? Double(segment.total) / Double(totalCount) : 0
                        let segmentWidth = geo.size.width * widthFraction

                        ZStack(alignment: .leading) {
                            Capsule().fill(segment.color.opacity(0.16))
                            Capsule()
                                .fill(segment.color)
                                .frame(width: segmentWidth * segment.fraction)
                        }
                        .frame(width: segmentWidth)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: checkedCount)
            }
            .frame(height: 6)

            if totalCount > 0 {
                Text("\(checkedCount) von \(totalCount)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.sublabel)
            }
        }
    }
}
