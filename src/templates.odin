package codedawa

import "core:fmt"
import "core:strings"

// Render the <head>, opening <body>, and <header> section
render_head :: proc(b: ^strings.Builder, page_title: string) {
	strings.write_string(
		b,
		`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="author" content="Maurice Elliott">
  <title>`,
	)
	if len(page_title) > 0 {
		xml_escape(b, page_title)
		strings.write_string(b, " – Code Dawa")
	} else {
		strings.write_string(b, "Code Dawa")
	}
	strings.write_string(
		b,
		`</title>
  <link rel="stylesheet" href="/css/style.css">
  <link rel="icon" href="/favicon/logo.png">
  <link rel="alternate" type="application/rss+xml" title="Codedawa" href="/feed.rss">
</head>
<body>
`,
	)
}

render_header :: proc(b: ^strings.Builder) {
	strings.write_string(
		b,
		`<header>
  <a href="/" class="site-title">CodeDawa</a>
  <p class="tagline">Code is code, Dawa is the cure.</p>
</header>
`,
	)
}

render_footer :: proc(b: ^strings.Builder) {
	strings.write_string(b, `</body>
</html>
`)
}

render_home :: proc(articles: []Article) -> string {
	b := strings.builder_make()
	render_head(&b, "")
	render_header(&b)

	strings.write_string(
		&b,
		`
<main>
  <img
    src="/images/home_art-export.png"
    alt="pixel art of a computer, a keyboard, and a large cup of tea."
    class="home-art"
    width="250"
  >

  <p>
    My name is <strong>Maurice</strong>, I am a <strong>software engineer</strong>,
    <strong>father</strong>, <strong>creative</strong>, and lover of all things sad and
    desperate.<br>
    This website is not a professional place, just somewhere I feel comfortable exposing
    a little of my inner being to the wider internet, in the hopes that it makes others
    feel normal in their own skin. At the same time it is for me mostly, and if I feel
    better after posting here, it has done its job.<br>
    <strong>Dawa</strong> is arabic for medicine, or <strong>cure</strong>. My implication
    with that is I found the cure to my addictions through code. Although saying that, it
    was definitely more my son being in the world that cured me.
  </p>

  <section class="links">
    <p><strong>Links:</strong></p>
    <a href="https://github.com/MauriceElliott">Github</a>
  </section>

  <section class="musings">
    <p><strong>Posts:</strong></p>
`,
	)

	for &a in articles {
		df := date_formatted(a.date)
		defer delete(df)
		fmt.sbprintf(
			&b,
			"    <p>\n      <strong>%s</strong> –\n      <a href=\"%s\">",
			df,
			a.url,
		)
		xml_escape(&b, a.title)
		strings.write_string(&b, "</a>\n    </p>\n")
	}

	strings.write_string(&b, `  </section>
</main>

`)
	render_footer(&b)
	return strings.to_string(b)
}

render_blog :: proc(articles: []Article) -> string {
	b := strings.builder_make()
	render_head(&b, "All Posts")
	render_header(&b)

	strings.write_string(
		&b,
		`
<main>
  <h1>All Posts</h1>
  <p class="date">Archive of all musings and articles.</p>

  <ul class="post-list">
`,
	)

	for &a in articles {
		df := date_formatted(a.date)
		defer delete(df)
		strings.write_string(&b, "    <li>\n      <a href=\"")
		strings.write_string(&b, a.url)
		strings.write_string(&b, "\">")
		xml_escape(&b, a.title)
		strings.write_string(&b, "</a>\n      <span class=\"date\">")
		strings.write_string(&b, df)
		strings.write_string(&b, "</span>\n    </li>\n")
	}

	strings.write_string(&b, `  </ul>
</main>

`)
	render_footer(&b)
	return strings.to_string(b)
}

render_article :: proc(a: ^Article) -> string {
	b := strings.builder_make()
	render_head(&b, a.title)
	render_header(&b)

	dl := date_long(a.date)
	defer delete(dl)

	strings.write_string(&b, "\n<main class=\"article\">\n  <h1>")
	xml_escape(&b, a.title)
	strings.write_string(&b, "</h1>\n  <p class=\"date\">")
	strings.write_string(&b, dl)
	strings.write_string(&b, "</p>\n")

	if len(a.image) > 0 {
		strings.write_string(&b, "\n  <img src=\"")
		strings.write_string(&b, a.image)
		strings.write_string(&b, "\" alt=\"\" class=\"featured-image\">\n")
	}

	if len(a.tags) > 0 {
		ts := tags_str(a.tags)
		defer delete(ts)
		strings.write_string(&b, "\n  <p class=\"tags\">Tagged with: ")
		xml_escape(&b, ts)
		strings.write_string(&b, "</p>\n")
	}

	strings.write_string(&b, "\n  <div class=\"article-body\">\n    ")
	strings.write_string(&b, a.body)
	strings.write_string(&b, "\n  </div>\n</main>\n\n")

	render_footer(&b)
	return strings.to_string(b)
}

// Escape special HTML characters
xml_escape :: proc(b: ^strings.Builder, s: string) {
	for ch in s {
		switch ch {
		case '&':
			strings.write_string(b, "&amp;")
		case '<':
			strings.write_string(b, "&lt;")
		case '>':
			strings.write_string(b, "&gt;")
		case '"':
			strings.write_string(b, "&quot;")
		case '\'':
			strings.write_string(b, "&#39;")
		case:
			strings.write_rune(b, ch)
		}
	}
}

