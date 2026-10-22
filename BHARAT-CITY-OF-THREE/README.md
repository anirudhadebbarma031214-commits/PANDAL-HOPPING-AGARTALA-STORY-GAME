# BHARAT: CITY OF THREE — Windows Prototype

A separate Godot 4 project stored in this repository without replacing the existing Pandal Hopping game.

## Play on Windows
1. Open the repository's **Actions** tab.
2. Choose **Build BHARAT City of Three (Windows)**.
3. Click **Run workflow** (or open the automatic run triggered by a project update) and wait for it to finish.
4. Open the completed run and download the **BHARAT-CITY-OF-THREE-Windows** artifact.
5. Extract the ZIP and run `BHARAT_CITY_OF_THREE.exe`.

## Prototype features
- Tripura-inspired local streets, market, pond and ghat, highway, dhaba, mall and safe house
- Three switchable protagonists
- Auto-rickshaw, hatchback, delivery scooter and jeep
- NPC pedestrians and a food-delivery mission with a ₹550 reward
- Cinematic-style lighting and a third-person follow camera

This is an early playable prototype using procedural placeholder geometry, not finished AAA-quality assets.

## Controls
- **WASD** — move / drive
- **Shift** — sprint
- **E** — interact / enter or exit a vehicle
- **1, 2, 3** — switch protagonists when not driving
- **M** — mission briefing

Godot source files are in `project/`. The Windows executable is produced by GitHub Actions as a downloadable artifact; it does not run inside the GitHub webpage.
