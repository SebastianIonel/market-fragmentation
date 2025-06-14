// this file is used for unit testing

// load k4unit script
\l k4unit/k4unit.q

// load sample data
KUltf `:samples.csv;

// load application code
\l ../src/q/app.q

// update trade data from csv file
t: ("DSTFISFF"; enlist ",") 0: `:trade_test_data.csv

// run tests
KUrt[];

// print results KUTR
-1"Not ok";
show select from KUTR where not ok;

-1"Ok";
show select from KUTR where ok;


/ exit 0