import SwiftUI
import MarkdownUI

struct MarkdownRenderer: View {
    let content: String

    var body: some View {
        Markdown(content)
            .markdownTheme(.flare)
    }
}

extension Theme {
    static let flare = Theme()
        .text {
            ForegroundColor(.adaptiveText)
            FontSize(15)
        }
        .heading1 { configuration in
            configuration.label
                .markdownMargin(top: 16, bottom: 8)
                .font(.title3.bold())
                .foregroundStyle(Color.adaptiveText)
        }
        .heading2 { configuration in
            configuration.label
                .markdownMargin(top: 12, bottom: 6)
                .font(.headline)
                .foregroundStyle(Color.adaptiveText)
        }
        .link {
            ForegroundColor(.adaptivePrimary)
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.9))
            BackgroundColor(Color.adaptiveText2.opacity(0.1))
        }
        .codeBlock { configuration in
            configuration.label
                .markdownMargin(top: 8, bottom: 8)
                .padding(12)
                .background(Color.adaptiveText2.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: 4, bottom: 4)
        }
        .blockquote { configuration in
            configuration.label
                .markdownMargin(top: 8, bottom: 8)
                .padding(.leading, 12)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.adaptivePrimary.opacity(0.3))
                        .frame(width: 3)
                }
        }
}
