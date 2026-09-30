*Trying out simplest model for project 
*current set: regions
*will have to complicate regions sets to add more countries 
*will have to add time dimension, will also be a new set 
*NEW SET SHOULD BE ALUMINUM PRIMARY OR SECONDARY: set al /primary, secondary/;

set r /USA, ROW/;

*parameters = essentially cost curves, FIND BETTER NUMBERS - currently using rough estimated numbers from AI 
*prices USD/metric ton , qty = metric tons , currently total aluminum (primary + secondary) 
parameter 
*price of aluminum USA and ROW 
pbar(r) /USA 2855, ROW 2420/,
*qty supplied aluminum USA and ROW
qbar_s(r) /USA 2236000, ROW 96000000/,
*qty demanded aluminum USA and ROW
qbar_d(r) /USA 5830000, ROW 92406000/,
*elasticity of supply generally -- this will have to break out for primary secondary, different for each country 
e_s /0.4/,
*elasticity of demand generally -- ^^
e_d /-0.4/;

*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
*will have to break out for primary and secondary aluminun and include the different elasticities for each country
parameter a(r),b(r),c(r),d(r); 

b(r) = pbar(r) / (e_d * qbar_d(r));
a(r) = pbar(r) - b(r) * qbar_d(r);
d(r) = pbar(r) / (e_s * qbar_s(r));
c(r) = pbar(r) - d(r) * qbar_s(r);

*t will essentially be the cost of transportation/logistics? 
scalar t ;
t = pbar('ROW') - pbar('USA');

*varibales - will have to have more specefic to primary and secondary
positive variable Qd(r), Qs(r);
positive variable X "exports"; 
variable W "total welfare, target of optimization";

*will have to have market clearing for different countries and primary/secondary once added 
*also will have to add different constrains ie EU restiricitions on secondary exports once 2027....
equation objfn, market_clearing_USA, market_clearing_ROW, trade_balance;

objfn.. W =e=  
   sum(r, a(r) * Qd(r) + b(r) * Qd(r) *Qd(r) /2 - c(r) * Qs(r) - d(r) *Qs(r) * Qs(r) / 2 ) - t * X;

market_clearing_USA.. Qd('USA') + X =e= Qs('USA');
market_clearing_ROW.. Qd('ROW') =e= Qs('ROW') + X;

model simple /all/; 

solve simple using QCP maximizing W;
parameter rep ; 
rep ("BAU", "Qd",r) = Qd.l(r);
rep("BAU", "Qs",r) = Qs.l(r);
rep("BAU", "P", "USA") = market_clearing_USA.m;
rep("BAU", "P", "ROW") = market_clearing_ROW.m;

execute_unload "alldata_simple.gdx" ;


*now converting to MPC i can add the tariff stuff 