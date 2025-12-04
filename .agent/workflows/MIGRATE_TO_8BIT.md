---
description: Migration plan to move from standard UI to 8-bit Flame Engine style
---

# 8-Bit Migration Plan

This workflow outlines the steps to migrate the Idle Universe game to an 8-bit pixel art style using the Flame Engine.

## Phase 1: Asset Preparation
1.  **Acquire Assets**:
    -   Need pixel art sprites for:
        -   Core Star (Sun) - `sun_8bit.png`
        -   Background Stars - `star_small.png`, `star_medium.png`
        -   Planets/Generators - `planet_01.png` to `planet_06.png`
        -   Particles - `particle_8bit.png`
    -   Need Pixel Font: e.g., "Press Start 2P" or "Vt323".

2.  **Import Assets**:
    -   Place images in `assets/images/`.
    -   Place font in `assets/fonts/` (or use Google Fonts if available).
    -   Update `pubspec.yaml` to include assets.

## Phase 2: Flame Component Migration
1.  **Update `UniverseGame`**:
    -   Load sprite images in `onLoad`.
    -   Pass sprites to components.

2.  **Refactor `CoreStarComponent`**:
    -   Change from `PositionComponent` (drawing circles) to `SpriteAnimationComponent` or `SpriteComponent`.
    -   Implement pixel-perfect scaling.

3.  **Refactor `OrbitSystemComponent`**:
    -   Update `PlanetComponent` to use `SpriteComponent`.
    -   Map Generator IDs to specific pixel sprites.

## Phase 3: UI Styling (Hybrid Approach)
1.  **Update `AppTheme`**:
    -   Switch fonts to a Pixel Font (e.g., `GoogleFonts.pressStart2p` or `vt323`).
    -   Change colors to a limited 8-bit palette (e.g., PICO-8 palette).
    -   Remove gradients and rounded corners; use solid borders.

2.  **Component Styling**:
    -   Update `ItemCard` and `ResourcesBar` to use "9-patch" style pixel borders.
    -   Use `PixelArt` style icons (or load images) instead of Material Icons.

## Phase 4: Full Flame UI (Optional/Advanced)
1.  **HUD Components**:
    -   Create `HudMarginComponent` for resources.
    -   Create `SpriteButtonComponent` for interactive buttons.
    -   *Note*: This is more complex and may reduce accessibility compared to Flutter UI.

## Execution
Run the following to start the asset setup (placeholder):
```bash
# Example: Create directory structure
mkdir -p assets/images/8bit
```
