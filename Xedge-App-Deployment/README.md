# Xedge App Deployment

## Overview

This example is the source form of `MyApp.zip` for the tutorial [Mastering Xedge Application Deployment: From Installation to Creation](https://realtimelogic.com/articles/Mastering-Xedge-Application-Deployment-From-Installation-to-Creation).

The example shows the layout expected by Xedge when packaging an application ZIP. The deployable app is built from the contents of `www/`, not from the `Xedge-App-Deployment/` directory itself.

## Files

- `www/.config` - Xedge application metadata and install/upgrade callbacks.
- `www/.preload` - Startup script loaded when the app starts.
- `www/index.lsp` - Simple LSP page shown at the app URL.
- `www/MyTest.xlua` - Small Xedge `.xlua` startup/shutdown example.

## How to package

Create `MyApp.zip` by zipping the contents of `www/` from inside that directory:

```bash
cd www
zip -D -q -u -r -9 ../MyApp.zip .
```

This command is intentional: the ZIP must contain `.config`, `.preload`, `index.lsp`, and `MyTest.xlua` at the ZIP root. Do not zip the parent `www` directory itself.

## How to deploy to Xedge

1. Package the app as shown above.
2. Open the Xedge IDE in your browser.
3. Open the menu in the top-right corner and select **App Upload**.
4. Drag and drop `MyApp.zip` into the uploader.
5. Click **Save** without enabling unpacking.
6. Navigate to the app URL configured by `www/.config`.

The included `.config` uses:

```lua
name="MyApp"
dirname="myapp"
```

This means the app is exposed under the `myapp` application path, for example:

```text
http://device-address/myapp/
```

## Local Mako preview

You can preview the LSP page with Mako Server:

```bash
cd Xedge-App-Deployment
mako -l::www
```

This is useful for checking `index.lsp`, but the Xedge `.config` install and upgrade callbacks are part of the Xedge deployment workflow and are not the same as a plain Mako preview.

## Notes / Troubleshooting

- Keep `.config` at the root of the ZIP.
- Package from inside `www/` so the ZIP layout is correct.
- If you change `dirname` in `.config`, the browser URL changes accordingly.
- If you regenerate `MyApp.zip`, inspect the ZIP contents before uploading; there should be no leading `www/` directory in the archive.
