# Miat's PvpAlerts for The Elder Scrolls Online (Updated)

This version implements several fixes, changes, and new features.

Fixes:

- The UI Errors have been patched to the latest API changes.
- Arcanist Support has been added to the KOS System and various other sections of the addon
- Text for the 3D Floating Swords reflecting specific inter-faction fights has been corrected to display the correct factions
- A small edge case UI error in the KOS system has been fixed

New Features:

- This release adds two new settings: "User Display Name Type Preference" and "Kill Feed Name Type Preference".
These provide several options "Character", "Account", and "Character@Account", this will be used for all the UI frames where PvpAlerts displays the name of a player. Previously these were all hard-coded to use the character name, so this should provide some more flexibility, and enable you to set PvpAlerts to be consistent with the rest of your UI. By default this will be set to "Character" for "User Display Name Type Preference" and "Link" for "Kill Feed Name Type Preference" (which inherits the value for "User Display Name Type Preference") to preserve consistency with the previous UI behavior.

- The new counts for kills at crossed swords markers on the map have been added to the 3D Floating Crossed-Swords markers
- Tide King's Gaze has been added to the important incoming abilities table (should alert when you're being tracked by the eye)
- The "Who is this?" right click option on player names and "/who" command have been enabled outside of PVP Zones (note that this does not enable logging of players encountered outside of PVP, you'll only be able to check if a player is someone you've previously encountered in a PVP zone).
- The KillFeed has been reworked, transitioned to the new ZOS EVENT_PVP_KILL_FEED_DEATH API, and will now incorporate the additional information from this API function.
- The Player Database will now store alliance ranks for characters and use this in UI functions, including populating them to the nameplates the addon creates for various UI elements.
- The Miat's ReticleOver player name display and Kill Feed, will now display a color coded (by faction) imperial diamond next to the name of whoever is the active campaign emperor.

- The API version been updated to the U40 API.
