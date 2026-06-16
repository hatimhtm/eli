# Shipping Eli

What's left to make Eli installable by others and to turn on the one-click
update button. None of this is code — it's signing + hosting, done once.

## Status of what's done vs. what needs your Apple account

- ✅ **Sparkle keys**: a signing keypair already exists in your Keychain (shared
  with Relay). Eli's `SUPublicEDKey` is set to the matching public key. No action.
- ✅ **Update feed**: `SUFeedURL` points at this repo:
  `https://raw.githubusercontent.com/hatimhtm/eli/main/appcast.xml`.
- ⚠️ **Developer ID certificate**: this Mac has *Apple Development* certs but **no
  "Developer ID Application" certificate**, which is what notarization needs. That
  cert can only be created from your paid account (one click in Xcode). Until then,
  recipients open the app with **right-click ▸ Open** the first time (normal for
  open-source Mac apps).

## 1. Create the Developer ID cert (one time)

Xcode ▸ Settings ▸ Accounts ▸ (your team) ▸ Manage Certificates ▸ **+** ▸
**Developer ID Application**. Then set the team in `project.yml`:
```yaml
settings:
  base:
    DEVELOPMENT_TEAM: <your team ID>
```

## 2. Per release

```sh
xcodegen generate
# Archive + export Developer ID signed:
xcodebuild -project Eli.xcodeproj -scheme Eli -configuration Release archive -archivePath Eli.xcarchive
xcodebuild -exportArchive -archivePath Eli.xcarchive -exportPath export -exportOptionsPlist ExportOptions.plist
# Notarize + staple:
xcrun notarytool submit export/Eli.app.zip --keychain-profile "AC_PASSWORD" --wait
xcrun stapler staple export/Eli.app
# Sign + build the appcast (uses the Keychain private key):
.../Sparkle/bin/generate_appcast /path/to/folder-with-Eli.app.zip
```
Commit the new `Eli-<version>.zip` + `appcast.xml` to this repo's `main` (or attach
the zip as a Release asset and point the appcast `url` at it). Bump
`MARKETING_VERSION` in `project.yml` each release.

**Result:** when you push a release, Eli (on your wife's Mac) notices within a day,
the toolbar button **lights up**, and one click downloads, installs, and relaunches.

## 3. Publish the repo (optional, for open-source release)

Files are ready: `LICENSE` (MIT), `README.md`, `.github/workflows/ci.yml`,
`.gitignore`. To publish:
```sh
cd Eli && git init && git add . && git commit -m "Eli v0.1.0"
gh repo create hatimhtm/eli --public --source . --push
```
Use the `106043141+hatimhtm@users.noreply.github.com` commit email; no Claude
co-author trailer.

## Reminders
- **Rotate the test Gemini key** in `Secrets.local.json` is git-ignored and never
  shipped — the app reads the key from the user's Keychain. Still, rotate the
  test key in Google AI Studio before going public.
- The `.eli` document and backups live in the sandbox container; they survive
  app updates.
