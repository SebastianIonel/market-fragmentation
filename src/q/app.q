////////////////////////////////
// Set up configuration data
////////////////////////////////
.cfg.filterrules:()!();
 .cfg.filterrules[`TM]:([venue:`LSE`BAT`CHI`TOR]
                       qualifier:(
                          `A`Auc`B`C`X`DARKTRADE`m;
                          `A`AUC`B`c`x`DARK;
                          `a`auc`b`c`x`DRK;
                          `A`Auc`B`C`X`DARKTRADE`m)
                        );
.cfg.filterrules[`OB]:([venue:`LSE`BAT`CHI`TOR]
                       qualifier:(`A`Auc`B`C`m;`A`AUC`B`c;`a`auc`b`c;`A`Auc`B`C`m));
.cfg.filterrules[`DRK]:([venue:`LSE`BAT`CHI`TOR]
                         qualifier:`DARKTRADE`DARK`DRK`DARKTRADE);

.cfg.symVenue:()!();
.cfg.symVenue[`BARCl.BS]:`BAT;
.cfg.symVenue[`BARCl.CHI]:`CHI;
.cfg.symVenue[`BARC.L]:`LSE;
.cfg.symVenue[`BARC.TQ]:`TOR;
.cfg.symVenue[`VODl.BS]:`BAT;
.cfg.symVenue[`VODl.CHI]:`CHI;
.cfg.symVenue[`VOD.L]:`LSE;
.cfg.symVenue[`VODl.TQ]:`TOR;

.cfg.multiMarketMap:([sym:`BARCl.BS`BARCl.CHI`BARC.L`BARC.TQ`VODl.BS`VODl.CHI`VOD.L`VODl.TQ] 
                     primarysym:`BARC.L`BARC.L`BARC.L`BARC.L`VOD.L`VOD.L`VOD.L`VOD.L;
                     venue:`BAT`CHI`LSE`TOR`BAT`CHI`LSE`TOR);

.cfg.multiMarketAgg:()!();
.cfg.multiMarketAgg[`volume]:"sum volume"
.cfg.multiMarketAgg[`vwap]:"wavg[volume;vwap]"
.cfg.multiMarketAgg[`range]: "(max maxprice)-(min minprice)"
.cfg.multiMarketAgg[`tickcount]:"sum tickcount"
.cfg.multiMarketAgg[`maxbid]:"max maxbid"
.cfg.multiMarketAgg[`minask]:"min minask"
.cfg.multiMarketAgg[`lastmidprice]:"((max lastbid)+(min lastask))%2"

.cfg.defaultParams:`startTime`endTime`filterRule`multiMarketRule!(08:30;16:30;`OB;`none);


////////////////////////////////
// Generate trade data
////////////////////////////////
\P 6

trade:([]date:`date$();sym:`$();time:`time$();price:`float$();size:`int$());

generateRandomPrices:{[s0;n] 
    dt:1.0%252;                          
    vol:.2;                              
    mu:.01;
    w: n?1000000;                   
    s:s0*exp (dt*mu - 0.5*vol*vol) + (sin .z.t * w) * vol * sqrt dt; 
    s
 }

n:1000;
`trade insert (n#2013.01.15;
               n?`BARCl.BS`BARCl.CHI`BARC.L`BARC.TQ; 
               08:00:00.000+28800*til n;
               generateRandomPrices[244;n]; 10*n?100000);

`trade insert (n#2013.01.15;
               n?`VODl.BS`VODl.CHI`VOD.L`VODl.TQ; 
               08:00:00.000+28800*til n;
               generateRandomPrices[161;n]; 
               10*n?100000);


/ add dummy qualifiers
trade:{update qualifier:1?.cfg.filterrules[`TM;.cfg.symVenue[sym]]`qualifier from x}each trade;

/ add dummy prevailing quotes 
spread:0.01;
update bid:price-0.5*spread, ask:price+0.5*spread from `trade;

`time xasc `trade;

////////////////////////////////
// Utilities
////////////////////////////////

.util.applyDefaultParams:{[params]
    .cfg.defaultParams,params
    };

.util.validTrade:{[sym;qualifier;rule] 
    venue:.cfg.symVenue[sym];
    validqualifiers:(.cfg.filterrules[rule]each venue)`qualifier;
    first each qualifier in' validqualifiers
    };

.util.extendSymsForMultiMarket:{[symList] 
    distinct raze {update origSymList:x from
                   select symList:sym from .cfg.multiMarketMap
                   where primarysym in .cfg.multiMarketMap[x]`primarysym
                   } each (),symList
    }

/ debug
params:`symList`date`startTime`endTime`columns!(
    `VOD.L`BARC.L; 
    2013.01.15;
    08:30;09:30;
    `volume`vwap`range`maxbid`minask`lastmidprice);

////////////////////////////////
// API Helpers
////////////////////////////////

buildParams:{[arg]
    params:`symList`date`startTime`endTime`columns!(
    `VOD.L`BARC.L; 
    2013.01.15;
    08:30;09:30;
    `volume`vwap`range`maxbid`minask`lastmidprice);
    args:" " vs arg;
    if[`none~`$args[0];
        params:@[params;`filterRule;:;`$args[0]];
    ];
    if[`multi~`$args[1];
        params:@[params;`multiMarketRule;:;`$args[1]];
    ];

    if[not ""~args[2];
        params:@[params;`startTime;:;"T"$args[2]];
    ];
    if[not ""~args[3];
        params:@[params;`endTime;:;"T"$args[3]];
    ];
    if[not ""~args[4];
        params:@[params;`date;:;"D"$args[4]];
    ];
    params
 };

////////////////////////////////
// Analytic functions
////////////////////////////////

getIntervalData:{[params]
    / -1"Running getIntervalData for params: ",-3!params;
    params:.util.applyDefaultParams[params]; 
    if[params[`multiMarketRule]~`multi;
        extended_syms:.util.extendSymsForMultiMarket[params`symList]; 
        params:@[params;`symList;:;extended_syms`symList];
    ];

    / check if date is valid
    if[not params[`date] in trade`date;
        / return {'sym': ['BARC.L', 'VOD.L'], 'volume': [0, 0], 'vwap': [0, 0], 'range': [0, 0], 'maxbid': [0, 163.02900411741146], 'minask': [0, 0], 'lastmidprice': [0, 0]}
        res:([]sym:params[`symList]; volume:0; vwap:0; range:0; maxbid:0; minask:0; lastmidprice:0);
        :(`sym,params[`columns])#0!res
    ];
  res:select volume:sum[size], vwap:wavg[size;price], range:max[price]-min[price], 
           maxprice:max price, minprice:min price,
           maxbid:max bid, minask:min ask,
           lastbid:last bid, lastask:last ask, lastmidprice:(last[bid]+last[ask])%2 
    by sym from trade
    where date=params[`date],
          sym in params[`symList],
          time within (params`startTime;params`endTime),
          .util.validTrade[sym;qualifier;params`filterRule];

  if[params[`multiMarketRule]~`multi;
    res:lj[res;`sym xkey select sym:symList, origSymList from extended_syms]; 
    byClause:(enlist`sym)!enlist`origSymList;
    aggClause:columns!-5!'.cfg.multiMarketAgg[columns:params`columns]; 
    res:0!?[res;();byClause;aggClause];
  ];
  :(`sym,params[`columns])#0!res
 };



getDistributionQualifier:{[params]
  params:.util.applyDefaultParams[params]; 
    if[params[`multiMarketRule]~`multi;
        extended_syms:.util.extendSymsForMultiMarket[params`symList]; 
        params:@[params;`symList;:;extended_syms`symList];
    ];
    
    / check if date is valid
    if[not params[`date] in trade`date;  
      res: select amount:0 by qualifier from trade;
      :select qualifier, amount from res
    ];
  res: select amount:count i by qualifier from trade
    where date=params[`date],
          time within (params`startTime;params`endTime);
   
   select qualifier, amount from res
 }

/ debug
a: getDistributionQualifier  params;
b:getIntervalData @[params;`filterRule;:;`TM];