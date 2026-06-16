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

The release ships a **DMG** (what people download + drag to Applications). Sparkle
updates from the same DMG (its appcast enclosure points at it).

```sh
xcodegen generate
# Build universal (Intel + Apple Silicon):
xcodebuild -project Eli.xcodeproj -scheme Eli -configuration Release \
  ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO build   # add Developer ID signing when notarizing
# (ad-hoc only, until a Developer ID cert exists:)  codesign --force --deep --sign - Eli.app
# Notarize + staple (once you have a Developer ID cert):
xcrun notarytool submit Eli.dmg --keychain-profile "AC_PASSWORD" --wait && xcrun stapler staple Eli.dmg

# Build the DMG (Eli.app + drag-to-Applications):
mkdir stage && cp -R Eli.app stage/ && ln -s /Applications stage/Applications
hdiutil create -volname Eli -srcfolder stage -ov -format UDZO "Eli-<version>.dmg"

# Sign the DMG + build the appcast (uses the Keychain EdDSA key):
.../Sparkle/bin/generate_appcast --download-url-prefix \
  "https://github.com/hatimhtm/eli/releases/latest/download/" /folder-with-the-dmg

# Publish: attach the DMG + appcast.xml to a GitHub release tagged v<version>:
gh release create v<version> Eli-<version>.dmg appcast.xml --notes-file CHANGELOG.md
```
Bump `MARKETING_VERSION` **and** `CURRENT_PROJECT_VERSION` in `project.yml` each release
(Sparkle compares the build number to decide what's newer).

**Result:** people download the DMG and drag Eli into Applications; existing installs
see the update when they click **Check for Updates**, then one click installs it.

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
