*this is monopoly max profits vs social surplus maxing
scalar a /2/, b /-1/, c /0/, d /1/ ;
positive variable X ;
variable profit ;
variable social_surplus;
equation profit_max, social_surplus_max;

profit_max.. profit =e= (a+b*X) -c*X -d*X * X/2 ;

social_surplus_max.. social_surplus =e= (a+b*X) * X -c*X -d*X * X/2 ;
