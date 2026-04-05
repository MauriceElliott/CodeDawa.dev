package codedawa

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

SITE_NAME        :: "Codedawa"
SITE_URL         :: "https://codedawa.dev"
SITE_AUTHOR      :: "Maurice Elliott"
SITE_DESCRIPTION :: "Code is code, Dawa is the cure."

main :: proc() {
	serve := false
	port := "8080"

	args := os.args[1:]
	for i := 0; i < len(args); i += 1 {
		switch args[i] {
		case "-serve":
			serve = true
		case "-port":
			if i + 1 < len(args) {
				port = args[i + 1]
				i += 1
			}
		}
	}

	if !build() {
		os.exit(1)
	}

	if serve {
		fmt.printf("Serving locally:\n  python3 -m http.server %s -d Build\n", port)
	}
}

build :: proc() -> bool {
	fmt.println("Building...")

	remove_dir_recursive("Build")
	if !make_dir_recursive("Build") {
		fmt.eprintln("Error: could not create Build/")
		return false
	}

	articles, ok := load_articles()
	if !ok {
		fmt.eprintln("Error: could not load articles")
		return false
	}

	// Sort by date descending (newest first)
	slice.sort_by(articles[:], proc(a, b: Article) -> bool {
		return date_to_unix(a.date) > date_to_unix(b.date)
	})

	if !copy_dir("Assets", "Build") {
		fmt.eprintln("Error: could not copy assets")
		return false
	}

	if !write_page("Build/index.html", render_home(articles[:])) {
		fmt.eprintln("Error: could not write index.html")
		return false
	}

	if !write_page("Build/blog/index.html", render_blog(articles[:])) {
		fmt.eprintln("Error: could not write blog/index.html")
		return false
	}

	for &a in articles {
		out_path := strings.concatenate({"Build", a.url, "index.html"})
		defer delete(out_path)
		if !write_page(out_path, render_article(&a)) {
			fmt.eprintf("Error: could not write article %s\n", a.title)
			return false
		}
	}

	if !write_file("Build/feed.rss", generate_rss(articles[:])) {
		fmt.eprintln("Error: could not write feed.rss")
		return false
	}
	if !write_file("Build/sitemap.xml", generate_sitemap(articles[:])) {
		fmt.eprintln("Error: could not write sitemap.xml")
		return false
	}
	if !write_file("Build/robots.txt", generate_robots()) {
		fmt.eprintln("Error: could not write robots.txt")
		return false
	}

	if os.exists("CNAME") {
		if !copy_file("CNAME", "Build/CNAME") {
			fmt.eprintln("Error: could not copy CNAME")
			return false
		}
	}

	fmt.printf("Done. Built %d article(s).\n", len(articles))
	return true
}

write_page :: proc(path: string, content: string) -> bool {
	dir := filepath_dir(path)
	defer delete(dir)
	if !make_dir_recursive(dir) do return false
	return os.write_entire_file(path, transmute([]u8)content) == nil
}

write_file :: proc(path: string, content: string) -> bool {
	return os.write_entire_file(path, transmute([]u8)content) == nil
}

filepath_dir :: proc(path: string) -> string {
	last_slash := strings.last_index(path, "/")
	if last_slash < 0 do return strings.clone(".")
	return strings.clone(path[:last_slash])
}
