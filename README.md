# 3D tlač – parametrické diely v OpenSCAD

Zbierka vlastných **parametrických 3D modelov** navrhnutých v [OpenSCAD](https://openscad.org) a optimalizovaných na tlač na **Bambu Lab H2C**. Každý diel sa dá prispôsobiť cez Customizer: zmeníš vonkajšie rozmery a všetko ostatné (hrúbky stien, rebrá, mriežka) sa dopočíta tak, aby sa diel tlačil **bez podpier, rýchlo a s čo najmenej materiálu**.

> Poradie priorít pri návrhu: **funkcia a pevnosť → tlač bez podpier → čas a materiál → vzhľad**

---

## Projekty

| | Projekt | Popis |
|---|---|---|
| <img src="Configurable%20basket/nahlady/kosik.png" width="180" alt="Košík"> | **[Košíky do skrine + vodiaca lista](Configurable%20basket/)** | Stohovateľné košíky s diamantovou mriežkou (oko 30/60, bez podpier), ľubovoľná šírka, hĺbka a výška stohu. K tomu lišta na polici, ktorá košíky vycentruje a drží v rade. PLA, tryska 0,6 mm. |

---

## Štruktúra repozitára

```
3D-print-projects/
├── README.md                 tento prehľad
├── CLAUDE.md                 pravidlá návrhu pre Claude Code
├── docs/
│   ├── 02-tlaciaren-a-materialy.md   tlačiareň, trysky, materiály, rýchlosti
│   └── 03-zasady-navrhu.md           hrúbky z perimetrov, bez podpier, tolerancie
├── sablony/
│   └── sablona.scad          šablóna nového dielu (pomocné moduly a funkcie)
└── <projekt>/
    ├── README.md             popis, rozmery, rozhodnutia, nastavenie slicera
    ├── scad/                 .scad + .json sady z Customizera
    ├── stl/                  exportované .stl
    ├── 3mf/                  projekty z Bambu Studia
    ├── vyroba/               výrobný checklist (.xlsx)
    └── nahlady/              .png náhľady
```

---

## Ako sa navrhuje

1. **Šablóna:** nový diel začína kópiou [`sablony/sablona.scad`](sablony/sablona.scad). Na začiatku súboru je blok *Nastavenie slicera* a sekcie Customizera `[Rozmery]`, `[Volby]`, `[Tlac]`, `[Konstanty]`.
2. **Hrúbky z perimetrov:** steny a rebrá majú presne hrúbku `n` liniek, takže sú celé z perimetrov, bez gap fill a bez výplne. Vzorce sú v [`docs/03-zasady-navrhu.md`](docs/03-zasady-navrhu.md).

   ```
   s    = w - h * (1 - pi/4)     // rozostup liniek
   T(n) = w + (n - 1) * s        // hrubka n liniek
   ```

3. **Bez podpier:** previsy ≤ 45°, diery do špičky (kosoštvorec, slza), spodné hrany skosené 45°, výrezy nikdy neorezané vodorovne zhora.
4. **Kontrola:** každý diel sa vyrenderuje, skontroluje sa ECHO s odvodenými hodnotami, `assert` a manifold. Vznikne STL a náhľad.

### Renderovanie

Príkazy sa spúšťajú z priečinka projektu:

```bash
openscad --backend=manifold -o stl/diel.stl scad/diel.scad
```

```bash
openscad -o nahlady/diel.png --imgsize=1200,900 --viewall --autocenter --colorscheme=Tomorrow scad/diel.scad
```

Parametre sa dajú meniť cez `-D 'vyska=250' -D 'stoh_kusov=2'` alebo načítať sadu z Customizera cez `-p scad/diel.json -P <nazov_sady>`. Prepínač `--backend=manifold` funguje v OpenSCAD 2024+, kód je kompatibilný aj s 2021.01.

---

## Vybavenie

| | |
|---|---|
| **Tlačiareň** | Bambu Lab H2C – dve trysky, výmena hotendov Vortek, vyhrievaná komora do 65 °C |
| **Bezpečný tlačový priestor** | 300 × 320 × 320 mm |
| **Trysky** | 0,4 mm (detaily, mechanika) · 0,6 mm (veľké diely, rýchlosť) |
| **Filament** | 2× AMS 2 Pro (PLA, PETG) · 1× AMS HT (ASA, technické materiály) |
| **Materiály** | PLA · PETG · ASA |
| **Slicer** | Bambu Studio |

Podrobnosti o teplotách, sušení a návrhových dôsledkoch materiálov sú v [`docs/02-tlaciaren-a-materialy.md`](docs/02-tlaciaren-a-materialy.md).

---

<sub>Návrhy vznikajú v spolupráci s [Claude Code](https://claude.com/claude-code). Pravidlá spolupráce sú v [`CLAUDE.md`](CLAUDE.md).</sub>
