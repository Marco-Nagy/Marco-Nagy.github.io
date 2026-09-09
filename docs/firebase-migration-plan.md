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

1. **Architecture — full Firebase.** Firestore for content, Cloud Storage for media. The admin writes directly; the deployed site reads live. This replaces the export-JSON-and-rebuild pipeline entirely and supersedes the "no backend" rule in the project's skill file.
2. **Scope** — everything on the site becomes admin-editable, including hero/about/contact/footer/nav/skills copy.
3. **Media** — uploaded to Cloud Storage as URLs. Compression settings still to be measured (see Phase 6).

### Why the free tier holds — and what actually limits it

| Firebase Spark (free) | Quota | What it means here |
|---|---|---|
| Firestore storage | 1 GB | Content is text; irrelevant |
| Firestore reads | 50K/day | **See read design below** |
| Firestore writes | 20K/day | Admin-only; irrelevant |
| Cloud Storage | 5 GB | Fine for compressed media |
| Storage downloads | **1 GB/day** | **The real ceiling** |

**Read design decides visitor capacity.** One document per entity = ~51 reads per visitor ≈ 980 visitors/day. Instead: **one `content/bundle` document plus a tiny `content/meta` version document.** A visitor reads `meta` (1 read), compares `contentVersion` to their cached copy in `shared_preferences`, and fetches `bundle` only when it changed. Typical returning visitor: **1 read**. That puts Firestore comfortably out of the way.

**Media is the actual constraint.** At current sizes (~46MB per clip) the 1 GB/day download cap allows roughly **21 full page views per day**. Compressed to ~2MB total it allows roughly **500 per day**. Compression is what determines real visitor capacity, not the database.

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

New deps: `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_auth`. Run `flutterfire configure` (generates `firebase_options.dart`). Initialize in `main.dart` before `runApp`.

Create `portfolio_bundle.dart`; add `readAll()` / `writeAll(bundle)` to `portfolio_local_data_source(_impl).dart`, composing from the existing getters plus the existing `keysWithPrefix` helper for custom items. Create `lib/features/portfolio_content/data/data_sources/portfolio_remote_data_source.dart` + `_impl.dart` (`@LazySingleton`) exposing `fetchMeta()`, `fetchBundle()`, `writeBundle()`.

Also: **`admin_fab.dart` currently has zero call sites.** Turn it into the admin speed-dial (Sign in / Publish / Export / Site content / Sections) mounted once in `portfolio_scaffold.dart` inside an `AdminGate` — it becomes the entry point every later phase needs.

**Verify:** debug build connects to Firebase; a hand-written `content/meta` document is readable from the app; `readAll()` produces a bundle with 3 projects, 9 certificates, 1 work entry, 3 packages, 14 add-ons, 7 sections, 7 skill groups, 6 badges, 1 siteContent.

### Phase 1 — Read path + caching + seed migration · 10% · *needs 0*

Rewrite the repository read path per D2 and add `bundled_content_loader.dart` (`rootBundle.loadString`, null when absent) for the D3 floor. Replace the unversioned `portfolio_seeded` boolean with `portfolio_content_version`; convert every `_decodeList` fallback from `const []` (lines 150/163/180/193/211/245/258/273/291) to a bundle-backed thunk so a missing key falls back to real content instead of blanking the section; make the catch-all at `:112` assert + `debugPrint` so schema drift is loud in debug instead of silent.

**Bootstrap:** the first Firestore bundle is produced by exporting the current Dart seeds — you never hand-write it. Export → upload once → then delete `lib/features/portfolio_content/data/seed/` (all 7 files) and their imports. Last-resort fallback becomes the committed JSON, then `const PortfolioBundle()` + a hard assert.

**Verify:** fresh profile loads from Firestore; second load costs 1 read (check the Firebase console); bumping `contentVersion` remotely refreshes the client; airplane mode falls back to cache; cleared cache + blocked network falls back to the committed JSON; `grep -r "Seed" lib/` returns nothing.

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

The `<owner-uid>` literal above is the reason the console step records the UID: `request.auth != null` alone is not enough, because the public `signUp` endpoint stays open by default and the Firebase config ships in the web bundle — anyone could self-register and satisfy it. The UID is an identifier, not a credential, so it is safe to commit in `firestore.rules` / `storage.rules`; those files deploy via the CLI and never enter the Flutter bundle.

**Verify:** signed out, a write is rejected by rules (confirm in console logs); signed in, it succeeds; a second browser sees the change after one reload; a release build shows no admin affordances at all.

### Phase 3 — Static UI → dynamic · 22% · *parallel to 0–2* — largest phase

**3a. Two app-wide cubits.** `SiteContentCubit` and `SectionsCubit`, following the `CertificatesViewModelCubit` shape, provided **above `MaterialApp`** in `marco_portfolio_app.dart` beside `AppCubit` — the nav bar, drawer and footer live in `PortfolioScaffold` below every screen's own provider, so per-screen provision cannot reach them. Both expose non-nullable fields with sane defaults seeded from cache, so **chrome never renders a spinner or an error**; it paints the last-good value while a fetch is in flight. Add `context.site` / `context.visibleSections` extensions.

**3b. The `url_opener.dart` problem.** It reads `ProfileInfo` from a non-widget context (lines 28/30/43/59). Strip it to `static Future<bool> open(String url)` and move the content-dependent parts into a new `SiteLinks` view-data object (`mailto`, `tel`, `resume`) exposed as `context.siteLinks`. Explicitly rejecting the shortcut of calling `getIt<SiteContentCubit>()` inside `UrlOpener` — it would make a leaf utility depend on the DI container and a presentation cubit, inverting the dependency direction the rest of the codebase respects, to save ~6 call-site edits.

**3c. Convert the call sites** — hero headline/tags/photo/orbit badges, about statements (via the existing-but-never-called `StatementData.fromSiteContent`), skills block, contact links, footer headline/availability/socials, monogram, nav items, resume button, splash name.

**Then delete:** `profile_info.dart`, `skill_groups.dart`, `tech_badges.dart`, `app_links.dart`, `nav_items.dart`, and the content keys from both translation JSONs.

**Verify:** `grep -rn "ProfileInfo\|NavItem.all\|AppLinks\|SkillGroups\.\|TechBadges\." lib/` returns nothing. Editing the site name in the admin form changes nav, hero, splash and footer — on the deployed site, with no rebuild.

### Phase 4 — The 6 missing forms · 18% · *needs 3 for SiteContent/Skills only*

**Shared abstraction: two small widgets only** — `admin_text_field.dart` (thin wrapper over `UnderlineTextField`) and `bilingual_field_pair.dart` (the en/ar row that recurs ~20 times, 6 of them inside `project_form_screen.dart`). **Not** a schema-driven form engine: the fields are genuinely heterogeneous (`MediaRefField` is 590 lines, plus gradient/sub-list/color fields) and Dart has no reflection, so a generic engine becomes a large tagged union with worse ergonomics. `AdminFormScreen` + `AdminFormSheet` already *are* the scaffold abstraction. Also move `admin_sub_list.dart` from the projects feature into `core/widgets/admin/` — `PricingPackage` needs it and it is not project-specific.

Forms: `certificate_form_screen`, `work_history_form_screen`, `pricing_package_form_screen`, `pricing_add_on_form_sheet` (4 fields — a sheet, not a page), `site_content_form_screen` (43 fields grouped into Identity / Hero / About / Contact / Footer `ExpansionTile`s), `skill_group_form_screen` + `tech_badge_form_sheet`.

Reused verbatim from `project_form_screen.dart`: `IdGenerator.next()`, `TextListConverter`, `Validators`, `MediaRefField`, `AdminColorField`, `AdminChoiceField<T>`, the controller lifecycle pattern, and the `static Future<T?> open(context, {entity})` convention.

**The wiring is the real work.** For each of `certificates_section.dart:107`, `experience_section.dart:98`, `pricing_section.dart:146` and `:218`: replace `onEdit: () {}` with the form + `cubit.doAction(Save*(result))` (**those handlers already exist and have never been dispatched**), wrap `onDelete` in `AdminConfirmDialog.show` to match Projects, and add an `AdminAddButton` to each section header — none of these four sections has one today.

**Verify:** add/edit/delete one of each, reload, confirm it persisted to Firestore, and check the change appears in a second browser.

### Phase 5 — Reorder · 6% · *needs 4*

**Build drag-and-drop.** The cost is unusually low: the data source **already** has `saveX(List<T>)` for all 9 collections, each repo method is a `_guard` one-liner, and each use case is a 3-line passthrough (`SectionsUseCase.saveAll` is the template). One new widget — `admin_reorderable_list.dart` wrapping `ReorderableListView` inside an `AdminGate`, so no drag handles ship to visitors. With numeric fields instead, swapping two rows means editing two records and getting the arithmetic right, across 9 entities. Remove the numeric `order` field from `project_form_screen.dart` once this lands — two sources of truth for ordering will drift.

### Phase 6 — Media: compression + Cloud Storage upload · 12% · *needs 0, 2*

**6a. Compress first — settings to be measured, not assumed.** A GOM export produced MP4s *larger* than the source GIFs (25–46MB each), proving the container is irrelevant and only encoder settings matter. Baseline with the installed ffmpeg 9.0.1:

```
ffmpeg -y -i "in.gif" -vf "scale=540:-2:flags=lanczos,fps=24" \
  -c:v libx264 -crf 30 -preset slow -pix_fmt yuv420p \
  -movflags +faststart -an "out.mp4"
```

Escalation if still too large: `-crf 34`, then width 440, then WebM/VP9. **Record the measured sizes before committing** — they determine the daily visitor ceiling (1 GB/day ÷ page weight).

**6b. Real upload flow, replacing the current trap.** `MediaRefField._pickAsset()` (`media_ref_field.dart:162-191`) is the *default* action and reads the picked file only for its name, discarding the bytes — it assumes the developer already copied the file into the repo by hand, and `_pinAsAsset()` (`:232-247`) is a pure text swap that copies nothing. Firebase makes this honest: **pick → upload to Cloud Storage → store the download URL as `ImageRef.network`.** The model already supports `ImageSourceKind.network` and `MediaKind.videoFile` with a URL, so no rendering changes are needed. Add an upload progress indicator and a size guard that rejects files above a set ceiling before upload.

**6c. Wire the 5 clips + cover to Flowery Store through the admin UI** — this doubles as the end-to-end acceptance test. Then delete the 6 orphaned originals from `assets/projects/` and `AppImages.floweryStoreShots`/`floweryDeliveryShots`/`fitnessAppShots` (`app_images.dart:12-30` — all 9 paths point at files that do not exist). Declare or delete `assets/backgrounds/`, which exists on disk but is missing from `pubspec.yaml`.

**6d. `tool/validate_assets.dart`** (plain Dart, CI before release build) — fails on referenced-but-missing local paths, paths outside declared assets directories, orphan files, filenames outside `[a-z0-9._/-]`, and **any `ImageSourceKind.embedded` in the bundle** (base64 must never reach Firestore — it would blow the 1 MiB document limit).

### Phase 7 — Tests · 5% · *interleaved; round-trip test precedes deleting the seeds*

Zero tests exist today. Target what can silently destroy content, using `SharedPreferences.setMockInitialValues` and `fake_cloud_firestore`.

1. **`bundle_round_trip_test.dart`** — every entity and the full bundle: `toJson` → `fromJson` → equals. freezed's `==` makes this free. Lands with Phase 0, **before** Phase 1 deletes the seeds.
2. **`bundle_size_test.dart`** — asserts the serialized bundle stays under Firestore's 1 MiB document limit and contains no embedded base64.
3. **`remote_sync_test.dart`** — the D2 cases: version match uses cache without a fetch; version mismatch fetches and rewrites cache; fetch failure falls back to cache; empty cache + failure falls back to the committed JSON.
4. **`media_ref_legacy_json_test.dart`** — pins the bare-`ImageRef` migration at `media_ref.dart:55-58`, load-bearing for every browser with stored content and currently unprotected.
5. **`certificates_view_model_test.dart`** — one `bloc_test` as the pattern reference.

Skip widget and golden tests.

---

## Effort & sequencing

| Phase | Share | Done today | Blocked by |
|---|---|---|---|
| 0 Firebase setup + bundle | 15% | 0% | — |
| 1 Read path + cache + seed migration | 10% | ~20% (local layer exists) | 0, 7.1 |
| 2 Auth + rules + write path | 12% | 0% | 0, 1 |
| 3 Static → dynamic | 22% | ~30% (data layer only) | — (parallel to 0–2) |
| 4 Missing forms | 18% | ~35% (Projects + dead handlers) | 3 (for SiteContent/Skills) |
| 5 Reorder | 6% | ~15% (repo support) | 4 |
| 6 Media | 12% | 0% | 0, 2 |
| 7 Tests | 5% | 0% | interleaved |

Critical path: **0 → 7.1 → 1 → 2 → 6**. Phase 3 is the largest single chunk and runs in parallel with 0–2.

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
