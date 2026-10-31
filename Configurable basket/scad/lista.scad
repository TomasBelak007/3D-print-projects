// =====================================================================
//  Vodiaca lista pre kosiky do skrine
//  Priskrutkuje sa na policu do medzery medzi kosiky (alebo ku stene skrine).
//  Boky hrebena maju 45 st. a kopiruju spodne skosenie kosika
//  (skos_dole v priklad-kosik.scad) -> kosik sa pri zasunuti sam vycentruje
//  a nema kam ujst do strany. Kosik stoji na polici, nie na liste.
//  Vruty so zapustenou hlavou (4x16): hlava je zapustena tak hlboko,
//  aby sa nedotkla skosenia kosika; zahlbenie 90 st. pokracuje plynulo
//  az po vrch hrebena (bez hranatych vyrezov).
//
//  NASTAVENIE SLICERA (Bambu Studio):
//    Tryska ............ 0.6 mm (ide aj 0.4)   Vrstva ......... 0.30 mm
//    Wall loops ........ 3                     Top/bottom ..... 4 / 4
//    Vypln ............. 30 % gyroid           Material ....... PLA
//    Doska ............. Textured PEI          Podpery ........ NIE (boky 45 st.)
//    Orientacia ........ spodkom na dosku
// =====================================================================

/* [Rozmery] */
dlzka   = 280;     // dlzka listy (hlbka kosika je 300; max ~315 na H2C)
typ     = "stred"; // ["stred", "kraj"] stred = medzi dva kosiky, kraj = ku stene skrine
medzera = 3;       // medzera medzi kosikmi (stred) alebo kosikom a stenou (kraj), mm

/* [Volby] */
nabeh      = true;  // predny koniec hrebena zosikmeny – kosik sa lahsie navedie
skrutky    = true;  // diery pre vruty so zapustenou hlavou
pocet_skr  = 3;     // pocet vrutov na listu

/* [Vrut] */
vrut_d     = 4;     // priemer vrutu (4x16)
vrut_hlava = 8;     // priemer zapustenej hlavy (90 st.)

/* [Tlac] */
vola  = 0.4;   // vola medzi bokom hrebena a skosenim kosika (kolmo na plochu)
paska = 0.0;   // hrubka podlozky/pasky pod listou (pri vrutoch 0)

/* [Konstanty – zhodne s kosikom] */
skos_dole = 5;     // 45 st. skosenie spodnej hrany kosika (priklad-kosik.scad)
rezerva_h = 1.0;   // hreben konci o tolko pod koncom skosenia – nikdy nezdvihne kosik
nabeh_l   = 25;    // dlzka nabehu na prednom konci
okraj_skr = 40;    // vzdialenost krajnych vrutov od koncov listy
max_do_polic = 0.5; // o kolko moze spodok hlavy vrutu zajst do police (drevotrieska)
e = 0.01;
$fn = 40;

// ---------------------------------------------------------------------
// Geometria: os x naprieč listou (0 = stred medzery, pri "kraj" = stena),
// os z nahor od polic. Bok kosika vpravo je pri x = g/2, jeho skosenie je
// priamka x + z = g/2 + skos_dole. Bok hrebena je s nou rovnobezny,
// posunuty o volu kolmo -> vodorovne o vola*sqrt(2).
g     = typ == "stred" ? medzera : 2 * medzera;   // "kraj" = polovica stredovej listy
h     = skos_dole - paska - rezerva_h;            // vyska hrebena nad listou
xb    = g/2 + skos_dole - paska - vola*sqrt(2);   // polovicna sirka pri spodku
xt    = xb - h;                                   // polovicna sirka hore

// vrut: zahlbenie 90 st.; vrch hlavy co najvyssie, ale mimo skosenia kosika
r_hl  = (vrut_hlava + 0.4) / 2;                   // polomer zahlbenia hore
r_dr  = (vrut_d + 0.4) / 2;                       // polomer diery pre driek
kuz_h = r_hl - r_dr;                              // hlbka kuzela zahlbenia
xs    = typ == "stred" ? 0 : r_hl;                // poloha vrutu naprieč (kraj: ku stene)
z_hl  = min(h, g/2 + skos_dole - paska - (xs + r_hl) - vola*sqrt(2));  // vrch hlavy

assert(h > 1, "hreben je prilis nizky – zmensi pasku alebo rezervu");
assert(xt > 0.8, "hreben je hore prilis uzky – zvacsi medzeru alebo zmensi volu");
assert(dlzka <= 315, "lista sa nezmesti na podlozku H2C");
assert(!skrutky || z_hl >= kuz_h - max_do_polic,
       str("hlava vrutu sa nezmesti mimo skosenia kosika – zvacsi medzeru (pre typ ",
           typ, " aspon ~", typ == "stred" ? 3 : 5.5, " mm) alebo vypni skrutky"));

echo(str("lista ", typ, ": spodok ", (typ == "stred" ? 2*xb : xb), " mm, vrch ",
         (typ == "stred" ? 2*xt : xt), " mm, vyska ", h, " mm",
         skrutky ? str(", vrch hlavy z = ", z_hl, " mm, hlava zajde do police ",
                       max(0, kuz_h - z_hl), " mm") : ""));

// 2D profil prierezu (x, z)
module profil(hh = h) {
    xt2 = xb - hh;
    if (typ == "stred")
        polygon([[-xb, 0], [xb, 0], [xt2, hh], [-xt2, hh]]);
    else   // kraj: zvisla zadna strana pri stene (x = 0), sikmy bok ku kosiku
        polygon([[0, 0], [xb, 0], [xt2, hh], [0, hh]]);
}

module hranol(hh, l) {   // profil vytiahnuty pozdlz osi y v dlzke l
    rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(l) profil(hh);
}

module diera_vrut() {    // v polohe vrutu
    z0 = z_hl - kuz_h;                                       // spodok kuzela
    translate([0, 0, -e]) cylinder(r = r_dr, h = h + 1);     // driek
    // kuzel 90 st. od drieku az nad vrch hrebena (otvara sa nahor -> bez previsu)
    translate([0, 0, z0]) cylinder(r1 = r_dr, r2 = r_dr + (h + 1 - z0), h = h + 1 - z0);
}

module lista() {
    difference() {
        union() {
            if (nabeh) {
                translate([0, nabeh_l, 0]) hranol(h, dlzka - nabeh_l);
                hull() {   // nabeh: hreben klesa z plnej vysky na 0.6 mm
                    translate([0, nabeh_l - e, 0]) hranol(h, e);
                    hranol(0.6, e);
                }
            } else {
                hranol(h, dlzka);
            }
        }
        if (skrutky) {
            n  = max(1, pocet_skr);
            dy = n > 1 ? (dlzka - 2*okraj_skr) / (n - 1) : 0;
            for (i = [0 : n - 1])
                translate([xs, n > 1 ? okraj_skr + i*dy : dlzka/2, 0]) diera_vrut();
        }
    }
}

lista();
