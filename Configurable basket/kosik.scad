// =====================================================================
//  Parametricky kosik do skrine – diamantova mriezka
//  Bambu Lab H2C, PLA, tryska 0.6 mm, vrstva 0.3 mm
//  Slicer: wall loops 4, bottom shells 7, podpery nie
//
//  Menis iba SIRKA / HLBKA / VYSKA. Vsetko ostatne sa dopocita.
//  Hrubka steny, sirka rebier mriezky a velkost oka su konstantne –
//  pri vacsom kosiku pribudnu oka, nezvacsia sa.
// =====================================================================

/* [Rozmery – vonkajsie, mm] */
sirka = 250;   // X – predna stena (s uchytom)
hlbka = 300;   // Y – do skrine
vyska = 250;   // Z – celkova vyska stohu (pri stoh_kusov = 1 vyska kosika)
stoh_kusov = 1; // [1, 2, 3] kolko kosikov na sebe ma dat spolu vyska

/* [Volby] */
uchyt        = true;   // vyrez na prsty v prednej aj zadnej stene
steny_mriezka = true;  // dierkovane steny (vypnute = plne steny)
dno_mriezka  = true;   // dierkovane dno (setri ~100 g PLA a cas)
polovicne_oka_steny = true; // polovicne oka na stenach: spodok a boky (hore nie – strop)
polovicne_oka_dno   = true; // polovicne oka na dne: vsetky 4 strany

/* [Velkost oka] */
oko_x      = 30;         // cielova roztec ok vodorovne (mm)
oko_y      = 60;         // cielova roztec ok zvisle – pomer 1:2
                         // -> hrany ~27 st. od zvislice, bez podpier;
                         // 30/60 = o ~20 % menej materialu ako 24/48


/* [Konstanty – netreba menit] */
// 4 linky (wall loops 2 na kazdy obrys) pri linke 0.62 a vrstve 0.3 ~ 2.3 mm
stena      = 2.3;
// rebro = 2 x stena = 8 liniek -> v sliceri WALL LOOPS = 4,
// rebro vyplnia len perimetre z oboch dier = rychle a pevne
rebro      = 2 * stena;
dno        = 2.1;        // 7 vrstiev po 0.3
zaoblenie_oka = 1.2;     // zaoblenie rohov diamantu
r_roh      = 8;          // vonkajsi polomer rohov kosika
okraj_roh  = r_roh + 4;  // plny zvisly stlpik v rohu
pas_dole   = 8;          // plny pas nad dnom
lem        = 5;          // vnutorny trojuholnikovy lem hore, 45°/45°
pas_hore   = 2*lem + 6;  // plny pas pod hornou hranou (obsahuje lem)
skos_dole  = 5;          // 45° skosenie spodnej hrany (zvonka)
okraj_dno  = r_roh + 10; // plny okraj dna
uchyt_s    = min(90, sirka * 0.4);  // sirka vyrezu na prsty
uchyt_h    = 28;                    // hlbka vyrezu od hornej hrany
uchyt_r    = 8;                     // zaoblenie prechodu vyrezu do hornej hrany

$fn = 48;
e   = 0.01;

// ---------------------------------------------------------------------
module zaobleny_obdlznik(x, y, r) {
    r2 = max(min(r, x/2 - e, y/2 - e), e);
    translate([r2, r2]) offset(r = r2) square([x - 2*r2, y - 2*r2]);
}

// bocne a spodny vrchol zaobleny, horny ostry -> strop diery je spicka, bez previsu
module diamant(A, B, r) {
    union() {
        offset(r = r) offset(delta = -r)
            polygon([[A, 0], [0, B], [-A, 0], [0, -B]]);
        polygon([[A/2, B/2], [0, B], [-A/2, B/2]]);
    }
}

// Diamantova mriezka vyplnajuca obdlznik L x V (lavy dolny roh = 0,0).
// Pocet ok sa zaokruhli, roztec sa dopasuje presne na plochu.
// ex = [x1, x2, y1]: zona (napr. pod uchytom) – oko, ktore by do nej
// zasahovalo, sa vynecha cele (ziadne orezane oka = ziadne vodorovne stropy).
// polo = [vlavo, vpravo, dole, hore]: na ktorych okrajoch pridat polovicne oka.
// Polovicne oka su orezane o pol rebra od okraja plochy.
module mriezka(L, V, ex = undef, polo = [false, false, false, false]) {
    n  = max(1, round(L / oko_x));
    m  = max(1, round(V / oko_y));
    px = L / n;  py = V / m;
    P  = px / 2; Q  = py / 2;
    k  = sqrt(P*P + Q*Q);
    A  = P - rebro/2 * k / Q;   // polovicna sirka diery
    B  = Q - rebro/2 * k / P;   // polovicna vyska diery
    function volne(x, y) = is_undef(ex) ||
        x + A < ex[0] || x - A > ex[1] || y + B < ex[2];
    if (A > 1 && B > 1) {
        for (i = [0 : n-1], j = [0 : m-1])
            let (x = (i + .5) * px, y = (j + .5) * py)
                if (volne(x, y)) translate([x, y]) diamant(A, B, zaoblenie_oka);
        if (n > 1 && m > 1)
            for (i = [1 : n-1], j = [1 : m-1])
                let (x = i * px, y = j * py)
                    if (volne(x, y)) translate([x, y]) diamant(A, B, zaoblenie_oka);

        // polovicne (na rohoch stvrtinove) oka na okrajoch posunutej mriezky
        c = rebro / 2;
        if (polo[0] || polo[1] || polo[2] || polo[3])
            intersection() {
                translate([c, c]) square([L - 2*c, V - 2*c]);
                union()
                    for (i = [0 : n], j = [0 : m])
                        let (x  = i * px, y = j * py,
                             bx = (i == 0 && polo[0]) || (i == n && polo[1]),
                             by = (j == 0 && polo[2]) || (j == m && polo[3]),
                             ix = i > 0 && i < n,
                             iy = j > 0 && j < m)
                            if (((bx && (iy || by)) || (by && ix)) && volne(x, y))
                                translate([x, y]) diamant(A, B, zaoblenie_oka);
            }
    }
}

// ---------------------------------------------------------------------
// vnutorny "zlom" pri dne – rovnobezny so skosenim, hrubka = stena
// Stohovanie: spodne 45 st. skosenie horneho kosika lezi na hornej 45 st.
// ploche lemu dolneho kosika -> horny zapadne o (skos_dole - stena).
zapad = skos_dole - stena;
assert(zapad > 0 && zapad < lem, "skos_dole musi byt vacsi ako stena a mensi ako stena + lem");
h_kosika = (vyska + (stoh_kusov - 1) * zapad) / stoh_kusov;
echo(str("vyska kosika = ", h_kosika, " mm; stoh ", stoh_kusov, " ks = ",
         stoh_kusov * h_kosika - (stoh_kusov - 1) * zapad, " mm"));

zi = skos_dole + stena*sqrt(2) - stena;   // vyska, kde zacina zvisla vnutorna stena
xi = skos_dole + stena*sqrt(2) - dno;     // odsadenie vnutorneho okraja dna

polo_steny = polovicne_oka_steny ? [true, true, true, false] : [false, false, false, false];
polo_dno   = polovicne_oka_dno   ? [true, true, true, true]  : [false, false, false, false];

z0 = zi + pas_dole;             // zaciatok mriezky v stenach
Vm = h_kosika - pas_hore - z0;     // vyska mriezky

module vyrez_uchytu_2d() {      // v rovine steny: x pozdlz steny, y = z
    // "closing" (offset +r, potom -r) zaobli prechod vyrezu do hornej hrany
    offset(r = -uchyt_r) offset(delta = uchyt_r)
    union() {
        translate([sirka/2, h_kosika - uchyt_h + uchyt_s/4])
            hull() {
                for (s = [-1, 1])
                    translate([s * (uchyt_s/2 - uchyt_s/4), 0]) circle(r = uchyt_s/4);
                translate([-uchyt_s/2, 0]) square([uchyt_s, uchyt_h + 10]);
            }
        // pas nad hornou hranou, aby vznikli vnutorne rohy na zaoblenie
        translate([sirka/2 - uchyt_s/2 - 3*uchyt_r, h_kosika]) square([uchyt_s + 6*uchyt_r, 50]);
    }
}

module plat(z, ins, h = e) {   // tenka doska z obrysu odsadeneho o ins
    translate([ins, ins, z]) linear_extrude(h)
        zaobleny_obdlznik(sirka - 2*ins, hlbka - 2*ins, r_roh - ins);
}

module teleso() {
    difference() {
        // vonkajsok so skosenim dole
        hull() { plat(0, skos_dole); plat(skos_dole, 0, h_kosika - skos_dole); }
        // vnutro so skosenim rovnobeznym s vonkajsim
        hull() { plat(dno, xi); plat(zi, stena, h_kosika); }
    }
    // vnutorny trojuholnikovy lem: spodok 45° (bez podpier), vrch 45°
    difference() {
        plat(h_kosika - 2*lem, stena, 2*lem);
        hull() { plat(h_kosika - 2*lem - e, stena); plat(h_kosika - lem, stena + lem); }
        hull() { plat(h_kosika - lem, stena + lem); plat(h_kosika, stena, 1); }
    }
}

module kosik() {
    difference() {
        teleso();

        // predna + zadna stena (dlzka = sirka)
        if (steny_mriezka)
        translate([0, hlbka + 1, 0]) rotate([90, 0, 0])
            linear_extrude(hlbka + 2)
                translate([okraj_roh, z0])
                    mriezka(sirka - 2*okraj_roh, Vm,
                        uchyt ? [sirka/2 - uchyt_s/2 - uchyt_r - rebro - okraj_roh,
                                 sirka/2 + uchyt_s/2 + uchyt_r + rebro - okraj_roh,
                                 h_kosika - uchyt_h - 2*rebro - z0]
                              : undef,
                        polo_steny);

        // bocne steny (dlzka = hlbka)
        if (steny_mriezka)
        translate([-1, 0, 0]) rotate([90, 0, 90])
            linear_extrude(sirka + 2)
                translate([okraj_roh, z0]) mriezka(hlbka - 2*okraj_roh, Vm, undef, polo_steny);

        // vyrez na prsty
        if (uchyt)
            translate([0, hlbka + 1, 0]) rotate([90, 0, 0])
                linear_extrude(hlbka + 2) vyrez_uchytu_2d();

        // dno
        if (dno_mriezka)
            translate([okraj_dno, okraj_dno, -1])
                linear_extrude(dno + 2)
                    mriezka(sirka - 2*okraj_dno, hlbka - 2*okraj_dno, undef, polo_dno);
    }
}

kosik();
