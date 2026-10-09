*!!!!!!!!!EU EXPORT BAN!!!!!!
*current sets: regions (US, EU, OECD (-EU countries in OECD and US), Non-OECD(essentially row now?)), aluminum type (primary or secondary)
**may further complicate the regions set, Certainly add canada next (next situation is US Tariffs)
*will have to add time dimension, this is another set? 
*****NEXT STEPS: FIND more ACCURATE DATA, ADD CANADA, US TARIFFS******

set r /USA, EU, OECD, N_OECD/;
set al /primary, secondary/;

*parameters = essentially cost curves, !!!!!!!!FIND BETTER NUMBERS!!!!! - currently using rough estimated numbers from AI 
*prices USD/metric ton , qty = metric tons 
parameter 
*!!!!!!!!!!!!!!!!Prices for Importers need to be higher than the respective exporters!!!!!!!!!!!!!!!! 
pbar(r,al) /USA.primary 5500, USA.secondary 3100, EU.primary 3700, EU.secondary 3300, OECD.primary 3550, OECD.secondary 3100, N_OECD.primary 3150, N_OECD.secondary 3500/,
*qty supplied aluminum USA and ROW 
qbar_s(r,al) /USA.primary 700000, USA.secondary 5000000, EU.primary 3000000, EU.secondary 6900000, OECD.primary 7300000, OECD.secondary 5300000, N_OECD.primary 62000000, N_OECD.secondary 12800000/,
*qty demanded aluminum USA and ROW
qbar_d(r,al) /USA.primary 3500000, USA.secondary 3300000, EU.primary 7500000, EU.secondary 6200000, OECD.primary 4500000, OECD.secondary 4500000, N_OECD.primary 57500000, N_OECD.secondary 16000000/,
**!!!!!change for at least primary and secondary for now!!!!
*elasticity of supply
e_s(r,al) /USA.primary 0.4, USA.secondary 0.2, EU.primary 0.4, EU.secondary 0.2, OECD.primary 0.4, OECD.secondary 0.2, N_OECD.primary 0.4, N_OECD.secondary 0.2/,
*elasticity of demand 
e_d(r,al) /USA.primary -0.2, USA.secondary -0.5, EU.primary -0.2, EU.secondary -0.5, OECD.primary -0.2, OECD.secondary -0.5, N_OECD.primary -0.2, N_OECD.secondary -0.5/;

*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
parameter a(r,al),b(r,al),c(r,al),d(r,al); 

b(r,al) = pbar(r,al) / (e_d(r,al) * qbar_d(r,al));
a(r,al) = pbar(r,al) - b(r,al) * qbar_d(r,al);
d(r,al) = pbar(r,al) / (e_s(r,al) * qbar_s(r,al));
c(r,al) = pbar(r,al) - d(r,al) * qbar_s(r,al);

alias(r,rr); 
*t will essentially be the cost of transportation
parameter t(r,rr,al);


t(r,rr,al) = abs(pbar(rr,al) - pbar(r,al)) ; 


positive variable Qd(r,al), Qs(r,al);

* variable X(r,al) "exports"; 
variable W "total welfare";

*market clearing conditions 
equation objfn; 



alias(r,rr) ; 
positive variable ship(r,rr,al) ; 
*no exports of secondary aluminum from EU to non-OECD
ship.fx('EU', 'N_OECD', 'secondary') = 0;

objfn.. W =e=  
   sum((r,al), a(r,al) * Qd(r,al) + b(r,al) * Qd(r,al) *Qd(r,al) /2 
   - c(r,al) * Qs(r,al) - d(r,al) *Qs(r,al) * Qs(r,al) / 2 ) 
   - sum((r,rr,al), t(r,rr,al) * ship(r,rr,al));

equation market_clearing_r(r,al) ; 
market_clearing_r(r,al)..  Qd(r,al) + sum(rr$(not sameas(r,rr)), ship(r,rr,al)) =e= Qs(r,al) + sum(rr$(not sameas(r,rr)), ship(rr,r,al));

model simple /all/; 

solve simple using QCP maximizing W;

*$exit

parameter rep;

rep("EU secondary ban to non-oecd", "Qd", r, al) = Qd.l(r,al);
rep("EU secondary ban to non-oecd", "Qs", r, al) = Qs.l(r,al);
rep("EU secondary ban to non-oecd", "P", r, al) = market_clearing_r.m(r,al);

execute_unload "eu_export_ban.gdx" ;


