# FAIR website

This is a static site for the Fundamental AI Research Institute at UT Dallas.

## Edit content

Content lives in [`content/site.yml`](content/site.yml). Update the YAML values and lists there; do not edit the generated HTML pages by hand.

## Build

Ruby is used only for its built-in YAML parser and ERB-free generator, so there are no dependencies to install:

```sh
ruby build.rb
python3 -m http.server 8000
```

Open <http://localhost:8000> to review the generated site. The build creates `index.html`, `research.html`, `people.html`, `centers.html`, `opportunities.html`, `partnerships.html`, `news.html`, and `contact.html`.
