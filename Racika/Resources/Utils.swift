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

extension UIColor {
    convenience init(hex: String) {
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
            red:   CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue:  CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}

extension Color {
    static func dynamic(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }

    static let rBrown      = Color.dynamic(light: "6B4226", dark: "9C6A46")  // primary brand
    static let rBrownDark  = Color.dynamic(light: "5C3A1E", dark: "E8D5C0")  // primary darker
    static let rBrownLight = Color.dynamic(light: "E8D5C0", dark: "3D2F24")  // primary tint
    static let rGreen      = Color.dynamic(light: "3D6B4F", dark: "62A87C")  // aksi utama, CTA
    static let rGreenBg    = Color.dynamic(light: "EBF3EE", dark: "1C2D24")  // background hijau muda
    static let rAmber      = Color.dynamic(light: "C4832A", dark: "E8A855")  // warning / cara simpan
    static let rAmberBg    = Color.dynamic(light: "FDF3E3", dark: "3D2E1C")  // background amber muda
    static let rBlue       = Color.dynamic(light: "2C7BB8", dark: "5FAAD9")  // freezer / dingin
    static let rBlueBg     = Color.dynamic(light: "E8F2FA", dark: "1C2B3D")  // background biru muda
    static let rCream      = Color.dynamic(light: "F5EFE6", dark: "1E1E20")  // surface card
    static let rBg         = Color.dynamic(light: "FAF7F2", dark: "121212")  // page background
    static let rBorder     = Color.dynamic(light: "ECE3D8", dark: "2C2C2E")  // hairline border
    static let rText1      = Color.dynamic(light: "2C1810", dark: "FAF7F2")  // primary text
    static let rText2      = Color.dynamic(light: "6B4226", dark: "E8D5C0")  // secondary text
    static let rText3      = Color.dynamic(light: "9C7B6B", dark: "8C7265")  // muted text
    static let rRed        = Color.dynamic(light: "B84A3A", dark: "E06D5E")  // tanda rusak / error
    static let rRedBg      = Color.dynamic(light: "FDF1EF", dark: "3D1D1B")  // background merah muda
}
