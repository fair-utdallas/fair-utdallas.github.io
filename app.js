const toggle = document.querySelector('.menu-toggle');
const nav = document.querySelector('.nav');

const pageLinks = [['partnerships.html', 'Partnerships'], ['news.html', 'News']];
pageLinks.forEach(([href, label]) => {
  if (nav && !nav.querySelector(`[href="${href}"]`)) {
    const link = document.createElement('a');
    link.href = href;
    link.textContent = label;
    nav.insertBefore(link, nav.querySelector('.nav-contact'));
  }
});

toggle?.addEventListener('click', () => {
  const open = nav.classList.toggle('open');
  toggle.setAttribute('aria-expanded', String(open));
});

document.querySelectorAll('.nav a').forEach((link) => {
  link.addEventListener('click', () => {
    nav.classList.remove('open');
    toggle?.setAttribute('aria-expanded', 'false');
  });
});

const sections = [...document.querySelectorAll('.page-section')];
const links = [...document.querySelectorAll('.nav a')];
const highlight = () => {
  const current = sections.reduce((active, section) => {
    if (window.scrollY >= section.offsetTop - 130) return section.id;
    return active;
  }, 'home');
  links.forEach((link) => link.classList.toggle('active', link.getAttribute('href') === `#${current}`));
};
window.addEventListener('scroll', highlight, { passive: true });
highlight();
