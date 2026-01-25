import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"

    var body: some HTML {

        Image("/images/home_art.png", description: "pixel art of a computer, a keyboard, and a large cup of tea.")
            .frame(width: 250)
            .margin(.bottom, 30)
            .class("float-end")

        Text{
            "My name is "    
            Strong("Maurice")
            ", I am a "    
            Strong("software engineer")
            ", "
            Strong("father")
            ", "
            Strong("creative")
            ", and lover of all things sad and desperate. "
            "<br>"
            "This website is not a professional place, just somewhere I feel comfortable exposing a little of my inner being to the wider internet, in the hopes that it makes others feel normal in their own skin. At the same time it is for me mostly, and if I feel better after posting here, it has done its job."
            "<br>"
            Strong("Dawa")
            " is arabic for medicine, or "
            Strong("cure")
            ". My implication with that is I found the cure to my addictions through code. Although saying that, it was definitely more my son being in the world that cured me."
        }
            .font(.body)
            .margin(.bottom, 100)

        Section {
            Text(Strong("Links:"))
            .font(.body)

            Link("Github", target: "https://github.com/MauriceElliott")
                .foregroundStyle(.primary)
                .font(.body)
                .margin(.top, 20)
                .margin(.bottom, 10)
            Text("")
            Link("Introduction", target: "/introduction")
                .foregroundStyle(.primary)
                .font(.body)
                .margin(.top, 20)
                .margin(.bottom, 10)
        }
    }
}
