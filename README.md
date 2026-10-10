# PANDAL HOPPING: AN AGARTALA STORY
**A GAME BY ANI STUDIO**

> “Sometimes you have to leave home to realize what home means.”

A Godot 4 mobile-focused, third-person story-game prototype inspired by Agartala, Tripura and Durga Puja. This repository is source-first: **no Android build is being run as part of this update**.

## Current prototype
- Procedurally generated Agartala-inspired road grid and city landmarks in `main.gd`
- Third-person character and follow camera
- Keyboard and touchscreen movement/look input
- Loading screen and mobile HUD
- Game-state and audio director registered as autoloads
- Integrated pause menu and replayable Bengali dialogue with English subtitles
- Smartphone UI script and reusable world-builder
- Procedural Bangalore office and Badarghat home interior scenes under `scenes/`
- Badarghat home, mall, railway station, airport and Puja-related story direction planned for continued development

## Open on a computer
1. Install **Godot 4.3 or a compatible Godot 4.x release** from the official Godot website.
2. Download this repository using **Code → Download ZIP**, then extract it.
3. In Godot, choose **Import** and select this folder's `project.godot`.
4. Open the project and press **F6** to run the current scene, or **F5** to run the project.
5. If Godot reports errors, open the Output panel and fix the first parser error before continuing.

## Android status
An Android APK has **not been built or verified by this update**. This update intentionally does not install SDKs, export templates or large dependencies because the developer's C: drive is low on space. The Android export workflow should only be run after there is enough free disk space and Android export dependencies are available.

## Story direction
The intended opening starts in a Bangalore office at night. A call from Ma and Baba reminds the protagonist to return to Badarghat for Mahalaya and Durga Puja. Bengali dialogue should appear with English subtitles. The story continues with reunion at home, Agartala exploration, a trip to Udaipur with a friend, shopping for Puja clothes and visiting pandals.

## Important limitations
- Procedural meshes are prototype geometry, not AAA assets.
- Audio hooks are placeholders; no licensed music or recorded dhak/traffic sound is bundled.
- The Bangalore office and Badarghat home scenes are separate prototype scenes and are not yet connected into a full cinematic transition sequence.
- The smartphone UI script is available but still needs to be wired into the main HUD.
- No claim is made that the current project is error-free or that an Android APK works.

## Credits
Game concept and direction: **ANI STUDIO**.
