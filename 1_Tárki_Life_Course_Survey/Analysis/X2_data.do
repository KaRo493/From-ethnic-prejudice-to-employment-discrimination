cd c:/kolloj/becker/SF

use y1_big.dta,clear
set more off

*Principal component analysis with variables (df5*) measuring full agreement with positive and negative statements on Roma
*The sample contains those answering all 14 questions 
keep df5a-df5n roma rJ1kat o lany kor anya suly
lab var anyaisk "Mother's educational attainment"
lab var o "NABC 2006 standardizwd reading score"
lab var rJ1kat "Quintiles of districts by Jobbik support"
lab var kor Age
lab var lany Girl
lab var roma Roma
lab var suly "Population weight (inverse of sampling probability)"
order roma lany kor o suly rJ1kat


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
*for var df5b df5d df5f df5g df5k df5m df5n : regress X i.rJ1kat if roma==0 [aw=suly], rob
	*Controls
for var df5b df5d df5f df5g df5k df5m df5n : regress X i.rJ1kat o lany i.kor i.anya if roma==0 [aw=suly], rob

save X2.dta,replace

set more on