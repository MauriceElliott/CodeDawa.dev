import Foundation
import Ignite

@main
struct IgniteWebsite {
    static func main() async {
        var site = Codedawa()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct Codedawa: Site {
    var name = "Codedawa"
    var titleSuffix = " – Code Dawa"
    var url = URL(static: "https://codedawa.dev")
    var builtInIconsEnabled = true

    var lightTheme: (any Theme)? = AutomataDay()
    var darkTheme: (any Theme)? = AutomataNight()
    var theme: (any Theme)? = AutomataNight()
    var author = "Maurice Elliott"
    var favicon: URL? { URL(static: "/favicon/logo.png") }

    var homePage = Home()
    var layout = MainLayout()
    
    var articlePages: [any ArticlePage] {
        ArticleLayout()
    }
}
