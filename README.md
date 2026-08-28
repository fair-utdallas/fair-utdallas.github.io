# FAIR website

This is a static site for the Fundamental AI Research Institute at UT Dallas.

## Edit content

Content lives in the YAML files under [`content/`](content/). Update those values and lists; do not edit the generated HTML pages by hand.

## Build

Ruby is used only for its built-in YAML parser and ERB-free generator. The HTML files are generated artifacts; edit the YAML, then rebuild them:

```sh
ruby build.rb
python3 -m http.server 8000
```

Open <http://localhost:8000> to review the generated site. The build creates `index.html`, `research.html`, `people.html`, `centers.html`, `opportunities.html`, `partnerships.html`, `news.html`, and `contact.html`.

GitHub Pages builds the site from the YAML files automatically through the workflow in [`.github/workflows/pages.yml`](.github/workflows/pages.yml). Do not edit the generated HTML pages by hand.
