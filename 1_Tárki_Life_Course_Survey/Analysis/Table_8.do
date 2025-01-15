cd c:/kolloj/becker/sf
log using Table_8.log,replace
use y1.dta,clear

set more off

*This one estimates the choice of Jobbik, and strong agreement with statement df5b: The problems of Gypsies would be solved if they finally started to work

regress df5b srch_roma srch_n o lany i.kor i.anya if roma==0 [aw=suly], rob
lincom srch_roma-srch_n
gen esample=e(sample)

regress jobbik srch_roma srch_n  o lany i.kor i.anya if roma==0 & esample [aw=suly], rob
lincom srch_roma-srch_n



set more on
log close
