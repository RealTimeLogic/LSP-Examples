# BAS WebAuthn API

- [BAS WebAuthn REST API](#bas-webauthn-rest-api)
  - [Error Handling](#error-handling)
  - [REST API Endpoints](#rest-api-endpoints)
    - [1. Find User](#1-find-user)
    - [2. Generate Registration Options](#2-generate-registration-options)
    - [3. Register a User](#3-register-a-user)
    - [4. Generate Authentication Options](#4-generate-authentication-options)
    - [5. Authenticate User](#5-authenticate-user)
- [Client-Server Workflow](#client-server-workflow)
- [Module webauth.lua](#module-webauthlua)
  - [Creating a WebAuthn Instance](#creating-a-webauthn-instance)
    - [Function Parameters](#function-parameters)
  - [WebAuthn instance](#webauthn-instance)
    - [`webauthn:get()`](#webauthnget)
    - [`webauthn:set(users)`](#webauthnsetusers)
    - [`webauthn:quarantined(username)`](#webauthnquarantinedusername)
    - [`webauthn:validate(url)`](#webauthnvalidateurl)
  - [Callback API](#callback-api)
    - [User Registration Process](#user-registration-process)
    - [User Authentication Process](#user-authentication-process)
    - [Handling Login Failures](#handling-login-failures)
- [Database Schema](#database-schema)
  - [Usernames as Unique Identifiers](#usernames-as-unique-identifiers)
  - [Multiple Authenticators per User](#multiple-authenticators-per-user)
  - [Authenticator Data Structure](#authenticator-data-structure)
  - [Users Table](#users-table)
  - [Serializing the `users` table with binstrings](#serializing-the-users-table-with-binstrings)
- [Quarantined Table for New Registrations](#quarantined-table-for-new-registrations)

## BAS WebAuthn REST API

This is the REST API provided by the **[webauthn.lua module](WebAuthnModule/.lua/webauthn.lua)**. It is compatible with the **[SimpleWebAuthn JavaScript library](https://simplewebauthn.dev/docs/packages/browser)**.

### **Error Handling** 
All REST API endpoints may return the following JSON response on failure:

```json { "ok": false, "msg": "error-code" }```

Where `error-code` can be:
* **`Invalidrequest`** - The provided data is incorrect.
* **`webautherr`** - WebAuthn decoding/verification error.
* **`notfound`** - User not found.
* **`404`** - Web service not found.

### **REST API Endpoints**

#### **1. Find User**
`POST /webauthn/finduser`
##### **Request:**
``{ "user": "username" }``
##### **Response:**
```{ "ok": true }``` if found, ```{ "ok": false, "msg": "quarantined" }``` if found, but requires validation, or ```{ "ok": false, "msg": "notfound" }``` if the user does not exist.


#### **2. Generate Registration Options**
`POST /webauthn/regoptions`
```{ "user": "username" }```
##### **Response:**
Returns **registration options** needed for [startRegistration()](https://simplewebauthn.dev/docs/packages/browser#startregistration) in **SimpleWebAuthn**.

#### **3. Register a User**
`POST /webauthn/register`
##### **Request:**
Takes **WebAuthn attestation data** from [startRegistration()](https://simplewebauthn.dev/docs/packages/browser#startregistration).

##### **Response:**

`{ "ok": true, "msg": "message from register callback" }`

or

```{ "ok": false, "msg": "error-code" }```

where `error-code` can be:
* `Invalidrequest`
* `webautherr`
* A response message from the **server-side `register` callback** 

#### **4. Generate Authentication Options**
`POST /webauthn/authoptions`
`{ "user": "username" }`
##### **Response:**
Returns **authentication options** needed for [startAuthentication()](https://simplewebauthn.dev/docs/packages/browser#startauthentication) in **SimpleWebAuthn**.

**or:**

```{ "ok": false, "msg": "quarantined" }``` if found, but requires validation, or ```{ "ok": false, "msg": "notfound" }``` if the user does not exist.

#### **5. Authenticate User**
`POST /webauthn/authenticate`
##### **Request:**
Takes **WebAuthn assertion data** from [startAuthentication()](https://simplewebauthn.dev/docs/packages/browser#startauthentication).
##### **Response:**

```{ "ok": true, "msg": "message from authenticate callback" }```

or

```{ "ok": false, "msg": "error-code" }```

where `error-code` can be:
* `Invalidrequest`
* `webautherr`
* A response message from the **server-side `authenticate` callback** .

## **Client-Server Workflow**
1. **User enters their username** in the login form.
2. **Check if the user exists** (`webauthn/finduser`) or use (`webauthn/authoptions`).
   - If **not found**, show the **registration button** .
   - If **found**, proceed to authentication.
3. **User registers (if needed)**:
   - Request **registration options** (`webauthn/regoptions` ).
   - Call **[startRegistration()](https://simplewebauthn.dev/docs/packages/browser#startregistration)** .
   - Submit `startRegistration()` data to **`webauthn/register`** .
4. **User logs in**:
   - Request **authentication options** (`webauthn/authoptions` ).
   - Call **[startAuthentication()](https://simplewebauthn.dev/docs/packages/browser#startauthentication)** .
   - Submit `startAuthentication()` data to **`webauthn/authenticate`** .
5. **Server verifies** the authentication data using the client's public key.


## Module webauth.lua

### **Creating a WebAuthn Instance**
To initialize a **server-side WebAuthn instance**, load the module and call the `create` function:

```lua
webauthn, wadir = require"webauthn".create{
   register = function(),
   registered = function(),
   authenticate = function(),
   loginerr = function()
}
```

#### **Function Parameters**

The `create` function accepts a table with several **callback functions**. For details on required and optional callback functions, see the **[Callback API](#callback-api)**.

The `create` function returns:
- **`webauthn`** - The WebAuthn instance.
- **`wadir`** - The directory for the **[WebAuthn REST API](#rest-api-endpoints)**. The **`wadir` directory** must be installed into **[BAS's Virtual File System](https://realtimelogic.com/ba/doc/en/VirtualFileSystem.html)** to expose the WebAuthn REST API.

### WebAuthn instance

The WebAuthn instance provides the following API methods for managing user authentication data.

#### `webauthn:get()`
**Returns:**
- The **[Users Table](#users-table)**, containing all registered users and their authenticators.

**Usage Notes:**
- Your application is responsible for **reading, serializing, and persistently saving** this data.

#### `webauthn:set(users)`
**Parameters:**
- **`users`** - The **[Users Table](#users-table)** to be installed.

**Usage Notes:**
- This method is typically called **at startup** to load the persisted **Users Table** into the WebAuthn instance.

#### `webauthn:quarantined(username)`
**Parameters:**
- **`username`** - The username to check.

**Returns:**
- The **User Table** if the user has a quarantined authenticator.
- `nil` if the user has no quarantined authenticators.

**Note:**
Only the **authenticator device** is quarantined, not the user.
- A user may register **multiple authenticators**, and another **authenticator device** may have already been validated.

#### `webauthn:validate(url)`
**Parameters:**
- **`url`** - The **validation URL** provided to the `register` callback when the authenticator was registered.

**Returns:**
- The **username** if the quarantined authenticator was successfully validated.
- `nil` if no matching quarantined authenticator is found.

**Usage Notes:**
- This method **moves a quarantined authenticator** from the **quarantined table** to the **Users Table** after validation.

This API provides essential methods for managing **WebAuthn user registrations, quarantined authenticators, and database persistence** within a **BAS-powered** application.

### Callback API

The required and optional callback functions passed into function require"webauthn".[create()](#creating-a-webauthn-instance).

#### User Registration Process
1. Registration data is sent to the **`register` callback(`username`,`user`,`rawId`,`url`)** after being successfully validated.

   The callback must return:
   - **`ok` (boolean)** - `true` if the registration is to be accepted, `false` otherwise.
   - **`accept` (boolean)**:
     - `true`: The user is immediately allowed to log in.
     - `false`: The user is placed in the **`quarantined`** table for further approval.
   - **`msg` (string)** - optional response sent to browser.
   
   **Note**
   - If the function returns `false, x, [msg]` then ```{ "ok": false, "msg": msg | "" }``` is sent to the browser.
   - If the function returns `true, false` then ```{ "ok": false, "msg": "quarantined" }``` is sent to the browser.
   - If the function returns `true, true, [msg]` then ```{ "ok": true, "msg": msg or "" }``` is sent to the browser and the callback `registered` is called.

2. The **`registered` callback(`username` [,`cmd`])** is called when the user completes the registration process.
   - If the second return value from the `register` callback was true, this callback is called with callback(`username`).
   - If the second return value from the `register` callback was false, this callback is called with callback(`username` ,`cmd`) when the user completes the registration process. The callback must respond by rendering a web page or redirecting the user to for example the login page. Argument `cmd` is the combined **[request](https://realtimelogic.com/ba/doc/en/lua/lua.html#request)** and **[response](https://realtimelogic.com/ba/doc/en/lua/lua.html#response)** object.

#### User Authentication Process
- Authentication data is sent to the **`authenticate` callback(`username`,`user`,`rawId`)** after being successfully validated.
- The callback must return:
  - **`ok` (boolean)** - `true` if authentication is accepted, `false` otherwise.
  - **`msg` (string)** - optional response sent to browser.

#### Handling Login Failures
- Any type of login validation failure triggers the **`loginerr` callback(message)**.
- This callback receives a **failure message** detailing the reason for rejection.



## Database Schema

The following schema explains the `webauth` data structure. It is the format you must use when calling `webauth:set(data)`, and it is the format returned when calling `webauth:get()`. The structure is implemented as **Lua tables,** with the following key principles:

### Usernames as Unique Identifiers

- Each user is identified by a **unique username**, which serves as the key in the `users` table.
- The username **does not have to be an email address**.
- If an email address is used as a username, it must be **normalized externally** before being stored in this structure.

### Multiple Authenticators per User

- A single user can register **multiple authenticators** (e.g., security keys, biometric sensors on different devices).
- Each authenticator is stored within the user's table, **indexed by its `rawId`**.

### Authenticator Data Structure

Each authenticator entry contains:

- **key**:
  - **`rawId`**: The unique identifier for the authenticator.
- **value** - a table:
  - **`signatureCounter`**: A counter used to detect cloned authenticators.
  - **`pubKey`**: The public key for **ES256 (ECDSA P-256, SHA-256)**, stored as `{x, y}` coordinates.
  - **`createdAt`**: A timestamp marking when the authenticator was registered.
  - **`lastUsedAt`**: A timestamp recording the last successful authentication.

### Users Table

```lua
-- Table 'users': Key-value table where the key is string:user (username)
users = {
  ["username-1"] = { -- user-table
    -- Key-value table where the key is binstring:rawId (authenticator ID)
    ["rawId-1"] = { -- authenticator data
      signatureCounter = 0,
      pubKey = { x = binstring, y = binstring }, -- ES256 (P-256 ECDSA)
      createdAt = 1700000000,  -- UNIX timestamp
      lastUsedAt = 1700000100   -- UNIX timestamp
    },
    ["rawId-2"] = {
      signatureCounter = 88,
      pubKey = { x = binstring, y = binstring },
      createdAt = 1700000050,
      lastUsedAt = 1700000200
    }
  }
}
```

### Serializing the `users` table with binstrings

A binstring (binary string) is simply a Lua string that contains raw binary data instead of human-readable text. In Lua, binary data can be stored in strings because Lua strings are byte sequences, not null-terminated character arrays like in C.

JSON does not support binary data, so storing binstring values (e.g., rawId and public keys) in JSON will corrupt them or require inefficient Base64 encoding. For proper serialization of the `users` table, use CBOR or UBJSON, both of which natively support binary data.


### Quarantined Table for New Registrations
- A separate **`quarantined`** table exists, with the following structure:
  ```lua
  quarantined={
     ["url-1"] = {username,user-table}
  }
  ```
  
  **New user registrations** are stored here if the registration callback returns `true,false`.
