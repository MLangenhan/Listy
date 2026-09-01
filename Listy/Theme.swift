//
//  Theme.swift
//  Listy
//
//  Created by Moritz Langenhan on 14.05.26.
//

import SwiftUI

enum Theme {

    // MARK: – Neutrale Basis
    // Bewusst zurückhaltend: Struktur kommt durch Weißraum und Typografie,
    // nicht durch Boxen und Schatten. Systemfarben genutzt, wo möglich,
    // damit Light/Dark Mode und Kontrast-Einstellungen automatisch passen.

    static let background = Color(UIColor.systemBackground)
    static let label       = Color(UIColor.label)
    static let sublabel    = Color(UIColor.secondaryLabel)
    static let tertiary    = Color(UIColor.tertiaryLabel)

    /// Sehr dezenter Untergrund für die wenigen Stellen, die wirklich einen
    /// Container brauchen (Textfelder, Bottom-Bar) — kein Ersatz für jede Zeile.
    static let surface = Color(UIColor.secondarySystemBackground)

    /// Haarlinie für Trenner zwischen Zeilen, statt Boxen mit Hintergrundfarbe.
    static let divider = Color(UIColor.separator)

    // MARK: – Aktions-Akzent
    // Eine einzige Farbe für Handlungen (Buttons, aktive Zustände, Auswahl).
    // Taucht NIE als Kategorie-Farbe auf — das hält "Handlung" und
    // "Information" visuell auseinander. Gedecktes Petrol statt des
    // vorherigen hellen Blaus, damit es zur ruhigen Basis passt.
    static let accent = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.42, green: 0.68, blue: 0.66, alpha: 1.0)   // helleres Petrol für Dark Mode
                : UIColor(red: 0.11, green: 0.32, blue: 0.34, alpha: 1.0)   // tiefes Petrol für Light Mode
        }
    )

    /// Leichter Tint des Akzents für Hintergründe hinter ausgewählten/aktiven
    /// Elementen (z.B. gefüllte Checkbox-Umrandung) — nie als Fläche für Text.
    static let accentSubtle = accent.opacity(0.12)

    // MARK: – Kategorie-Palette
    // Gedämpfte, mittelhelle Töne derselben Sättigungsfamilie, damit 14
    // unterschiedliche Farben trotzdem wie EIN System wirken statt wie ein
    // Farbkasten. Reine Werte hier — welche Kategorie welchen Index bekommt,
    // entscheidet StoreCategory (nächster Schritt), nicht diese Datei.
    static let categoryPalette: [Color] = [
        Color(hue: 0.33, saturation: 0.28, brightness: 0.62), // gedämpftes Salbeigrün
        Color(hue: 0.08, saturation: 0.35, brightness: 0.72), // warmes Sandbraun
        Color(hue: 0.12, saturation: 0.40, brightness: 0.78), // helles Hafergelb
        Color(hue: 0.09, saturation: 0.45, brightness: 0.68), // Karamell
        Color(hue: 0.10, saturation: 0.30, brightness: 0.70), // Weizen
        Color(hue: 0.02, saturation: 0.35, brightness: 0.65), // gedecktes Terrakotta
        Color(hue: 0.05, saturation: 0.30, brightness: 0.68), // Ziegelrot-gedämpft
        Color(hue: 0.85, saturation: 0.25, brightness: 0.70), // gedämpftes Beerenrosa
        Color(hue: 0.58, saturation: 0.20, brightness: 0.75), // weiches Himmelblau
        Color(hue: 0.00, saturation: 0.30, brightness: 0.62), // gedecktes Fleischrot
        Color(hue: 0.11, saturation: 0.32, brightness: 0.60), // Senfgewürz
        Color(hue: 0.55, saturation: 0.22, brightness: 0.72), // kühles Eisblau
        Color(hue: 0.75, saturation: 0.15, brightness: 0.65), // Graulila
        Color(hue: 0.95, saturation: 0.28, brightness: 0.60), // Weinrot-gedämpft
        Color(hue: 0.00, saturation: 0.00, brightness: 0.55), // Neutralgrau (Sonstiges/Catch-All)
    ]

    // MARK: – Layout-Tokens
    // Konsistente Werte statt magischer Zahlen über die Views verstreut —
    // wichtig für den cleanen Look, kleine Abweichungen fallen hier sofort auf.

    static let cornerRadius: CGFloat = 10
    // War: 1 / UIScreen.main.scale (UIScreen.main deprecated seit iOS 26).
    // Fester Wert statt dynamischer Scale-Berechnung — der Unterschied zwischen
    // 0.5pt (2x) und 0.33pt (3x) ist für eine Trennlinie visuell irrelevant,
    // und Theme ist ein reiner Namespace ohne Zugriff auf @Environment.
    static let hairline: CGFloat = 0.5
    static let sectionSpacing: CGFloat = 28
}
