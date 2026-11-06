// director's helpers for a composition: zooms on footage and the music's beat grid.
// Pure functions of their arguments, so renders stay deterministic.
(function () {
  // A zoom on footage. The clip plays in a card of cardW x cardH; its source is srcW x srcH (a 4K
  // take: 3840x2160). Scale s about source point (sx, sy), put at the card's centre, kept inside the
  // card so no edge shows. Returns GSAP vars for the untimed wrapper around the <video>
  // (transform-origin: 0 0).
  function aim(s, sx, sy, o) {
    const card = { w: o.cardW, h: o.cardH }, k = o.srcW / card.w;
    const cx = sx / k, cy = sy / k;
    const x = Math.min(0, Math.max(card.w - card.w * s, card.w / 2 - cx * s));
    const y = Math.min(0, Math.max(card.h - card.h * s, card.h / 2 - cy * s));
    return { scale: s, x, y };
  }

  // How many source pixels each output pixel gets at zoom s: past 1.5 the take looks soft.
  function magnification(s, o) {
    return (s * o.cardW) / o.srcW;
  }

  // The beat grid: time of beat n counted from the drop (n may be negative or fractional).
  function beats(bpm, drop) {
    const pulse = 60 / bpm;
    const at = (n) => drop + n * pulse;
    at.pulse = pulse;
    return at;
  }

  window.director = { aim, magnification, beats };
})();
