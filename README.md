# PvpAlerts_Patch

Patching Miat's PvP Alerts for ESO

In order to install the patch the files from this repository should replace the contents of the PvpAlerts folder in your Documents>Elder Scrolls Online>live>AddOns directory overwriting the originals.

This patch implements several changes for ESO's U38 (Necrom) update. 

- Arcanist Support has been added to the KOS System and various other sections of the addon
- Text for the 3D Floating Swords reflecting specific inter-faction fights has been corrected to display the correct factions
- Tide King's Gaze has been added to the important incoming abilities table (should alert when you're being tracked by the eye)
- A small edge case error in the KOS system has been fixed
- The "Who is this?" right click option on player names and "/who" command have been enabled outside of PVP Zones (note that this does **not** enable logging of players encountered outside of PVP, you'll only be able to check if a player is someone you've previously encountered in a PVP zone).

Note that the API version has not been updated due to some functions still not working correctly as a resullt of ZOS's upstream changes.
