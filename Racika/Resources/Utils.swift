//
//  Utils.swift
//  Racika
//
//  Created by Daffa Putera Kouseina on 28/06/26.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    static let rBrown     = Color(hex: "6B4226")  // primary brand
    static let rGreen     = Color(hex: "3D6B4F")  // aksi utama, CTA
    static let rGreenBg   = Color(hex: "EBF3EE")  // background hijau muda
    static let rAmber     = Color(hex: "C4832A")  // warning / cara simpan
    static let rAmberBg   = Color(hex: "FDF3E3")  // background amber muda
    static let rCream     = Color(hex: "F5EFE6")  // surface card
    static let rBg        = Color(hex: "FAF7F2")  // page background
    static let rText1     = Color(hex: "2C1810")  // primary text
    static let rText2     = Color(hex: "6B4226")  // secondary text
    static let rText3     = Color(hex: "9C7B6B")  // muted text
    static let rRed       = Color(hex: "B84A3A")  // tanda rusak / error
}
