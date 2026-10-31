# Zásady návrhu pre efektívnu FDM tlač

## 1. Hrúbky z perimetrov (najdôležitejšie pravidlo)
Bambu Studio / Orca kladie susedné perimetre s rozostupom:

```
s = w - h * (1 - pi/4)        // w = sirka linky, h = vyska vrstvy
T(n) = w + (n - 1) * s        // hrubka n liniek vedla seba
```

**Wall loops sa počítajú pre každý obrys zvlášť.** Stena nádoby má obrys zvonka aj zvnútra, preto pri `wall loops = N` má **2N liniek**. Rebro medzi dvoma dierami má tiež 2N liniek.

| Tryska / vrstva | s | 2 linky | 4 linky | 6 liniek | 8 liniek |
|---|---|---|---|---|---|
| 0,4 / 0,20 (w 0,42) | 0,377 | 0,80 | 1,55 | 2,31 | 3,06 |
| 0,4 / 0,28 (w 0,42) | 0,360 | 0,78 | 1,50 | 2,22 | 2,94 |
| 0,6 / 0,30 (w 0,62) | 0,556 | 1,18 | **2,29** | 3,40 | **4,51** |
| 0,8 HF / 0,40 (w 0,82) | 0,734 | 1,55 | **3,02** | 4,49 | 5,96 |

Pravidlá:
- Stena, rebro aj čap majú hrúbku **T(2N)** pre zvolený wall loops N. Vtedy sú celé z perimetrov, bez gap fill a bez riedkej výplne, čo je rýchle aj pevné.
- Hrúbku nastavíš v sliceri ako **wall loops = N**. V `sablona.scad` ju vypočíta funkcia `hrubka(linky)`.
- Plné dno alebo veko: hrúbka = násobok vrstvy, **bottom/top shell layers** = hrúbka / h.

## 2. Bez podpier
- **Previs ≤ 45° od zvislice** (PETG ≤ 40°).
- **Diery v zvislých stenách** daj do špičky: kosoštvorec, slza (teardrop) alebo gotický oblúk. Vodorovný strop vytvorí most, zaoblený vrchol vytvorí malý vodorovný úsek.
- **Okná a výrezy** nikdy neorezávaj rovnou vodorovnou čiarou zhora. Oko, ktoré by zasiahlo do zakázanej zóny, vynechaj celé.
- **Spodné vonkajšie hrany: skosenie 45°** (0,5–1 mm proti elephant foot, alebo väčšie ako dizajn a pre stohovanie). Fillet dole vytvorí previs.
- **Horné hrany:** fillet alebo skosenie, ako chceš.
- **Vnútorné lemy a výstuhy:** spodná plocha pod 45°, vrch ľubovoľný (trojuholníkový profil).
- **Mosty:** ak sa nedá vyhnúť, max ~15 mm (0,4) / ~20 mm (0,6) pri PLA. Lepšie je zmeniť orientáciu alebo diel rozdeliť.
- **Vodorovné diery** (os rovnobežne s podložkou): slzový tvar so špičkou hore.

## 3. Čas a materiál – čo naozaj pomáha
Od najväčšieho dopadu:
1. **Objem materiálu.** Užšie rebrá, väčšie oká pri rovnakom pomere, dierkované dno, odľahčenie vnútra.
2. **Prietok** (max volumetric speed, rýchly filament, 0,6 tryska namiesto 0,4).
3. **Výška vrstvy** (0,3 → 0,4 na 0,6 tryske = o štvrtinu menej vrstiev).
4. **Počet ostrovčekov na vrstvu.** Každá diera = obvod + retrakcia + presun. Väčšie oká sú o ~4–7 % rýchlejšie.
5. **Výmeny farieb** (purge).

Ďalšie poznatky:
- **Pri mriežke rozhoduje o materiáli dĺžka rebier na plochu,** nie počet dier: `ρ = sqrt(P² + Q²) / (P·Q)`, kde P a Q sú polovice rozteče. Napríklad 24/48 a 30/30 majú rovnakú hustotu, ale 30/60 o ~20 % menšiu.
- **Kosoštvorcová mriežka s pomerom 1:2** (hrany ~27° od zvislice) je tuhá, tlačí sa bez podpier a skladá sa z rovných ťahov.
- **Pevné prvky** (dno, lem, plné pásy) netreba pri nízkych dieloch škálovať. Treba však počítať s tým, že nízke diely sú preto pomerne drahšie.
- **Plná výplň v hrubých častiach je zbytočná.** Na pevnosť stačí viac perimetrov, výplň 10–15 % gyroid alebo kubická.

## 4. Tolerancie a spoje (štart, dolaď skúšobným kusom)
| | 0,4 tryska | 0,6 tryska |
|---|---|---|
| Lisovaný spoj (na tesno) | 0,05–0,1 mm | 0,1 mm |
| Posuvný spoj (veko, zásuvka) | 0,2 mm | 0,3 mm |
| Voľný spoj, print-in-place | 0,3–0,4 mm | 0,5 mm |
| Diera pre skrutku M3 / M4 / M5 | 3,3 / 4,3 / 5,4 | 3,4 / 4,4 / 5,5 |
| Zalisovacia matica M3 (heat-set, 5 mm dlhá) | Ø 4,0–4,2, hĺbka 6 | Ø 4,2, hĺbka 6 |
| Šesťhranná matica M3 do výrezu | 6,4 cez hrany (+0,2) | 6,5 |

- PETG: +0,05 mm ku všetkým vôľam. ASA: počítaj so zmrštením ~0,5 % na dlhých rozmeroch.
- Malé zvislé diery vychádzajú o 0,1–0,2 mm menšie. Na presné diery navrhni o kúsok väčší priemer alebo ich prevŕtaj.
- Okolo skrutky alebo matice treba aspoň 3 linky materiálu (pri 0,6 trysky aspoň 1,7 mm).

## 5. Orientácia a pevnosť
- Diel je najslabší **medzi vrstvami** (v smere Z). Hlavné ťahové zaťaženie smeruj do roviny XY.
- Háky, úchyty a klipy tlač naležato, aby vrstvy išli pozdĺž ohybu.
- Dlhé tenké steny vystuž rebrami, lemom alebo zvlnením. Lem pri hornej hrane nádoby je najlacnejšia výstuha.

## 6. OpenSCAD – dohody
- Parametre v sekciách pre Customizer, odvodené hodnoty pod nimi, moduly nakoniec.
- Na kontrolu limitov a nezmyselných vstupov použi `assert()`. Odvodené hodnoty vypíš cez `echo()`.
- 2D profil a potom `linear_extrude`. `offset(r=+r) offset(delta=-r)` zaoblí vypuklé rohy, `offset(r=-r) offset(delta=+r)` zaoblí vnútorné rohy (closing).
- `hull()` tenkých dosiek (`linear_extrude(0.01)`) = skosenie alebo frustum konvexného tvaru.
- Rozlíšenie: `$fa = 4; $fs = 0.4;` pre náhľad je OK. Na export zvýš kvalitu len tam, kde je to vidieť.
- OpenSCAD 2024+: zapni **Manifold** (Preferences → Advanced). Export je potom 10–100× rýchlejší.
- Všetky rozmery v mm, vonkajšie rozmery dielu ako vstup.
