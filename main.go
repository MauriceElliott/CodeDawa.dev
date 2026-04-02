package main

import (
	"bytes"
	"encoding/xml"
	"flag"
	"fmt"
	"html/template"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/yuin/goldmark"
	meta "github.com/yuin/goldmark-meta"
	"github.com/yuin/goldmark/extension"
	"github.com/yuin/goldmark/parser"
	htmlrenderer "github.com/yuin/goldmark/renderer/html"
)

const (
	siteName        = "Codedawa"
	siteURL         = "https://codedawa.dev"
	siteAuthor      = "Maurice Elliott"
	siteDescription = "Code is code, Dawa is the cure."
)

type Article struct {
	Title      string
	Date       time.Time
	Categories string
	Body       template.HTML
	URL        string
	Image      string
	Tags       []string
}

func (a Article) DateFormatted() string { return a.Date.Format("Jan 2, 2006") }
func (a Article) DateLong() string      { return a.Date.Format("January 2, 2006") }
func (a Article) DateRFC1123() string   { return a.Date.Format(time.RFC1123Z) }
func (a Article) TagsStr() string       { return strings.Join(a.Tags, ", ") }

type PageData struct {
	PageTitle string
	Articles  []Article
	Article   *Article
}

var md = goldmark.New(
	goldmark.WithExtensions(
		extension.GFM,
		meta.Meta,
	),
	goldmark.WithParserOptions(
		parser.WithAutoHeadingID(),
	),
	goldmark.WithRendererOptions(
		htmlrenderer.WithUnsafe(),
	),
)

func main() {
	serve := flag.Bool("serve", false, "Start local dev server after build")
	port := flag.String("port", "8080", "Port for dev server")
	flag.Parse()

	if err := build(); err != nil {
		fmt.Fprintf(os.Stderr, "build error: %v\n", err)
		os.Exit(1)
	}

	if *serve {
		addr := ":" + *port
		fmt.Printf("Serving at http://localhost%s\n", addr)
		http.Handle("/", http.FileServer(http.Dir("Build")))
		if err := http.ListenAndServe(addr, nil); err != nil {
			fmt.Fprintf(os.Stderr, "server error: %v\n", err)
			os.Exit(1)
		}
	}
}

func build() error {
	fmt.Println("Building...")

	if err := os.RemoveAll("Build"); err != nil {
		return fmt.Errorf("cleaning Build/: %w", err)
	}
	if err := os.MkdirAll("Build", 0755); err != nil {
		return fmt.Errorf("creating Build/: %w", err)
	}

	tmpl, err := template.ParseGlob("templates/*.html")
	if err != nil {
		return fmt.Errorf("parsing templates: %w", err)
	}

	articles, err := loadArticles()
	if err != nil {
		return fmt.Errorf("loading articles: %w", err)
	}

	sort.Slice(articles, func(i, j int) bool {
		return articles[i].Date.After(articles[j].Date)
	})

	if err := copyAssets(); err != nil {
		return fmt.Errorf("copying assets: %w", err)
	}

	if err := renderPage(tmpl, "home", "Build/index.html", PageData{
		PageTitle: "",
		Articles:  articles,
	}); err != nil {
		return fmt.Errorf("rendering home: %w", err)
	}

	if err := renderPage(tmpl, "blog", "Build/blog/index.html", PageData{
		PageTitle: "All Posts",
		Articles:  articles,
	}); err != nil {
		return fmt.Errorf("rendering blog: %w", err)
	}

	for i := range articles {
		outPath := "Build" + articles[i].URL + "index.html"
		if err := renderPage(tmpl, "article", outPath, PageData{
			PageTitle: articles[i].Title,
			Article:   &articles[i],
		}); err != nil {
			return fmt.Errorf("rendering %q: %w", articles[i].Title, err)
		}
	}

	if err := generateRSS(articles); err != nil {
		return fmt.Errorf("generating RSS: %w", err)
	}
	if err := generateSitemap(articles); err != nil {
		return fmt.Errorf("generating sitemap: %w", err)
	}
	if err := generateRobots(); err != nil {
		return fmt.Errorf("generating robots.txt: %w", err)
	}

	// Copy CNAME for GitHub Pages if present.
	if _, err := os.Stat("CNAME"); err == nil {
		if err := copyFile("CNAME", "Build/CNAME"); err != nil {
			return fmt.Errorf("copying CNAME: %w", err)
		}
	}

	fmt.Printf("Done. Built %d article(s).\n", len(articles))
	return nil
}

func loadArticles() ([]Article, error) {
	var articles []Article
	err := filepath.WalkDir("Content", func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || !strings.HasSuffix(path, ".md") {
			return nil
		}
		article, err := parseArticle(path)
		if err != nil {
			return fmt.Errorf("parsing %s: %w", path, err)
		}
		articles = append(articles, article)
		return nil
	})
	return articles, err
}

func parseArticle(path string) (Article, error) {
	source, err := os.ReadFile(path)
	if err != nil {
		return Article{}, err
	}

	ctx := parser.NewContext()
	var buf bytes.Buffer
	if err := md.Convert(source, &buf, parser.WithContext(ctx)); err != nil {
		return Article{}, err
	}

	fm := meta.Get(ctx)

	title, _ := fm["title"].(string)
	categories, _ := fm["categories"].(string)
	image, _ := fm["image"].(string)

	var date time.Time
	switch v := fm["date"].(type) {
	case string:
		date, _ = time.Parse("2006-01-02 15:04", v)
	case time.Time:
		date = v
	}

	var tags []string
	if t, ok := fm["tags"].([]interface{}); ok {
		for _, tag := range t {
			if s, ok := tag.(string); ok {
				tags = append(tags, s)
			}
		}
	}

	rel, _ := filepath.Rel("Content", path)
	slug := filepath.ToSlash(strings.TrimSuffix(rel, ".md"))
	url := "/" + slug + "/"

	return Article{
		Title:      title,
		Date:       date,
		Categories: categories,
		Body:       template.HTML(buf.String()),
		URL:        url,
		Image:      image,
		Tags:       tags,
	}, nil
}

func renderPage(tmpl *template.Template, name, outPath string, data PageData) error {
	if err := os.MkdirAll(filepath.Dir(outPath), 0755); err != nil {
		return err
	}
	f, err := os.Create(outPath)
	if err != nil {
		return err
	}
	defer f.Close()
	return tmpl.ExecuteTemplate(f, name, data)
}

func copyAssets() error {
	return filepath.WalkDir("Assets", func(src string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel("Assets", src)
		dst := filepath.Join("Build", rel)
		if d.IsDir() {
			return os.MkdirAll(dst, 0755)
		}
		return copyFile(src, dst)
	})
}

func copyFile(src, dst string) error {
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, in)
	return err
}

// ── RSS ──────────────────────────────────────────────────────────────────────

type rssRoot struct {
	XMLName xml.Name   `xml:"rss"`
	Version string     `xml:"version,attr"`
	Channel rssChannel `xml:"channel"`
}

type rssChannel struct {
	Title       string    `xml:"title"`
	Link        string    `xml:"link"`
	Description string    `xml:"description"`
	Items       []rssItem `xml:"item"`
}

type rssItem struct {
	Title   string `xml:"title"`
	Link    string `xml:"link"`
	PubDate string `xml:"pubDate"`
	Author  string `xml:"author"`
	GUID    string `xml:"guid"`
}

func generateRSS(articles []Article) error {
	items := make([]rssItem, len(articles))
	for i, a := range articles {
		link := siteURL + a.URL
		items[i] = rssItem{
			Title:   a.Title,
			Link:    link,
			PubDate: a.DateRFC1123(),
			Author:  siteAuthor,
			GUID:    link,
		}
	}
	feed := rssRoot{
		Version: "2.0",
		Channel: rssChannel{
			Title:       siteName,
			Link:        siteURL,
			Description: siteDescription,
			Items:       items,
		},
	}
	out, err := xml.MarshalIndent(feed, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile("Build/feed.rss", append([]byte(xml.Header), out...), 0644)
}

// ── Sitemap ──────────────────────────────────────────────────────────────────

type urlSet struct {
	XMLName xml.Name     `xml:"urlset"`
	Xmlns   string       `xml:"xmlns,attr"`
	URLs    []sitemapURL `xml:"url"`
}

type sitemapURL struct {
	Loc string `xml:"loc"`
}

func generateSitemap(articles []Article) error {
	urls := []sitemapURL{{Loc: siteURL + "/"}}
	for _, a := range articles {
		urls = append(urls, sitemapURL{Loc: siteURL + a.URL})
	}
	sitemap := urlSet{
		Xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
		URLs:  urls,
	}
	out, err := xml.MarshalIndent(sitemap, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile("Build/sitemap.xml", append([]byte(xml.Header), out...), 0644)
}

// ── robots.txt ───────────────────────────────────────────────────────────────

func generateRobots() error {
	content := fmt.Sprintf("User-agent: *\nSitemap: %s/sitemap.xml\n", siteURL)
	return os.WriteFile("Build/robots.txt", []byte(content), 0644)
}
