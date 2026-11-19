*similar to primary/scrap, EU/OpD/RoW BUT now there is connection between aluminum materials-trying to make a secondary demand curve that is a function of primary and scrap

**indicies**
*regions 
set r /EU, OpD, RoW/;
*aluminum materials
set al /primary, scrap/;

**parameters** 
*prices = USD/metric ton , qtys = metric tons  

*!!!!!!!!!!!!!!!!Prices for Importers need to be higher than the respective exporters!!!!!!!!!!!!!!!!  
pbar(r,al) /EU.primary  2767.91,  EU.scrap  1745.37, OpD.primary 2783.96,  OpD.scrap 1706.82, RoW.primary 2419.00,  RoW.scrap 2000.00/,
*qty supplied
qbar_s(r,al) /EU.primary  1200000,  EU.scrap  5601192, OpD.primary 7898000,  OpD.scrap 6113480, RoW.primary 63702000, RoW.scrap 29985328/,
*qty demanded 
qbar_d(r,al) /EU.primary  7022482, EU.scrap 5000000, OpD.primary 8623521, OpD.scrap 4374909, RoW.primary 57153997, RoW.scrap 32325091/,
*elasticity of supply
e_s(r,al) /EU.primary  0.4,  EU.scrap  0.21, OpD.primary 0.4,  OpD.scrap 0.21, RoW.primary 0.4,  RoW.scrap 0.21/,
*elasticity of demand for only primary aluminum 
e_d_primary_only(r) /EU -0.2, OpD -0.2, RoW -0.2/,
*elasticity of demand for secondary aluminum (scrap+primary share)
e_d_secondary(r) /EU -0.5, OpD -0.5, RoW -0.5/;

**share = share of secondary demand that is satisfied by prumary aluminum   
*change this number to adjust this share for sensitivity   
scalar share /0.2/;

*creating below for 2 demand curves 
parameter 
*secondary demand (scrap+primary share) for each region 
dbar_secondary(r),
*amount of primary used in secondary demand (scrap+primary share) for each region
primary_used_in_dbar_secondary(r),
*primary demand (primary only) for each region 
dbar_primary(r);

*secondary demand calcuation(scrap = (1-share)*secondary -> seconday = scrap/(1-share))
dbar_secondary(r) = qbar_d(r,"scrap") / (1 - share);
*share of primary in secondary * secondary qty 
primary_used_in_dbar_secondary(r) = share*dbar_secondary(r);
*left over in only primary demand
dbar_primary(r) = qbar_d(r,"primary") - primary_used_in_dbar_secondary(r);

*buying scrap -> melting into secondary, this is balancer so scrap price + melting equals primary price for calibration
parameter melting_cost(r);
melting_cost(r) = pbar(r,"primary") - pbar(r,"scrap");


*currently based off of Pd = a + b*Qd, Ps = c + d*Qs, where a,b,c,d are parameters
*primary only demand intercept, primary only demand slope, secondary demand intercept, secondary demand slope
parameter a_p(r), b_p(r), a_sec(r), b_sec(r);

b_p(r) = pbar(r,"primary") / (e_d_primary_only(r) * dbar_primary(r));  
a_p(r) = pbar(r,"primary") - b_p(r) * dbar_primary(r); 
*having some issues with where this is going kind of stuck also realzing i may have made scrap price completly dependent on 



alias(r,rr) ;
