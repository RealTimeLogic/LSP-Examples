<?lsp

local base=app.dir:baseuri()

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
<title>WebAuthn Example 2: login</title>
  <script src="https://unpkg.com/@simplewebauthn/browser/dist/bundle/index.umd.min.js"></script>
  <script src="https://cdn.tailwindcss.com"></script> <!-- Add Tailwind CSS -->
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">
  <div class="bg-white p-6 rounded-lg shadow-md w-96">
    <h1 class="text-xl font-bold text-center mb-4">Sign In with Passkey</h1>
    <form id="auth-form" class="space-y-4">
      <input type="email" id="user" name="user" autocomplete="username webauthn" required 
             placeholder="Enter your email" class="w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
      <button type="submit"
              class="w-full bg-blue-500 text-white py-2 rounded-md hover:bg-blue-600 transition">
        Log In
      </button>
    </form>
    <button id="register-btn" class="w-full mt-4 bg-green-500 text-white py-2 rounded-md hover:bg-green-600 transition hidden">
      Register
    </button>
    <div id="messages" class="text-center text-sm text-gray-700 mt-4"></div>
  </div>

  <script>
const { startAuthentication, startRegistration } = SimpleWebAuthnBrowser;
const form = document.getElementById('auth-form');
const userInput = document.getElementById('user');
const messagesDiv = document.getElementById('messages');
const registerBtn = document.getElementById('register-btn');

// Load saved username from Web Storage
document.addEventListener('DOMContentLoaded', () => {
      const savedUser = localStorage.getItem('savedUser');
      if (savedUser) {
         userInput.value = savedUser;
      }
   });

form.addEventListener('submit', async (event) => {
      event.preventDefault();
      // Normalize as per: WebAuthn.md#database-schema
      const user = userInput.value.trim().toLowerCase();

      try {
         const authOptionsResponse = await fetch('<?lsp=base?>webauthn/authoptions', {
              method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ user }),
                  });
         const options = await authOptionsResponse.json();

         if (false==options.ok && options.msg === "notfound") {
            messagesDiv.textContent = 'User not found. Would you like to register?';
            registerBtn.classList.remove('hidden');
            return;
         }

         try {
            const authResponse = await startAuthentication(options);
            const verificationResponse = await fetch('<?lsp=base?>webauthn/authenticate', {
                 method: 'POST',
                     headers: { 'Content-Type': 'application/json' },
                     body: JSON.stringify(authResponse),
                     });
            const verification = await verificationResponse.json();

            if (verification.ok) {
               console.log(`Message (msg) from server: ${verification.msg}`);
               // Save the username in Web Storage
               localStorage.setItem('savedUser', user);
               messagesDiv.textContent = 'Authentication successful!';
               // Hide the form and "Log In" button after success
               form.style.display = 'none';
               setTimeout(() => {location.reload();}, 2000);
            } else {
               console.log(`Error (err) from server: ${verification.msg}`);
               messagesDiv.textContent = 'Authentication failed. Try registering again.';
               registerBtn.classList.remove('hidden');
            }
         } catch (authError) {
            console.error(authError);
            messagesDiv.textContent = 'Authentication failed. No valid passkey found. Please register again.';
            registerBtn.classList.remove('hidden');
         }
      } catch (error) {
         messagesDiv.textContent = `Error: ${error.message}`;
      }
   });

registerBtn.addEventListener('click', async () => {
      const user = userInput.value;

      try {
         const regOptionsResponse = await fetch('<?lsp=base?>webauthn/regoptions', {
              method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ user }),
                  });

         const options = await regOptionsResponse.json();
         console.log(JSON.stringify(options, null, 2));
         const regResponse = await startRegistration({ optionsJSON: options });

         const verificationResponse = await fetch('<?lsp=base?>webauthn/register', {
              method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify(regResponse),
                  });
         const verification = await verificationResponse.json();

         if (verification.ok) {
            console.log(`Message (msg) from server: ${verification.msg}`);
            // Save the username in Web Storage
            localStorage.setItem('savedUser', user);
            messagesDiv.textContent = 'Registration successful!';
            registerBtn.classList.add('hidden');
         } else {
            let msg;
            if('quarantined' == verification.msg) {
               form.style.display = 'none';
               registerBtn.classList.add('hidden');
               messagesDiv.textContent =  'Registration email sent to your inbox!';
            }
            else {
               messagesDiv.textContent =  'Registration failed.';
            }

            console.log(`Error (err) from server: ${verification.msg}`);
         }
      } catch (error) {
         messagesDiv.textContent = `Error: ${error.message}`;
      }
   });
  </script>
</body>
</html>
