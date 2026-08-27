const toggle = document.querySelector('.menu-toggle');
const nav = document.querySelector('.nav');

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
