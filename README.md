# Codedawa

Source for [codedawa.dev](https://codedawa.dev), a personal blog built with a custom Go static site generator.

## Building

```bash
go run .
```

To preview locally:

```bash
go run . -serve
# site available at http://localhost:8080
```

To compile a binary:

```bash
go build -o codedawa && ./codedawa
```

## Structure

- **Assets/**: Static assets (images, fonts, CSS)
- **Content/**: Markdown blog posts with YAML front matter
- **templates/**: Go HTML templates
- **Build/**: Generated HTML (output, deploy this directory)

## Adding a post

Create a `.md` file anywhere under `Content/` with YAML front matter:

```markdown
---
title: Post title
date: 2026-01-01 12:00
categories: some_category
---

Content here.
```

The URL is derived from the file path: `Content/posts/my-post.md` → `/posts/my-post/`.
