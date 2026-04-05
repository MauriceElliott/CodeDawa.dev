package codedawa

import "core:strings"
import "core:fmt"

generate_rss :: proc(articles: []Article) -> string {
	b := strings.builder_make()
	strings.write_string(&b, `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>`)
	strings.write_string(&b, SITE_NAME)
	strings.write_string(&b, `</title>
    <link>`)
	strings.write_string(&b, SITE_URL)
	strings.write_string(&b, `</link>
    <description>`)
	strings.write_string(&b, SITE_DESCRIPTION)
	strings.write_string(&b, `</description>
`)

	for &a in articles {
		link := strings.concatenate({SITE_URL, a.url})
		defer delete(link)
		rfc := date_rfc1123(a.date)
		defer delete(rfc)

		strings.write_string(&b, "    <item>\n      <title>")
		xml_escape(&b, a.title)
		strings.write_string(&b, "</title>\n      <link>")
		strings.write_string(&b, link)
		strings.write_string(&b, "</link>\n      <pubDate>")
		strings.write_string(&b, rfc)
		strings.write_string(&b, "</pubDate>\n      <author>")
		strings.write_string(&b, SITE_AUTHOR)
		strings.write_string(&b, "</author>\n      <guid>")
		strings.write_string(&b, link)
		strings.write_string(&b, "</guid>\n    </item>\n")
	}

	strings.write_string(&b, `  </channel>
</rss>
`)
	return strings.to_string(b)
}

generate_sitemap :: proc(articles: []Article) -> string {
	b := strings.builder_make()
	strings.write_string(&b, `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>`)
	strings.write_string(&b, SITE_URL)
	strings.write_string(&b, `/</loc>
  </url>
`)

	for &a in articles {
		strings.write_string(&b, "  <url>\n    <loc>")
		strings.write_string(&b, SITE_URL)
		strings.write_string(&b, a.url)
		strings.write_string(&b, "</loc>\n  </url>\n")
	}

	strings.write_string(&b, `</urlset>
`)
	return strings.to_string(b)
}

generate_robots :: proc() -> string {
	return fmt.aprintf("User-agent: *\nSitemap: %s/sitemap.xml\n", SITE_URL)
}
