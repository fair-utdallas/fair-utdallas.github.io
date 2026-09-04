#!/usr/bin/env ruby
# Static site generator for FAIR. Edit content/site.yml, then run: ruby build.rb
require "yaml"
require "cgi"

content_dir = File.join(__dir__, "content")
DATA = Dir[File.join(content_dir, "*.yml")].sort.reduce({}) do |data, file|
  data.merge(YAML.load_file(file))
end
SITE = DATA.fetch("site")

def h(value)
  CGI.escapeHTML(value.to_s)
end

def nav(active)
  items = DATA.fetch("nav").map do |item|
    active_class = item["url"] == active ? ' class="active"' : ""
    "      <a#{active_class} href=\"#{h(item["url"])}\">#{h(item["label"])} </a>"
  end
  items << "      <a class=\"nav-contact\" href=\"contact.html\">#{h(SITE["nav_contact"])} <span>#{h(SITE["link_arrow"])}</span></a>"
  items.join("\n")
end

def layout(title, active, body, footer: true)
  footer_html = footer ? %Q{<footer class="footer">\n      <span>© #{h(SITE["year"])} #{h(SITE["full_name"])}</span>\n      <span>#{h(SITE["university"])}</span>\n      <a href="contact.html">#{h(SITE["footer_contact"])}</a>\n    </footer>} : ""
  <<~HTML
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="description" content="#{h(SITE["full_name"])} at #{h(SITE["university"])}.">
      <title>#{h(title)} — #{h(SITE["name"])}</title>
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
      <link rel="stylesheet" href="styles.css">
    </head>
    <body>
      <div class="site-shell">
        <header class="topbar">
          <a class="brand" href="index.html" aria-label="#{h(SITE["name"])} home">
            <img class="brand-logo" src="#{h(SITE["logo"]["full"])}" alt="" aria-hidden="true">
          </a>
          <button class="menu-toggle" aria-label="#{h(SITE["menu_label"])}" aria-expanded="false"><span></span><span></span></button>
          <nav class="nav" aria-label="Main navigation">
    #{nav(active)}
          </nav>
        </header>
        <main>
    #{body}
        </main>
        #{footer_html}
      </div>
      <script src="app.js"></script>
    </body>
    </html>
  HTML
end

def subhero(label, title, intro, orange: false)
  klass = orange ? "subhero compact orange-hero" : "subhero compact"
  <<~HTML
    <section class="#{klass}">
      <div class="section-label">#{h(label)}</div>
      <h1>#{title.gsub("\n", "<br>")} </h1>
      <p>#{h(intro)}</p>
    </section>
  HTML
end

def intro_band(title, text)
  <<~HTML
    <div class="intro-band">
      <h2>#{title.gsub("\n", "<br>")}</h2>
      <p>#{h(text)}</p>
    </div>
  HTML
end

def write_page(file, title, active, body, footer: true)
  File.write(File.join(__dir__, file), layout(title, active, body, footer: footer))
end

home = DATA["home"]
thrusts = DATA.fetch("research").fetch("items")
visual = SITE["visual"]
home_cards = home["research_featured"].map do |i|
  item = thrusts.fetch(i)
  <<~HTML
    <a class="research-card" href="research.html">
      <h3>#{h(item["title"])}</h3>
      <p>#{h(item["text"])}</p>
      <b>#{h(item["lead"])}</b>
    </a>
  HTML
end.join
home_cards += <<~HTML
  <a class="research-card featured" href="research.html">
      <span class="card-arrow">#{h(SITE["link_arrow"])}</span>
    <h3>#{h(home["research_cta"])}</h3>
    <p>#{h(home["research_cta_text"])}</p>
  </a>
HTML
opportunities_all = DATA.fetch("opportunities").fetch("items")
home_opps = home["education_featured"].map do |i|
  item = opportunities_all.fetch(i)
  %Q{<div><span>#{format("%02d", i + 1)}</span><h3>#{h(item["title"])}</h3><p>#{h(item["text"])}</p></div>}
end.join
home_domains = home["why_domains"].map { |d| "<span>#{h(d)}</span>" }.join
home_body = <<~HTML
  <section class="hero page-section" id="home">
    <div class="hero-copy">
      <p class="eyebrow">#{h(home["eyebrow"])}</p>
      <h1>#{home["title"].gsub("\n", "<br>")}</h1>
      <p class="hero-intro">#{h(home["intro"])}</p>
    <a class="button button-dark" href="research.html">#{h(home["explore_label"])} <span>#{h(SITE["down_arrow"])}</span></a>
  </div>
    <div class="hero-visual" aria-label="#{h(home["visual_label"])}"><div class="orbit orbit-one"></div><div class="orbit orbit-two"></div><div class="orbit orbit-three"></div><div class="core"><img src="#{h(SITE["logo"]["small"])}" alt="FAIR logo"></div><span class="node node-a">#{h(visual["nodes"][0])}</span><span class="node node-b">#{h(visual["nodes"][1])}</span><span class="node node-c">#{h(visual["nodes"][2])}</span><span class="node node-d">#{h(visual["nodes"][3])}</span><svg class="constellation" viewBox="0 0 600 600" aria-hidden="true"><path d="M105 187L245 92 432 156 502 355 364 487 164 424zM245 92l119 395M432 156L164 424M105 187l397 168M105 187l59 237" /></svg></div>
  </section>
  <section class="statement page-section">
    <div class="section-label">#{h(home["institute_label"])}</div>
    <div class="statement-content"><p class="display-copy">#{h(home["statement"])}</p><p class="body-copy">#{h(home["statement_detail"])}</p></div>
  </section>
  <section class="dark-band page-section" id="why">
    <div class="section-label">#{h(home["why_label"])}</div>
    <div class="dark-band-grid">
      <h2>#{home["why_title"].gsub("\n", "<br>")}</h2>
      <div>
        <p>#{home["why_lead"]}</p>
        <p>#{h(home["why_detail"])}</p>
        <a class="text-link" href="research.html">#{h(home["why_link"])} <span>#{h(SITE["link_arrow"])}</span></a>
      </div>
    </div>
    <div class="partner-lines">#{home_domains}</div>
  </section>
  <section class="research page-section" id="research">
    <div class="section-heading">
      <div>
        <div class="section-label">#{h(home["research_label"])}</div>
        <h2>#{home["research_title"].gsub("\n", "<br>")}</h2>
      </div>
      <p>#{h(home["research_intro"])}</p>
    </div>
    <div class="research-grid">
  #{home_cards}
    </div>
  </section>
  <section class="education dark-band page-section" id="education">
    <div class="section-label">#{h(home["education_label"])}</div>
    <div class="education-grid">
      <div>
        <h2>#{home["education_title"].gsub("\n", "<br>")}</h2>
        <p>#{h(home["education_intro"])}</p>
        <a class="text-link" href="opportunities.html">#{h(home["education_link"])} <span>#{h(SITE["link_arrow"])}</span></a>
      </div>
      <div class="opportunity-stack">#{home_opps}</div>
    </div>
  </section>
  <section class="contact page-section" id="contact">
    <div class="contact-orb" aria-hidden="true"></div>
    <div class="section-label">#{h(home["contact_label"])}</div>
    <h2>#{home["contact_title"].gsub("\n", "<br>")}</h2>
    <p>#{h(home["contact_intro"])}</p>
    <a class="button button-light" href="mailto:#{h(SITE["email"])}">#{h(SITE["email"])} <span>#{h(SITE["link_arrow"])}</span></a>
    <div class="contact-footer"><span>© #{h(SITE["year"])} #{h(SITE["full_name"])}</span><span>#{h(SITE["university"])}</span><a href="contact.html">#{h(SITE["footer_contact"])}</a></div>
  </section>
HTML
write_page("index.html", SITE["full_name"], "", home_body, footer: false)

research = DATA["research"]
research_items = research["items"].each_with_index.map do |item, i|
  <<~HTML
    <article>
      <span>#{format("%02d", i + 1)}</span>
      <div><h3>#{h(item["title"])}</h3><p>#{h(item["text"])}</p></div>
      <b>#{h(item["lead"])}</b>
    </article>
  HTML
end.join
write_page("research.html", research["label"], "research.html", subhero(research["label"], research["title"], research["intro"]) + <<~HTML
  <section class="content-page">
    #{intro_band(research["section_title"], research["section_intro"])}
    <div class="thrust-list">
  #{research_items}
    </div>
  </section>
HTML
)

people = DATA["people"]
leadership = people["leadership"].map do |p|
  image = p["image"] ? %Q{<img class="person-image" src="#{h(p["image"])}" alt="#{h(p["name"])}">} : ""
  %Q{<div class="profile featured-profile">#{image}<span>#{h(p["role"])}</span><h3>#{h(p["name"])}</h3><p>#{h(p["text"])}</p></div>}
end.join
names = ->(list) { list.each_with_index.map { |p, i| image = p["image"] ? %Q{<img class="person-image" src="#{h(p["image"])}" alt="#{h(p["name"])}">} : ""; "<div>#{image}<h3>#{h(p["name"])}</h3><p>#{h(p["area"])}</p></div>" }.join }
people_body = subhero(people["label"], people["title"], people["intro"]) + <<~HTML
  <section class="content-page">
    <div class="people-group"><h2>#{h(people["groups"]["leadership"])}</h2><div class="profile-grid">#{leadership}</div></div>
    <div class="people-group"><h2>#{h(people["groups"]["council"])}</h2><div class="name-grid">#{names.call(people["council"])}</div></div>
    <div class="people-group"><h2>#{h(people["groups"]["co_pis"])}</h2><div class="name-grid co-pis">#{names.call(people["co_pis"])}</div></div>
    <div class="people-group"><h2>#{h(people["groups"]["affiliated_faculty"])}</h2><p class="group-intro">#{h(people["affiliated_intro"])}</p><div class="name-grid affiliated-faculty">#{names.call(people["affiliated_faculty"])}</div></div>
    <div class="people-group"><h2>#{h(people["groups"]["external_affiliates"])}</h2><div class="name-grid external-affiliates">#{names.call(people["external_affiliates"])}</div></div>
  </section>
HTML
write_page("people.html", people["label"], "people.html", people_body)

def entity_rows(items)
  items.each_with_index.map { |item, i| "<div><span>#{format("%02d", i + 1)}</span><h3>#{h(item["name"])}</h3><p>#{h(item["text"])}</p></div>" }.join
end
centers = DATA["centers"]
centers_body = subhero(centers["label"], centers["title"], centers["intro"]) + <<~HTML
  <section class="content-page">
    #{intro_band(centers["founding_title"], centers["founding_intro"])}
    <div class="entity-list">#{entity_rows(centers["founding"])}</div>
    <div class="partner-intro">#{intro_band(centers["partners_title"], centers["partners_intro"] )}</div>
    <div class="entity-list partner-list">#{entity_rows(centers["partners"])}</div>
  </section>
HTML
write_page("centers.html", centers["label"], "centers.html", centers_body)

opps = DATA["opportunities"]
opp_cards = opps["items"].each_with_index.map { |item, i| "<article><span>#{format("%02d", i + 1)}</span><h3>#{h(item["title"])}</h3><p>#{h(item["text"])}</p></article>" }.join
write_page("opportunities.html", opps["label"], "opportunities.html", subhero(opps["label"], opps["title"], opps["intro"]) + <<~HTML
  <section class="content-page">
    #{intro_band(opps["section_title"], opps["section_intro"])}
    <div class="opportunity-cards">#{opp_cards}</div>
    <div class="callout"><span>#{h(opps["callout_label"])}</span><h2>#{opps["callout_title"].gsub("\n", "<br>")}</h2><a class="button button-dark" href="contact.html">#{h(opps["callout_button"])} <span>#{h(SITE["link_arrow"])}</span></a></div>
  </section>
HTML
)

partnerships = DATA["partnerships"]
partnership_rows = partnerships["items"].each_with_index.map { |item, i| "<div><span>#{format("%02d", i + 1)}</span><div><h3>#{h(item["title"])}</h3><p>#{h(item["text"])}</p></div></div>" }.join
write_page("partnerships.html", partnerships["label"], "partnerships.html", subhero(partnerships["label"], partnerships["title"], partnerships["intro"]) + <<~HTML
  <section class="content-page">
    #{intro_band(partnerships["section_title"], partnerships["section_intro"])}
    <div class="partnership-rows">#{partnership_rows}</div>
    <div class="application-band"><h2>#{partnerships["application_title"].gsub("\n", "<br>")}</h2><p>#{h(partnerships["application_intro"])}</p><a class="button button-dark" href="contact.html">#{h(partnerships["application_button"])} <span>#{h(SITE["link_arrow"])}</span></a></div>
  </section>
HTML
)

news = DATA["news"]
write_page("news.html", news["label"], "news.html", subhero(news["label"], news["title"], news["intro"]) + <<~HTML
  <section class="content-page"><div class="empty-news large-empty"><span>#{h(news["status"])}</span><h2>#{news["placeholder_title"].gsub("\n", "<br>")}</h2><p>#{h(news["placeholder"])}</p></div></section>
HTML
)

contact = DATA["contact"]
write_page("contact.html", contact["label"], "contact.html", <<~HTML
  <section class="contact contact-page">
    <div class="contact-orb" aria-hidden="true"></div><div class="section-label">#{h(contact["label"])}</div>
    <h1>#{contact["title"].gsub("\n", "<br>")}</h1>
    <p>#{h(contact["intro"])}</p>
    <a class="button button-light" href="mailto:#{h(SITE["email"])}">#{h(SITE["email"])} <span>#{h(SITE["link_arrow"])}</span></a>
    <div class="contact-details"><div><span>#{h(contact["institute_label"])}</span><p>#{h(SITE["full_name"])}<br>#{h(SITE["university"])}</p></div><div><span>#{h(contact["email_label"])}</span><p><a href="mailto:#{h(SITE["email"])}">#{h(SITE["email"])}</a></p></div></div>
  </section>
HTML
)

puts "Built #{%w[index research people centers opportunities partnerships news contact].length} FAIR pages from content/*.yml"
