# Výrobný checklist – košíky do skrine (cyklo oblečenie)

Súbor: `kosik.scad` (oko 30/60, polovičné oká zapnuté) · PLA · tryska 0,6 · vrstva 0,3 · wall loops 4 · bottom shells 7 · Sport mode

Všetky stohy majú výšku 250 mm. Horný košík zapadne do dolného o 2,7 mm.

## 1. Stoh 250 = 125 + 127,7
- [x] Košík 125 mm (hotový)
- [ ] Košík 127,7 mm, nastavenie `vyska = 127.7`, `stoh_kusov = 1` (tlačí sa)
- [ ] Kontrola: stoh na sebe = 250 mm

## 2. Stoh 250 / 2 kusy, 2× (4 košíky po 126,35 mm)
Nastavenie: `vyska = 250`, `stoh_kusov = 2` (konzola vypíše 126,35 mm)
- [ ] Košík 1/4
- [ ] Košík 2/4, potom kontrola stohu A = 250 mm
- [ ] Košík 3/4
- [ ] Košík 4/4, potom kontrola stohu B = 250 mm

## 3. Stoh 250 / 3 kusy, 1× (3 košíky po 85,13 mm)
Nastavenie: `vyska = 250`, `stoh_kusov = 3` (konzola vypíše 85,13 mm)
- [ ] Košík 1/3
- [ ] Košík 2/3
- [ ] Košík 3/3, potom kontrola stohu C = 250 mm

## Pred každou tlačou
- [ ] Správne `vyska` a `stoh_kusov` (skontrolovať ECHO v konzole OpenSCAD)
- [ ] V Bambu Studio: 0,6 tryska, 0,3 vrstva, wall loops 4, bottom shells 7, bez podpier
- [ ] Na cievke je dosť filamentu (~350 g na 126 mm, ~300 g na 85 mm, s rezervou)
- [ ] Čistá doska (Textured PEI)

## Po každej tlači
- [ ] Lem hore čistý, bez ovisnutých liniek
- [ ] Špičky ôk a polovičné oká čisté
- [ ] Bez podextrudovania v Sport mode (steny nie sú matné ani deravé)
- [ ] Košík sedí na predchádzajúcom kuse v stohu

## Odhad (podľa slicovania bez polovičných ôk, reálne o niečo menej)
| Položka | Ks | Čas / ks | PLA / ks |
|---|---|---|---|
| 127,7 mm | 1 | ~8h35m | ~350 g |
| 126,35 mm | 4 | ~8h30m | ~350 g |
| 85,13 mm | 3 | ~6h50m | ~305 g |
| **Zostáva** | **8** | **~63 h (Sport ~50–54 h)** | **~2,7 kg** |
