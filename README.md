# Codedawa

Source for [codedawa.dev](https://codedawa.dev), a personal blog built with a custom Odin static site generator.

## Building

Requires: [Odin](https://odin-lang.org/) and `libcmark-dev` (or via Homebrew: `brew install cmark`)

Build the site:

```bash
odin build src -out:codedawa
./codedawa
```

To build and serve locally (auto-detects first open port starting at 8000):

```bash
./build.sh
```

## Structure

- **Assets/**: Static assets (images, fonts, CSS)
- **Content/**: Markdown blog posts with YAML front matter
- **src/**: Odin source code
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
