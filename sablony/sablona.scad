// =====================================================================
//  SABLONA – parametricky diel pre Bambu Lab H2C
//  Skopiruj, premenuj, uprav sekcie [Rozmery] a [Volby] a modul diel().
//
//  NASTAVENIE SLICERA (Bambu Studio) – vypln pre kazdy diel:
//    Tryska ............ 0.6 mm          Vrstva ......... 0.30 mm
//    Wall loops ........ 2               Bottom shells .. 7 (= dno / vrstva)
//    Top shells ........ 4               Vypln .......... 15 % gyroid
//    Material .......... PLA (AMS 2 Pro) Doska .......... Textured PEI
//    Podpery ........... NIE (vsetko <= 45 st.)
// =====================================================================

/* [Rozmery – vonkajsie, mm] */
sirka = 120;    // X
hlbka = 80;     // Y
vyska = 60;     // Z

/* [Volby] */
mriezka_steny = true;
mriezka_dno   = false;

/* [Tlac] */
tryska     = 0.6;   // [0.4, 0.6, 0.8]
vrstva     = 0.30;  // 0.20 pre 0.4 trysku, 0.30 pre 0.6, 0.40 pre 0.8 HF
wall_loops = 2;     // = nastavenie v sliceri (na kazdy obrys)
material   = "PLA"; // ["PLA", "PETG", "ASA"]

/* [Konstanty – netreba menit] */
// --- odvodene z trysky a vrstvy ---
w_linky = tryska <= 0.4 ? 0.42 : tryska <= 0.6 ? 0.62 : 0.82;  // sirka linky (Bambu default)
s_linky = w_linky - vrstva * (1 - PI/4);            // roztec susednych liniek
function hrubka(linky) = w_linky + (linky - 1) * s_linky;
stena   = hrubka(2 * wall_loops);                   // stena = 2N liniek
rebro   = stena;                                    // rebro mriezky = 2N liniek
function vrstvy(h) = max(1, round(h / vrstva)) * vrstva;  // zaokruhli na nasobok vrstvy
dno     = vrstvy(2.0);
skos    = 1.0;                                      // skosenie spodnej hrany (elephant foot)
r_roh   = 6;                                        // vonkajsi polomer rohov

// --- vole podla trysky a materialu ---
vola_lis  = (tryska <= 0.4 ? 0.10 : 0.10) + (material == "PETG" ? 0.05 : 0);
vola_posun= (tryska <= 0.4 ? 0.20 : 0.30) + (material == "PETG" ? 0.05 : 0);
vola_volna= (tryska <= 0.4 ? 0.35 : 0.50) + (material == "PETG" ? 0.05 : 0);

// --- limity H2C (obe trysky: 300 x 320 x 325, s rezervou) ---
podlozka = [300, 320, 320];

$fa = 4; $fs = 0.4;
e = 0.01;

assert(sirka <= podlozka[0] && hlbka <= podlozka[1] && vyska <= podlozka[2],
       str("Diel sa nezmesti na podlozku H2C ", podlozka));
echo(str("stena = ", stena, " mm (", 2*wall_loops, " linky), dno = ", dno,
         " mm (", round(dno/vrstva), " vrstiev)"));

// =====================================================================
//  KNIZNICA – 2D
// =====================================================================

// obdlznik so zaoblenymi rohmi, lavy dolny roh v [0,0]
module zaobleny_obdlznik(x, y, r) {
    r2 = max(min(r, x/2 - e, y/2 - e), e);
    translate([r2, r2]) offset(r = r2) square([x - 2*r2, y - 2*r2]);
}

// zaoblenie vnutornych rohov 2D tvaru (closing)
module zaobli_vnutorne(r) { offset(r = -r) offset(delta = r) children(); }
// zaoblenie vonkajsich rohov 2D tvaru (opening)
module zaobli_vonkajsie(r) { offset(r = r) offset(delta = -r) children(); }

// kosostvorec; horny vrchol ostry (strop diery bez previsu), ostatne zaoblene
module diamant(A, B, r = 1) {
    union() {
        offset(r = r) offset(delta = -r) polygon([[A,0],[0,B],[-A,0],[0,-B]]);
        polygon([[A/2, B/2], [0, B], [-A/2, B/2]]);
    }
}

// slza – diera so spickou hore (pre vodorovne osi), d = priemer
module slza(d, uhol = 45) {
    r = d/2;
    hull() {
        circle(r = r);
        translate([0, r / sin(uhol)]) square(e, center = true);
    }
}

// diamantova mriezka v obdlzniku L x V. Roztec sa dopasuje na plochu.
// ex = [x1, x2, y1] – zona, do ktorej oka nesmu zasahovat (vynechaju sa cele)
module mriezka(L, V, oko_x, oko_y, rebro, zaobl = 1.2, ex = undef) {
    n  = max(1, round(L / oko_x));
    m  = max(1, round(V / oko_y));
    px = L / n;  py = V / m;
    P  = px / 2; Q  = py / 2;
    k  = sqrt(P*P + Q*Q);
    A  = P - rebro/2 * k / Q;
    B  = Q - rebro/2 * k / P;
    function volne(x, y) = is_undef(ex) ||
        x + A < ex[0] || x - A > ex[1] || y + B < ex[2];
    if (A > 1 && B > 1) {
        for (i = [0 : n-1], j = [0 : m-1])
            let (x = (i + .5) * px, y = (j + .5) * py)
                if (volne(x, y)) translate([x, y]) diamant(A, B, zaobl);
        if (n > 1 && m > 1)
            for (i = [1 : n-1], j = [1 : m-1])
                let (x = i * px, y = j * py)
                    if (volne(x, y)) translate([x, y]) diamant(A, B, zaobl);
    }
}

// =====================================================================
//  KNIZNICA – 3D
// =====================================================================

// tenka doska z obrysu sirka x hlbka odsadeneho o ins (pre hull skosenia)
module plat(sx, sy, r, z, ins, h = e) {
    translate([ins, ins, z]) linear_extrude(h)
        zaobleny_obdlznik(sx - 2*ins, sy - 2*ins, r - ins);
}

// kvader so zaoblenymi zvislymi hranami a 45 st. skosenim dole
module kvader_skos(sx, sy, sz, r = r_roh, c = skos) {
    hull() { plat(sx, sy, r, 0, c); plat(sx, sy, r, c, 0, sz - c); }
}

// otvorena nadoba: stena t, dno d, skosenie c zvonka aj zvnutra (konst. hrubka)
module nadoba(sx, sy, sz, t = stena, d = dno, r = r_roh, c = skos) {
    zi = c + t*sqrt(2) - t;     // vnutorny zlom pri dne
    xi = c + t*sqrt(2) - d;
    difference() {
        kvader_skos(sx, sy, sz, r, c);
        hull() { plat(sx, sy, r, d, max(xi, t)); plat(sx, sy, r, max(zi, d), t, sz); }
    }
}

// vnutorny trojuholnikovy lem pod hornou hranou (45/45, bez podpier)
module lem(sx, sy, sz, l = 4, t = stena, r = r_roh) {
    difference() {
        plat(sx, sy, r, sz - 2*l, t, 2*l);
        hull() { plat(sx, sy, r, sz - 2*l - e, t); plat(sx, sy, r, sz - l, t + l); }
        hull() { plat(sx, sy, r, sz - l, t + l);   plat(sx, sy, r, sz, t, 1); }
    }
}

// zvisla diera pre skrutku (d = priemer zavitu), s volitelnou hlavou
module diera_skrutka(d = 3, h = 20, hlava_d = 0, hlava_h = 0) {
    cylinder(d = d + (tryska <= 0.4 ? 0.3 : 0.4), h = h);
    if (hlava_d > 0) translate([0, 0, h - hlava_h]) cylinder(d = hlava_d + 0.4, h = hlava_h + e);
}

// otvor pre zalisovaciu maticu (heat-set insert)
module diera_insert(d = 4.0, hlbka_v = 6) { cylinder(d = d, h = hlbka_v + e); }

// sestrana matica do vyrezu (s = rozmer cez hrany)
module diera_matica(s = 5.5, h = 2.4) {
    cylinder(d = (s + 0.2) / cos(30), h = h, $fn = 6);
}

// =====================================================================
//  DIEL – sem pis konkretny navrh
// =====================================================================
module diel() {
    difference() {
        union() {
            nadoba(sirka, hlbka, vyska);
            lem(sirka, hlbka, vyska);
        }
        okraj = r_roh + 4;
        z0 = dno + skos + 6;
        Vm = vyska - z0 - 12;
        if (mriezka_steny && Vm > 20) {
            translate([0, hlbka + 1, 0]) rotate([90, 0, 0]) linear_extrude(hlbka + 2)
                translate([okraj, z0]) mriezka(sirka - 2*okraj, Vm, 20, 40, 2*rebro);
            translate([-1, 0, 0]) rotate([90, 0, 90]) linear_extrude(sirka + 2)
                translate([okraj, z0]) mriezka(hlbka - 2*okraj, Vm, 20, 40, 2*rebro);
        }
        if (mriezka_dno)
            translate([okraj + 4, okraj + 4, -1]) linear_extrude(dno + 2)
                mriezka(sirka - 2*okraj - 8, hlbka - 2*okraj - 8, 20, 40, 2*rebro);
    }
}

diel();
