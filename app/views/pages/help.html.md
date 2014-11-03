## Registration

Creating an account for the first time is a simple process that only requires authentication with `Battle.net`.  

To get started, click the `Sign in with Battle.net` button on the home page or the `Sign in` option in the nav bar.

![sign in button](images/help/sign-in-with-battle-net.png)

You will be redirected to Battle.net and presented with a confirmation page asking if you approve the `VCP` application to access your 
_World of Warcraft_ profile information, providing `VCP` with a list of all your _World of Warcraft_ `Characters`.

![confirmation](images/help/battle-net-confirmation.png)

`VCP` uses the widely accepted [OAuth 2.0 protocol](http://oauth.net/2/) to handle authentication through `Battle.net`.  You can find 
full details about the implementation of the Battle.net API and OAuth 2.0 on the [Battle.net website](https://dev.battle.net/docs/read/oauth).

Once you have confirmed that `VCP` should have access to your `Character` list, you will be redirected back to the `VCP` homepage and 
presented with a message confirmed your authentication and successful login.

Your `VCP` account is automatically created and associated with all your `Characters` as provided by the `Battle.net API`.  Your account 
display `Name` is automatically set to the portion of your `Battle.net Battletag` prior to the _#_ symbol.  Thus a Battletag of 
`Someguy#1234` will have a default display `Name` of `Someguy`.

You may edit your `Name` (as well as any future settings) by clicking the dropdown arrow near the `Profile` navbar link in the top right 
and selecting `Edit Profile`.

## User Profile

Upon signing in with `Battle.net` for the first time, all your `Character` data will be slowly processed in the 
background and added to the system.

If you wish to view the *full* list of `Characters` for your account you may do so by clicking the `Profile` button in the navbar to view
 your account `Profile`.
 
![character list](images/help/profile-characters.png)

You can manipulate this table (and many others like it throughout the site) with the sorters at the top of the columns, page navigation, 
and even filter the results with the search box in the top right.  For example, here we are only viewing `Characters` in the _Vox 
Immortalis_ `Guild`:

![character list filtered](images/help/profile-characters-filtered.png)

### Roles

You may also view any assigned `Roles` for a particular `User` by looking at the bottom of his or her `Profile` page.

![roles list](images/help/roles-list.png)

## Characters

The [characters](/characters) page contains a list of all `Active` characters in the system.  An `Active` character (sometimes referred to
 as `Verified`
 as well) is any character that has been successfully confirmed to exist via the `Battle.net API`.  While many inactive characters will 
 be added to the system and visible through the `User Profile` character list, only those that are genuinely confirmed (and thus actively
  played) will be shown in the main [characters](/characters) page.

Typically, a character is `Active` (or `Verified`) if that character has a valid profile on the `Battle.net Armory`.

### Character Profile



### Forcing `Verification`

If you own a character that is `Unverified` that you wish to force a verification performed, you may do so through either the `Character Profile` page, 
or within your character list on your own `User Profile` page.

Simply click on the `Refresh` image corresponding to the character you wish to refresh, and this will queue up a background process to check 
the `Battle.net API` for new character information and update the record of this character accordingly.   