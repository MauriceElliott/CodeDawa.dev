package codedawa

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import cm "vendor:commonmark"

Date :: struct {
	year:   int,
	month:  int,
	day:    int,
	hour:   int,
	minute: int,
}

Article :: struct {
	title:      string,
	date:       Date,
	categories: string,
	body:       string,
	url:        string,
	image:      string,
	tags:       [dynamic]string,
}

date_formatted :: proc(d: Date) -> string {
	months := [?]string{
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
	}
	m := months[d.month] if d.month >= 1 && d.month <= 12 else "???"
	return fmt.aprintf("%s %d, %d", m, d.day, d.year)
}

date_long :: proc(d: Date) -> string {
	months := [?]string{
		"", "January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December",
	}
	m := months[d.month] if d.month >= 1 && d.month <= 12 else "Unknown"
	return fmt.aprintf("%s %d, %d", m, d.day, d.year)
}

date_rfc1123 :: proc(d: Date) -> string {
	days_in_month := [?]int{0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	is_leap := (d.year % 4 == 0 && d.year % 100 != 0) || (d.year % 400 == 0)

	// Compute day of week using Tomohiko Sakamoto's algorithm
	y := d.year
	m := d.month
	day := d.day
	t := [?]int{0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4}
	if m < 3 do y -= 1
	dow := (y + y / 4 - y / 100 + y / 400 + t[m - 1] + day) %% 7

	day_names := [?]string{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
	month_names := [?]string{
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
	}

	return fmt.aprintf(
		"%s, %02d %s %d %02d:%02d:00 +0000",
		day_names[dow], d.day,
		month_names[d.month] if d.month >= 1 && d.month <= 12 else "???",
		d.year, d.hour, d.minute,
	)
}

date_to_unix :: proc(d: Date) -> i64 {
	// Simple days-since-epoch calculation for sorting
	days := i64(d.year) * 365 + i64(d.year / 4) - i64(d.year / 100) + i64(d.year / 400)
	days += i64(d.month) * 30 + i64(d.day)
	return days * 86400 + i64(d.hour) * 3600 + i64(d.minute) * 60
}

tags_str :: proc(tags: [dynamic]string) -> string {
	if len(tags) == 0 do return ""
	return strings.join(tags[:], ", ")
}

// Parse YYYY-MM-DD HH:MM date format
parse_date :: proc(s: string) -> Date {
	d: Date
	// Expected format: "2025-12-07 23:53"
	parts := strings.split(s, " ")
	defer delete(parts)
	if len(parts) < 1 do return d

	date_parts := strings.split(parts[0], "-")
	defer delete(date_parts)
	if len(date_parts) == 3 {
		d.year, _ = strconv.parse_int(date_parts[0])
		d.month, _ = strconv.parse_int(date_parts[1])
		d.day, _ = strconv.parse_int(date_parts[2])
	}

	if len(parts) >= 2 {
		time_parts := strings.split(parts[1], ":")
		defer delete(time_parts)
		if len(time_parts) >= 2 {
			d.hour, _ = strconv.parse_int(time_parts[0])
			d.minute, _ = strconv.parse_int(time_parts[1])
		}
	}
	return d
}

// Parse YAML-like frontmatter between --- delimiters
Frontmatter :: struct {
	title:      string,
	date:       string,
	categories: string,
	image:      string,
	tags:       [dynamic]string,
}

parse_frontmatter :: proc(source: string) -> (fm: Frontmatter, body: string) {
	// Check for opening ---
	if !strings.has_prefix(source, "---") do return fm, source

	// Find closing ---
	rest := source[3:]
	if len(rest) > 0 && rest[0] == '\n' do rest = rest[1:]
	if len(rest) > 0 && rest[0] == '\r' do rest = rest[1:]

	close_idx := strings.index(rest, "\n---")
	if close_idx < 0 do return fm, source

	header := rest[:close_idx]
	body = rest[close_idx + 4:]
	// Skip newline after closing ---
	if len(body) > 0 && body[0] == '\n' do body = body[1:]
	if len(body) > 0 && body[0] == '\r' do body = body[1:]

	// Parse key: value lines
	in_tags := false
	lines := strings.split(header, "\n")
	defer delete(lines)

	for line in lines {
		trimmed := strings.trim_space(line)
		if len(trimmed) == 0 do continue

		// Check for list item (tag)
		if in_tags && strings.has_prefix(trimmed, "- ") {
			tag := strings.trim_space(trimmed[2:])
			if len(tag) > 0 {
				append(&fm.tags, strings.clone(tag))
			}
			continue
		}

		in_tags = false
		colon := strings.index(trimmed, ":")
		if colon < 0 do continue

		key := strings.trim_space(trimmed[:colon])
		val := strings.trim_space(trimmed[colon + 1:])

		switch key {
		case "title":
			fm.title = strings.clone(val)
		case "date":
			fm.date = strings.clone(val)
		case "categories":
			fm.categories = strings.clone(val)
		case "image":
			fm.image = strings.clone(val)
		case "tags":
			in_tags = true
			// If tags are inline (tags: [a, b]), handle that too
			if len(val) > 0 && !strings.has_prefix(val, "[") {
				// Single tag on same line
				append(&fm.tags, strings.clone(val))
				in_tags = false
			}
		}
	}

	return fm, body
}

parse_article :: proc(rel_path: string) -> (article: Article, ok: bool) {
	data, read_err := os.read_entire_file_from_path(rel_path, context.allocator)
	if read_err != nil do return article, false
	defer delete(data)
	source := string(data)

	fm, body := parse_frontmatter(source)

	// Render markdown to HTML using cmark
	opts := cm.Options{.Unsafe}
	body_cstr := strings.clone_to_cstring(body)
	defer delete(body_cstr)
	html_cstr := cm.markdown_to_html(body_cstr, len(body), opts)
	defer cm.free(html_cstr)
	html := strings.clone(string(html_cstr))

	// Build URL from relative path (e.g. "Content/posts/foo.md" -> "/posts/foo/")
	after_content := rel_path
	if strings.has_prefix(rel_path, "Content/") {
		after_content = rel_path[len("Content/"):]
	}
	slug := strings.trim_suffix(after_content, ".md")
	slug_fwd, _ := strings.replace_all(slug, "\\", "/")
	defer if slug_fwd != slug do delete(slug_fwd)
	url := strings.concatenate({"/", slug_fwd, "/"})

	article = Article{
		title      = fm.title,
		date       = parse_date(fm.date),
		categories = fm.categories,
		body       = html,
		url        = url,
		image      = fm.image,
		tags       = fm.tags,
	}
	ok = true
	return
}

load_articles :: proc() -> (articles: [dynamic]Article, ok: bool) {
	articles = make([dynamic]Article)
	_walk_content("Content", &articles) or_return
	ok = true
	return
}

@(private)
_walk_content :: proc(dir: string, articles: ^[dynamic]Article) -> bool {
	fd, err := os.open(dir)
	if err != nil do return false
	defer os.close(fd)

	entries, read_err := os.read_dir(fd, -1, context.allocator)
	if read_err != nil do return false
	defer delete(entries)

	for entry in entries {
		// Build a relative path like "Content/posts/foo.md"
		rel_path := strings.concatenate({dir, "/", entry.name})
		defer delete(rel_path)

		if entry.type == .Directory {
			_walk_content(rel_path, articles) or_return
		} else if strings.has_suffix(entry.name, ".md") {
			article, parse_ok := parse_article(rel_path)
			if !parse_ok {
				fmt.eprintf("Warning: could not parse %s\n", rel_path)
				continue
			}
			append(articles, article)
		}
	}
	return true
}
