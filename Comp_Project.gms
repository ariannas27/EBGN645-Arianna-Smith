
*current sets: regions (US, EU, OECD (-EU countries in OECD and US), Non-OECD(essentially row now?)), aluminum type (primary or secondary)
**may further complicate the regions set, Certainly add canada next (next situation is US Tariffs)
*will have to add time dimension, this is another set? 
*****NEXT STEPS: FIND ACCURATE DATA, EU EXPORT BAN, ADD CANADA, US TARIFFS******

set r /USA, EU, OECD, N_OECD/;
set al /primary, secondary/;

*parameters = essentially cost curves, !!!!!!!!FIND BETTER NUMBERS!!!!! - currently using rough estimated numbers from AI 
*prices USD/metric ton , qty = metric tons , currently total aluminum (primary + secondary) 
parameter 
****NUMBERS ARE PRETTY RANDOM NEED TO SEARCH FOR BETTER DATA**************
*!!!!!!!!!!!!!!!!Prices for Importers need to be higher than the respective exporters!!!!!!!!!!!!!!!! 
pbar(r,al) /USA.primary 5500, USA.secondary 3100, EU.primary 3700, EU.secondary 3300, OECD.primary 3550, OECD.secondary 3100, N_OECD.primary 3150, N_OECD.secondary 3500/,
*qty supplied aluminum USA and ROW 
qbar_s(r,al) /USA.primary 700000, USA.secondary 5000000, EU.primary 3000000, EU.secondary 6900000, OECD.primary 7300000, OECD.secondary 5300000, N_OECD.primary 62000000, N_OECD.secondary 12800000/,
*qty demanded aluminum USA and ROW
qbar_d(r,al) /USA.primary 3500000, USA.secondary 3300000, EU.primary 7500000, EU.secondary 6200000, OECD.primary 4500000, OECD.secondary 4500000, N_OECD.primary 57500000, N_OECD.secondary 16000000/,
**!!!!!change for at least primary and secondary for now!!!!
*elasticity of supply
e_s(r,al) /USA.primary 0.4, USA.secondary 0.4, EU.primary 0.4, EU.secondary 0.4, OECD.primary 0.4, OECD.secondary 0.4, N_OECD.primary 0.4, N_OECD.secondary 0.4/,
*elasticity of demand 
e_d(r,al) /USA.primary -0.4, USA.secondary -0.4, EU.primary -0.4, EU.secondary -0.4, OECD.primary -0.4, OECD.secondary -0.4, N_OECD.primary -0.4, N_OECD.secondary -0.4/;

*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
parameter a(r,al),b(r,al),c(r,al),d(r,al); 

b(r,al) = pbar(r,al) / (e_d(r,al) * qbar_d(r,al));
a(r,al) = pbar(r,al) - b(r,al) * qbar_d(r,al);
d(r,al) = pbar(r,al) / (e_s(r,al) * qbar_s(r,al));
c(r,al) = pbar(r,al) - d(r,al) * qbar_s(r,al);


*t will essentially be the cost of transportation
parameter t(r,al);
*transport of primary from OECD to USA
t("OECD", "primary") = pbar("USA", "primary") - pbar("OECD", "primary");
*transport of primary from non-oecd to EU 
t("N_OECD", "primary") = pbar("EU", "primary") - pbar("N_OECD", "primary");
*transport of secondary from US to non OECD 
t("USA", "secondary") = pbar("N_OECD", "secondary") - pbar("USA", "secondary");
*transport of secondary from EU to non-OECD 
t("EU", "secondary") = pbar("N_OECD", "secondary") - pbar("EU", "secondary");
*transport of secondary from OECD to non-OECD 
t("OECD", "secondary") = pbar("N_OECD", "secondary") - pbar("OECD", "secondary");

*varibales - will have to have more specefic to primary and secondary
positive variable Qd(r,al), Qs(r,al);
**!!!!needs to be for region too!!!!
positive variable X(r,al) "exports"; 
variable W "total welfare";

*market clearing conditions 
equation objfn, market_clearing_USA, market_clearing_EU, market_clearing_OECD, market_clearing_N_OECD;


objfn.. W =e=  
   sum((r,al), a(r,al) * Qd(r,al) + b(r,al) * Qd(r,al) *Qd(r,al) /2 
   - c(r,al) * Qs(r,al) - d(r,al) *Qs(r,al) * Qs(r,al) / 2 ) 
   - sum((r,al), t(r,al) * X(r,al));
** market clearning for each region: OECD exports primary to US, Non-OECD exports primary to EU, US EU and OECD export secondary to non-oecd 
*US imports primary, export secondary 
market_clearing_USA(al).. Qd('USA',al) + X('USA',al)$sameas(al,"secondary") =e= Qs('USA',al) + X('USA',al)$sameas(al,"primary");
**EU imports primary, exports secondary 
market_clearing_EU(al).. Qd('EU',al) + X('EU',al)$sameas(al,"secondary") =e= Qs('EU',al) + X('EU',al)$sameas(al,"primary");
*OECD exports primary and secondary
market_clearing_OECD(al).. Qd('OECD',al) + X('OECD',al) =e= Qs('OECD',al);
*non oecd exports primary and imports secondary 
market_clearing_N_OECD(al).. Qd('N_OECD',al) + X('N_OECD',al)$sameas(al,"primary") =e= Qs('N_OECD',al) + X('N_OECD',al)$sameas(al,"secondary");



model simple /all/; 

solve simple using QCP maximizing W;

*$exit

parameter rep;

rep("BAU", "Qd", r, al) = Qd.l(r,al);
rep("BAU", "Qs", r, al) = Qs.l(r,al);
rep("BAU", "P", "USA", al) = market_clearing_USA.m(al);
rep("BAU", "P", "EU", al) = market_clearing_EU.m(al);
rep("BAU", "P", "OECD", al) = market_clearing_OECD.m(al);
rep("BAU", "P", "N_OECD", al) = market_clearing_N_OECD.m(al);

execute_unload "simple.gdx" ;


