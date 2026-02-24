import Ignite

protocol BaseTheme: Theme {}

extension BaseTheme {
	var siteWidth: ResponsiveValues {
        .init(
            large: .px(700),
            xLarge: .px(900),
            xxLarge: .px(900)
        )
	}

	var codeBlockFontSize: LengthUnit { .px(16) }
    var inlineCodeFontSize: LengthUnit { .px(16) }

    var h1Size: ResponsiveValues { .init(LengthUnit.px(32)) }  // 1.78x
    var h2Size: ResponsiveValues { .init(LengthUnit.px(28)) }  // 1.56x
    var h3Size: ResponsiveValues { .init(LengthUnit.px(22)) }  // 1.22x
    var h4Size: ResponsiveValues { .init(LengthUnit.px(20)) }  // 1.11x
    var h5Size: ResponsiveValues { .init(LengthUnit.px(18)) }  // Same as body
    var h6Size: ResponsiveValues { .init(LengthUnit.px(16)) }  // 0.89x body

    var bodyFontSize: ResponsiveValues { .init(LengthUnit.px(18)) }
    var lineSpacing: LengthUnit { .em(1.5) }
    var headingLineSpacing: LengthUnit { .em(2) }
}

struct AutomataNight: BaseTheme {
	var name = "AutomataNight"
	var font: Font = Font(
        name: "Departure Mono",
        source: "./../fonts/DepartureMono-Regular.woff2"
    )

    var headingFont: Font = Font(
        name: "Departure Mono",
        source: "./../fonts/DepartureMono-Regular.woff2"

    )

    var monospaceFont: Font = Font(
        name: "Annotation Mono",
	    source: "./../fonts/DepartureMono-Regular.woff2"
    )

    let colorScheme: ColorScheme = .dark

    var accent: Color { Color(hex: "#EBA123") } // yellow
    var secondaryAccent: Color { Color(hex: "#6B997B") } // green
    var secondary: Color { Color(hex: "#77D989") } // light-green
    var background: Color { Color(hex: "#1A1313") } // black
    var secondaryBackground: Color { Color(hex: "#30231E") } // light-black
    var link: Color { Color(hex: "#7A97CC") } // blue
    var hoveredLink: Color { Color(hex: "#8DCBCC") } // light-aqua

    var syntaxHighlighterTheme: HighlighterTheme { .githubDark }
}

struct AutomataDay: BaseTheme {
	var name = "AutomataDay"
	var font: Font = Font(
        name: "Annotation Mono",
        source: "./../fonts/DemiBold.woff2"
    )

    var headingFont: Font = Font(
        name: "Annotation Mono",
        source: "./../fonts/DemiBold.woff2"
    )

    var monospaceFont: Font = Font(
         name: "Annotation Mono",
         source: "./../fonts/Regular.woff2"
     )

    let colorScheme: ColorScheme = .light

    var accent: Color { Color(hex: "#B67F21") } // yellow
    var secondaryAccent: Color { Color(hex: "#732127") } // light-red
    var secondary: Color { Color(hex: "#52212C") } // red
    var background: Color { Color(hex: "#DAD4BA") } //bright-white 
    var secondaryBackground: Color { Color(hex: "#CDC8B0") } // white
    var link: Color { Color(hex: "#3A4A67") } // blue
    var hoveredLink: Color { Color(hex: "#2B797A") } // light-aqua

    var syntaxHighlighterTheme: HighlighterTheme { .solarizedLight }
}
