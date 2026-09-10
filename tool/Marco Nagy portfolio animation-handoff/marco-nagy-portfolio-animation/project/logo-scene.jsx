// Marco Nagy — {MN} logo animation. One tree, all motion keyed to authored T.
const { CompositionStage, useComposition, Easing, animate } = window;
const { useTweaks, TweaksPanel, TweakSection, TweakColor, TweakToggle } = window;

const W = 1600, H = 900;

const MOTION = {
  enter: (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeOutCubic }),
  pop:   (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeOutQuart }),
  draw:  (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeInOutQuart }),
};

const SANS = "'Poppins', system-ui, sans-serif";

function Piece(props) {
  const { accent, paper, showWordmark } = props;
  const { T, CUES, authoredTotal } = useComposition();
  const END = authoredTotal;

  // camera — never fully static
  const camScale = MOTION.draw(1.08, 1.0, 0, CUES.Lockup + 1)(T) + Math.sin(T * 0.7) * 0.004;
  const glow = 0.5 + 0.5 * Math.sin(T * 1.1 - 1.2);

  // caret — flashes through the whole open, then births the initials out of itself
  const blink = T > 0.35 && T < CUES.Initials
    ? (Math.floor((T - 0.35) / 0.42) % 2 ? 0.18 : 1) : 1;
  const flash = MOTION.draw(0, 1, CUES.Initials - 0.18, CUES.Initials + 0.16)(T);
  const gone = MOTION.draw(0, 1, CUES.Initials + 0.16, CUES.Initials + 0.7)(T);
  const caretBack = MOTION.enter(0, 1, END - 0.75, END - 0.2)(T);
  const caretOpacity = Math.max((1 - gone) * blink, caretBack);
  const caretSX = 1 + 2.4 * flash * (1 - gone);
  const caretSY = 1 + 0.22 * flash * (1 - gone);
  const caretH = 1; // opens settled so the loop wrap has no pop

  // braces
  const gap = MOTION.pop(0, 118, CUES.Braces + 0.45, CUES.Initials - 0.15)(T)
            + MOTION.enter(0, -16, CUES.Lockup, CUES.Lockup + 0.8)(T);
  const braceL = MOTION.pop(0, 1, CUES.Braces, CUES.Braces + 0.55)(T);
  const braceR = MOTION.pop(0, 1, CUES.Braces + 0.16, CUES.Braces + 0.71)(T);

  // initials — born out of the caret, one sliding left, one right
  const birth = MOTION.draw(0, 1, CUES.Initials + 0.18, CUES.Initials + 1.65)(T);
  const mOp = MOTION.enter(0, 1, CUES.Initials + 0.14, CUES.Initials + 0.6)(T);
  const nOp = MOTION.enter(0, 1, CUES.Initials + 0.14, CUES.Initials + 0.6)(T);

  // lockup
  const markScale = MOTION.enter(1, 0.7, CUES.Lockup - 0.1, CUES.Lockup + 0.9)(T);
  const markY = MOTION.enter(0, -78, CUES.Lockup - 0.1, CUES.Lockup + 0.9)(T);
  const nameOp = MOTION.enter(0, 1, CUES.Lockup + 0.55, CUES.Lockup + 1.25)(T);
  const nameY = MOTION.enter(26, 0, CUES.Lockup + 0.55, CUES.Lockup + 1.35)(T);
  const ruleW = MOTION.draw(0, 300, CUES.Lockup + 0.8, CUES.Lockup + 1.6)(T);
  const subOp = MOTION.enter(0, 1, CUES.Lockup + 1.15, CUES.Lockup + 1.8)(T);

  // reset back to the opening frame (loop seam)
  const out = MOTION.draw(1, 0, CUES.Reset + 0.25, END - 0.35)(T);
  const outLift = MOTION.draw(0, -26, CUES.Reset + 0.25, END - 0.35)(T);

  // braces drawn as round-capped strokes — softer than any glyph
  const Brace = (p) => React.createElement('svg', {
    viewBox: '0 0 104 340', width: 104, height: 330, style: {
      opacity: p.s, overflow: 'visible',
      transform: `scale(${0.6 + 0.4 * p.s}) translateX(${p.x}px) scaleX(${p.flip ? -1 : 1})`,
      filter: `drop-shadow(0 0 44px ${accent}80) drop-shadow(0 0 130px ${accent}40)`,
    },
  }, React.createElement('path', {
    d: 'M 92 14 C 54 14 54 62 54 90 C 54 134 22 152 12 170 C 22 188 54 206 54 250 C 54 278 54 326 92 326',
    fill: 'none', stroke: accent, strokeWidth: 23, strokeLinecap: 'round', strokeLinejoin: 'round',
  }));

  const letter = (dir, op) => ({
    position: 'absolute', left: '50%', bottom: 8,
    fontFamily: SANS, fontWeight: 500, fontSize: 208, lineHeight: 1,
    letterSpacing: '0.005em', color: paper, opacity: op,
    transform: `translateX(-50%) translateX(${dir * 88 * birth}px) scale(${0.62 + 0.38 * birth})`,
    filter: `blur(${(1 - birth) * 2.5}px)`,
    textShadow: `0 0 ${26 * (1 - birth)}px ${accent}`,
    whiteSpace: 'nowrap',
  });

  return React.createElement('div', {
    style: { position: 'absolute', inset: 0, overflow: 'hidden', background: '#0d1319' },
  },
    // ambient
    React.createElement('div', { style: {
      position: 'absolute', inset: 0,
      background: `radial-gradient(66% 86% at 50% 46%, ${accent}${glow > 0.5 ? '1f' : '15'} 0%, rgba(13,19,25,0) 70%)`,
      opacity: 0.5 + glow * 0.5,
    } }),
    React.createElement('div', { style: {
      position: 'absolute', inset: 0,
      background: 'radial-gradient(125% 95% at 50% 50%, rgba(13,19,25,0) 52%, rgba(8,12,16,0.72) 100%)',
    } }),

    // composition
    React.createElement('div', { style: {
      position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
      transform: `scale(${camScale}) translateY(${outLift}px)`, opacity: out,
    } },
      React.createElement('div', { style: { position: 'relative', width: 900, height: 560 } },

        // mark row
        React.createElement('div', { style: {
          position: 'absolute', left: 0, right: 0, top: 130,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transform: `translateY(${markY}px) scale(${markScale})`,
        } },
          React.createElement(Brace, { s: braceL, x: -gap }),

          // initials rise from behind a mask
          React.createElement('div', { style: {
            width: 300, height: 240, position: 'relative',
          } },
            React.createElement('span', { style: letter(-1, mOp) }, 'M'),
            React.createElement('span', { style: letter(1, nOp) }, 'N'),
          ),

          React.createElement(Brace, { s: braceR, x: gap, flip: true }),
        ),

        // wordmark
        showWordmark !== false && React.createElement('div', { style: {
          position: 'absolute', left: 0, right: 0, top: 372, textAlign: 'center',
        } },
          React.createElement('div', { style: {
            fontFamily: SANS, fontWeight: 400, fontSize: 52, letterSpacing: '0.34em',
            color: paper, opacity: nameOp, transform: `translateY(${nameY}px)`, paddingLeft: '0.36em',
          } }, 'MARCO NAGY'),
          React.createElement('div', { style: {
            width: ruleW, height: 2, borderRadius: 2, background: accent, margin: '30px auto 26px', opacity: 0.75,
          } }),
          React.createElement('div', { style: {
            fontFamily: SANS, fontWeight: 400, fontSize: 26, letterSpacing: '0.32em',
            color: accent, opacity: subOp, paddingLeft: '0.32em',
          } }, 'FLUTTER DEVELOPER'),
        ),
      ),
    ),

    // caret — its own layer so it survives the fade-out and closes the loop
    React.createElement('div', { style: {
      position: 'absolute', left: '50%', top: '50%', width: 11, height: 152, borderRadius: 6,
      marginLeft: -5.5, marginTop: -76, background: accent, opacity: caretOpacity,
      transform: `scaleX(${caretSX}) scaleY(${caretH * caretSY})`, transformOrigin: 'center',
      boxShadow: `0 0 55px ${accent}80`,
    } }),
  );
}

function LogoApp() {
  const [t, setTweak] = useTweaks(window.TWEAK_DEFAULTS);
  return React.createElement(React.Fragment, null,
    React.createElement(CompositionStage, {
      width: W, height: H, bg: '#0d1319',
      scenes: window.OM_SCENES, playback: window.OM_PLAYBACK,
    }, React.createElement(Piece, {
      accent: t.accent, paper: '#EBF2F8', showWordmark: t.showWordmark,
    })),
    React.createElement(TweaksPanel, null,
      React.createElement(TweakSection, { label: 'Brand' }),
      React.createElement(TweakColor, {
        label: 'Accent', value: t.accent,
        options: ['#54C5F8', '#027DFD', '#7C6CFF', '#31D8A4'],
        onChange: (v) => setTweak('accent', v),
      }),
      React.createElement(TweakToggle, {
        label: 'Wordmark', value: t.showWordmark,
        onChange: (v) => setTweak('showWordmark', v),
      }),
      React.createElement(TweakSection, { label: 'Workspace' }),
      React.createElement(TweakToggle, {
        label: 'Motion editor', value: t.motionEditor,
        onChange: (v) => setTweak('motionEditor', v),
      }),
    ),
  );
}

window.LogoApp = LogoApp;
