# 3D tlač – OpenSCAD → Bambu Lab H2C

Si môj partner na návrh 3D tlačených dielov. Komunikujeme po slovensky.

## Štruktúra repozitára
- `CLAUDE.md` – tieto inštrukcie (načítajú sa automaticky).
- `docs/02-tlaciaren-a-materialy.md` – tlačiareň, trysky, materiály, rýchlosti, limity podložky.
- `docs/03-zasady-navrhu.md` – vzorce hrúbok z perimetrov, pravidlá bez podpier, tolerancie, OpenSCAD dohody. **Pred návrhom nového dielu si ich prečítaj.**
- `sablony/sablona.scad` – šablóna s pomocnými modulmi a funkciami. Nový diel začni jej kópiou.
- `Configurable basket/kosik.scad` – referenčný príklad (diamantová mriežka, lem, stohovanie). `lista.scad` je vodiaca lista ku košíkom, `vyrobny-checklist-kosiky.md` je výrobný checklist.
- Každý projekt má vlastný priečinok (`README.md`, `.scad`, `.json` z Customizera, `.stl`, `.3mf`, prípadne checklist).

## Výstup
- Vždy dodaj **parametrický OpenSCAD súbor (.scad)**. Kód musí ísť skompilovať v OpenSCAD 2021.01 aj 2024+.
- Hlavné rozmery (spravidla vonkajšie, v mm) daj na začiatok súboru do sekcií pre Customizer: `/* [Rozmery] */`, `/* [Volby] */`, `/* [Tlac] */`, `/* [Konstanty] */`.
- Všetko ostatné sa z nich **dopočíta**. Hrúbky stien a rebier sa odvodzujú z trysky, vrstvy a počtu perimetrov (vzorce sú v `docs/03-zasady-navrhu.md`), nie z veľkosti dielu.
- Komentáre píš po slovensky, bez diakritiky (kvôli kompatibilite).
- Vychádzaj zo `sablony/sablona.scad` (pomocné moduly a funkcie). Ako referenčný príklad slúži `Configurable basket/kosik.scad`.
- Na začiatok súboru daj blok **„Nastavenie slicera"**: tryska, vrstva, wall loops, top/bottom shell layers, výplň, materiál, doska, či je treba podpera (cieľ je nie).
- Model si sám vyrenderuj, skontroluj, či je uzavretý (manifold) a či nemá previsy nad 45°, a vytvor aj náhľad a STL (pozri nižšie).
- Ku každému návrhu vytvor v priečinku projektu **`README.md`** s popisom toho, čo navrhujeme (pozri nižšie). Pri úpravách návrhu ho udržuj aktuálny.

## README.md projektu
Píš po slovensky (s diakritikou), stručne a vecne. Obsahuje:
- **Názov a účel** – čo diel je, na čo slúži, kde a ako sa použije.
- **Náhľad** – vložený obrázok `diel.png`.
- **Hlavné rozmery a parametre** – tabuľka kľúčových parametrov z Customizera (predvolené hodnoty) a odvodené hodnoty z ECHO.
- **Konštrukčné rozhodnutia** – zvolený tvar/vzor a prečo, dopad na čas a materiál, prípadne porovnanie variant; čo bolo zvolené predvolene, lebo to v zadaní chýbalo.
- **Nastavenie slicera** – rovnaké ako blok v `.scad` (tryska, vrstva, wall loops, shells, výplň, materiál, doska, podpery).
- **Súbory** – zoznam súborov v priečinku a na čo slúžia (`.scad`, `.json` sady, `.stl`, `.3mf`).
- **Výsledky tlače** – čas a gramy zo slicera, poznámky z tlače a zmeny, ktoré z nich vyplynuli (dopĺňaj priebežne).

## Renderovanie a kontrola (Claude Code)
- STL: `openscad -o diel.stl diel.scad` (v OpenSCAD 2024+ pridaj `--backend=manifold`, je oveľa rýchlejší).
- Náhľad: `openscad -o diel.png --imgsize=1200,900 --viewall --autocenter --colorscheme=Tomorrow diel.scad`.
- Parametre z príkazového riadku: `-D 'vyska=127.7' -D 'stoh_kusov=1'`, alebo sadu z Customizera: `-p diel.json -P <nazov_sady>`.
- Skontroluj výstup ECHO (odvodené hodnoty) a že render neskončil chybou `assert`. Varovanie o nemanifoldnom výsledku je chyba, ktorú treba opraviť.
- STL a náhľad ukladaj do priečinka projektu vedľa `.scad`.

## Cieľ: efektívna tlač
Poradie priorít: **funkcia a pevnosť → tlač bez podpier → čas a materiál → vzhľad.**
- Navrhuj tak, aby podpery neboli potrebné: previsy ≤ 45°, horné okraje dier do špičky, spodné hrany skosené pod 45°.
- Hrúbky stien a rebier volím tak, aby ich vyplnili celé perimetre (žiadne gap fill, žiadna výplň v tenkých stenách).
- Pri voľbe vzoru alebo tvaru zdôvodni dopad na čas a materiál. Kde to pomôže, porovnaj dve varianty.
- Over si, že diel sa zmestí na podložku (pozri limity tlačiarne). Ak nie, navrhni delenie so spojmi.

## Moje vybavenie
- Bambu Lab **H2C**: dve trysky, ľavá s výmenou hotendov Vortek, aktívne vyhrievaná komora do 65 °C.
- Trysky, ktoré mám: **0,4 mm a 0,6 mm**.
- **2× AMS 2 Pro** (sušenie do 65 °C) a **1× AMS HT** (1 cievka, sušenie aj pre technické materiály).
- Materiály, s ktorými mám skúsenosti: **PLA, PETG, ASA**.
- Slicer: Bambu Studio.

Podrobnosti sú v `docs/02-tlaciaren-a-materialy.md`.

## Štýl spolupráce
- Ak niečo v zadaní chýba, zvoľ rozumný predvolený rozmer alebo vlastnosť a povedz, čo si zvolil. Pýtaj sa len vtedy, keď by zlý odhad znamenal veľa zbytočnej tlače.
- Pri úpravách uprav celý `.scad` súbor priamo v repozitári.
- Keď ti pošlem výsledok zo slicera (čas, gramy) alebo fotku výtlačku, vyhodnoť ho a navrhni konkrétnu zmenu parametra.
- Git: commit správy po slovensky, krátke. `.DS_Store` a dočasné súbory `~$*` sa necommitujú.
