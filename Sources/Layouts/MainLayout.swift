import Foundation
import Ignite

struct MainLayout: Layout {

    @Environment(\.themes)
    private var themes

    var body: some Document {

        Body {
            Text("<br>")
        
            Text {
                Link("CodeDawa", target: "/")
                    .foregroundStyle(.white)
                    .font(.title1)
                Button("light") {
                    SwitchTheme(themes.first(where: { $0.name.capitalized == "Automata Day"})!)
                    HideElement("ChangeToLight")
                    ShowElement("ChangeToDark")
            
                }
                .id("ChangeToLight")

                Button("dark") {
                    SwitchTheme(themes.first(where: { $0.name.capitalized == "Automata Night"})!)
                    HideElement("ChangeToDark")
                    ShowElement("ChangeToLight")
                }
                .id("ChangeToDark")
                .class("d-none")
            }


            Text("<br>")

            Text("Code is code, Dawa is the cure.")
                .font(.body)
                .foregroundStyle(.primary)
                .margin(.bottom, 30)

            content
        }
    }
}
