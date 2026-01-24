import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"

    @Environment(\.themes)
    private var themes

    var body: some HTML {

        Text("<br>")
        
        Text {
            Link("CodeDawa", target: "/")
                .foregroundStyle(.white)
                .font(.title1)
            Button("light") {
                SwitchTheme(themes.first(where: { $0.name.capitalized == "Automata Day"})!)
                HideElement("ChangeToLight")
                HideElement("ChangeToLightImg")
                ShowElement("ChangeToDark")
                ShowElement("ChangeToDarkImg")
            
            }
            .id("ChangeToLight")
            .class("d-none")

            Image("/images/dark_theme.png")
            .id("ChangeToLightImg")
            .class("d-none")

            Button("dark") {
                SwitchTheme(themes.first(where: { $0.name.capitalized == "Automata Night"})!)
                HideElement("ChangeToDark")
                HideElement("ChangeToDarkImg")
                ShowElement("ChangeToLight")
                ShowElement("ChangeToLightImg")
            }
            .id("ChangeToDark")

            Image("/images/light_theme.png")
            .id("ChangeToDarkImg")
        }


        Text("<br>")

        Text("Code is code, Dawa is the cure.")
            .font(.body)
            .foregroundStyle(.primary)
            .margin(.bottom, 30)

        Image("/images/home_art.png", description: "pixel art of a computer, a keyboard, and a large cup of tea.")
            .frame(width: 250)
            .margin(.bottom, 30)
            .class("float-end") 

        Text{
        "My name is "    
        Strong("Maurice")
        ", I am a software engineer, "
        Strong("father")
        ", creative, and lover of all things sad and desperate. "
        "<br>"
        "This website is not a professional place, just somewhere I feel comfortable exposing a little of my inner being to the wider internet, in the hopes that it makes others feel normal in their own skin. At the same time it is for me mostly, and if I feel better after posting here, it has done its job."
        "<br>"
        "Dawa is arabic for medicine, or cure. My implication with that is I found the cure to my addictions through code. Although saying that, it was definitely more my son being in the world that cured me."
        }
            .font(.body)
            .margin(.bottom, 100)

        Section {
            Link("Github", target: "https://github.com/MauriceElliott")
                .foregroundStyle(.primary)
                .font(.lead)
                .margin(.top, 20)
                .margin(.bottom, 10)

            Text("<br>")

            Link("Introduction", target: "/introduction")
                .foregroundStyle(.primary)
                .font(.lead)
                .margin(.top, 20)
                .margin(.bottom, 10)
        }
    }
}
