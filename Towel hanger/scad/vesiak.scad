// =====================================================================
//  Vesiak na uteraky – lepi sa na stenu obojstrannou paskou
//  Doska (zadna strana na stenu) a 1 az N sikmych kolikov s gulovym
//  koncom a zaoblenim pri koreni. Podla povodneho modelu z Fusion 360.
//
//  NASTAVENIE SLICERA (Bambu Studio):
//    Tryska ............ 0.4 mm          Vrstva ......... 0.20 mm
//    Wall loops ........ 4 (kolik O6 je cely z perimetrov)
//    Top/bottom ........ 5 / 4           Vypln .......... 15 % gyroid
//    Material .......... PLA (AMS 2 Pro) Doska .......... hladka PEI (rovny povrch pre pasku)
//    Podpery ........... NIE – kolik 45 st., zaoblenie pod kolikom <= 45 st.,
//                        strop kapsy na pasku je most 21 mm (H2C zvladne)
//    Orientacia ........ doskou na podlozku (strana na stenu dole)
//
//  Render (z priecinka projektu):
//    openscad --backend=manifold -o stl/vesiak_1.stl scad/vesiak.scad
//    openscad --backend=manifold -o stl/vesiak_3_koliky.stl -p scad/vesiak.json -P 3_koliky scad/vesiak.scad
// =====================================================================

/* [Rozmery – vonkajsie, mm] */
// Pocet kolikov vedla seba na jednej doske
pocet_kolikov = 1;      // [1:1:10]
// Roztec kolikov = sirka dosky na jeden kolik (sirka dosky = pocet x roztec)
roztec = 25;            // [15:0.5:100]
// Vyska dosky (smer hore-dole na stene)
vyska_dosky = 35;       // [20:0.5:150]
// Hrubka dosky (zaokruhli sa na nasobok vrstvy)
hrubka_dosky = 3.0;     // [2:0.2:8]

/* [Kolik] */
// Priemer kolika
priemer_kolika = 6;     // [4:0.5:15]
// Dlzka kolika pozdlz osi – od povrchu dosky po spicku gule
dlzka_kolika = 31.6;    // [10:0.5:100]
// Uhol kolika od steny (90 = kolmo zo steny). Min. 45 st. (PETG 50 st.), mensi sa zdvihne
uhol_kolika = 45;       // [45:1:90]
// Polomer zaoblenia pri koreni kolika
r_zaoblenia = 3;        // [0:0.5:8]
// Posun kolika hore (+) / dole (-) od stredu dosky
posun_kolika = 0;       // [-30:0.5:30]

/* [Volby] */
// Polomer rohov dosky (pohlad zo steny)
r_rohu = 3;             // [0:0.5:15]
// Zaoblenie hornej (prednej) hrany dosky
r_hrany = 0.5;          // [0:0.1:2]
// Skosenie spodnej hrany proti elephant foot (strana na stenu)
skos_dole = 0.4;        // [0:0.1:1]
// Kapsa na obojstrannu pasku na zadnej strane (jedna na kazdy kolik)
kapsa = true;
// Hlbka kapsy – paska musi byt hrubsia, aby dosadla na stenu
hlbka_kapsy = 1.0;      // [0.4:0.2:3]
// Sirka okraja okolo kapsy
okraj_kapsy = 2;        // [1:0.5:6]
// Polomer rohov kapsy
r_kapsy = 2;            // [0:0.5:10]

/* [Tlac] */
tryska     = 0.4;   // [0.4, 0.6, 0.8]
vrstva     = 0.20;  // 0.20 pre 0.4 trysku, 0.30 pre 0.6, 0.40 pre 0.8 HF
wall_loops = 4;     // = nastavenie v sliceri (na kazdy obrys)
material   = "PLA"; // ["PLA", "PETG", "ASA"]

/* [Kvalita] */
$fa = 3; $fs = 0.3;
// Pocet krokov zaoblenia pri koreni
kroky_zaoblenia = 24;   // [4:1:60]

/* [Konstanty – netreba menit] */
// --- odvodene z trysky a vrstvy ---
w_linky = tryska <= 0.4 ? 0.42 : tryska <= 0.6 ? 0.62 : 0.82;  // sirka linky (Bambu default)
s_linky = w_linky - vrstva * (1 - PI/4);            // roztec susednych liniek
function hrubka(linky) = w_linky + (linky - 1) * s_linky;
function vrstvy(h) = max(1, round(h / vrstva)) * vrstva;  // zaokruhli na nasobok vrstvy
plast   = hrubka(2 * wall_loops);                   // hrubka plna z perimetrov (obe strany)

// --- limity H2C ---
podlozka = [300, 320, 320];
previs_max = material == "PETG" ? 40 : 45;          // od zvislice

t     = vrstvy(hrubka_dosky);                       // hrubka dosky
sirka = pocet_kolikov * roztec;                     // sirka dosky
r     = priemer_kolika / 2;
a_min = 90 - previs_max;                            // najmensi uhol bez previsu
a     = max(uhol_kolika, a_min);                    // od roviny steny (PETG: zdvihne sa na 50)
f     = r_zaoblenia;
Lc    = dlzka_kolika - r;                           // od dosky po stred gule
e     = 0.01;

// Zaoblenie v kute s volnym uhlom th (medzi doskou a plastom kolika):
// sirka zaoblenia vo vodorovnom smere vo vyske h nad doskou
function zaobl_ht(th)   = f / tan(th/2) * sin(th);      // vyska dotyku na koliku
function zaobl_w(h, th) = f <= 0 || h >= zaobl_ht(th) ? 0 :
    (f / tan(th/2) - sqrt(max(0, f*f - (h - f)*(h - f)))) - h / tan(th);

// podorys kolika na doske od korena (smer +Y = hore na stene, kolik sa klopi hore)
dole      = r / sin(a) + zaobl_w(0, 180 - a);       // pod korenom (tupy kut)
hore      = max(r / sin(a) + zaobl_w(0, a),         // nad korenom (ostry kut pod kolikom)
                Lc * cos(a) + r);                   // priemet spicky
// koren tak, aby bol podorys kolika v strede dosky (+ posun)
y_k       = vyska_dosky / 2 - (hore - dole) / 2 + posun_kolika;
vylozenie = t + Lc * sin(a) + r;                    // ako daleko trci zo steny

// kapsa na pasku: strop kapsy je most cez kratsiu stranu
hk       = vrstvy(hlbka_kapsy);
kapsa_x  = roztec - 2 * okraj_kapsy;
kapsa_y  = vyska_dosky - 2 * okraj_kapsy;
most     = min(kapsa_x, kapsa_y);

if (uhol_kolika < a_min)
    echo(str("POZOR: uhol_kolika ", uhol_kolika, " st. je pre ", material, " malo (previs max. ",
             previs_max, " st.) – pouzity ", a_min, " st."));
assert(y_k - dole >= 1, str("kolik presahuje dosku dole – zvacsi vyska_dosky alebo posun_kolika (", y_k - dole, ")"));
assert(y_k + hore <= vyska_dosky - 1, str("spicka kolika presahuje dosku hore – zvacsi vyska_dosky (", vyska_dosky - y_k - hore, ")"));
assert(roztec >= priemer_kolika + 2 * f + 2, "roztec je mensia ako kolik so zaoblenim");
assert(sirka <= podlozka[0] && vyska_dosky <= podlozka[1] && vylozenie <= podlozka[2],
       str("Diel sa nezmesti na podlozku H2C ", podlozka));

echo(str("doska ", sirka, " x ", vyska_dosky, " x ", t, " mm (", round(t / vrstva), " vrstiev)",
         " | kolikov ", pocet_kolikov, " | uhol kolika ", a, " st.",
         " | vylozenie zo steny ", vylozenie, " mm",
         " | koren kolika ", y_k, " mm od spodnej hrany",
         " | plast z perimetrov ", plast, " mm"));
if (kapsa) {
    assert(t - hk >= 4 * vrstva, "nad kapsou musia ostat aspon 4 vrstvy – zmensi hlbka_kapsy");
    echo(str("kapsa ", kapsa_x, " x ", kapsa_y, " x ", hk, " mm na kolik | most ", most, " mm",
             most > 20 ? " – POZOR, dlhy most" : ""));
}

// =====================================================================
//  KNIZNICA
// =====================================================================

// obdlznik so zaoblenymi rohmi, lavy dolny roh v [0,0]
module zaobleny_obdlznik(x, y, rr) {
    r2 = max(min(rr, x/2 - e, y/2 - e), e);
    translate([r2, r2]) offset(r = r2) square([x - 2*r2, y - 2*r2]);
}

// tenka doska z obrysu odsadeneho o ins vo vyske z
module plat(z, ins, h = e) {
    translate([ins, ins, z]) linear_extrude(h)
        zaobleny_obdlznik(sirka - 2*ins, vyska_dosky - 2*ins, r_rohu - ins);
}

// =====================================================================
//  DIEL
// =====================================================================

// doska: skosenie dole, zaoblena horna hrana (hull tenkych dosiek)
module doska() {
    n = 8;
    hull() {
        plat(0, skos_dole);
        plat(skos_dole, 0);
        plat(t - r_hrany - e, 0);
        for (i = [1 : n])
            let (phi = 90 * i / n)
                plat(t - r_hrany + r_hrany * sin(phi) - e, r_hrany * (1 - cos(phi)));
    }
}

// vodorovny rez kolikom so zaoblenim vo vyske h nad doskou (stred rezu v [0,0])
// polovica +Y (ostry kut pod kolikom) a -Y maju rozne siroke zaoblenie
module rez_zaoblenia(h) {
    wx = zaobl_w(h, 90);
    wp = zaobl_w(h, a);
    wm = zaobl_w(h, 180 - a);
    ry = r / sin(a);
    union() {
        intersection() {
            scale([r + wx, ry + wp]) circle(r = 1, $fn = 72);
            translate([-50, 0]) square([100, 100]);
        }
        intersection() {
            scale([r + wx, ry + wm]) circle(r = 1, $fn = 72);
            translate([-50, -100]) square([100, 100]);
        }
    }
}

module zaoblenie() {
    hmax = max(zaobl_ht(a), zaobl_ht(90), zaobl_ht(180 - a));
    // kroky hustejsie pri doske, kde sa zaoblenie meni najrychlejsie
    hs = [for (i = [0 : kroky_zaoblenia]) hmax * pow(i / kroky_zaoblenia, 2)];
    for (i = [0 : kroky_zaoblenia - 1])
        hull() for (h = [hs[i], hs[i + 1]])
            translate([0, h / tan(a), t + h - e]) linear_extrude(e) rez_zaoblenia(h);
}

// kolik s korenom v [0,0,0] na povrchu dosky; cast pod povrchom sa orezie
module kolik() {
    s0 = r / tan(a) + r;                            // zaciatok osi pod povrchom dosky
    intersection() {
        rotate([-(90 - a), 0, 0]) {
            translate([0, 0, -s0]) cylinder(r = r, h = s0 + Lc);
            translate([0, 0, Lc]) sphere(r = r);
        }
        translate([-100, -100, -e]) cube([200, 200, 200]);
    }
}

module vesiak() {
    difference() {
        union() {
            doska();
            for (i = [0 : pocet_kolikov - 1])
                translate([roztec * (i + 0.5), y_k, 0]) {
                    translate([0, 0, t]) kolik();
                    if (f > 0) zaoblenie();
                }
        }
        // kapsy na pasku, medzi nimi rebro 2 x okraj (kratsi most ako jedna dlha kapsa)
        if (kapsa)
            for (i = [0 : pocet_kolikov - 1])
                translate([roztec * i + okraj_kapsy, okraj_kapsy, -e])
                    linear_extrude(hk + e) zaobleny_obdlznik(kapsa_x, kapsa_y, r_kapsy);
    }
}

vesiak();
