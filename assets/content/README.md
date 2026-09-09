# Bundled content

`portfolio_content.json` is the cold-start floor from decision D3 in
`docs/firebase-migration-plan.md`. It is produced by the **Export content
JSON** action in the debug-mode admin menu and committed here by hand.

Content's source of truth is Firestore (`content/bundle` + `content/meta`),
not this file. The read path (`PortfolioRepo.syncFromRemote`, run once at
startup) only reaches this file when Firestore cannot be reached *and* the
local cache is empty — a first visit during an outage, a quota exhaustion, or
a misconfigured security rule. Everyone else reads the cache or Firestore.

Doubling as a backup: every export committed here is a restorable snapshot in
git history, which is why scheduled Firestore backups (a Blaze-only feature)
were skipped — see the Phase 2 status note in the migration plan.

To refresh it after a content change: open the admin menu -> **Export content
JSON** -> paste the clipboard contents over this file -> commit.
