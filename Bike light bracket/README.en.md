# ExposureBracket

**Snap-on GoPro mount for round bike lights – parametric OpenSCAD, customize in your browser**

A C-shaped snap clip that turns any cylindrical light into a GoPro-compatible (2-prong male) mount. Designed for the **Exposure Lights Tracer / Trace** (Ø18 mm body), but it's fully parametric – open the OpenSCAD customizer, type in your light's diameter and download a fitted STL. No CAD skills needed.

The M5 bolt axis is **perpendicular to the light axis**, so the light tilts up/down on any standard GoPro mount (handlebar, saddle rail, helmet, etc.).

## What's included

| Path | Contents |
|---|---|
| `scad/exposure_clip.scad` | Parametric OpenSCAD source – works with the MakerWorld Parametric Model Maker and with OpenSCAD on your computer |
| `scad/exposure_clip.json` | Customizer parameter sets |
| `stl/` | Ready-to-print STL files for Ø18 mm lights (file name = `<mouth angle>_fit<interference>_w<wall mm>` or `_wl<wall loops>`) |
| `3mf/` | Bambu Studio project |
| `nahlady/` | Renders and the original reference |

## Tested configuration

100° mouth / 0.30 mm interference / 2.5 mm wall – printed in ASA on a Bambu Lab H2C (2026-09-20) and tested on the light: holds firmly, snaps on and off without drama. Other variants are provided for stiffer/looser fits but are untested – start with the tested one.

## Dimensions (default)

- Inner diameter Ø17.70 mm (0.30 mm interference on Ø18)
- Wall 2.5 mm, band width 15 mm (= GoPro tab width)
- GoPro tabs 2 × 2.9 mm, 3.2 mm gap, R7.5, Ø5.3 hole for M5
- Bolt axis 8.0 mm above the band surface (0.5 mm clearance for the mating part's middle prong)
- Overall ~18 × 38 × 15 mm, ~2.8 cm³

## Print settings

- Orientation: flat side of the band on the bed, light axis vertical
- **No supports** – all walls are vertical; only the M5 hole bridges
- Material: **ASA** (recommended – UV and heat resistant, doesn't yellow or soften in the sun). PETG works. **Do not use PLA – it cracks when snapping on.**
- ASA needs an enclosed, heated chamber, otherwise layers can split at the mouth where the part is stressed the most
- 0.2 mm layers, 4–5 perimeters, 40 % infill, brim
- Note on shrinkage: ASA shrinks ~0.4–0.7 %, i.e. up to ~0.1 mm on the diameter on top of the designed interference. If the clip won't go on, measure the actual inner diameter with calipers before changing `fit`.

## Customizing

Use the customizer on MakerWorld, or open the `.scad` file in OpenSCAD (free, [openscad.org](https://openscad.org)) → Window → Customizer → F6 → Export STL.

Parameters:

- `priemer_svetla` (light diameter) – diameter of your light (mm)
- `presah` (fit) – interference on diameter, negative = clamps. Goes on too easily → -0.15, cracks when snapping → -0.50
- `wall_loops` – wall loops per contour; the wall is made of exactly 2 × wall_loops lines (0.4 nozzle / 0.2 layer: 3 → 2.31 mm, 4 → 3.06 mm). Stiffness grows with the cube of the thickness
- `uhol_otvoru` (mouth angle) – mouth angle. Falls off → 95, cracks when snapping → 105
- `sirka` (band width) – band width (min 15 mm = GoPro tab width; the tab stays flush with the flat side so the part still prints without supports)
- `r_hrotov` (mouth fillet) – lead-in radius on the mouth tips
- GoPro tab dimensions and M5 hole are in a separate group, normally leave them alone

Rotation around the light body is held by friction (`fit`), not by the mouth – if you need more grip, add a strip of bar tape or a 0.5 mm TPU shim inside.

Command line, if you prefer:

```bash
openscad -o stl/clip.stl -D priemer_svetla=18 -D presah=-0.3 -D wall_loops=3 -D uhol_otvoru=100 scad/exposure_clip.scad
```
