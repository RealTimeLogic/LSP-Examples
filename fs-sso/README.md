This example shows how to implement Single Sign On (SSO) using
[OpenID Connect](https://openid.net/connect/).
The example is designed for [Microsoft Azure AD](https://portal.azure.com/).

Shipping products with pre-installed passwords creates a major security vulnerability by essentially setting up a "backdoor" into the system. This risk can be mitigated by implementing Single Sign-On (SSO) solutions. SSO protocols allow users to use a single set of login credentials to access multiple applications or services, reducing the reliance on a pre-installed password. By centralizing the authentication process, SSO makes it harder for unauthorized individuals to gain access and more effortless for system administrators to manage and monitor account activities. This helps significantly enhance system security and integrity.

See the tutorial [Single Sign On for Embedded Devices](https://www.linkedin.com/pulse/benefits-active-directory-single-sign-on-embedded) for an introduction to this technology.

In this example, authenticated users are provided access to a
[WebDAV](https://realtimelogic.com/products/webdav/)
session URL, enabling registered and authenticated users to map a WebDAV server (a non web application) as a network drive.

### Note that [SSO is also fully integrated into the Xedge UI](https://realtimelogic.com/ba/doc/en/Xedge.html#auth).

To use the example, create a mako.conf file with the following
settings:

```
openid={
   tenant="your tenant id",
   client_id="your client id",
   client_secret="your client secret",
   redirect_uri="https://localhost/"
}
```

For testing on 'localhost', use the redirect_uri as shown above.

**See also the [Xedge documentation](https://realtimelogic.com/ba/doc/?url=Xedge.html), which includes an easy-to-use web interface for enabling Active Directory Single Sign-On.**

## Azure Instructions

1. Open the [Azure portal](https://portal.azure.com/) and click on the **Azure Active Directory** icon.
2. In the left pane, click on **App registrations**.
3. At the top of the page, click on **+ New registration**.
4. Enter a suitable name for your application.
5. In most cases, the account type should be set to **Single tenant**.
6. Click on **Select a platform** and choose **Web**.
7. For the redirect URI, include all relevant sites, such as test sites. If you are setting this up for testing purposes, enter the URLs `http://localhost` and `https://localhost`.
8. Click on **Register** at the bottom of the page.
9. On the following page, make sure to copy and save both the **Application (client) ID** and **Directory (tenant) ID**.
10. Navigate to **Client credentials** and click on **Add a certificate or secret**.
11. Click on **+ New client secret**.
12. Provide a name for your client secret.
13. Choose a suitable expiration date for the secret.
14. Click on **Add** at the bottom of the page.
15. Finally, copy the **client secret Value** immediately, as you will not be able to see this value again.
16. Copy **Directory (tenant) ID**, **Application (client) ID**, and **client secret Value**, and insert into mako.conf

### Grant users access

After completing the above instructions, you can grant individual users within the organization access to the application by following these steps:

1. In the Azure portal, click on the **Azure Active Directory** icon.
2. In the left pane, click on **Enterprise applications**.
3. Search for and select the application you just registered in the application list.
4. Click on the **Users and groups** tab in the application's Overview page.
5. Click on the **+ Add user** button, located above the users list.
6. In the **Add Assignment** panel, click on the **Users and groups** field.
7. Search for and select the individual users you want to grant access to the application. You can select multiple users by clicking on the checkboxes next to their names.
8. Once you've selected all the users you want to grant access to, click on the **Select** button at the bottom of the panel.
9. Optionally, you can assign a specific role to the users by selecting it from the **Role** dropdown menu. If no roles are defined for the application, users will be assigned the default access.
10. Click on the **Assign** button at the bottom of the panel to grant the selected users access to the application.

The users you've granted access to will now be able to sign in and use the application based on the permissions and roles assigned to them.


For additional details, see the Microsoft tutorial
[Register an application with the Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis).

Click next to continue with the [next tutorial](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis), including section
[Add permissions to access Microsoft Graph](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis#add-permissions-to-access-microsoft-graph).

Run the example, using the Mako Server, as follows:

```
cd fs-sso
mako -l::www
```

For detailed instructions on starting the Mako Server, check out our [command line video tutorial](https://youtu.be/vwQ52ZC5RRg) and review the server's [command line options](https://realtimelogic.com/ba/doc/?url=Mako.html#loadapp) in our documentation.





