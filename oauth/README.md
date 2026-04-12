# OAuth 2.0 Example

## Overview

This directory contains one OAuth 2.0 example that was converted from PHP to LSP. It is based on the original sample published here: [sample-oauth2-client/github.php](https://github.com/aaronpk/sample-oauth2-client/blob/master/github.php).

## Files

- `sample-oauth2-client/github.lsp` - The LSP version of the GitHub OAuth 2.0 client example.

## How to run

Start the example with the Mako Server:

```bash
cd oauth
mako -l::sample-oauth2-client
```

For more detail on starting the Mako Server, see the [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and the [command line options documentation](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp).

## How it works

The example follows the same overall flow as the original PHP sample: it redirects the browser to GitHub for authorization, receives the callback, exchanges the authorization data for access data, and then uses that data in the application flow.

## Notes / Troubleshooting

- Review the original tutorial for the required OAuth application configuration.
- OAuth examples typically require correct callback URLs and client credentials before the flow will succeed.
