# Static → Dynamic: Full Content Control (Firebase)

Migration plan for turning the portfolio from a static site with debug-only local
admin into a live-editable site backed by Firebase. Written so a session with no
prior context can pick it up. Dated 2026-09-09.

## Context

Marco's portfolio is a Flutter web app deployed as a static site to GitHub Pages, with a debug-only admin layer (`AdminGate` → `kDebugMode`) meant to give full add/edit/delete control over every piece of content while staying read-only for visitors.

That promise is only half-built, and the built half cannot ship:

- **Content authored in debug never reaches production.** Everything persists to `shared_preferences` → browser `localStorage`, scoped per-origin. Edits made on `localhost` are invisible to `marco-nagy.github.io`, which reseeds from hardcoded Dart constants.
- **Screenshots render as pink placeholders on the live site.** The 9 asset paths the seed references (`app_images.dart:12-30`) do not exist. Meanwhile ~41MB of orphaned media sits in `assets/projects/` wired to nothing.
- **Only 1 of 9 entities has a working edit form.** Certificates, Work History, Pricing Packages and Add-ons ship literal `onEdit: () {}` no-ops, and their `Save*` cubit handlers have never been dispatched.
- **Four entities have a complete data layer and zero UI.** `SiteContent` (43 bilingual fields), Skills, Sections and CustomSection are seeded to storage, registered in DI, and read by no widget. `StatementData.fromSiteContent` is a mapper that has never been called.
- **A returning visitor can never receive new content.** `seedIfEmpty()` gates on a single unversioned boolean; every list fallback is `const []`, so a new collection renders permanently empty and one corrupt field silently blanks a whole section.

Intended outcome: every visitor-facing string, image and list is editable through the admin UI, saved to Firebase, and visible to visitors immediately without a rebuild — with the hardcoded Dart seed constants deleted.

## Decisions (confirmed with the user)

1. **Architecture — Firebase for content, Cloudinary for media.** Firestore holds the content; Cloudinary hosts the images and clips. The admin writes directly; the deployed site reads live. This replaces the export-JSON-and-rebuild pipeline entirely and supersedes the "no backend" rule in the project's skill file.
2. **Scope** — everything on the site becomes admin-editable, including hero/about/contact/footer/nav/skills copy.
3. **Media** — uploaded to Cloudinary as URLs (see Phase 6). *Revised 2026-09-09: this was Cloud Storage until the project hit the Blaze wall — see the Phase 6 status note.*

### Why the free tier holds — and what actually limits it

| Firebase Spark (free) | Quota | What it means here |
|---|---|---|
| Firestore storage | 1 GB | Content is text; irrelevant |
| Firestore reads | 50K/day | **See read design below** |
| Firestore writes | 20K/day | Admin-only; irrelevant |
| Cloud Storage | — | **Not used** — needs Blaze; media went to Cloudinary |

**Read design decides visitor capacity.** One document per entity = ~51 reads per visitor ≈ 980 visitors/day. Instead: **one `content/bundle` document plus a tiny `content/meta` version document.** A visitor reads `meta` (1 read), compares `contentVersion` to their cached copy in `shared_preferences`, and fetches `bundle` only when it changed. Typical returning visitor: **1 read**. That puts Firestore comfortably out of the way.

**Media used to be the constraint, and no longer is.** The original design put clips in Cloud Storage, whose 1 GB/day egress cap allowed roughly 21 full page views per day at the current ~46MB per clip, or ~500 compressed. Cloudinary's free tier is measured in tens of GB per month rather than 1 GB per day, and it serves from a CDN with per-device transcoding, so the daily visitor ceiling stops being the number that governs this project. Compression still matters — for load time now, not for a quota.

### Security is now mandatory, not optional

`AdminGate` only hides UI in release builds. Firebase config ships inside the web bundle, so anyone can call the API directly. Public read + unrestricted write would let a stranger overwrite the whole portfolio. Therefore **Firebase Auth (a single owner account) plus Firestore/Storage rules — public read, authenticated write — are a required part of Phase 2, not a follow-up.**

---

## Part 1 — Where things stand today

Scoring per entity: entity + use case 25% · dynamic display 25% · add/edit/delete forms 35% · reorder 15%.

### By entity

| Entity | Entity + use case | Display | Forms | Reorder | Done |
|---|---|---|---|---|---|
| PersonalProject | ✅ | ✅ | ✅ full + confirm | numeric only | **~90%** |
| Certificate | ✅ | ✅ | delete only, no confirm, `onEdit: () {}` | — | **~58%** |
| WorkHistoryEntry | ✅ | ✅ | delete only, no confirm, `onEdit: () {}` | — | **~58%** |
| PricingPackage | ✅ | ✅ | delete only, no confirm, `onEdit: () {}` | — | **~58%** |
| PricingAddOn | ✅ | ✅ | delete only, no confirm, `onEdit: () {}` | — | **~58%** |
| SiteContent (43 fields) | ✅ | ❌ no consumer | ❌ | n/a | **~25%** |
| SkillGroup / TechBadge | ✅ | ❌ no consumer | ❌ | — | **~25%** |
| SectionDefinition | ✅ + `saveAll` | ❌ nav uses `NavItem.all` | ❌ | repo ready, no UI | **~28%** |
| CustomSectionItem | ✅ | ❌ no renderer | ❌ | — | **~25%** |

### By visible section

| Section | Display source | State |
|---|---|---|
| Projects (list + detail) | `ProjectsViewModelCubit` | Dynamic |
| Certificates | `CertificatesViewModelCubit` | Dynamic |
| Experience | `ExperienceViewModelCubit` | Dynamic |
| Pricing | `PricingViewModelCubit` | Dynamic |
| Home / Featured works | rows dynamic; heading + subtitle + "view all" static (`en.json:24-27`) | Partial |
| Hero | `en.json:18-20`, `profile_info.dart:57-70`, `AppImages.profile`, `tech_badges.dart` | Static |
| About | `profile_info.dart:33-55`, `skill_groups.dart:11-47` | Static |
| Contact | `profile_info.dart:11-15`, `en.json:101-102` | Static |
| Footer | `en.json:116-120`, `profile_info.dart:15-16` | Static |
| Top nav / Resume | `nav_items.dart:14-37`, `app_links.dart:9,12` | Static |
| Splash | `ProfileInfo.fullName` | Static |

### Infrastructure

| Capability | State |
|---|---|
| Admin widget toolkit (14 widgets) | ✅ complete |
| `AdminGate` release safety | ✅ no stray `kDebugMode` checks anywhere |
| Local persistence + repo + DI | ✅ complete — becomes the cache layer |
| Firebase project / SDK / auth / rules | ❌ none |
| Remote read + write path | ❌ none |
| Content versioning | ⚠️ broken — unversioned boolean |
| Asset integrity | ⚠️ broken — 9 referenced paths missing, 6 real files (~41MB) orphaned |
| Tests | ❌ none (`flutter_test` + `bloc_test` are dev deps, unused) |

**Overall: ~16% of the migration is done.** What exists is the local data layer and the Projects admin form; the remote layer that makes content reach visitors does not exist at all.

---

## Part 2 — The plan

### Cross-cutting decisions

**D1 — One bundle document, not a collection per entity.** `lib/features/portfolio_content/domain/entities/portfolio_bundle.dart` (freezed + json_serializable, matching the other 9 entities) holds all 9 collections plus `Map<String, List<CustomSectionItem>> customItems`, `schemaVersion`, `contentVersion`, `updatedAt`. Firestore layout:

```
content/meta    -> { contentVersion: int, updatedAt: timestamp }   // 1 read per visit
content/bundle  -> the full PortfolioBundle as one document        // read only on change
```

This codebase deliberately has no models/mappers layer — freezed domain entities *are* the wire format — so the bundle is a domain entity beside them, not a data model. Firestore's 1 MiB document limit is the one thing to watch; text-only content is far below it, and media lives in Storage as URLs, not inline. Phase 7 adds a size assertion on write.

**D2 — Local storage becomes a cache, not the source of truth.** `PortfolioLocalDataSourceImpl` keeps its entire existing API. The repository gains a remote source in front of it:

```
read:  cached contentVersion == remote meta.contentVersion ?  local cache
                                                            :  fetch bundle -> write cache -> return
write: (admin only) write Firestore bundle + bump meta.contentVersion -> refresh cache
```

Offline/failed fetch falls back to the cache, and a cold visitor with no cache and no network gets the last committed JSON asset (see D3). Chrome never renders an error.

**D3 — Keep a committed JSON fallback as the cold-start floor.** `assets/content/portfolio_content.json` still ships, produced by the admin's Export action, and is read when Firestore is unreachable *and* the cache is empty. This is cheap insurance: it means a Firebase outage, a quota exhaustion, or a misconfigured rule degrades the site to slightly-stale content rather than an empty page. It also solves the migration bootstrap in Phase 1.

**D4 — Content strings vs LangKeys.** *If Marco would ever change the words without a code change, it's `SiteContent`. If the string exists because a widget is there, it's `LangKeys`.* Hero greeting/name/role, footer headline/availability and featured-works copy move to `SiteContent` and get **deleted** from `en.json`/`ar.json`. Nav labels and section headings move to `SectionDefinition.titleEn/titleAr` (fields that already exist, unused). Button labels, admin labels, empty/error states stay in `LangKeys`.

---

### Phase 0 — Firebase setup + bundle entity · 15%

New deps: `firebase_core`, `cloud_firestore`, `firebase_auth`, and `http` (for the Cloudinary upload in Phase 6 — no `firebase_storage`, and no Cloudinary SDK). Run `flutterfire configure` (generates `firebase_options.dart`). Initialize in `main.dart` before `runApp`.

Create `portfolio_bundle.dart`; add `readAll()` / `writeAll(bundle)` to `portfolio_local_data_source(_impl).dart`, composing from the existing getters plus the existing `keysWithPrefix` helper for custom items. Create `lib/features/portfolio_content/data/data_sources/portfolio_remote_data_source.dart` + `_impl.dart` (`@LazySingleton`) exposing `fetchMeta()`, `fetchBundle()`, `writeBundle()`.

Also: **`admin_fab.dart` currently has zero call sites.** Turn it into the admin speed-dial (Sign in / Publish / Export / Site content / Sections) mounted once in `portfolio_scaffold.dart` inside an `AdminGate` — it becomes the entry point every later phase needs.

**Verify:** debug build connects to Firebase; a hand-written `content/meta` document is readable from the app; `readAll()` produces a bundle with 3 projects, 9 certificates, 1 work entry, 3 packages, 14 add-ons, 7 sections, 7 skill groups, 6 badges, 1 siteContent. *The `readAll()` half is now `local_data_source_bundle_test.dart`, asserted against the seeds rather than against fixed counts, so adding a certificate does not break it.*

**Measured 2026-09-10 — the 1 MiB limit is already breached in practice.** The seeded bundle serialises to **23.5 KB** (projects 9.1 · siteContent 3.6 · pricingAddOns 3.1 · certificates 2.5 · the rest under 1.5 each), comfortably clear. But exporting from a real browser profile produced **3092.6 KB** — roughly 3 MB of `ImageSourceKind.embedded` base64 authored during the `wip/project-media` work and sitting in `localStorage`. Firestore would reject that document outright.

Two consequences. **The Phase 1 bootstrap must be exported from seed content, not from an authored profile** — `resetToSeed()` first, or a clean browser profile. And **`AdminFab`'s export now measures before it copies**, reporting size and embedded-image count and turning the snackbar red when either would block publishing, rather than letting the failure surface as an opaque Firestore rejection at save time. The embedded images are not lost: Phase 6b uploads them to Cloudinary and replaces each with a URL, which returns the bundle to roughly seed size.

### Phase 1 — Read path + caching + seed migration · 10% · *needs 0*

Rewrite the repository read path per D2 and add `bundled_content_loader.dart` (`rootBundle.loadString`, null when absent) for the D3 floor. Replace the unversioned `portfolio_seeded` boolean with `portfolio_content_version`; make the catch-all at `:112` assert + `debugPrint` so schema drift is loud in debug instead of silent.

**Built 2026-09-10 — the `const []` fallbacks are handled differently than planned, and better.** The plan as written asked for each `_decodeList` fallback (the nine `const <T>[]` sites) to become a bundle-backed thunk, so a key with no local value could fall back to remote content instead of an empty list. That turned out to need no per-getter change at all: `PortfolioRepo.syncFromRemote()` runs once at startup, and when the cache is stale it calls `PortfolioLocalDataSource.writeAll()` with the *whole* fetched bundle — which populates every collection's key, including one that has never existed locally, before any `getX()` is ever called. A collection added in a later schema update is empty on a device for at most the single sync it takes to arrive, not permanently. The nine `const []` sites stay exactly as they are; they now mean "this collection is genuinely empty," which is the case they were always meant to catch, once "not yet synced" is handled upstream of them instead. `_decodeList`/`_decodeObject` catch blocks were extended to call a shared `_reportDrift` (assert + debugPrint) rather than swallowing silently — the part of the original ask that did land unchanged.

**Bootstrap:** the first Firestore bundle is produced by exporting the current Dart seeds — you never hand-write it. Export → upload once → then delete `lib/features/portfolio_content/data/seed/` (all 7 files) and their imports. Last-resort fallback becomes the committed JSON, then `const PortfolioBundle()` + a hard assert.

**Verify:** fresh profile loads from Firestore; second load costs 1 read (check the Firebase console); bumping `contentVersion` remotely refreshes the client; airplane mode falls back to cache; cleared cache + blocked network falls back to the committed JSON; `grep -r "Seed" lib/` returns nothing.

**Status 2026-09-10 — done, including the live bootstrap.** `remote_sync_test.dart` (8 tests, against fakes) proves the version-match/stale/unreachable/cold-start/schema-drift cases the Verify line above lists — a cache-current sync costs exactly one fake read and never touches the bundle fetch, a stale one fetches and persists, an unreachable remote and a failed mid-fetch both leave the cache untouched, and a bundle from a newer schema is refused rather than written over a working cache.

The manual bootstrap ran for real: the seven seed files were exported once via the admin's Export action (3 projects, 9 certificates, 1 work entry, 3 packages, 14 add-ons, 7 sections, 7 skill groups, 6 badges, 1 siteContent — the exact Phase 0 acceptance numbers), `contentVersion` bumped from the export's `0` to `1` by hand, and published with a one-off script (`tool/upload_bundle.js`, using `firebase-admin` and a service-account key that never leaves the machine — gitignored, and not the same credential as the app's own Firebase config) rather than through the Firestore console UI, which has no way to paste a JSON document directly. The same export is committed as `assets/content/portfolio_content.json` — the D3 cold-start floor is therefore real content, not a placeholder. A fresh Chrome profile was confirmed reading `content/bundle` over the WebChannel connection (visible in DevTools Network as the `channel?...` / `webchannel_blob` requests — Firestore's web SDK does not surface a request literally named "firestore").

With a real device reading Firestore confirmed, `lib/features/portfolio_content/data/seed/` (all 7 files) was deleted, along with `seedIfEmpty()` and `PortfolioLocalDataSource.resetToSeed()` — the local data source now has no seed dependency of any kind, only `readAll()`/`writeAll()` and the per-entity getters/setters. `PortfolioRepo.resetToSeed()` was **renamed to `resetToPublished()`**, not just deleted: the admin's "Reset" button is a real, ongoing feature (discard local edits, restore known-good content), and post-migration that has to mean "reload the last published Firestore bundle," not "restore hardcoded constants." It deliberately always re-fetches rather than reusing `syncFromRemote`'s version-match short-circuit — an admin's unpublished local edit never changes the cached `contentVersion` (only a publish does), so a version-matches-cache check would treat "same version, different content" as nothing to do and silently keep the edit, exactly the case Reset exists to undo. Three test files that had imported the seed classes as sample data (`bundle_round_trip_test.dart`, `bundle_size_test.dart`, `local_data_source_bundle_test.dart`) now share `test/features/portfolio_content/sample_bundle.dart`, hand-built fixtures with every field — including nested ones, a project's panels/shots/videos/links — set away from its default, so a field that silently failed to serialise could not hide behind a default-equals-missing coincidence the way seed data's mix of populated and blank fields sometimes could.

`grep -r "Seed" lib/` now returns nothing.

### Phase 2 — Auth + security rules + write path · 12% · *needs 0, 1*

**Rules (deploy before any write path exists):**

```
match /content/{doc} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.uid == '<owner-uid>';
}
```

Same shape for Storage. Create a single owner account (email/password), add a sign-in sheet reachable from the `AdminFab`, and persist the session. `AdminGate` stays as the UI gate; **auth is the real security boundary.** Add `writeBundle()` wiring: every admin save writes the bundle and bumps `meta.contentVersion` in one batch so readers never see a half-written state.

**Where the sign-in lives — confirmed 2026-09-09.** `AdminGate.isEnabled` stays `kDebugMode`. The sign-in sheet hangs off the `AdminFab` speed-dial *inside* the gate, so it exists only under `flutter run`. There is deliberately **no hidden `/#/admin` route and no release-build sign-in**: Marco edits from his dev machine, and the writes reach visitors live. Rejected alternatives were `kDebugMode || signedIn` behind a hidden route (ships the whole admin form tree — `MediaRefField` alone is 590 lines — to every visitor, against the per-visitor weight budget in "Media is the actual constraint") and the same thing behind a deferred chunk (same reach, more build complexity, still unnecessary). Tree-shaking means admin code is not merely hidden in release; it is absent.

**Superseded 2026-09-11 — there is now a third build, and admin UI does ship in it.** The paragraph above is kept as the record of what was decided; the `kDebugMode`-only gate and the "no release-build sign-in" rule it states are no longer what the code does.

The reasoning holds for the *public* build and is unchanged there. What changed is the premise that "Marco edits from his dev machine": editing from a phone, or from any machine without a Flutter toolchain, was impossible. So `AdminGate` now answers to three cases:

| build | behaviour |
|---|---|
| public release (`flutter build web`) | renders nothing; no `ADMIN_BUILD` define, no Cloudinary credential compiled in |
| admin release (`--dart-define=ADMIN_BUILD=true`) | renders only once Firebase Auth reports a signed-in owner |
| debug (`flutter run`) | renders immediately, no sign-in — a dev machine is already trusted |

The admin build deploys to Firebase Hosting (free on Spark) at its own unlisted URL, with `X-Robots-Tag: noindex, nofollow`; the public site still goes to GitHub Pages, built exactly as before. The weight objection that sank `kDebugMode || signedIn` above is answered by the separate build rather than by a deferred chunk — visitors fetch a bundle the admin tree was tree-shaken out of, so they carry none of it.

Sign-in is reachable from the footer's "Built with Flutter" line, which sits deliberately *outside* the gate — when nothing is signed in every other admin affordance is hidden, so it is the only way in. On the public build that line is inert text. This remains a UI gate, not the security boundary: Firestore's rules still accept a write only from the owner uid, so whoever finds the admin URL meets a locked screen and would be refused by the server even past it.


The `<owner-uid>` literal above is the reason the console step records the UID: `request.auth != null` alone is not enough, because the public `signUp` endpoint stays open by default and the Firebase config ships in the web bundle — anyone could self-register and satisfy it. The UID is an identifier, not a credential, so it is safe to commit in `firestore.rules`; that file deploys via the CLI and never enters the Flutter bundle.

**Status 2026-09-09 — the console half of this phase is already done, ahead of schedule.** The project is `marco-nagy` (project number 60073568220), Firestore is Standard edition in production mode, Email/Password is the only sign-in provider (Email link left off), client sign-up and client delete are both disabled in Authentication → Settings → User actions, and the owner account exists with uid `fGxyNkBNLoZDoaj8DHwWowZMevF3`. `firestore.rules` is committed at the repo root with that uid inlined and deploys with `firebase deploy --only firestore:rules` against the committed `firebase.json` / `.firebaserc` — no `firebase init` is needed. The project is on **Spark**; there is no `storage.rules` because Cloud Storage is not used. Scheduled backups were skipped deliberately: D3's exported JSON in git is the backup, and it versions better than a daily snapshot. What remains of Phase 2 is the app-side work — the sign-in sheet on the `AdminFab`, session persistence, and `writeBundle()` batching the bundle with the `meta.contentVersion` bump.

**Verify:** signed out, a write is rejected by rules (confirm in console logs); signed in, it succeeds; a second browser sees the change after one reload; a release build shows no admin affordances at all.

### Phase 3 — Static UI → dynamic · 22% · *parallel to 0–2* — largest phase

**3a. Two app-wide cubits.** `SiteContentCubit` and `SectionsCubit`, following the `CertificatesViewModelCubit` shape, provided **above `MaterialApp`** in `marco_portfolio_app.dart` beside `AppCubit` — the nav bar, drawer and footer live in `PortfolioScaffold` below every screen's own provider, so per-screen provision cannot reach them. Both expose non-nullable fields with sane defaults seeded from cache, so **chrome never renders a spinner or an error**; it paints the last-good value while a fetch is in flight. Add `context.site` / `context.visibleSections` extensions.

**3b. The `url_opener.dart` problem.** It reads `ProfileInfo` from a non-widget context (lines 28/30/43/59). Strip it to `static Future<bool> open(String url)` and move the content-dependent parts into a new `SiteLinks` view-data object (`mailto`, `tel`, `resume`) exposed as `context.siteLinks`. Explicitly rejecting the shortcut of calling `getIt<SiteContentCubit>()` inside `UrlOpener` — it would make a leaf utility depend on the DI container and a presentation cubit, inverting the dependency direction the rest of the codebase respects, to save ~6 call-site edits.

**3c. Convert the call sites** — hero headline/tags/photo/orbit badges, about statements (via the existing-but-never-called `StatementData.fromSiteContent`), skills block, contact links, footer headline/availability/socials, monogram, nav items, resume button, splash name.

**Then delete:** `profile_info.dart`, `skill_groups.dart`, `tech_badges.dart`, `app_links.dart`, `nav_items.dart`, and the content keys from both translation JSONs.

**Verify:** `grep -rn "ProfileInfo\|NavItem.all\|AppLinks\|SkillGroups\.\|TechBadges\." lib/` returns nothing. Editing the site name in the admin form changes nav, hero, splash and footer — on the deployed site, with no rebuild.

**Status 2026-09-10 — done. Three cubits, not two, and one silent bug found on the way.**

`SiteContentCubit`, `SectionsCubit` and **`SkillsCubit`** are provided together in a `MultiBlocProvider` above `MaterialApp`. The third was not in the plan: 3c asks for both the hero orbit badges and the About skills block, and both need `SkillsUseCase`. Per-screen provision would have worked — they are screen content, not chrome — but `@injectable` registers cubits as factories, so a per-screen provider refetches both collections on every navigation through a single-page site whose nav *is* navigation. App-wide costs one read and keeps one provisioning story instead of two.

Each cubit dispatches its `Load*` in the provider's `create:`, so the read is in flight before the first frame; `main()` already awaits `syncFromRemote()` before `runApp`, so these hit a warm cache and settle in a microtask. None of the three has a `Loading` state at all — the invariant "chrome never renders a spinner" is structural rather than a convention a later consumer could break by switching on a state that does not exist.

`context.site` / `context.siteLinks` / `context.visibleSections` / `context.sectionTitle(id)` / `context.skillGroups` / `context.techBadges` live in their own `site_content_extensions.dart` rather than in `context_extensions.dart`. Keeping them apart means the app's most-imported file does not pull `flutter_bloc` and three presentation cubits into every widget that only wanted `context.colors`. Every getter `watch`es, so a call site rebuilds on a content change without a `BlocBuilder` of its own.

**Real bug, caught by a test written for it: the `mailto:` encoder was the form-encoding one.** `UrlOpener.openMailTo` built its query with `Uri.encodeQueryComponent`, which emits `+` for a space — correct for an HTTP form post, wrong in a mail client, where `Project+enquiry` arrives in the subject line with the plus in it. This shipped in the old code and moved into `SiteLinks.mailto()` unchanged before `site_links_test.dart` failed on it; the fix is `Uri.encodeComponent`. It had stayed invisible because `UrlOpener.open` returns `false` for anything it cannot launch and the UI shows one generic error, so a mangled `mailto:` is indistinguishable from "the mail app did not open" — and the contact form puts spaces and newlines in *every* message it sends, so this was the normal path, not an edge case.

**The hero orbit stays build configuration — Marco's call, 2026-09-10, and it is the right one.** The hero rendered 11 branded SVGs from `tech_badges.dart`; the published `techBadges` held 6 entries carrying only an `iconKey`, and 4 of those 6 had no SVG at all. 3c lists the orbit badges as a call site to convert, and converting them was the reflex — but it buys less than it looks like it does. **A badge cannot exist without its logo being in `assets/tech/` and declared in `pubspec.yaml`, which is a rebuild either way.** Routing the list through Firestore therefore bought reordering and hiding, at the cost of a list and a set of logos that could drift apart — and they already had, which is exactly how the count fell from 11 to 6 without anyone noticing.

So `core/constants/tech_brand_marks.dart` holds the ordered list of 11 marks (label, asset path, brand colour, fallback glyph) and `hero_photo.dart` renders `TechBrandMarks.all` directly. `TechBadgeEntity` is untouched and still in the bundle, the data layer and `SkillsCubit` — this governs what the hero draws, not what the schema carries, so Phase 4 can still put a badge manager somewhere else if it wants one. The `context.techBadges` extension getter was removed rather than left with no call site.

`tech_brand_marks_test.dart` guards the seam in both directions: every listed path must appear in the real `assets/tech` directory listing — compared against the listing rather than `File.existsSync`, because the case slip that matters (`github.svg` vs `gitHub.svg`) passes an existence check on Windows and 404s only once served over HTTP — and every SVG in the folder must be listed, so a logo added and never wired up is caught as shipped weight nothing draws.

**Carried to Phase 4 — confirmed with Marco 2026-09-10: the featured-works copy (`home_works_*`) stays in `LangKeys` for now.** D4 classifies it as content, and it is. But `SiteContent` has no fields for it, and adding them here would render blank headings on the live site: publishing writes the local cache, the cache came from Firestore, and Firestore would not have the field either — so **no field added ahead of its form can ever be given a value**. That is the general rule this phase established, not a quirk of these four strings. It moves with `site_content_form_screen`, which is the first thing that can author them. Tracked in the Phase 4 section below so it is not lost.

Also folded in, since the fields existed and were populated and would otherwise have stayed dead: contact title/subtitle from `SiteContent`, and all six section headings from `SectionDefinition.titleEn/titleAr` (D4's "section headings" half, which 3c's call-site list did not spell out). `NavLink` and the drawer now take the whole `SectionDefinition` rather than an id, so `RouteNames.forSection` can route a custom section — the id-only form could only ever reach a built-in.

28 keys left both translation JSONs. `flutter analyze` clean, 65 tests pass (41 before, 24 added across `site_links_test.dart`, `content_cubits_test.dart` and `tech_brand_marks_test.dart`).

### Phase 4 — The 6 missing forms · 18% · *needs 3 for SiteContent/Skills only*

**Shared abstraction: two small widgets only** — `admin_text_field.dart` (thin wrapper over `UnderlineTextField`) and `bilingual_field_pair.dart` (the en/ar row that recurs ~20 times, 6 of them inside `project_form_screen.dart`). **Not** a schema-driven form engine: the fields are genuinely heterogeneous (`MediaRefField` is 590 lines, plus gradient/sub-list/color fields) and Dart has no reflection, so a generic engine becomes a large tagged union with worse ergonomics. `AdminFormScreen` + `AdminFormSheet` already *are* the scaffold abstraction. Also move `admin_sub_list.dart` from the projects feature into `core/widgets/admin/` — `PricingPackage` needs it and it is not project-specific.

Forms: `certificate_form_screen`, `work_history_form_screen`, `pricing_package_form_screen`, `pricing_add_on_form_sheet` (4 fields — a sheet, not a page), `site_content_form_screen` (43 fields grouped into Identity / Hero / About / Contact / Footer `ExpansionTile`s), `skill_group_form_screen` + `tech_badge_form_sheet`.

**Carried over from Phase 3.** `site_content_form_screen` grows past 43 fields: add `homeWorksHeadlineEn/Ar`, `homeWorksSubtitleEn/Ar`, `homeWorksMoreLabelEn/Ar` and `homeWorksViewAllEn/Ar` to `SiteContent` **in this phase, not before it** — Phase 3 established that a field added ahead of its form can never be given a value, because a publish only ever writes back what Firestore already held. Add the fields and the Identity/Hero/About/Contact/Footer groups gain a *Featured works* one; then convert `featured_works_section.dart:41/48/93/108` and delete `home_works_headline`, `home_works_subtitle`, `home_works_more_label` and `home_works_view_all` from both translation JSONs. Type the four values into the form and publish before checking the site, or the headings render blank — which is the whole reason this waited.

`tech_badge_form_sheet` is **no longer needed for the hero**: the orbit reads `TechBrandMarks.all`, a build-time catalogue, per the Phase 3 note above. `TechBadgeEntity` still exists in the bundle and `SkillsCubit` still loads it, so build the sheet only if something else is going to render those badges — otherwise drop it from this phase's list and leave the entity dormant.

Reused verbatim from `project_form_screen.dart`: `IdGenerator.next()`, `TextListConverter`, `Validators`, `MediaRefField`, `AdminColorField`, `AdminChoiceField<T>`, the controller lifecycle pattern, and the `static Future<T?> open(context, {entity})` convention.

**The wiring is the real work.** For each of `certificates_section.dart:107`, `experience_section.dart:98`, `pricing_section.dart:146` and `:218`: replace `onEdit: () {}` with the form + `cubit.doAction(Save*(result))` (**those handlers already exist and have never been dispatched**), wrap `onDelete` in `AdminConfirmDialog.show` to match Projects, and add an `AdminAddButton` to each section header — none of these four sections has one today.

**Verify:** add/edit/delete one of each, reload, confirm it persisted to Firestore, and check the change appears in a second browser.

**Status 2026-09-10 — done, in three commits. Two of this phase's open questions were settled by Marco, not by the plan.**

**4a — the wiring was indeed the real work, and it was cheaper than it looked.** Every translation key the four forms needed (`form_add_certificate`, `field_provider_en`, `field_company`, `field_base_price`, `field_has_counter`, …) already existed, written when the data layer was and never referenced since. So `certificate_form_screen`, `work_history_form_screen`, `pricing_package_form_screen` and `pricing_add_on_form_sheet` are mostly assembly. Each of the four `onEdit: () {}` sites now opens its form and dispatches the `Save*` action that had existed, with a working cubit handler, without ever being dispatched; delete goes through `AdminConfirmDialog` to match Projects.

One thing the plan did not call out: **all four sections rendered a bare "nothing here yet" message with no way out of it.** The empty state returned early, before any add affordance, so an empty Certificates list was a dead end. Every `AdminAddButton` here sits *outside* the empty check — an empty list is exactly when adding the first record has to be reachable.

Shared widgets came to two, as planned, but not the two named: `bilingual_field_pair.dart` (side by side above ~520px, stacked below, English-only validation because `context.localized` already falls back to English) and `admin_switch_field.dart` for the two content booleans. `admin_text_field.dart` was not built — `UnderlineTextField` already takes label/controller/validator, and a wrapper over it would have added a layer that defaults one argument. `admin_sub_list.dart` moved to `core/widgets/admin/` as planned.

**4b — the site content form, and the last of D4.** `site_content_form_screen` edits all 43 fields in six collapsible groups, reached from the `AdminFab` because a singleton has no list row to hang an edit button from. `maintainState` is on so a collapsed group's fields stay in the enclosing `Form`; without it Save would validate only whatever happened to be open. The eight `homeWorks*` fields landed here rather than in Phase 3, and `featured_works_section` now reads them — which closes D4: no content string remains in either translation JSON.

**Those four headings render blank until they are typed into the form and published.** That is the predicted, expected state, not a bug: a publish only ever writes back what Firestore already held, so a field cannot carry a value before the form that authors it exists. The English and Arabic copy that left the JSONs is recoverable from this commit's parent.

A new **fixture-coverage test** was added while doing this, because adding eight fields exposed that the round-trip suite's whole value rested on an unenforced convention — `sample_bundle.dart` sets every field away from its default, and forgetting one leaves the tests passing while silently no longer covering it. It compares the fixture's `toJson()` against `const SiteContent().toJson()` and fails on any key that matches, which is reflection-free because json_serializable already enumerates the fields. **It found a hole on its first run:** the fixture's `monogram` was `'MN'`, the entity's own default, so that field had never actually been covered by the round-trip test at all.

**4c — and the two questions the plan left open.** Both were put to Marco rather than decided here:

- **`tech_badge_form_sheet` was dropped.** The plan had already made it conditional after the Phase 3 badge decision; with the orbit reading `TechBrandMarks.all`, nothing renders `TechBadgeEntity`, so a form for it would edit something invisible. The entity stays in the bundle and `SkillsCubit` still loads it — dormant, not deleted.
- **The sections editor moved *forward* into this phase**, out of Phase 5. `SectionsCubit` had gained `SaveSection`/`SaveAllSections`/`DeleteCustomSection` in Phase 3 with nothing dispatching them, and rename-plus-hide needs none of the drag-and-drop machinery. Phase 5 is therefore now only reordering.

Both managers hang off the `AdminFab` and use a new `AdminListScreen` rather than `AdminFormScreen` — that one owns a `Form`, validates on the way out and docks a Save bar, and these save each change as it is made, so sharing it would have meant a Save button that saves nothing. The sections screen lists **all** sections rather than visible ones: hiding one there is the only way to get it back, so a hidden section that also vanished from the manager would be unreachable.

Four upsert tests were added with them. These cubits got a UI that dispatches `Save*` for the first time, and the failure worth guarding is an upsert that appends instead of replacing — on screen that is an edited record appearing twice, or a hidden section coming back, and it survives a reload because the duplicate really is in the store.

`flutter analyze` clean, **70 tests pass** (66 after 4b, 65 after 4a).

### Phase 5 — Reorder · 6% · *needs 4*

**Narrowed 2026-09-10.** Renaming a section and toggling its nav visibility shipped in Phase 4c (`sections_manager_screen`), so what is left here is strictly the drag-and-drop ordering — for sections and for the other eight collections. `admin_reorderable_list.dart` can drop into `sections_manager_screen` rather than needing a screen of its own.

**Build drag-and-drop.** The cost is unusually low: the data source **already** has `saveX(List<T>)` for all 9 collections, each repo method is a `_guard` one-liner, and each use case is a 3-line passthrough (`SectionsUseCase.saveAll` is the template). One new widget — `admin_reorderable_list.dart` wrapping `ReorderableListView` inside an `AdminGate`, so no drag handles ship to visitors. With numeric fields instead, swapping two rows means editing two records and getting the arithmetic right, across 9 entities. Remove the numeric `order` field from `project_form_screen.dart` once this lands — two sources of truth for ordering will drift.

**Status 2026-09-11 — done, for seven collections rather than nine, and the plan's cost estimate above was wrong in one specific way.**

"The data source **already** has `saveX(List<T>)` for all 9 collections" is true — but only of the *data source*. At the repository and use-case layers only `saveSections` existed, so six collections needed a new method at each of three layers before a single row could be dragged. Not hard, but not the one-liner the estimate implied.

Seven collections, not nine: `techBadges` and `customItems` were left out deliberately, because nothing renders them. The hero orbit reads `TechBrandMarks.all` (the Phase 3 decision above), and custom sections still have no renderer — reordering either would have been a control over something invisible.

**Inline drag does not survive contact with two of the seven, so none of them use it.** The plan assumed a `ReorderableListView` could wrap each section in place. Projects and Experience are single-column and would have been fine. Certificates is a two-column `GridView`, which `ReorderableListView` cannot do at all, and Pricing packages render as a horizontal `Row` on desktop. On top of that every section sits inside `PortfolioScaffold`'s own `SingleChildScrollView`, where drag auto-scroll fights the page.

Put to Marco, who chose one uniform answer over a mixed one: a **reorder mode** per section. A `⇅` button (inside `AdminGate`) swaps that section's body for a single-column list of compact rows with drag handles; pressing Done swaps it back. Same gesture everywhere regardless of how the section normally renders, and the compact rows are short enough that the nested-scroll problem mostly stops mattering. `admin_reorderable_list.dart` + `admin_reorder_button.dart`, used seven times.

Ordering is renumbered from list position in the repository (`saveSections`'s existing pattern), not by the caller — so a reorder cannot produce two records claiming the same slot. The numeric `order` field came out of **six** forms, not the one the plan names: certificate, work history, skill group, pricing add-on, pricing package and project all had one, and every one of them was a second source of truth for the same ordering.

`flutter analyze` clean, 70 tests at the time (10 added).

### Phase 6 — Media: compression + Cloudinary upload · 12% · *needs 0, 2*

**Status 2026-09-09 — the host changed; the shape of the phase did not.** Cloud Storage is no longer offered on Spark for new projects, and upgrading to Blaze turned out to require a **one-time $30 activation payment** on an Egyptian billing account — a real cost, not the $0 the quota analysis had assumed. The project was returned to **Spark** and media moved to **Cloudinary's** free tier. Two alternatives were weighed and rejected: serving media from the repo via GitHub Pages (free and uncapped, but `flutter run -d chrome` cannot write to disk, so the picker could never copy a file into the repo and 6b's honest-upload fix would be impossible), and Supabase Storage (a real storage service with proper per-object policies, but it brings a full SDK, less monthly bandwidth, and no transcoding). Verify Cloudinary's current free-tier numbers before relying on them.

**Why an unsigned Cloudinary preset is safe *here*, and would not be in most apps.** Unsigned upload normally means anyone who reads your JS bundle can upload to your account. That cannot happen in this app: every admin affordance sits inside `AdminGate`, which is `kDebugMode`, so the upload code and the preset name are tree-shaken out of the release bundle and never reach a visitor. The Phase 2 decision to keep the admin debug-only is what buys this — if that is ever revisited, this must be revisited with it, and the upload moved behind a signed request.

**6a. Compress before upload — and on the free plan this is mandatory, not an optimisation.** Cloudinary's free tier caps a single **image at 10 MB**, a video file at 100 MB, and — the one that bites — a **video transformation at 40 MB**. The current `assets/projects/` GIFs run 4.8–12.5 MB, so the 12.5 MB one is rejected outright as an image, and the GOM MP4 exports (25–46 MB) sit above the transformation cap, meaning `f_auto,q_auto` would silently not apply to the largest of them. So the ffmpeg pass happens **before** upload, always. Delivery-side `f_auto,q_auto` then handles per-browser format and quality, which is what replaces the per-file encoder tuning this step originally demanded. The GOM export producing MP4s *larger* than the source GIFs proves the container is irrelevant and only encoder settings matter. Baseline with the installed ffmpeg 9.0.1:

```
ffmpeg -y -i "in.gif" -vf "scale=540:-2:flags=lanczos,fps=24" \
  -c:v libx264 -crf 30 -preset slow -pix_fmt yuv420p \
  -movflags +faststart -an "out.mp4"
```

Escalation if still too large: `-crf 34`, then width 440. WebM/VP9 is no longer worth hand-encoding — `f_auto` emits it to browsers that want it. Sizes no longer set a visitor ceiling, so measure for load time, not for quota.

**Measured 2026-09-09.** `assets/images/profile.png` served through `f_auto,q_auto`, requested with a browser's `Accept` header: **1,817,472 bytes `image/png` → 65,588 bytes `image/webp`, a 96.4% reduction, with no pre-processing at all.** Note the `Accept` header is load-bearing in any such measurement — without it `f_auto` returns the original PNG and the comparison looks like the transformation does nothing.

**6b. Real upload flow, replacing the current trap.** `MediaRefField._pickAsset()` (`media_ref_field.dart:162-191`) is the *default* action and reads the picked file only for its name, discarding the bytes — it assumes the developer already copied the file into the repo by hand, and `_pinAsAsset()` (`:232-247`) is a pure text swap that copies nothing. Cloudinary makes this honest: **pick → `POST` the bytes as multipart to `https://api.cloudinary.com/v1_1/<cloud-name>/auto/upload` with the unsigned preset → store the returned `secure_url` as `ImageRef.network`.** That is a plain HTTPS request, so `http` is the only new dependency and no SDK is added. The model already supports `ImageSourceKind.network` and `MediaKind.videoFile` with a URL, so no rendering changes are needed. Add an upload progress indicator and a size guard that rejects files above a set ceiling before upload — set that ceiling from the free-plan limits in 6a (10 MB images, 40 MB video if the delivery transformation is to work) so the failure is a clear message in the form rather than an opaque 400 from the API. The cloud name (`wh2ssugy`) and the preset name live in one debug-only const file, never in `SiteContent` — they are build configuration, not content.

**Verified end to end on 2026-09-09**, before any Dart was written, with:

```
curl.exe -X POST "https://api.cloudinary.com/v1_1/wh2ssugy/auto/upload" \
  -F "file=@assets/images/profile.png" -F "upload_preset=ml_default"
```

The account's stock `ml_default` preset is reused rather than adding one: it is already Unsigned, and Cloudinary blocks unsigned uploads until a preset is whitelisted at the account level (`Settings → Upload → Unsigned uploading`), which is the one non-obvious setup step — the error text is `Upload preset must be whitelisted for unsigned uploads`. It is configured with asset folder `portfolio`, public ID from the filename, and **Append a unique suffix on**; that suffix plus Cloudinary's own `/v<version>/` segment is what makes a replaced asset take a new URL instead of going stale behind the CDN. The response carries `secure_url`, and `asset_folder`, so `MediaRefField` needs nothing from the API beyond that one field.

**Store delivery URLs, not raw ones.** Inject `f_auto,q_auto` after `/upload/` in the returned `secure_url` before saving it, so every visitor gets the format and quality their browser handles best. No cache headers to set: Cloudinary serves from a CDN with long-lived caching already, which is why the `Cache-Control` work Cloud Storage would have required is absent here. Its URLs also carry a version segment (`/v1234567890/`), so a replaced asset gets a new URL on its own — the stale-file problem that an `immutable` header would have created does not arise.

**6c. Wire the 5 clips + cover to Flowery Store through the admin UI** — this doubles as the end-to-end acceptance test. Then delete the 6 orphaned originals from `assets/projects/` and `AppImages.floweryStoreShots`/`floweryDeliveryShots`/`fitnessAppShots` (`app_images.dart:12-30` — all 9 paths point at files that do not exist). Declare or delete `assets/backgrounds/`, which exists on disk but is missing from `pubspec.yaml`.

**6d. `tool/validate_assets.dart`** (plain Dart, CI before release build) — fails on referenced-but-missing local paths, paths outside declared assets directories, orphan files, filenames outside `[a-z0-9._/-]`, and **any `ImageSourceKind.embedded` in the bundle** (base64 must never reach Firestore — it would blow the 1 MiB document limit).

**Status 2026-09-12 — 6b and 6d done; 6a and 6c were overtaken by events and closed differently.**

**The upload is signed, not the unsigned preset this plan argued for.** Marco's call, and it changes the security reasoning above rather than merely the mechanism. `api_key`/`api_secret` are read with `String.fromEnvironment` and supplied by `--dart-define-from-file=cloudinary.local.json`, a gitignored file (`cloudinary.local.json.example` is the committed template). Nothing lands in source, so the "unsigned is safe because the preset name is not a credential" argument is moot — there is a real credential now, and it lives only on the machine that runs the build.

That claim was checked rather than asserted. Building both variants and grepping the output:

```
public build (flutter build web):   no secret, no api key, no api.cloudinary.com at all
admin build (ADMIN_BUILD=true):     all three present, as intended — it is never published
difference in main.dart.js:         ~57 KB
```

The tree-shaker removed `CloudinaryUploadService` outright from the public build. Worth noting the guarantee that actually matters is the *build command*, not the tree-shaker: compiled without the defines, `String.fromEnvironment` is the empty string, so there is no secret in those binaries to find regardless of how much code survives.

**`uploadDocument` deliberately skips `f_auto,q_auto`.** Cloudinary treats a PDF as an image it is willing to rasterise, so asking it for an automatic format returns a picture of page one instead of the document. Also note a Cloudinary account can block PDF *delivery* by default (`Settings → Security`) — the upload succeeds and the URL then 401s. This account allows it; a new one may not.

**Three places were still not on Cloudinary after the first pass, and two were silent.**

- `ProfilePhotoField` (hero and About photos) was never wired up at all — it still cropped and embedded base64 locally. It failed silently: no error, the photo simply never left the browser. Found only because Marco tried it.
- Certificate images rendered through a hardcoded `ImageRef.asset(certificate.imageAsset)`, so even a correctly pasted Cloudinary URL would have been read as a local path and shown broken. The rule for reading such a string now lives once, as `ImageRef.fromSource`, instead of being duplicated per form.
- The CV had no upload at all. `image_picker` cannot open a PDF on any platform, so `file_picker` joined the dependencies for that one job — `image_picker` stays for its `maxWidth`/`imageQuality` resize, which `file_picker` has no equivalent for and which is what keeps a raw phone photo out of the crop editor.

**The crop editor was rewritten by hand, and `crop_your_image` is gone.** Marco reported lag twice. Resizing at pick time (`maxDimension: 1600`, `imageQuality: 85`) helped but was not the cause: that package does its crop in the pure-Dart `image` package inside `compute()`, and `compute()` does not reach a real thread on Flutter Web — there is no general isolate spawning there, so the "background" work runs on the UI thread. The replacement captures the crop natively through `RepaintBoundary.toImage()`, which is both faster and one dependency lighter. Three real bugs came out of rebuilding it: `Transform` passes its incoming constraints through unchanged, which squashed the zoomed image back to frame size so dragging appeared to do nothing (fixed with `OverflowBox`); only pinch-zoom was wired, which a desktop mouse cannot produce (a `Slider` was added); and that slider then overflowed the card by 67px, pushing Save off-screen so it looked dead (the content is now in a `SingleChildScrollView`).

**6a and 6c did not happen as written — the orphaned media was deleted instead of compressed and uploaded.** The five GIFs and the screenshot in `assets/projects/` (~40 MB) were removed with `git rm`, along with `AppImages.floweryStoreShots`/`floweryDeliveryShots`/`fitnessAppShots` — nine paths with zero call sites, each logging a 404 on every web run. They remain in git history if the clips are ever wanted back. The ffmpeg pass in 6a therefore has nothing left to compress; it stays here as the recipe for whenever a clip is next uploaded.

**6d shipped and immediately paid for itself.** `tool/validate_assets.dart` (plain Dart, no Flutter) checks the five things listed above. Its first real run found 15 problems, including two nobody had flagged: `gitHub.svg` and `graphQL.svg` carried capitals, which worked only because the machine they were written on has a case-insensitive filesystem — on a Linux web host they would have 404'd. Both renamed. It now reports clean across 7 directories and 21 files.

**Dead code the Cloudinary decision left behind, now removed.** "Pin as asset" was the notable one: it replaced the field's value with `assets/projects/<name>`, a directory that is now empty, so pressing it would have *broken* a working Cloudinary URL. The workflow it assumed — copy the file into the repo, declare it, rebuild — is exactly what uploading replaced. It is gone, and a legacy embedded image now says to re-upload instead. With it went `ImagePickerService.pick()`, `suggestedAssetPath()` and `embeddedWarnBytes`, all defined and none called, plus three translation keys.

Still open: `MediaKind.videoFile` takes a pasted URL rather than an upload. Deliberate — Marco scoped this pass to images.

`flutter analyze` clean, **100 tests**, `validate_assets` clean.

### Phase 7 — Tests · 5% · *interleaved; round-trip test precedes deleting the seeds*

Zero tests exist today. Target what can silently destroy content, using `SharedPreferences.setMockInitialValues` and `fake_cloud_firestore`.

1. **`bundle_round_trip_test.dart`** — every entity and the full bundle: `toJson` → `fromJson` → equals. freezed's `==` makes this free. Lands with Phase 0, **before** Phase 1 deletes the seeds.
2. **`bundle_size_test.dart`** — asserts the serialized bundle stays under Firestore's 1 MiB document limit and contains no embedded base64. **Written early, in Phase 0, because the problem turned out to be live rather than hypothetical** (see the measurement below).
3. **`remote_sync_test.dart`** — the D2 cases: version match uses cache without a fetch; version mismatch fetches and rewrites cache; fetch failure falls back to cache; empty cache + failure falls back to the committed JSON.
4. **`media_ref_legacy_json_test.dart`** — pins the bare-`ImageRef` migration at `media_ref.dart:55-58`, load-bearing for every browser with stored content and currently unprotected.
5. **`certificates_view_model_test.dart`** — one `bloc_test` as the pattern reference.

Skip widget and golden tests.

---

## Effort & sequencing

*Updated 2026-09-10 — the percentages below are current, not the original snapshot.*

| Phase | Share | Done | Blocked by |
|---|---|---|---|
| 0 Firebase setup + bundle | 15% | **100%** | — |
| 1 Read path + cache + seed migration | 10% | **100%** | 0, 7.1 |
| 2 Auth + rules + write path | 12% | **100%** | 0, 1 |
| 3 Static → dynamic | 22% | **100%** | — (parallel to 0–2) |
| 4 Missing forms | 18% | **100%** | 3 (for SiteContent/Skills) |
| 5 Reorder | 6% | **100%** (7 of 9 collections; 2 have no renderer) | 4 |
| 6 Media | 12% | **100%** (6a/6c closed by deleting the orphans instead) | 0, 2 |
| 7 Tests | 5% | ~95% (7.1–7.3 plus nine not on the original list) | interleaved |

**~99% done.** Every phase has landed. What is left is not a phase but a short list: the video half of `MediaRefField` still takes a pasted URL rather than an upload (images only was a deliberate scope call), and the remaining Phase 7 cases from the original list.

The critical path **0 → 7.1 → 1 → 2 → 6** is complete: content is editable from a deployed admin build, media uploads to Cloudinary, and the resulting URL is stored in Firestore.

**Resolved 2026-09-12.** The nine image paths pointing at files that did not exist (`assets/projects/flowery_store_1.png` and its eight siblings) are gone, along with the ~40 MB of orphaned media they were never wired to, so no project renders a placeholder from a dead asset path any more. `tool/validate_assets.dart` now fails the build if such a path is reintroduced.

Suggested PR order: `0` · `7.1` · `1` · `2` · `3a+3b` · `3c` · `4` · `5` · `6` · `7.2–7.5`.

## End-to-end verification

Run after Phase 6:

1. `flutter run -d chrome` (debug) → sign in via the admin FAB.
2. Edit the site name, add a certificate, reorder two projects, upload a compressed clip to Flowery Store.
3. `dart fix --apply` → `flutter analyze` → `flutter test` → all clean.
4. `dart tool/validate_assets.dart` → exits 0.
5. `flutter build web --release` → serve `build/web` → **every edit from step 2 is visible, no admin affordances are present, no placeholder boxes appear**, and signing in is impossible because the UI does not exist.
6. In a browser profile that has never visited: confirm the page loads, then check the Firebase console shows **1–2 reads** for that visit, not ~51.
7. Attempt a write from a signed-out client (console or curl) → rejected by rules.
8. Deploy; confirm the same on `marco-nagy.github.io`.
