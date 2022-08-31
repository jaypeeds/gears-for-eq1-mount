use <gearbox/gearbox.scad>

// drapeaux : 
//   base -> dessin de la base 
//   cover -> dessin du capot
//   gears --> dessin des engrenages
//   mirror_* -> génération config symétrique sur l'axe correspondant
//   printed_rods -> dessin des axes 
//   exit_cover -> sortie de l'axe entraîneur par le capot
//   exit_base -> sortie de l'axe entraîneur par la base
// 
// tnum1 : nombre de dents sur l'engrenage entaîneur
// tnum2 : nombre de dents sur l'engrenage entrainé
// cp : pas circulaire des engrenages en mm/dent
// pa : angle de pression = 20° (standard)
// holed* : diamètre de perçage des différents axes des étages
// h* : hauteur des engrenages
// a : angles relatifs des centres d'étage
// stage1_c1 : centre de l'engrenage entraîneur
   
// Reporter ensuite ces angles dans Fusion360
//entraineurs = [25, 25];
//entraines = [75, 125];
//L'axe 1 est sur roulement de phi 10 ext. 4 de hauteur

// pas circulaire = nombre de mm par dent
pascirc=[2,2,2];
// angle de pression standard de 20°
pressang=[20,20,20];
// Etage 0 = 5mm avec serrage par vis
// Etage 1 = 4mm avec engrenage de 10x4 sans serage par vis
// Etage 1 = 6mm avec serrage par vis
// Implicitement : Le pignon d'entrée et de sortie n'ont qu'un seul étage
// entrée : qu'un étage bas
// sortie : qu'un étage haut
// hpbase = [ entrée, étage 1, étage 2, ... étage n-1 ]
// hphaut = [ étage1, étage 2, ... étage n-1, sortie ]
hpbase = [ 15, 7.5]; hphaut = [ 7.5, 7.5];
// Percements Moteur, axe intermédiare, axe sortie
axbase = [5, 4, 6.5]; 
axhaut = [5, 4, 6.5];
// En gros au départ angles = [60, -40]
// C0 est en (0,0) c'est l'axe moteur
// L'angle (C1,C0,C2) est de 60° 
// L'angle (C0,C2,C1) est à -40° au départ
// Faire varier l'angle initial de -40° pour que le centre C2 soit en gros à y = 0
// C2 est l'axe de sortie vers la monture qui doit tourner à 4 trs/h.
// Les nombres de dents 25, 75, 125 donnent un rapport multiplicatif de 125/25 x 75x25 = 15
// Le moteur doit donc tourner à 4 x 15 = 60 trs/h = 1 tr/mn
// Après approximation par dichotomie, la valeur d'angle est :
angles = [60, -35.2645]; 
// Nombres de dents
entraineurs = [25,25];
entraines = [75,125];
// pourraient être calculés à partir des angles.
xcentre = [0, 24.57, 0];
ycentre = [0, 15.92, 54.9];

gb_gearbox(base=false, cover=false, gears=false,
    mirror_x=false, mirror_y=false,
    printed_rods=false,
    exit_base=true, exit_cover=true,
    tnum1=entraineurs, tnum2=entraines,
    cp=pascirc, pa=pressang,
    holed1=axbase, holed2=axhaut,
    h1=hpbase, h2=hphaut,
    a=angles, stage1_c1=[0,0],
    rot2=[0, 0, 0],
    h2_gap=1, bottom_gap=0, top_gap=1,
    base_points=[],
    cover_points=[],
    base_h=3, cover_h=3,
    columns=[],
    base_color=[0.8, 0.5, 0.9], cover_color=[0.5, 0.7, 0.9], gears_color=[1, 1, 0.4],
    print_error=0.1, $fn=100);


for (stage = [0:1] ) {
    centre = gb_find_stage_center2(stage, tnum1=entraineurs, tnum2=entraines,cp=pascirc, a=angles, stage1_c1=[0,0]);
    echo("Centre ", centre.x, centre.y);
}

$fn=100;

// Anneau de serrage par vis
ecrou_h = 2.5;
ecrou_k = 5.5;
g = 0;
base_dia = 20;
base_h = 10;
n = 3;
r = base_dia / 4.0;
vis_dia = 3;
axe_dia = 5;
roulmt_dia = 10;
roulmt_h = 4;

module dessin_etage(ndx = 0) {
    if (ndx == 0 || ndx == 2) { 
    union() {
        // lamage du roulement face supérieure
        difference () { 
            gb_gear(index=ndx, 
                tnum1=entraineurs, tnum2=entraines,
                cp=pascirc, pa=pressang,
                holed1=axbase, holed2=axhaut,
                h1=hpbase, h2=hphaut,
                rot2=[],
                print_error=0.1, $fn=100);
                hhaut = (ndx == 0) ? hpbase[ndx]: hphaut[ndx - 1];
                echo("hauteur pignon ", hhaut);
            translate([0, 0, hhaut - roulmt_h]) 
            cylinder(roulmt_h, d1=roulmt_dia, d2=roulmt_dia, false);
        }
        // Bague de montage avec écrous
        translate([0, 0, -base_h /2.0])
        difference() {
            translate([0,0,-base_h/2.0]) cylinder(base_h, d1=base_dia, d2=base_dia, true);
            union() {
                cylinder(base_h + 2, d1=axe_dia, d2=axe_dia, center=true);
                for (v = [1:n]) {
                    a = v * (360/n);
                    translate([r * sin(a), r * cos(a), 0]) {
                        rotate([0, 0, -a]) {
                            cube([ecrou_k, ecrou_h, base_dia / 2.0 + 2], true);
                            rotate([90, 0, 0]) translate ([0,0,-base_dia / 4.0]) 
                                cylinder(base_dia / 2.0 + 2, d1=vis_dia, d2=vis_dia, true);
                        }
                    }
                }
            }
        } 
    }
} else {
    // ndx = 1;
    // Sans ecrou, avec roulements
    translate([0, 0, hpbase[ndx]+ hpbase[ndx] ])
    rotate([0, 180, 0])
    difference() { 
        gb_gear(index=ndx, 
            tnum1=entraineurs, tnum2=entraines,
            cp=pascirc, pa=pressang,
            holed1=axbase, holed2=axhaut,
            h1=hpbase, h2=hphaut,
            rot2=[],
            print_error=0.1, $fn=100
            );
        // Union des deux lamages de roulement
        union() {
            cylinder(roulmt_h, d1=roulmt_dia, d2=roulmt_dia, false);
            cylinder(hpbase[ndx]+hphaut[ndx-1], d1=axbase[ndx], d2=axhaut[ndx], false);
            translate([0, 0, hpbase[ndx] + hphaut[ndx-1] - roulmt_h]) cylinder(roulmt_h, d1=roulmt_dia, d2=roulmt_dia, false);
       }
    }
  }
}

for (i = [0:2]) translate([xcentre[i], ycentre[i], 0]) { dessin_etage(i) ;}
        