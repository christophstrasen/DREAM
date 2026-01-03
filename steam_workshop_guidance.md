# Steam Workshop description guidance (Steam BBCode / “BBStyle”)

Steam Workshop item descriptions use Steam’s BBCode-style markup (not Markdown/HTML). This document lists the subset we assume is safe to use in `workshop.txt` descriptions in this workspace.

## Supported elements (assumed safe)

- **Headings:** `[h1]Title[/h1]`, `[h2]Section[/h2]`, `[h3]Subsection[/h3]`
- **Emphasis:** `[b]bold[/b]`, `[i]italic[/i]`, `[u]underline[/u]`
- **Horizontal rule:** `[hr][/hr]`
- **Links:** `[url]https://example.com[/url]`, `[url=https://example.com]link text[/url]`
- **Lists:** `[list]` + `[*]` items + `[/list]`
- **Images:** `[img]https://host/path.png[/img]`
- **Quotes:** `[quote]quoted text[/quote]`
- **Code blocks:** `[code]monospace text[/code]`
- **Spoilers:** `[spoiler]hidden text[/spoiler]`

## Usage notes / gotchas

- **Lists require `[*]` for every item.** Lines that start with `[]` will render those brackets literally.
- **Always close tags**; malformed nesting can cause large sections to render incorrectly.
- **Strikethrough is not reliable** in Workshop descriptions (we observed `[s]...[/s]` not rendering). Avoid depending on it.
- **`[noparse]` is inconsistent**, and links may still render as links (Steam also auto-links bare URLs).
  - To show literal BBCode or URLs, prefer: `[code]...[/code]`
  - To avoid auto-linking in normal text, break the URL (e.g. `example (dot) com` or insert a space like `example. com`).
- **Images:** prefer HTTPS and reasonable sizes; some hosts/content may be blocked or proxied by Steam.

## Minimal “kitchen sink” snippet

```text
[h1]Title[/h1]
[i]One-line summary.[/i]
[hr][/hr]

[h2]Links[/h2]
[list]
[*][url=https://example.com]Homepage[/url]
[*][url]https://example.com/changelog[/url]
[/list]

[h2]Install[/h2]
[list]
[*]Subscribe
[*]Enable in Mods
[/list]

[quote]A short quote.[/quote]
[code]-- code / literal bbcode here[/code]
[spoiler]Hidden details[/spoiler]
```

