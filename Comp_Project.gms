
*current sets: regions (US, EU, OECD (-EU countries in OECD and US), Non-OECD(essentially row now?)), aluminum type (primary or secondary)
**may further complicate the regions set, Certainly add canada next (next situation is US Tariffs)
*will have to add time dimension, this is another set? 
*****NEXT STEPS: FIND ACCURATE DATA, EU EXPORT BAN, ADD CANADA, US TARIFFS******

set r /USA, EU, OECD, N_OECD/;
set al /primary, secondary/;

*parameters = essentially cost curves, FIND BETTER NUMBERS - currently using rough estimated numbers from AI 
*prices USD/metric ton , qty = metric tons , currently total aluminum (primary + secondary) 
parameter 
****NUMBERS ARE PRETTY RANDOM NEED TO SEARCH FOR BETTER DATA
*!!!!!!!!!!!!!!!!price of aluminum- Prices for Importers need to be higher than the exporters!!!!!!!!!!!!!!!! 
pbar(r,al) /USA.primary 2855, USA.secondary 100, EU.primary 100, EU.secondary 2420, OECD.primary 100, OECD.secondary 2420, N_OECD.primary 100, N_OECD.secondary 2420/,
*qty supplied aluminum USA and ROW 
qbar_s(r,al) /USA.primary 2236000, USA.secondary 100, EU.primary 96000000, EU.secondary 100, OECD.primary 96000000, OECD.secondary 100, N_OECD.primary 96000000, N_OECD.secondary 100/,
*qty demanded aluminum USA and ROW
qbar_d(r,al) /USA.primary 5830000, USA.secondary 100, EU.primary 92406000, EU.secondary 100, OECD.primary 100, OECD.secondary 100, N_OECD.primary 100, N_OECD.secondary 100/,
**!!!!!if issue w elasticity go back to generally for now - not broken out to primary and secondary/regions  
*elasticity of supply
e_s(r,al) /USA.primary 0.4, USA.secondary 0.4, EU.primary 0.4, EU.secondary 0.4, OECD.primary 0.4, OECD.secondary 0.4, N_OECD.primary 0.4, N_OECD.secondary 0.4/;
*elasticity of demand for primary & secondary 
e_d(r,al) /USA.primary -0.4, USA.secondary -0.4, EU.primary -0.4, EU.secondary -0.4, OECD.primary -0.4, OECD.secondary -0.4, N_OECD.primary -0.4, N_OECD.secondary -0.4/;

*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
parameter a(r,al),b(r,al),c(r,al),d(r,al); 

b(r,al) = pbar(r,al) / (e_d(r,al) * qbar_d(r,al));
a(r,al) = pbar(r,al) - b(r,al) * qbar_d(r,al);
d(r,al) = pbar(r,al) / (e_s(r,al) * qbar_s(r,al));
c(r,al) = pbar(r,al) - d(r,al) * qbar_s(r,al);

*t will essentially be the cost of transportation/logistics?
parameter t(al) ;
*!!! here you'll want to make sure that the prices for primary in ROW > USA, and vice versa for secondary!!!!
t("primary") = pbar('ROW',"primary") - pbar('USA',"primary");
t("secondary") = pbar('USA',"secondary") - pbar('ROW',"secondary");


*varibales - will have to have more specefic to primary and secondary
positive variable Qd(r,al), Qs(r,al);
positive variable X(al) "exports"; 
variable W "total welfare";

*will have to have market clearing for different countries and primary/secondary once added 
*also will have to add different constrains ie EU restiricitions on secondary exports once 2027....
equation objfn, market_clearing_USA, market_clearing_ROW;


objfn.. W =e=  
   sum((r,al), a(r,al) * Qd(r,al) + b(r,al) * Qd(r,al) *Qd(r,al) /2 
   - c(r,al) * Qs(r,al) - d(r,al) *Qs(r,al) * Qs(r,al) / 2 ) 
   - sum(al, t(al) * X(al));

market_clearing_USA(al).. Qd('USA',al) + X(al)$sameas(al,"primary") =e= Qs('USA',al) + X(al)$sameas(al,"secondary");
market_clearing_ROW(al).. Qd('ROW',al) + X(al)$sameas(al,"secondary") =e= Qs('ROW',al) + X(al)$sameas(al,"primary");

model simple /all/; 

solve simple using QCP maximizing W;

$exit
parameter rep ; 
rep ("BAU", "Qd",r) = Qd.l(r);
rep("BAU", "Qs",r) = Qs.l(r);
rep("BAU", "P", "USA") = market_clearing_USA.m;
rep("BAU", "P", "ROW") = market_clearing_ROW.m;

execute_unload "simple.gdx" ;


