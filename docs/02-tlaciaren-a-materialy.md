# Tlačiareň, trysky a materiály

## Bambu Lab H2C
| Parameter | Hodnota |
|---|---|
| Tlačový priestor, jedna tryska | 305 × 320 × 325 mm |
| Tlačový priestor, obe trysky v jednom tlači | 300 × 320 × 325 mm |
| Max. teplota trysky | 350 °C |
| Max. teplota podložky | 120 °C |
| Aktívne vyhrievanie komory | do 65 °C |
| Výmena hotendov | Vortek: ľavá tryska vymieňa hotendy zo zásobníka (až 6). Viac materiálov alebo farieb s menším preplachom. |
| Moje trysky | 0,4 mm, 0,6 mm a **0,8 mm High Flow** (Bambu Lab) |

**Bezpečný limit pre návrh: 300 × 320 × 320 mm.** Pri tlači dvoma tryskami treba nechať rezervu na wipe a prime tower.

### Zásobníky filamentu
- **2× AMS 2 Pro:** po 4 cievky, sušenie do 65 °C. Na PLA a PETG.
- **1× AMS HT:** 1 cievka, vyššia teplota sušenia. Na ASA a ďalšie technické materiály, prípadne TPU (iba ako suchý box, bez auto-feedu).
- AMS sa počas tlače nedá sušiť, ak je priradené k aktuálnej úlohe. Sušiť treba vopred alebo v nepoužívanej jednotke.

## Trysky – referenčné hodnoty (Bambu Studio)
| | 0,4 mm | 0,6 mm | 0,8 mm High Flow |
|---|---|---|---|
| Šírka linky (w) | 0,42 mm | 0,62 mm | 0,82 mm |
| Vrstvy | 0,12–0,28 (štandard **0,20**) | 0,18–0,42 (štandard **0,30**) | 0,24–0,56 (štandard **0,40**) |
| Max. prietok PLA (Bambu PLA Basic) | ~21 mm³/s | ~21 mm³/s | **~40 mm³/s** (Standard Flow 0,8: ~30) |
| Použitie | detaily, tolerancie, mechanika, malé diely | veľké diely, nádoby, rýchlosť a pevnosť | veľké hrubostenné diely, rýchle prototypy, kde nevadia viditeľné vrstvy |
| Min. hrúbka prvku | 2 linky ≈ 0,8 mm | 2 linky ≈ 1,2 mm | 2 linky ≈ 1,5 mm |

Pravidlo: **čo je väčšie ako ~150 mm a nemá jemné detaily, tlač na 0,6 mm.** Rovnaký objem materiálu prejde rýchlejšie a diel je pevnejší.

**0,8 High Flow** sa oplatí, keď diel má hrubé steny (≥ 3 mm) a veľký objem, a keď je čas dôležitejší ako vzhľad. Pri tenkostennej mriežke (napr. košíky) je úspora menšia, lebo rýchlosť obmedzujú krátke ťahy a zrýchlenia, nie prietok. Vrstva 0,40 = výrazne viditeľné schody na šikmých a zaoblených plochách, malé diery a detaily pod ~2 mm sa nevykreslia. Šírka linky, vrstvy a prietok sú štartovné hodnoty, over ich v profile Bambu Studia pre konkrétny hotend.

## Materiály
| | PLA | PETG | ASA |
|---|---|---|---|
| Tryska | 210–230 °C | 240–260 °C | 250–270 °C |
| Podložka | 55–65 °C | 70–80 °C | 90–105 °C |
| Komora | studená, dvierka/veko pootvoriť | studená až teplá | **zavretá, vyhrievaná 50–65 °C** |
| Sušenie | 50–55 °C, 6–8 h | 65 °C, 8 h | 80 °C, 8 h → **AMS HT** |
| AMS | AMS 2 Pro | AMS 2 Pro | AMS HT |
| Doska | Textured PEI | Textured PEI (pri hladkej doske lepidlo ako separátor) | Textured PEI + lepidlo |
| Chladenie | plné | 30–60 % | 0–30 % |
| Použitie | interiér, prototypy, presné diely | mechanicky namáhané diely, vlhko, mierne teplo (do ~70 °C) | exteriér, UV, teplo (do ~95 °C) |
| Pozor na | mäkne nad ~55 °C (auto, slnko) | strunky, lepí sa na PEI, nižšia presnosť | zmrštenie, warping na veľkých plochách, výpary (filter) |

### Návrhové dôsledky podľa materiálu
- **PLA:** najpresnejšie a najrýchlejšie. Previsy 45° bez problémov, mosty do ~15 mm (0,4) / ~20 mm (0,6).
- **PETG:** daj o 0,05–0,1 mm väčšie vôle ako pri PLA. Previsy max. ~40°, mosty kratšie. Je húževnaté, pri rázoch nepraská.
- **ASA:** veľké ploché diely zaobli (rohy R ≥ 5 mm) a pod rohy pridaj „mouse ears" (kotúčiky 0,3 mm). Vyhni sa dlhým rovným stenám bez rebier. Rátaj so zmrštením ~0,5 %.

## Rýchlosť a prietok
- Strop rýchlosti je väčšinou **Max volumetric speed** v profile filamentu. Prierez linky = w × h. Pri 0,62 × 0,3 = 0,19 mm² a limite 21 mm³/s to dáva max. ~110 mm/s. Pri 0,8 High Flow: 0,82 × 0,4 = 0,33 mm² a ~40 mm³/s → max. ~120 mm/s, ale s ~1,7× väčším prierezom linky.
- Režim **Sport (124 %)** v tlačiarni zrýchľuje pohyb, ale reálna úspora času je skôr 15–20 %. Na prvom kuse skontroluj podextrudovanie.
- Pri dlhých sériách sa oplatí overiť a zvýšiť max volumetric speed (rýchle PLA, 0,8 High Flow tryska).

## Viac materiálov a farieb
- Každá výmena farby na jednej tryske = preplach (purge). Vortek a druhá tryska purge výrazne znižujú.
- Dva materiály naraz (napr. PLA + PETG ako separátor podpier, telo + TPU tesnenie) rozdeľ na **ľavú a pravú trysku**.
- Farby, ktoré sa striedajú len po vrstvách (nápis navrchu), sú lacné. Farby striedajúce sa v každej vrstve sú drahé.

## Zdroje
- https://3dprintingindustry.com/news/bambu-lab-launches-the-new-h2c-multi-material-3d-printer-technical-specifications-and-pricing-246509
- https://blog.bambulab.com/bambu-lab-h2c-where-multi-material-vortek-system-meets-engineering-precision
- https://eu.store.bambulab.com/en-gr/products/ams-ht
