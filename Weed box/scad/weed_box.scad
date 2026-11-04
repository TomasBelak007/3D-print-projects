// =====================================================================
//  Weed box – okruhla krabicka so zavitom, na vicku embosovany listok
//  Dva diely: TELO (vnutorny zavit) a VICKO (zatka s vonkajsim zavitom).
//  Bambu Lab H2C, PLA, tryska 0.4 mm, vrstva 0.20 mm
//
//  NASTAVENIE SLICERA (Bambu Studio):
//    Tryska ............ 0.4 mm          Vrstva ......... 0.20 mm
//    Wall loops ........ 3               Bottom shells .. 8 (dno 1.6 mm)
//    Top shells ........ 5               Vypln .......... 15 % gyroid
//    Material .......... PLA (AMS 2 Pro) Doska .......... Textured PEI
//    Podpery ........... NIE (vsetko <= 45 st.)
//    Orientacia ........ telo dnom dole, vicko listkom HORE (tak ako v STL)
//
//  Preco je zavit vonkajsi na vicku: vicko s plastom okolo hrdla by malo
//  zvnutra strop s rozpatim ~65 mm (most sa neda, kuzel 45 st. je vysoky).
//  Vicko ako plna zatka lezi plochou stranou na doske, vrch nesie vypln
//  a listok je navrchu bez akychkolvek podpier.
//
//  Export: -D 'diel="telo"' a -D 'diel="vicko"'
// =====================================================================

/* [Rozmery – vonkajsie, mm] */
priemer = 70;   // vonkajsi priemer tela aj vicka
vyska   = 60;   // celkova vyska zavretej krabicky vratane listka

/* [Zavit] */
stupanie     = 4;    // stupanie zavitu (mm na otacku)
hlbka_zavitu = 1.2;  // vyska rebra zavitu (radialne)
otacky       = 1.5;  // kolko otacok ma zavit (= kolko sa skrutkuje)
vola_zavitu  = 0;    // radialna vola a vola na boku; 0 = automaticky podla trysky a materialu

/* [Listok] */
velkost_listka = 52;   // od konca stopky po spicku stredneho listka
vyska_listka   = 0.6;  // vyska embosu, zaokruhli sa na nasobok vrstvy
zilky          = true; // stredna zilka vyrezana vo vacsich listkoch

/* [Volby] */
diel = "oba"; // ["oba", "telo", "vicko", "zostava", "rez", "prienik"]
ryhy = true;  // zvisle ryhy na okraji vicka (uchop)

/* [Tlac] */
tryska     = 0.4;   // [0.4, 0.6, 0.8]
vrstva     = 0.20;  // 0.20 pre 0.4 trysku, 0.30 pre 0.6, 0.40 pre 0.8 HF
wall_loops = 3;     // = nastavenie v sliceri (na kazdy obrys)
material   = "PLA"; // ["PLA", "PETG", "ASA"]

/* [Konstanty – netreba menit] */
// --- odvodene z trysky a vrstvy ---
w_linky = tryska <= 0.4 ? 0.42 : tryska <= 0.6 ? 0.62 : 0.82;  // sirka linky (Bambu default)
s_linky = w_linky - vrstva * (1 - PI/4);            // roztec susednych liniek
function hrubka(linky) = w_linky + (linky - 1) * s_linky;
function vrstvy(h) = max(1, round(h / vrstva)) * vrstva;  // zaokruhli na nasobok vrstvy
stena   = hrubka(2 * wall_loops);                   // stena = 2N liniek
dno     = vrstvy(1.6);
skos    = 1.0;      // skosenie spodnej hrany tela (elephant foot)
skos_v  = 0.6;      // skosenie spodku zatky (nabeh + elephant foot)
skos_h  = 1.0;      // skosenie hornej hrany vicka
r_dno   = 6;        // vnutorne zaoblenie pri dne (lahko sa vyberie obsah)
lem     = hrubka(2 * wall_loops - 2);  // rovna plocha na hornej hrane tela = hlbka drazky medzi dielmi
okraj_v = 4;        // zvisly okraj vicka nad kuzelom
ryha_h  = 0.6;      // hlbka ryhy
ryha_r  = 1.6;      // polomer ryhy
ryha_p  = 4.5;      // ciel. roztec ryh po obvode
g_sedlo = 0.1;      // medzera v kuzelovom sedle v polohe "zostava"
okraj_z = 0.4;      // rezerva nad a pod zavitom
zapust  = 0.2;      // o kolko rebro zavitu zasahuje do steny (prekryv)
nabeh   = 45;       // uhol, na ktorom rebro nabieha zo steny (stupne)
fn_kruh = 180;      // segmentov na kruh aj na otacku zavitu
test_uhol = 0;      // kontrola: vicko odskrutkovane o tento uhol (stupne)
test_dz   = 0;      // kontrola: vicko posunute navyse v Z
farba     = "Tan";  // farba v nahlade

// --- vola podla trysky a materialu (medzi posuvnym a volnym spojom z docs) ---
vola_auto = (tryska <= 0.4 ? 0.30 : tryska <= 0.6 ? 0.40 : 0.50)
            + (material == "PETG" ? 0.05 : 0);
vola = vola_zavitu > 0 ? vola_zavitu : vola_auto;

// --- previs: PETG max 40 st., ostatne 45 st. od zvislice ---
uhol_boku = material == "PETG" ? 40 : 45;
k = 1 / tan(uhol_boku);                  // axialne mm na 1 mm radialne

// --- polomery ---
r_out = priemer / 2;
r_i   = r_out - stena;                   // vnutorna stena tela
r_p   = r_i - hlbka_zavitu - vola;       // valec zatky vicka

// --- profil zavitu: rebro tela a rebro vicka su rovnake lichobezniky ---
ca = vola / sin(uhol_boku);              // axialna vola na jeden bok
C  = stupanie/2 - k * (hlbka_zavitu - vola) - ca;  // sirka vrcholu rebra
B  = C + 2 * k * hlbka_zavitu;           // sirka paty rebra

// --- vyskove koty vicka (z = 0 je spodok zatky) ---
zs_v  = B/2 + okraj_z;                   // zaciatok osi rebra vicka
z_p   = zs_v + otacky*stupanie + B/2 + okraj_z;  // koniec valca zatky
z_kuz = z_p + (r_out - r_p) * k;         // koniec kuzela = zaciatok okraja
H_v   = vrstvy(z_kuz + okraj_v);         // vrch vicka bez listka
h_list= vrstvy(vyska_listka);

// --- vyskove koty tela ---
kuz_t = (r_out - lem - r_i) * k;         // vyska kuzeloveho sedla v tele
// vicko v zavretej polohe: z_v = H_t - (r_out - lem - r_p)*k - z_p + g_sedlo
// a z_v + H_v + h_list = vyska
H_t  = vyska - H_v - h_list + (r_out - lem - r_p) * k + z_p - g_sedlo;
z_v  = vyska - H_v - h_list;             // spodok zatky v zavretej polohe
zs_t = z_v + zs_v - stupanie/2;          // os rebra tela, o pol stupania oproti vicku
uzit_h = z_v - dno;                      // vnutorna vyska pod zatkou
objem_ml = PI * r_i * r_i * uzit_h / 1000;

// --- listok ---
L_stopka = 0.20;                         // dlzka stopky voci strednemu listku
L_c = velkost_listka / (1 + L_stopka);   // dlzka stredneho listka

// --- limity H2C ---
podlozka = [300, 320, 320];

$fn = fn_kruh;
e = 0.01;

assert(priemer <= podlozka[0] && vyska <= podlozka[2],
       str("Diel sa nezmesti na podlozku H2C ", podlozka));
assert(C >= 2 * vrstva, str("Vrchol rebra zavitu ", C, " mm je prilis uzky, zvacsi stupanie alebo zniz hlbku"));
assert(B <= stupanie - 2 * vrstva, str("Paty rebier sa dotykaju: B = ", B));
assert(hlbka_zavitu > vola + 0.4, "Zaber zavitu je mensi ako 0.4 mm");
assert(wall_loops >= 2 && ryha_h < lem, "Stena je tenka na sedlo alebo ryhy, treba wall_loops >= 2");
assert(zs_t - B/2 > dno + r_dno, str("Telo je prilis nizke: zavit zasahuje do zaoblenia pri dne, min. vyska = ",
       vyska + dno + r_dno - (zs_t - B/2)));
assert(zs_t + (otacky*stupanie) + B/2 < H_t - kuz_t, "Rebro tela zasahuje do sedla");
assert(velkost_listka <= 2 * (r_out - skos_h - 1.5) && velkost_listka >= 20,
       "Listok sa nezmesti na vicko alebo je prilis maly na detail");

echo(str("stena = ", stena, " mm (", 2*wall_loops, " liniek), dno = ", dno,
         " mm (", round(dno/vrstva), " vrstiev), lem = ", lem, " mm"));
echo(str("zavit: stupanie ", stupanie, ", hlbka ", hlbka_zavitu, ", bok ", uhol_boku,
         " st., vola ", vola, " mm (axialne ", ca, " na bok), vrchol C = ", C,
         ", pata B = ", B, ", zaber ", hlbka_zavitu - vola, " mm"));
echo(str("telo: vyska ", H_t, ", vnutorny D ", 2*r_i, ", otvor (cez rebro) D ", 2*(r_i - hlbka_zavitu)));
echo(str("vicko: vyska ", H_v, " + listok ", h_list, " (", round(h_list/vrstva),
         " vrstvy, zmena farby od z = ", H_v, "), zatka D ", 2*r_p, " x ", z_p));
echo(str("uzitocny objem: D ", 2*r_i, " x ", uzit_h, " mm = ~", round(objem_ml), " ml"));

// =====================================================================
//  ZAVIT
// =====================================================================

// Rebro po skrutkovici z polyhedronu. smer = +1 rebro von (vicko),
// -1 rebro dnu (telo). Konce plynule nabiehaju zo steny.
module rebro(r_koren, z0, smer) {
    n   = ceil(otacky * fn_kruh);
    a_c = otacky * 360;
    hh  = hlbka_zavitu + zapust;
    a0  = C/2 + k * hh;
    function mierka(a) = max(0.05, min(1, a / nabeh, (a_c - a) / nabeh));
    // prierez [radialne, axialne], poradie zachova orientaciu plosok
    function prierez(s) =
        let (p = [[-zapust, -a0*s], [-zapust + hh*s, -C/2*s],
                  [-zapust + hh*s,  C/2*s], [-zapust,  a0*s]])
        smer > 0 ? p : [p[3], p[2], p[1], p[0]];
    body = [for (i = [0 : n])
                let (a = a_c * i / n, s = mierka(a), z = z0 + stupanie * a / 360)
                for (q = prierez(s))
                    let (r = r_koren + smer * q[0])
                    [r * cos(a), r * sin(a), z + q[1]]];
    plochy = concat(
        [[3, 2, 1], [3, 1, 0]],
        [for (i = [0 : n-1], j = [0 : 3])
            let (b = 4*i, j1 = (j + 1) % 4)
            for (t = [[b+j, b+j1, b+4+j1], [b+j, b+4+j1, b+4+j]]) t],
        [[4*n, 4*n+1, 4*n+2], [4*n, 4*n+2, 4*n+3]]);
    polyhedron(points = body, faces = plochy, convexity = 6);
}

// =====================================================================
//  LISTOK – 2D obrys, 7 pilovitych listkov
// =====================================================================

// relativna sirka listka pozdlz osi, t = 0..1, maximum okolo 0.3
function sirka_t(t) = pow(max(0, sin(180 * pow(t, 0.7))), 0.85);

// pravy okraj: striedaju sa zarezy a zuby smerujuce k spicke
function pila(L, W, n) = [for (i = [1 : n-1])
    let (t1 = i / n, t2 = min(0.97, (i + 1.15) / n))
    for (q = [[W/2 * sirka_t(t1) * 0.72, L * t1], [W/2 * sirka_t(t2), L * t2]]) q];

module lupen(L, W, n) {
    p = pila(L, W, n);
    m = len(p);
    polygon(concat([[0, 0]], p, [[0, L]],
                   [for (i = [m-1 : -1 : 0]) [-p[i][0], p[i][1]]]));
}

// [uhol od osi, dlzka, sirka, zuby] – relativne k L_c
listky = [[0, 1.00, 0.30, 8], [32, 0.88, 0.27, 7], [66, 0.64, 0.22, 6], [115, 0.32, 0.14, 4]];

module listok_2d() {
    r_o = 0.45 * w_linky;     // odstrani prvky tensie ako ~1 linka
    translate([0, -L_c * (1 - L_stopka) / 2])
    offset(r = r_o) offset(delta = -r_o)
    difference() {
        union() {
            for (l = listky, s = (l[0] == 0 ? [1] : [-1, 1]))
                rotate(-s * l[0]) lupen(L_c * l[1], L_c * l[2], l[3]);
            polygon([[-0.025*L_c, 0.05*L_c], [0.025*L_c, 0.05*L_c],
                     [0.015*L_c, -L_stopka*L_c], [-0.015*L_c, -L_stopka*L_c]]);
        }
        if (zilky)
            for (l = listky, s = (l[0] == 0 ? [1] : [-1, 1]))
                if (L_c * l[2] >= 7)
                    rotate(-s * l[0]) polygon([
                        [-w_linky*0.8, L_c*l[1]*0.16], [w_linky*0.8, L_c*l[1]*0.16],
                        [w_linky*0.5, L_c*l[1]*0.86], [-w_linky*0.5, L_c*l[1]*0.86]]);
    }
}

// =====================================================================
//  DIELY
// =====================================================================

module telo() {
    obluk = [for (a = [0 : 10 : 90])
        [r_i - r_dno + r_dno * cos(a), dno + r_dno - r_dno * sin(a)]];
    color(farba) union() {
        rotate_extrude() polygon(concat(
            [[0, 0], [r_out - skos, 0], [r_out, skos * k], [r_out, H_t],
             [r_out - lem, H_t], [r_i, H_t - kuz_t]],
            obluk, [[0, dno]]));
        rebro(r_i, zs_t, -1);
    }
}

module vicko() {
    color(farba) difference() {
        union() {
            rotate_extrude() polygon([
                [0, 0], [r_p - skos_v, 0], [r_p, skos_v * k], [r_p, z_p],
                [r_out, z_kuz], [r_out, H_v - skos_h], [r_out - skos_h, H_v], [0, H_v]]);
            rebro(r_p, zs_v, 1);
        }
        if (ryhy) {
            n = round(2 * PI * r_out / ryha_p);
            for (i = [0 : n-1]) rotate(i * 360 / n)
                translate([r_out + ryha_r - ryha_h, 0, z_p])
                    cylinder(r = ryha_r, h = H_v - z_p + 1, $fn = 16);
        }
    }
    color("ForestGreen") translate([0, 0, H_v - e])
        linear_extrude(h_list + e) listok_2d();
}

// vicko v polohe odskrutkovane o test_uhol (proti smeru hodinovych ruciciek = povolenie)
module vicko_zavrete() {
    translate([0, 0, z_v + stupanie * test_uhol / 360 + test_dz])
        rotate(test_uhol) vicko();
}

if (diel == "telo") telo();
else if (diel == "vicko") vicko();
else if (diel == "oba") { telo(); translate([priemer + 10, 0, 0]) vicko(); }
else if (diel == "zostava") { telo(); vicko_zavrete(); }
else if (diel == "rez") difference() {
    union() { telo(); vicko_zavrete(); }
    translate([-priemer, -priemer, -1]) cube([2*priemer, priemer, vyska + stupanie + 5]);
}
else if (diel == "prienik") intersection() { telo(); vicko_zavrete(); }
