
log using c:/kolloj/becker/lfs_panel.log, replace

*This one predicts the prob of Roma and non-Roma of working in a small firm cond on being employed
*Source LFS, age 15-60, sample: employed with the self-employed, asst family members,casual workers and PW participants excluded

set more off
cd c:/kolloj/mef

use alfs95, clear
keep if kor>14 & kor<61 & tanul==0
cap drop roma
gen roma=(etnikum1==2 | etnikum2==2)

cap drop small_10
gen small_10=((tedo>=2 & tedo<=10) | tedo==18)

cap drop small_50a
gen small_50a=((tedo>=2 & tedo<=12) | tedo==18)
cap drop small_50b
gen small_50b=((tedo>=2 & tedo<=12) | tedo==18 | tedo==17)

cap drop small_20a
gen small_20a=((tedo>=2 & tedo<=11) | tedo==18)
cap drop small_50b
gen small_20b=((tedo>=2 & tedo<=11) | tedo==18 | tedo==17)

cap drop kozmunkas
gen kozmunkas=(kozmunkas_1==1 | kozmunkas_2==1)
cap drop ferfi
gen ferfi=(sex_ksh==1)

cap drop zavaros
gen zavaros=(empltH==3 | empltH>6 | kozmunkas==1)
keep if tedo<. & zavaros==0
drop zavaros

keep jaras telep wave iyear imonth ferfi kor educH roma tedo small* kozmunkas weight kor csoe tanul
save roma_small_final.dta,replace


foreach k of numlist 96 97 101/114 {
use alfs`k'
keep if kor>14 & kor<61 & tanul==0
cap drop roma
gen roma=(etnikum1==2 | etnikum2==2)

cap drop small_10
gen small_10=((tedo>=2 & tedo<=10) | tedo==18)

cap drop small_50a
gen small_50a=((tedo>=2 & tedo<=12) | tedo==18)

cap drop small_50b
gen small_50b=((tedo>=2 & tedo<=12) | tedo==18 | tedo==17)

cap drop small_20a
gen small_20a=((tedo>=2 & tedo<=11) | tedo==18)
cap drop small_20b
gen small_20b=((tedo>=2 & tedo<=11) | tedo==18 | tedo==17)


cap drop kozmunkas
gen kozmunkas=(kozmunkas_1==1 | kozmunkas_2==1)
cap drop ferfi
gen ferfi=(sex_ksh==1)

cap drop zavaros
gen zavaros=(empltH==3 | empltH>6 | kozmunkas==1)
keep if tedo<. & zavaros==0
drop zavaros


keep jaras telep wave iyear imonth ferfi kor educH roma tedo small* kozmunkas weight kor csoe tanul
append using roma_small_final.dta 
save roma_small_final.dta,replace
}

tab educH,gen(edu)
gen kor2=kor*kor
lab var small_10 "2-10 workers"
lab var small_50a "2-50 workers, only exact data"
lab var small_50b "2-50 workers, prob>10 included"
lab var small_10 "2-10 workers"
lab var small_20a "2-20 workers, only exact data"
lab var small_20b "2-20 workers, prob>10 included"
compress
sort jaras
save c:/kolloj/becker/roma_small_final.dta,replace

cd c:/kolloj/becker

sort jaras
merge jaras using becker_jaras_Lali.dta
gen bpest=(_m==1)
drop _m
recode jaras 1/23=1
recode educH 4/5=4 6/7=5
lab def edu 1 "0-7" 2 "8" 3 Voc 4 Sec 5 High, modify
lab valu educH edu
compress
save, replace
save c:/kolloj/becker/lfs_panel.dta,replace
set more on

*Descriptives and estimation
set more off

tab wave roma
tab wave roma if educH<4
tab wave roma if educH<3
sum small_* [aw=weight]
sum small_* if educH<4 [aw=weight]
sum small_* if educH<3 [aw=weight]

*NO JARAS FE

*ALL SKILL LEVELS
for var small_10 small_20* small_50*: reg X roma ferfi kor kor2 i.educH i.iyea if educH<5 [aw=weight], rob
*VOCATIONAL, PRIMARY, OR LESS THAN PRIMARY
for var small_10 small_20* small_50*: reg X roma ferfi kor kor2 i.educH i.iyea if educH<4 [aw=weight], rob
*PRIMARY OR LESS THAN PRIMARY
for var small_10 small_20* small_50*: reg X roma ferfi kor kor2 i.educH i.iyea if educH<3 [aw=weight], rob

*JARAS FE

*ALL SKILL LEVELS
for var small_10 small_20* small_50*: areg X roma ferfi kor kor2 i.educH i.iyea if educH<5 [aw=weight], rob absorb(jaras)
*VOCATIONAL, PRIMARY, OR LESS THAN PRIMARY
for var small_10 small_20* small_50*: areg X roma ferfi kor kor2 i.educH i.iyea if educH<4 [aw=weight], rob absorb(jaras)
*PRIMARY OR LESS THAN PRIMARY
for var small_10 small_20* small_50*: areg X roma ferfi kor kor2 i.educH i.iyea if educH<3 [aw=weight], rob absorb(jaras)


set more on
log close

