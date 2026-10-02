*Trying out simplest model for project 
*will have to complicate regions sets to add more countries 
**HERE SET OF REGIONS = EU, OECD, NON-OECD
*will have to add time dimension, will also be a new set 
*NEW SET SHOULD BE ALUMINUM PRIMARY OR SECONDARY: set al /primary, secondary/;

set r /EU, OECD, NON-OECD/;

*parameters = essentially cost curves, FILL IN NUMBERS
*prices USD/metric ton , qty = metric tons , currently total aluminum (primary + secondary) 
***NEED TO MAKE SET FOR PRIMARY AND SECONDAY, first do OECD and non OECD
parameter 
*price of aluminum USA and ROW 
pbar(r) /EU 0, OECD 0, NON-OECD 0/,
*qty supplied aluminum USA and ROW
qbar_s(r) /EU 0, OECD 0, NON-OECD 0/,
*qty demanded aluminum USA and ROW
qbar_d(r) /EU 0, OECD 0, NON-OECD 0/,
*elasticity of supply generally -- this will have to break out for primary secondary, different for each country 
e_s /0.4/,
*elasticity of demand generally -- ^^
e_d /-0.4/;
**seperate out e_d and e_s for primary and secondary, BY REGION ALSO?

*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
*will have to break out for primary and secondary aluminun and include the different elasticities for each country
parameter a(r),b(r),c(r),d(r); 

b(r) = pbar(r) / (e_d * qbar_d(r));
a(r) = pbar(r) - b(r) * qbar_d(r);
d(r) = pbar(r) / (e_s * qbar_s(r));
c(r) = pbar(r) - d(r) * qbar_s(r);

*t will essentially be the cost of transportation/logistics? 
*right now only EU can export out 
scalar t ;
t = pbar('?') - pbar('EU');

*varibales - will have to have more specefic to primary and secondary
positive variable Qd(r), Qs(r);
positive variable X "exports"; 
variable W "total welfare, target of optimization";

*will have to have market clearing for primary/secondary once added?
*also will have to add different constrains ie EU restiricitions on secondary exports once 2027....
equation objfn, market_clearing_EU, market_clearing_OECD, market_clearing_NON-OECD, trade_balance;

objfn.. W =e=  
   sum(r, a(r) * Qd(r) + b(r) * Qd(r) *Qd(r) /2 - c(r) * Qs(r) - d(r) *Qs(r) * Qs(r) / 2 ) - t * X;


market_clearing_EU.. Qd('EU') + X =e= Qs('EU');
market_clearing_OECD.. Qd('OECD') =e= Qs('OECD') + X;
market_clearing_NON-OECD.. Qd('NON-OECD') =e= Qs('NON-OECD') + X;

model simple /all/; 

solve simple using QCP maximizing W;
parameter rep ; 
rep ("BAU", "Qd",r) = Qd.l(r);
rep("BAU", "Qs",r) = Qs.l(r);
rep("BAU", "P", "EU") = market_clearing_EU.m;
rep("BAU", "P", "OECD") = market_clearing_OECD.m;
rep("BAU", "P", "NON-OECD") = market_clearing_NON-OECD.m;

execute_unload "alldata_simple.gdx" ;


*now converting to MPC i can add the tariff stuff 