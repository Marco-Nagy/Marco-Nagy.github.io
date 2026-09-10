# Prompt for the next session — Phase 3 of the Firebase migration

Paste this whole file's content as your first message.

---

I'm continuing a Firebase migration on this Flutter portfolio project (repo
root: `D:\FlutterProjects\Marco-Nagy.github.io`, branch `feat/firebase-phase-0`,
latest commit `67cb885`).

**Read `docs/firebase-migration-plan.md` first — it is the single source of
truth for this whole migration: the architecture, all cross-cutting decisions
(D1–D4), and a per-phase status note documenting exactly what was built, what
was rejected and why, and what real bugs were hit and how they were fixed.
Do not re-derive or re-decide anything that file already settles.**

## Where things stand

Phases 0, 1 and 2 are done (37% of the migration):

- **Phase 0**: Firebase project `marco-nagy` (Spark plan), Firestore in
  production mode, Auth (Email/Password, client sign-up disabled), security
  rules deployed and pinned to the owner uid, `PortfolioBundle` entity,
  `PortfolioRemoteDataSource`, the `AdminFab` speed-dial (Export).
- **Phase 1**: the `syncFromRemote()` read path (meta-then-maybe-bundle,
  cache/committed-JSON/empty fallback chain), `data/seed/` deleted (all 7
  files), the real Firestore bootstrap already done — `content/bundle` and
  `content/meta` exist and are live.
- **Phase 2**: `AdminAuthService` (sign-in/out), `AdminSignInSheet`, Publish
  wiring (`PortfolioRepo.publish()` → `BundleUseCase.publish()`'s size/embedded
  guard → `PortfolioRemoteDataSourceImpl.writeBundle()`). **Verified working
  end-to-end in a real browser session**: signed in, published, confirmed
  `content/meta.contentVersion` incremented in the Firestore console.

Media hosting uses **Cloudinary**, not Firebase Storage — Storage now requires
the Blaze plan, and Blaze required a one-time $30 activation payment on an
Egyptian billing account, so the project stayed on Spark. This only affects
Phase 6 (not started); it doesn't touch anything else.

### Two real bugs were found and fixed by actually testing Publish in the browser — read these before touching the write path again

1. **`lib/core/utils/json_normalize.dart`** (`ensurePlainJson`) — Firestore's
   client SDK rejected writes with `Unsupported field value: a custom
   _PersonalProject object`. freezed's generated `toJson()` does not
   recursively pre-convert nested entities by default, so a bundle's own
   `toJson()` still had raw objects one level down (a project's `panels`,
   `cover`, …); this worked everywhere else in the app only because
   `dart:convert`'s `json.encode` silently rescues that by calling `.toJson()`
   itself as it walks the tree — Firestore's SDK does not extend the same
   courtesy. Fix: round-trip through `json.encode`/`json.decode` before every
   `WriteBatch.set()`. Regression-tested in
   `test/core/utils/json_normalize_test.dart`, which walks the normalized
   structure the way Firestore's SDK does and would have caught this before
   it ever shipped.
2. A `permission-denied` error turned out to be a **stale deploy, not a code
   bug**: the owner-uid rule had been written into `firestore.rules` locally
   but the actual `firebase deploy --only firestore:rules` confirming it went
   live was never re-run after that edit — the console was still serving an
   earlier `allow write: if false;` placeholder. If you ever see
   `permission-denied` again, check what's *actually deployed* in the
   Firestore console's Rules tab before assuming the client code is wrong.

Also worth knowing: `PortfolioRepoImpl._guard` did not log the raw underlying
exception anywhere — only a friendly message reached the UI — which is why
diagnosing both bugs above required adding `debugPrint` there first. That
logging is now in place permanently.

## What's next: Phase 3 — Static UI → dynamic (22%, the largest phase)

Full spec is in the plan file under "Phase 3", including the exact rejected
alternative for `UrlOpener` and the precise list of files to delete at the end
(`profile_info.dart`, `skill_groups.dart`, `tech_badges.dart`, `app_links.dart`,
`nav_items.dart`) — go read it rather than re-deriving the approach. Summary:

- **3a**: `SiteContentCubit` and `SectionsCubit`, provided above `MaterialApp`
  in `marco_portfolio_app.dart` beside `AppCubit` (not per-screen — chrome
  like the nav bar and footer live in `PortfolioScaffold`, below every
  screen's own provider). Non-nullable fields with sane defaults seeded from
  cache, so chrome never renders a spinner or error. `context.site` /
  `context.visibleSections` extensions.
- **3b**: strip `url_opener.dart` to `static Future<bool> open(String url)`;
  move content-dependent parts into a new `SiteLinks` view-data object exposed
  as `context.siteLinks`. Do **not** take the shortcut of calling
  `getIt<SiteContentCubit>()` inside `UrlOpener` — the plan explains exactly
  why that inverts the dependency direction the rest of the codebase respects.
- **3c**: convert every call site (hero, about, skills, contact, footer, nav,
  splash, resume button) to read from `SiteContent`/`SectionDefinition`
  instead of the hardcoded constants, then delete those constants and their
  keys from both translation JSONs.

Verify: `grep -rn "ProfileInfo\|NavItem.all\|AppLinks\|SkillGroups\.\|TechBadges\." lib/`
returns nothing when done. Editing the site name in the admin (once Phase 4
adds that form) should change nav, hero, splash and footer together — but
Phase 3 itself has no new admin form; it only wires *reading*, so verify by
hand-editing a `content/bundle` field in the Firestore console and confirming
the UI picks it up on next launch.

## Working agreements from this project (apply throughout)

- Run `flutter analyze` and `flutter test` after every meaningful change —
  keep both clean before moving on. 41 tests currently pass.
- Real bugs get a regression test that reproduces the actual failure mode
  (see `json_normalize_test.dart` for the pattern), not just a happy-path
  check.
- I (the user) run long-lived commands — `flutter run -d chrome`, npm
  installs, `firebase deploy` — myself, following exact commands you give me,
  and report the real output back. Don't run `flutter run` in the background
  yourself.
- Port 8080 sometimes has a stale `dartvm` process from a previous session —
  if `flutter run` fails to bind, that's almost always why; check for it
  before assuming something else broke.
- I'm comfortable in Arabic and English — reply in Arabic when I write in
  Arabic; keep code, commands, and identifiers in English either way.
- Commit at the end of each phase (or sooner for a meaningfully separable
  chunk), on the current branch (`feat/firebase-phase-0` — I've been
  committing directly on it, not opening PRs mid-migration).
