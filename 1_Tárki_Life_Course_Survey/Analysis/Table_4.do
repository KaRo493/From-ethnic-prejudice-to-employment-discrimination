cd c:/kolloj/becker/SF

log using Table_4.log,replace
use y1.dta,clear
set more off

*Principal component analysis with variables (df5*) measuring full agreement with positive and negative statements on Roma
*The sample contains those answering all 14 questions 

factor df5a-df5n if roma==0, pcf factors(2)
rotate
cap drop f1 f2
predict f1 f2
lab var f1 "First principal component: negative statements"
lab var f2 "Second principal component: positive statements"

*Descriptives for vars in the first PC
d df5b df5d df5f df5g df5k df5m df5n
sum df5b df5d df5g df5k df5m df5n if roma==0

*Regressions with quintiles (of districts) by Jobbik support
	*No controls
for var df5b df5d df5f df5g df5k df5m df5n : regress X i.rJ1kat if roma==0 [aw=suly], rob
	*Controls
for var df5b df5d df5f df5g df5k df5m df5n : regress X i.rJ1kat o lany i.kor i.anya if roma==0 [aw=suly], rob


log close
set more on