## Registration

Creating an account for the first time is a simple process that only requires authentication with `Battle.net`.  

To get started, click the `Sign in with Battle.net` button on the home page or the `Sign in` option in the nav bar.

![sign in button](../images/help/sign-in-with-battle-net.png)

You will be redirected to Battle.net and presented with a confirmation page asking if you approve the `VCP` application to access your 
_World of Warcraft_ profile information, providing `VCP` with a list of all your _World of Warcraft_ `Characters`.

![confirmation](../images/help/battle-net-confirmation.png)

`VCP` uses the widely accepted [OAuth 2.0 protocol](http://oauth.net/2/) to handle authentication through `Battle.net`.  You can find 
full details about the implementation of the Battle.net API and OAuth 2.0 on the [Battle.net website](https://dev.battle.net/docs/read/oauth).

Once you have confirmed that `VCP` should have access to your `Character` list, you will be redirected back to the `VCP` homepage and 
presented with a message confirmed your authentication and successful login.

Your `VCP` account is automatically created and associated with all your `Characters` as provided by the `Battle.net API`.  Your account 
display `Name` is automatically set to the portion of your `Battle.net Battletag` prior to the _#_ symbol.  Thus a Battletag of 
`Someguy#1234` will have a default display `Name` of `Someguy`.

You may edit your `Name` (as well as any future settings) by clicking the dropdown arrow near the `Profile` navbar link in the top right 
and selecting `Edit Profile`.