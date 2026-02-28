# SMTP Examples

These examples show how to use the SMTP send email function [socket.mail()](https://realtimelogic.com/ba/doc/en/lua/auxlua.html#smtp). Although the examples are designed to run "as is" using the [Mako Server](https://makoserver.net/), they can also be used by other [Barracuda App Server](https://realtimelogic.com/products/barracuda-application-server/) products such as Xedge.

Note that [Xedge](https://realtimelogic.com/products/xedge/) has built-in email configuration via the IDE, as explained in the tutorial [How to Send Emails with Xedge IDE](https://realtimelogic.com/articles/How-to-Send-Emails-with-Xedge-IDE-A-StepbyStep-Guide).

Before running the examples using the Mako Server, edit [`mako.conf`](mako.conf) and configure [log.smtp](https://realtimelogic.com/ba/doc/en/Mako.html#oplog) with valid SMTP settings.

The `text`, `html`, and `eml` examples all use the Mako Server's log settings in `mako.conf` as their SMTP configuration. In each [`.preload`](text/.preload) script, the code loads `require"loadconf"`, clones `conf.log.smtp` into a local `smtpCfg` table, and then translates `consec = "starttls"` or `consec = "tls"` into the settings expected by `socket.mail()`. This means the same `from`, `to`, `server`, `port`, `user`, `password`, and transport security settings used for emailed logs are also used when these examples send email directly.

Run the email examples in this order:

1. `mako -l::text`
2. `mako -l::html`
3. `mako -l::eml`

All examples except `log` exit the Mako Server after the email is sent.

# Text Email Example

This example shows the smallest complete `socket.mail()` usage pattern: create an SMTP client from `mako.conf`, send a plain text body, print the result, and exit.

The [`.preload`](text/.preload) script performs the following steps:

1. Loads and clones the SMTP settings from `mako.conf`.
2. Converts `log.smtp.consec` into the transport settings used by `socket.mail()`.
3. Verifies that `socket.mail` was loaded by `mako.zip`.
4. Creates a plain text message body.
5. Creates an SMTP client with `socket.mail(smtpCfg)`.
6. Sends the message with `smtp:send{...}`.
7. Calls `mako.exit()` after the send attempt completes.

The message body is the [Robert Frost Poem](https://www.poetryfoundation.org/poems/44272/the-road-not-taken) used by the [SharkSSL SMTP C example](https://github.com/RealTimeLogic/SharkSSL/blob/main/examples/SMTP-example.c), but the send operation itself is pure Lua:

```lua
local smtp=socket.mail(smtpCfg)
local ok,err=smtp:send{
   from=smtpCfg.from,
   to=smtpCfg.to,
   subject="Text email sent by BAS",
   txtbody=message
}
```

Use this example first when validating your SMTP settings because it removes HTML, inline images, and template parsing from the test.

# HTML Email Example

This example sends an HTML email with an inline image by using `htmlbody`, a plain text fallback, and `htmlimg`.

Like the text example, [`.preload`](html/.preload) clones `conf.log.smtp` from `mako.conf`, normalizes the `consec` setting, creates an SMTP client, sends one message, and exits with `mako.exit()`.

The main difference is the message table passed to `smtp:send(...)`:

```lua
local ok,err=smtp:send{
   from=smtpCfg.from,
   to=smtpCfg.to,
   subject="HTML email sent by BAS",
   txtbody="The email can only be viewed by an HTML enabled client",
   htmlbody=message,
   htmlimg={
      id="the-unique-id",
      name="logo.png",
      source=ba.openio"home":open"data/BAS-Logo.png"
   }
}
```

The HTML body references the image with `src="cid:the-unique-id"`, and `htmlimg` attaches [`data/BAS-Logo.png`](data/BAS-Logo.png) as the corresponding inline MIME part.

This example is useful after the plain text example succeeds because it confirms that your SMTP configuration also works for multipart HTML messages with embedded content.

# Log Email Example

This example indirectly sends email by using [mako.log()](https://realtimelogic.com/ba/doc/en/Mako.html#mako_log) instead of calling `socket.mail()` directly.

The [`.preload`](log/.preload) script defines a small helper that enables timestamps and then writes two log messages:

1. The first call queues a log entry without flushing.
2. A `ba.timer(...)` callback runs two seconds later.
3. The second call uses `{flush=true}` so the buffered log data is flushed immediately.
4. If logging is not enabled, the helper reports that by calling `trace`.

This example uses the same email-related configuration in [`mako.conf`](mako.conf), but through Mako's logging system instead of through `socket.mail()`. The `log.smtp` table defines where log emails are sent, `log.signature` adds the message footer, and `log.logerr = true` enables emailed Lua exception reports.

The crash-report part of the example is triggered by [`index.lsp`](log/index.lsp) (http://localhost). When that page is requested while the server is running in the background, the page intentionally raises an error if `mako.daemon` is true. With `log.logerr = true`, that exception is turned into a log email containing the stack trace.

Background mode means:

1. On Windows, the server must be installed as a service.
2. On Linux, you can run `mako -s -l::log`, which keeps the server attached to the console while still running in background mode.

Unlike the `text`, `html`, and `eml` examples, the `log` example does not call `mako.exit()` because it is meant to demonstrate ongoing logging and request-triggered error reporting.

# EML Email Example

This example shows how to parse an `.eml` file, modify the parsed message, and send it with `socket.mail()`.

The `eml` module is useful when you want to design and store an email as a single file and then reuse it as a runtime template. A typical workflow is:

1. Create the email in a regular mail client or HTML email editor.
2. Save the message as an `.eml` file.
3. Parse the file at runtime.
4. Replace dynamic tags in the parsed body.
5. Set sender, recipient, and subject.
6. Send the message with `socket.mail()`.

This approach is practical for HTML emails because the original formatting, inline images, and MIME structure can stay in one consistent source file.

## The `eml` Module

The `eml` module is part of this example. It is not included with the Barracuda App Server as a built-in module.

The example provides the parser in [`.lua/eml`](eml/.lua/eml), and [`.preload`](eml/.preload) sets up module loading with [mako.createloader(io)](https://realtimelogic.com/ba/doc/en/Mako.html#mako_createloader) so it can be imported with:

```lua
local eml = require'eml/EmailMessage'
```

If you want to reuse the parser in another BAS application, copy the `eml` module files into that application's Lua module path and set up loading in the same way.

## What Is an EML File?

An EML file is a raw email message stored as text. It normally contains:

- Message headers such as `From`, `To`, `Subject`, `Content-Type`, and `Content-Transfer-Encoding`
- One body or multiple MIME parts
- Optional plain text and HTML alternatives
- Optional inline images or attachments

An EML file is effectively the serialized form of one email message. Because it preserves the MIME structure, it is a good format for storing a finished email template that can later be customized before sending.

For example, an HTML body could contain placeholders such as:

```html
<p>Hello {{NAME}},</p>
<p>Your order {{ORDER_ID}} is ready.</p>
```

After parsing the EML file, your Lua code can replace these tags before calling `smtp:send(...)`.

## How the Example Works

The [.preload script](eml/.preload) performs the following steps:

1. Loads and clones the SMTP settings from `mako.conf`.
2. Calls `mako.createloader(io)` so Lua can load modules from `eml/.lua`.
3. Loads the parser with `require "eml/EmailMessage"`.
4. Opens `data/BAS-Info.eml`.
5. Parses the EML file into a Lua table.
6. Verifies that an HTML body and inline-image table were extracted.
7. Adds fields required for sending.
8. Creates an SMTP client with `socket.mail(smtpCfg)`.
9. Sends the parsed and modified message with `smtp:send(m)`.

## Example Walkthrough

The core flow in [`.preload`](/a:/Email-and-Logging/eml/.preload) is:

```lua
mako.createloader(io)
local eml = require'eml/EmailMessage'
local emlFile=require"rwfile".file(ba.openio"home","data/BAS-Info.eml")
local m,err = eml(emlFile) -- Parse
m.txtbody="The email can only be viewed by an HTML enabled client"
m.from=smtpCfg.from
m.to=smtpCfg.to
m.subject="EML (HTML) email sent by BAS"
local smtp=socket.mail(smtpCfg)
local ok,err=smtp:send(m)
```

## What the Parser Returns

`require "eml/EmailMessage"` returns a function that parses the raw EML text:

```lua
local eml = require'eml/EmailMessage'
local m, err = eml(rawEmlText)
```

On success, the returned table may include:

- `m.htmlbody`
  The decoded HTML body, if present.
- `m.txtbody`
  The decoded plain text body, if present.
- `m.htmlimg`
  A table with inline image data extracted from MIME parts with `Content-ID`.
- `m.charset`
  The detected charset from the MIME headers or HTML meta tag.

This return value is shaped so it can be extended and then sent through `socket.mail()`.

## Using the Parsed Message with `socket.mail()`

After parsing, the example adds the fields typically required by the SMTP client:

- `m.from`
- `m.to`
- `m.subject`
- `m.txtbody` if a plain text fallback should be included

The parsed `m.htmlbody` and `m.htmlimg` values are preserved and passed directly to `smtp:send(m)`.

This means the EML file can hold the HTML design and any inline images, while the runtime code supplies delivery-specific values such as recipient and subject.

## Runtime Template Replacement

One of the main advantages of storing an email as EML is that you can keep one approved template and update only the dynamic values before sending.

### Option 1: Simple Tag Replacement

This is the simplest option and works well when the template only needs a few values replaced.

```lua
local m, err = eml(emlFile)
assert(m, err)

m.htmlbody = m.htmlbody
   :gsub("{{NAME}}", customerName)
   :gsub("{{ORDER_ID}}", orderId)

m.txtbody = (m.txtbody or "Hello {{NAME}}")
   :gsub("{{NAME}}", customerName)
   :gsub("{{ORDER_ID}}", orderId)

m.from = smtpCfg.from
m.to = customerEmail
m.subject = "Order " .. orderId

assert(socket.mail(smtpCfg):send(m))
```

This pattern is ideal when:

- the email layout should be maintained outside the Lua code
- designers or non-programmers produce the original email
- the same email structure is reused many times
- only a small number of fields need to change at runtime

### Option 2: Render Dynamic Content with `ba.parselsp()`

For more advanced systems, especially embedded systems, the email can still be stored as one stable EML template while selected sections are generated dynamically by Lua.

This is useful when the email includes generated data such as:

- logs
- alarms
- measurement tables
- runtime status summaries
- device-specific diagnostics

The BAS function [ba.parselsp()](https://realtimelogic.com/ba/doc/en/lua/lua.html#ba_parselsp) parses Lua Server Page content and returns Lua source code that can be compiled with `load()`. Note that ba.parselsp()can be used with any text format, including HTML. The parser simply converts text into Lua code and preserves the embedded Lua code within <?lsp ?> and <?lsp= ?> tags.

## Notes

- The parser normalizes message structure internally and decodes quoted-printable and base64 body content.
- Inline MIME parts with `Content-ID` are collected in `m.htmlimg`.
- The .preload example assumes the EML file contains an HTML body.
- If the EML file does not provide all fields required for sending, add them in Lua before calling `smtp:send(...)`.
