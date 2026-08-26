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
  items << "      <a class=\"nav-contact\" href=\"contact.html\">Get in touch <span>↗</span></a>"
  items.join("\n")
end

def layout(title, active, body)
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
          <a class="brand" href="index.html" aria-label="FAIR home">
            <span class="brand-mark">F</span>
            <span><strong>#{h(SITE["name"])}</strong><small>#{h(SITE["full_name"])}</small></span>
          </a>
          <button class="menu-toggle" aria-label="Toggle menu" aria-expanded="false"><span></span><span></span></button>
          <nav class="nav" aria-label="Main navigation">
    #{nav(active)}
          </nav>
        </header>
        <main>
    #{body}
        </main>
        <footer class="footer">
          <span>© #{h(SITE["year"])} #{h(SITE["full_name"])}</span>
          <span>#{h(SITE["university"])}</span>
          <a href="contact.html">Contact</a>
        </footer>
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

def write_page(file, title, active, body)
  File.write(File.join(__dir__, file), layout(title, active, body))
end

home = DATA["home"]
thrusts = DATA.fetch("research").fetch("items")
home_cards = home["research_featured"].map do |i|
  item = thrusts.fetch(i)
  <<~HTML
    <a class="research-card" href="research.html">
      <span class="card-number">#{format("%02d", i + 1)}</span>
      <h3>#{h(item["title"])}</h3>
      <p>#{h(item["text"])}</p>
      <b>#{h(item["lead"])}</b>
    </a>
  HTML
end.join
home_cards += <<~HTML
  <a class="research-card featured" href="research.html">
    <span class="card-arrow">\u2197</span>
    <span class="card-number">#{thrusts.length}</span>
    <h3>#{h(home["research_cta"])}</h3>
    <p>#{h(home["research_cta_text"])}</p>
  </a>
HTML
home_body = <<~HTML
  <section class="hero page-section" id="home">
    <div class="hero-copy">
      <p class="eyebrow">#{h(home["eyebrow"])}</p>
      <h1>#{home["title"].gsub("\n", "<br>").sub("intelligence.", "<em>intelligence.</em>")}</h1>
      <p class="hero-intro">#{h(home["intro"])}</p>
      <a class="button button-dark" href="research.html">Explore our research <span>↘</span></a>
    </div>
    <div class="hero-visual"><div class="orbit orbit-one"></div><div class="orbit orbit-two"></div><div class="orbit orbit-three"></div><div class="core">FAIR<span>UTD</span></div><span class="node node-a">learn</span><span class="node node-b">reason</span><span class="node node-c">perceive</span><span class="node node-d">act</span><svg class="constellation" viewBox="0 0 600 600" aria-hidden="true"><path d="M105 187L245 92 432 156 502 355 364 487 164 424zM245 92l119 395M432 156L164 424M105 187l397 168M105 187l59 237" /></svg></div>
  </section>
  <section class="statement page-section">
    <div class="section-label">The institute</div>
    <div class="statement-content"><p class="display-copy">#{h(home["statement"])}</p><p class="body-copy">#{h(home["statement_detail"])}</p></div>
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
HTML
write_page("index.html", SITE["full_name"], "", home_body)

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
write_page("research.html", "Research", "research.html", subhero("Research", "Foundations for\ntrustworthy intelligence.", research["intro"]) + <<~HTML
  <section class="content-page">
    #{intro_band("Thirteen paths.\n<em>One shared agenda.</em>", "From tractable inference to multimodal reasoning, FAIR connects theory, algorithms, perception, language, and action across the full arc of intelligent behavior.")}
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
people_body = subhero("People", "A community of\ncurious minds.", people["intro"]) + <<~HTML
  <section class="content-page">
    <div class="people-group"><h2>Leadership</h2><div class="profile-grid">#{leadership}</div></div>
    <div class="people-group"><h2>Executive Council</h2><div class="name-grid">#{names.call(people["council"])}</div></div>
    <div class="people-group"><h2>Co-Principal Investigators</h2><div class="name-grid co-pis">#{names.call(people["co_pis"])}</div></div>
    <div class="people-group"><h2>Affiliated Faculty</h2><p class="group-intro">Faculty affiliated with FAIR span computer science, cognitive science, engineering, philosophy, biology, and public policy.</p><div class="name-grid affiliated-faculty">#{names.call(people["affiliated_faculty"])}</div></div>
    <div class="people-group"><h2>External Affiliates</h2><div class="name-grid external-affiliates">#{names.call(people["external_affiliates"])}</div></div>
  </section>
HTML
write_page("people.html", "People", "people.html", people_body)

def entity_rows(items)
  items.each_with_index.map { |item, i| "<div><span>#{format("%02d", i + 1)}</span><h3>#{h(item["name"])}</h3><p>#{h(item["text"])}</p></div>" }.join
end
centers = DATA["centers"]
centers_body = subhero("Centers + partners", "One institute.\nMany strengths.", "FAIR gives UT Dallas’s AI community a shared identity and a platform for collaboration.") + <<~HTML
  <section class="content-page">
    #{intro_band("Founding\n<em>centers.</em>", "Each center retains its own identity and leadership. FAIR connects their expertise into a cohesive research agenda.")}
    <div class="entity-list">#{entity_rows(centers["founding"])}</div>
    <div class="partner-intro">#{intro_band("Partner\n<em>institutes.</em>", "FAIR extends its reach through close collaboration with partner institutes and groups.")}</div>
    <div class="entity-list partner-list">#{entity_rows(centers["partners"])}</div>
  </section>
HTML
write_page("centers.html", "Centers + Partners", "centers.html", centers_body)

opps = DATA["opportunities"]
opp_cards = opps["items"].each_with_index.map { |item, i| "<article><span>#{format("%02d", i + 1)}</span><h3>#{h(item["title"])}</h3><p>#{h(item["text"])}</p></article>" }.join
write_page("opportunities.html", "Education + Opportunities", "opportunities.html", subhero("Education + opportunities", "Learn by\ndoing the work.", opps["intro"]) + <<~HTML
  <section class="content-page">
    #{intro_band("The next generation\n<em>starts here.</em>", "Research-intensive training and interdisciplinary learning are central to FAIR’s mission at UT Dallas.")}
    <div class="opportunity-cards">#{opp_cards}</div>
    <div class="callout"><span>Interested in joining FAIR?</span><h2>Bring your<br><em>question.</em></h2><a class="button button-dark" href="contact.html">Get in touch <span>↗</span></a></div>
  </section>
HTML
)

partnerships = DATA["partnerships"]
partnership_rows = partnerships["items"].each_with_index.map { |item, i| "<div><span>#{format("%02d", i + 1)}</span><div><h3>#{h(item["title"])}</h3><p>#{h(item["text"])}</p></div></div>" }.join
write_page("partnerships.html", "Industry + Government", "partnerships.html", subhero("Industry + government", "Research that\ntravels.", partnerships["intro"], orange: true) + <<~HTML
  <section class="content-page">
    #{intro_band("From fundamental\n<em>questions to impact.</em>", "Partnerships help translate advances in learning, reasoning, perception, language, and trustworthy AI into real-world practice.")}
    <div class="partnership-rows">#{partnership_rows}</div>
    <div class="application-band"><h2>Let’s build<br><em>what’s next.</em></h2><p>FAIR welcomes conversations with industry, government, nonprofit, and academic organizations.</p><a class="button button-dark" href="contact.html">Start a conversation <span>↗</span></a></div>
  </section>
HTML
)

news = DATA["news"]
write_page("news.html", "News + Events", "news.html", subhero("News + events", "What’s\nahead.", news["intro"]) + <<~HTML
  <section class="content-page"><div class="empty-news large-empty"><span>Coming soon</span><h2>We’re preparing the<br><em>first updates.</em></h2><p>#{h(news["placeholder"])}</p></div></section>
HTML
)

write_page("contact.html", "Contact", "contact.html", <<~HTML
  <section class="contact contact-page">
    <div class="contact-orb" aria-hidden="true"></div><div class="section-label">Contact</div>
    <h1>Let’s explore<br><em>what’s possible.</em></h1>
    <p>Whether you’re a researcher, student, partner, or simply curious about fundamental AI, we’d like to hear from you.</p>
    <a class="button button-light" href="mailto:#{h(SITE["email"])}">#{h(SITE["email"])} <span>↗</span></a>
    <div class="contact-details"><div><span>Institute</span><p>#{h(SITE["full_name"])}<br>#{h(SITE["university"])}</p></div><div><span>Email</span><p><a href="mailto:#{h(SITE["email"])}">#{h(SITE["email"])}</a></p></div></div>
  </section>
HTML
)

puts "Built #{%w[index research people centers opportunities partnerships news contact].length} FAIR pages from content/site.yml"
