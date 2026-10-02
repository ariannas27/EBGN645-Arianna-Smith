*Trying out simplest model for project 
*current sets: regions (US and RoW), aluminum type (primary or secondary)
*will have to complicate regions sets to add more countries 
*will have to add time dimension, will also be a new set?
*****NEXT STEPS: FIND ACCURATE DATA, ADD CANADA, ADD A SHOCK******

set r /USA, ROW/;
set al /primary, secondary/;

*parameters = essentially cost curves, FIND BETTER NUMBERS - currently using rough estimated numbers from AI 
*prices USD/metric ton , qty = metric tons , currently total aluminum (primary + secondary) 
parameter 
****NUMBERS ARE PRETTY RANDOM NEED TO SEARCH FOR BETTER DATA"
*price of aluminum USA and ROW 
pbar(r,al) /USA.primary 2855, USA.secondary 100, ROW.primary 100, ROW.secondary 2420/,
*qty supplied aluminum USA and ROW 
qbar_s(r,al) /USA.primary 2236000, USA.secondary 100, ROW.primary 96000000, ROW.secondary 100/,
*qty demanded aluminum USA and ROW
qbar_d(r,al) /USA.primary 5830000, USA.secondary 100, ROW.primary 92406000, ROW.secondary 100/,
**should break out elasticities more or keep as just supply and demand generally? 
*elasticity of supply generally 
e_s /0.4/
*elasticity of demand generally 
e_d /-0.4/;

*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
*will have to break out for primary and secondary aluminun and include the different elasticities for each country
parameter a(r,al),b(r,al),c(r,al),d(r,al); 

*is this right?
b(r,al) = pbar(r,al) / (e_d * qbar_d(r,al));
a(r,al) = pbar(r,al) - b(r,al) * qbar_d(r,al);
d(r,al) = pbar(r,al) / (e_s * qbar_s(r,al));
c(r,al) = pbar(r,al) - d(r,al) * qbar_s(r,al);

*t will essentially be the cost of transportation/logistics?
parameter t(al) ;
*!!! here you'll want to make sure that the prices for primary in ROW > USA, and vice versa for secondary
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


