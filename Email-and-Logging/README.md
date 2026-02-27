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
