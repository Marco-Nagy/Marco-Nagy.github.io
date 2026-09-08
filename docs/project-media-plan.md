# Project media: video + GIF + showcase image editing

Design notes for the unfinished feature on `wip/project-media`. Written so a
session with no prior context can pick it up. Dated 2026-09-07.

## Where things stand

**Done and working** (the branch this doc lands on): debug-mode add / edit /
delete for projects — `AdminAddButton` → `ProjectFormSheet` → `SaveProject` →
`ProjectsUseCase.upsert` → `PortfolioRepo` → `shared_preferences`. Shared by the
Projects page and the home page's featured block via `ProjectsListView`.

**Started, then reverted**: the media migration. It is parked on
`wip/project-media` as a single commit that **does not compile** — the entities
were switched to `MediaRef` before the three render sites that consume them were
migrated. Do not merge that branch; cherry-pick from it or redo it in the order
below.

## What the schema already supports (no change needed)

These were in place before any of this work and cover most of what was asked:

| Need | Field |
|---|---|
| Screenshot framed as web vs mobile | `MediaShot.frame` → `DeviceFrameType.laptop` (web, landscape) vs `iphone` / `samsungS` |
| Play Store feature graphic | `ShowcaseFormat.featureGraphic` (1024:500) |
| Image as panel background | `ShotBackgroundStyle.image` + `ShotBackground.image`, with `overlayOpacity` / `blurSigma` |
| List-row thumbnail | `PersonalProject.cover`, drawn by `_RevealBlock` in `project_list_row.dart` |

`device_frame.dart` already paints all four bezels. What is missing is the
**editor UI**, not the model.

## Decisions taken

1. **Both video sources.** `mp4`/`webm` via `video_player`, and YouTube via
   `youtube_player_iframe`. Neither package is in `pubspec.yaml` on `main`.
2. **Media at project level *and* per shot** — a panel inside a phone or laptop
   bezel can play a screen recording, not just show a still.
3. **Picked images embed first, pin later.** The picker returns
   `ImageRef.embedded(base64)` so the result renders immediately (web has no
   writable `assets/`), and an explicit "pin as asset" action swaps that for the
   `assets/...` path a release build ships.

## Schema shape

New entity `lib/features/portfolio_content/domain/entities/media_ref.dart`:

```dart
enum MediaKind { image, videoFile, videoEmbed }

@freezed
abstract class MediaRef with _$MediaRef {
  const factory MediaRef({
    @Default(MediaKind.image) MediaKind kind,
    @Default(ImageRef()) ImageRef image,   // the still, or a video's poster
    @Default('') String videoUrl,          // asset path or URL
    @Default(true) bool muted,
    @Default(true) bool loop,
    @Default(true) bool autoplay,
  }) = _MediaRef;
}
```

Then **change the type of two existing fields**, keeping their names:

- `PersonalProject.cover`: `ImageRef` → `MediaRef`
- `MediaShot.image`: `ImageRef` → `MediaRef`

Changing the type rather than adding a parallel `preview` field avoids two
fields that mean almost the same thing. Keeping the *names* keeps the stored
JSON keys stable.

### Why `MediaRef.fromJson` is hand-written

`cover` and `MediaShot.image` already hold bare `ImageRef` payloads in visitors'
local storage. Without a hand-written factory nothing would even throw:
json_serializable finds no `image` key, falls back to the `@Default`, and every
stored screenshot silently becomes blank. `_readList` only rescues payloads that
fail to parse, and this one parses perfectly. So `fromJson` takes both shapes:

```dart
factory MediaRef.fromJson(Map<String, dynamic> json) =>
    json.containsKey('image')
        ? _$MediaRefFromJson(json)
        // Legacy: this field used to hold a bare ImageRef.
        : MediaRef(image: ImageRef.fromJson(json));
```

The discriminator is `image`, **not** `kind` — both types carry a `kind` key, so
that one cannot tell them apart.

`ShotBackground.image` stays an `ImageRef`. A video background was out of scope.

## Constraints worth knowing before writing code

- **GIF is nearly free.** Flutter decodes and animates GIFs in `Image.asset` /
  `Image.network`, and `AppImage` routes through both. A `.gif` in `cover`
  animates today with no new code — and because `_RevealBlock` only shows the
  cover on hover, it already effectively "plays on hover".
- **A YouTube player does not survive `Transform.rotate`.** It is a platform
  view (iframe on web), and the hover reveal draws its preview rotated. So:
  hover previews must be a GIF or a `video_player` surface, which Flutter
  composites normally; YouTube belongs only on flat, upright surfaces such as
  the detail view. Encode this in the API — `AppMedia` should take an
  `allowPlatformView` flag and fall back to the poster when it is false.
- **`shared_preferences` on web is `localStorage`, ~5 MB for the whole site.**
  A few embedded base64 screenshots will blow that. The image field warns past
  ~700 KB and points at the asset path instead.
- **Pushing to `main` deploys the live site** — see
  `.github/workflows/github_pages.yaml`. Work on branches.

## Player patterns

All three renderers keep `AppImage`'s contract: a broken source degrades to the
`fallback` widget, it never throws and never shows a black box.

**`AppMedia`** dispatches on `kind` and takes `playing` from its parent — a
player never decides on its own whether to run. `allowPlatformView: false` makes
`videoEmbed` render its poster instead, which is what keeps YouTube out of
transformed surfaces.

**GIF — no package, no widget, but not free either.** Flutter animates GIFs in
`Image.asset`/`.network`/`.memory` and cannot pause them. `_RevealBlock` lives
inside an `AnimatedOpacity` at `opacity: 0`, so it stays mounted and painting:
every project's GIF would loop invisibly, forever, and a hover would catch one
mid-loop. So `AppMedia` mounts an animated source only while `playing` — which
also makes each hover start at frame one. Detect it by extension (`.gif`), or by
the data URI's mime for an embedded ref.

**`video_player` — `VideoFileView`.** Create the controller lazily, on the first
`playing == true`, never in `initState` or `build`: the projects page has a row
per project and each would otherwise open its own decoder. React to the parent
in `didUpdateWidget`; dispose in `dispose`. Show `media.image` as the poster
until `initialize()` resolves, and keep showing it forever if that call throws.
`BoxFit.cover` without distortion is
`ClipRect(FittedBox(cover, SizedBox.fromSize(size: value.size, VideoPlayer)))`.
Browsers refuse unmuted autoplay, so an unmuted `autoplay` ref must catch the
rejected `play()` and rest on its poster rather than looking broken.

**`youtube_player_iframe` — `VideoEmbedView`.** Deliberately lazier still:
poster plus a play badge, and the controller is built on the first tap. Each one
is an iframe on web and a WebView on mobile, so a five-panel detail view must
not boot five of them for a visitor who opens none. If the URL yields no video
id, fall back to the poster and an external `url_launcher` link.

Its API has moved across major versions (`fromVideoId` vs `initialVideoId`,
`close()` vs `dispose()`), so read the installed version out of pub-cache before
writing that file rather than recalling it. `video_player`'s API is stable.

Where each is allowed:

| Surface | Transformed | Allowed |
|---|---|---|
| `_RevealBlock` hover preview | yes, rotated | GIF, `videoFile` |
| Detail panel / inside a device frame | no | all three |
| Admin form previews | no | poster only — never boot a player in the editor |

## Implementation order (this is the part that went wrong)

Switching the entities first breaks three render sites at once and leaves the
tree uncompilable. Build the renderers **before** touching the entities, so the
tree only goes red for the length of one step:

1. `flutter pub get` with `video_player` + `youtube_player_iframe` added, then
   read the installed APIs from pub-cache rather than guessing at them.
2. Write `lib/core/widgets/common/app_media.dart` (`AppMedia`, the `AppImage`
   sibling: takes a `MediaRef`, a `playing` flag, `allowPlatformView`),
   `video_file_view.dart`, `video_embed_view.dart`.
3. Add `media_ref.dart`; run `dart run build_runner build --delete-conflicting-outputs`.
4. Switch `PersonalProject.cover` and `MediaShot.image` to `MediaRef`; regenerate.
5. Migrate consumers in one pass. This list was re-checked against the tree on
   2026-09-07; every entry is a real call site:
   - `seed_projects.dart` — three `cover:` plus the shot built in `_panel`
   - `list_row_data.dart` — the field type, and line 79 becomes
     `MediaRef.still(item.images.first)`; custom-section items stay `ImageRef`
   - `device_frame.dart` — the `image` parameter type
   - `showcase_panel_view.dart:124`
   - `project_list_row.dart:202` — `AppMedia(playing: revealed)`. `_RevealBlock`
     already takes `revealed`, so this is a one-line wire
   - `project_form_sheet.dart` — reads `cover.value` at lines 77 and 115, which
     `MediaRef` does not have. A mechanical fix (`cover.image.value`,
     `MediaRef.still(...)`) belongs in *this* step; the real media editor comes
     later. Without it, step 6 cannot go green.

   `project_detail_view.dart` needs no change — it hands `data` straight to
   `ShowcasePanelView` and never touches `cover` or `shot.image`.
6. `flutter analyze` — expect green here, before any form work starts.

## Admin editor, after the above is green

New shared widgets under `lib/core/widgets/admin/`:

- `image_ref_field.dart` — preview box + "choose image" + "pin as asset" +
  "clear", backed by `ImagePickerService` (see the wip branch for both).
- `media_ref_field.dart` — kind chips, wrapping `ImageRefField` for the poster
  plus a URL field for the two video kinds.
- `admin_choice_field.dart` — labelled single-select chips, reused by device
  frame, panel format, caption placement and background style.
- `admin_slider_field.dart` — for `scale`, `rotationDegrees`, `offsetX/Y`,
  `overlayOpacity`, `blurSigma`, all of which want a slider, not a text field.

New sheets under `lib/features/projects/presentation/widgets/`:
`shot_form_sheet.dart`, `panel_form_sheet.dart`, `background_form_sheet.dart`,
and inline panel/shot lists inside their parent sheets. Keep the lists inline
rather than adding another sheet level — nesting bottoms out at three modals
(project → panel → shot) that way.

`ProjectFormSheet` then owns `panels` and `showcaseBackground` for real, so drop
its "carried through untouched" comment when it does.

Every new label needs a `LangKeys` constant plus `translations/en.json` and
`translations/ar.json` entries.

## Known gaps not covered here

- No editor exists yet for Certificates, Work History or Pricing — those
  entities and use cases exist, but no form sheet and no add button.
- `lib/core/widgets/admin/admin_fab.dart` is dead code since the switch to
  `AdminAddButton`.
- `ProjectFormSheet` silently falls back to the previous accent when the hex is
  malformed, with no message to the user.
