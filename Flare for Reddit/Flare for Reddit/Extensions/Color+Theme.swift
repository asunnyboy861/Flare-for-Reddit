import SwiftUI

extension Color {
    static let flarePrimary = Color(red: 1.0, green: 0.27, blue: 0.0)
    static let flarePrimaryLight = Color(red: 1.0, green: 0.42, blue: 0.21)
    static let flareSecondary = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let flareBackground = Color.white
    static let flareSurface = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let flareText = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let flareText2 = Color(red: 0.53, green: 0.53, blue: 0.55)
    static let flareUpvote = Color(red: 1.0, green: 0.27, blue: 0.0)
    static let flareDownvote = Color(red: 0.44, green: 0.58, blue: 1.0)
    static let flareSuccess = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let flareError = Color(red: 1.0, green: 0.23, blue: 0.19)

    static let flareDarkPrimary = Color(red: 1.0, green: 0.42, blue: 0.21)
    static let flareDarkSecondary = Color(red: 0.88, green: 0.88, blue: 0.88)
    static let flareDarkBackground = Color.black
    static let flareDarkSurface = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let flareDarkText = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let flareDarkText2 = Color(red: 0.60, green: 0.60, blue: 0.62)
    static let flareDarkUpvote = Color(red: 1.0, green: 0.42, blue: 0.21)
    static let flareDarkDownvote = Color(red: 0.43, green: 0.62, blue: 1.0)
    static let flareDarkSuccess = Color(red: 0.19, green: 0.82, blue: 0.35)
    static let flareDarkError = Color(red: 1.0, green: 0.27, blue: 0.23)

    static var adaptivePrimary: Color {
        Color(light: .flarePrimary, dark: .flareDarkPrimary)
    }
    static var adaptiveSecondary: Color {
        Color(light: .flareSecondary, dark: .flareDarkSecondary)
    }
    static var adaptiveBackground: Color {
        Color(light: .flareBackground, dark: .flareDarkBackground)
    }
    static var adaptiveSurface: Color {
        Color(light: .flareSurface, dark: .flareDarkSurface)
    }
    static var adaptiveText: Color {
        Color(light: .flareText, dark: .flareDarkText)
    }
    static var adaptiveText2: Color {
        Color(light: .flareText2, dark: .flareDarkText2)
    }
    static var adaptiveUpvote: Color {
        Color(light: .flareUpvote, dark: .flareDarkUpvote)
    }
    static var adaptiveDownvote: Color {
        Color(light: .flareDownvote, dark: .flareDarkDownvote)
    }
    static var adaptiveSuccess: Color {
        Color(light: .flareSuccess, dark: .flareDarkSuccess)
    }
    static var adaptiveError: Color {
        Color(light: .flareError, dark: .flareDarkError)
    }

    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
