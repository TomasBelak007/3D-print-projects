// =====================================================================
//  EXP18 – nacvakavaci drziak svetla Exposure Tracer / Trace (O 18 mm)
//  s GoPro uchytom (2 zuby, samec). Svetlo sa nacvakne do "C" objimky,
//  os skrutky M5 je kolmo na os svetla -> svetlo sa naklana hore/dole
//  na lubovolnom GoPro drziaku (riadidla, sedlovka, prilba).
//
//  NASTAVENIE SLICERA (Bambu Studio):
//    Tryska ............ 0.4 mm          Vrstva ......... 0.20 mm
//    Wall loops ........ 4 (= wall_loops) Top/bottom ..... 4 / 4
//    Vypln ............. 40 % gyroid      Brim ........... ano
//    Material .......... ASA (AMS HT)     Doska .......... Textured PEI + lepidlo
//    Komora ............ zavreta, 50–65 st. C (inak praska v usti objimky)
//    Podpery ........... NIE – steny zvisle, pod koncom zubov 45 st. patka, diera M5 okruhla
//    Orientacia ........ plochou stranou objimky na dosku, os svetla zvisle
//
//  PLA nepouzivat – pri nacvaknuti praska. PETG ide.
//
//  Render (z priecinka projektu):
//    openscad --backend=manifold -o stl/EXP18_90_fit050_wl4.stl scad/exposure_clip.scad
//    openscad -o stl/clip.stl -D presah=-0.3 -D wall_loops=3 -D uhol_otvoru=100 scad/exposure_clip.scad
// =====================================================================

/* [Rozmery] */
// Priemer tela svetla (mm)
priemer_svetla = 18.0;   // [10:0.1:40]
// Sirka objimky; min 15 mm (= sirka GoPro zuba)
sirka = 15.0;            // [15:0.5:30]

/* [Volby] */
// Presah na priemere; zaporny = objimka zviera. Ide nasadit prilis lahko -> -0.15, praska -> -0.5
presah = -0.50;          // [-1.0:0.05:0.5]
// Uhol usta "C". Pada dole -> 95, praska pri nacvaknuti -> 105
uhol_otvoru = 90;        // [80:1:130]
// Polomer nabehu na hrotoch usta
r_hrotov = 1.0;          // [0:0.1:2]

/* [Tlac] */
tryska     = 0.4;    // [0.4, 0.6]
vrstva     = 0.20;   // 0.20 pre 0.4 trysku, 0.30 pre 0.6
// Wall loops v sliceri (na kazdy obrys); hrubka objimky = 2N liniek. Tuhost rastie s tretou mocninou
wall_loops = 4;      // [2:1:6]
material   = "ASA";  // ["PLA", "PETG", "ASA"]

/* [Konstanty – GoPro uchyt, netreba menit] */
// Hrubka jedneho zuba
hrubka_zuba = 2.9;
// Medzera medzi zubami (sem ide stredny zub protikusu)
medzera_zubov = 3.2;
// Polomer zaobleneho konca zuba
r_zuba = 7.5;
// Diera pre skrutku M5
diera_skrutky = 5.3;
// Vyska osi skrutky nad povrchom objimky (min r_zuba + vola)
zdvih_osi = 8.0;

/* [Kvalita] */
$fn = 180;

// ------------------------------------------------------------ odvodene
w_linky = tryska <= 0.4 ? 0.42 : 0.62;              // sirka linky (Bambu default)
s_linky = w_linky - vrstva * (1 - PI/4);            // roztec susednych liniek
function hrubka(linky) = w_linky + (linky - 1) * s_linky;
stena   = hrubka(2 * wall_loops);                   // objimka = 2N liniek, bez gap fill

r_in    = (priemer_svetla + presah) / 2;
r_out   = r_in + stena;
y_os    = r_out + zdvih_osi;                        // os skrutky
sirka_zuba = 2 * r_zuba;                            // 15 mm – sirka uchytu (GoPro standard)
z_zuba  = r_zuba;                                   // stred zuba a os skrutky (zub zarovno so Z = 0)
y_krk   = 7.0;                                      // zaciatok krku zuba (koniec orezie otvor)
balik   = 2 * hrubka_zuba + medzera_zubov;          // 9 mm
e       = 0.01;

assert(sirka >= sirka_zuba - 1e-6, "objimka nesmie byt uzsia ako GoPro zub (15 mm)");
assert(y_os - r_zuba > r_out, "stredny zub protikusu by narazil do objimky");
assert(material != "PLA", "PLA pri nacvaknuti praska – pouzi ASA alebo PETG");

echo(str("stena = ", stena, " mm (", 2 * wall_loops, " linky) | otvor D", r_in * 2,
         " | vonkajsi D", r_out * 2,
         " | usta ", 2 * r_in * sin(uhol_otvoru / 2), " mm"));

// 2D profil "C" objimky so zaoblenim na vsetkych styroch hrotoch usta
module profil_c() {
    ha = uhol_otvoru / 2;
    L  = 60;
    offset(r = r_hrotov) offset(r = -r_hrotov)
        difference() {
            circle(r = r_out);
            circle(r = r_in);
            polygon([[0, 0], [L, L * tan(ha)], [L, -L * tan(ha)]]);   // klin usta v smere +X
        }
}

// Jeden GoPro zub: profil "stadion" v rovine YZ, hrubka v smere X.
// V 2D profile je x = z_zuba - Z, teda x = r_zuba je doska (Z = 0).
module zub(x_off) {
    c = r_zuba / sqrt(2);
    translate([x_off, 0, z_zuba])
        rotate([0, 90, 0])             // sirka X -> Z, hrubka Z -> +X
            linear_extrude(hrubka_zuba)
                union() {
                    translate([-sirka_zuba / 2, y_krk]) square([sirka_zuba, y_os - y_krk]);
                    translate([0, y_os]) circle(r = r_zuba);
                    // 45 st. patka pod zaoblenym koncom (dotycnica v 45 st. bode kruhu)
                    translate([0, y_os]) polygon([[0, 0], [r_zuba, 0],
                        [r_zuba, 2*c - r_zuba], [c, c]]);
                }
}

module drziak() {
    difference() {
        union() {
            linear_extrude(sirka) profil_c();
            zub(-balik / 2);
            zub(medzera_zubov / 2);
        }
        // otvor pre telo svetla (orezie aj krky zubov, ktore siahaju dnu)
        translate([0, 0, -1]) cylinder(r = r_in, h = sirka + 2);
        // diera M5, os v smere X (okruhla, maly strop H2C zvladne)
        translate([-10, y_os, z_zuba]) rotate([0, 90, 0]) cylinder(d = diera_skrutky, h = 20);
    }
}

drziak();
