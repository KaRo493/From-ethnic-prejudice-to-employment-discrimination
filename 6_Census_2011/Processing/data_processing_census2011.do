/*------------------------------------------------------------------------------ 

	Data Processing - 2011

------------------------------------------------------------------------------*/



clear all
set more off
cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"

global date "20240619"

***************************************************
* Dwellings
**************************************************

use "X:\INPUT_KSH\Nepszamlalas\MTA_altal_tisztitott_adatok\Nepszamlalas_tisztitott_20140224\2011\Lakas_2011_H.dta", clear

keep terul szlok cimssz ingasz ktip lat furdo_b wc_b vize_b lakov_b

gen wout_bathr = (furdo_b == 0)
gen wout_bathr_mis = (furdo_b == .)


gen wout_wc = (wc_b == 0)
gen wout_wc_mis = (wc_b == .)


gen home_runn_wat = (vize_b == 2)
gen wat_mis = (vize_b == .)
gen wout_runn_wat = (vize_b == 0)

gen low_status = (lakov_b == 10)
gen status_mis = (lakov_b == .)
gen vlow_status = (lakov_b == 11)


save  lakas_becker.dta, replace

***************************************************
* Individuals
***************************************************


*legfrissebb népszámlálásból frissítve: 2015.03.16-án
use "X:\INPUT_KSH\Nepszamlalas\MTA_altal_tisztitott_adatok\Nepszamlalas_tisztitott_2015_03_03\2011\Szemely_2011_uj_H.dta", clear

*sorszámok elkészítése
egen person_id = group(terul szlok cimssz szsor)

*nem intézeti
drop if jc_b == 5 | jc_b == 6

egen flat_id = group(terul szlok cimssz)
egen family_id = group(terul szlok cimssz hsoruj lcssor) if lcslas_b != .

*Budapestet egy járásba helyezem
replace jaras = 23 if jaras <= 23
label define Ljaras_2011 23 "Budapest", modify
lab val jaras Ljaras_2011

gen ksh4 = floor(terul/10)
merge m:1 ksh4 using tel_jaras175.dta, keepus(j_kod) keep(1 3) nogen
replace jaras = j_kod if jaras!=j_kod
drop j_kod

****************************
* ROMA variable
****************************


gen roma = 0
foreach i in 3 57 125 {
	replace roma = 1 if enemz ==  `i' | mnemz == `i' | ///
	eanye_b == `i' | manye_b == `i' | ecsbeny_b == `i'| mcsbeny_b == `i' 
}
lab var roma "Roma (wide def: any nat., language)"

gen roma_narrow = 0
foreach i in 3 57 125 {
	replace roma_narrow = 1 if enemz ==  `i' | mnemz == `i' 
}
lab var roma_narrow "Roma (narrow def: any nat.)"



*******************************
* Controls
*******************************

* age sq
gen kevsq = kev^2

* Education
gen educ = 0
replace educ = 1 if irelo < 8 //nincs 8 osztály
replace educ = 2 if irelo >= 8 & irelszH <= 2 | irelo >= 8 & irelszH == 4 //van 8 osztály és nincs szakmunkás
replace educ = 3 if irelszH == 3 //szakmunkás
replace educ = 4 if irelszH >= 5 & irelszH <= 8 //érettségi képzéssel, nélküle, felsföfokú szakképzéssel + nem bef. egyivel együtt!
replace educ = 5 if irelszH >= 9 & irelszH <= 10 //föisk + egyi
lab def educre 1 "under 8 grades" 2 "8 grades" 3 "vocational" ///
4 "maturity" 5 "tertiary"
lab val educ educre
tab educ, missing

cap drop u8
gen u8 = 0
replace u8 = 1 if educ == 1
lab var u8 "under 8 grades"

gen c8 = 0
replace c8 = 1 if educ == 2
lab var c8 "8 grades"

gen voc = 0
replace voc = 1 if educ == 3
lab var voc "vocational"

gen mat = 0
replace mat = 1 if educ == 4
lab var mat "maturity"

gen tert = 0
replace tert = 1 if educ == 5
lab var tert "tertiary"

gen low_educ1 = 0
gen low_educ2 = 0

*nincs missing
tab irelsz_b, missing
tab irelo, missing

replace low_educ1 = 1 if u8 == 1 | c8 == 1
replace low_educ2 = 1 if u8 == 1 | c8 == 1 | voc == 1
lab var low_educ1 "under or completed 8 grades"
lab var low_educ2 "under or completed 8 grades + vocational"


* Ill
gen lterm_ill = 0
replace lterm_ill = 1 if fmegb == 3
replace lterm_ill = 0 if fmegb == 0 | fmegb == 1 | fmegb == 2
lab var lterm_ill "long-term ill"
gen lterm_ill_disab_mis = (fmegb == .)

*disabled
gen disab = 0
replace disab = 1 if fmegb == 2
replace disab = 0 if fmegb == 0 | fmegb == 1 | fmegb == 3
lab var disab "disabled"

gen lterm_ill_disab = 0
replace lterm_ill_disab = 1 if fmegb == 1
replace lterm_ill_disab = 0 if fmegb == 0 | fmegb == 2 | fmegb == 3
lab var lterm_ill_disab "long-term ill and disabled"


gen wout_selfcare = (bakad1 == 1 | bakad2 == 1 | bakad3 == 1 | fakad1 == 1 | fakad2 == 1 | fakad3 == 1)
gsort flat_id -wout_selfcare 
by flat_id : replace wout_selfcare = wout_selfcare[1]
lab var wout_selfcare "can't take care of himself"
gen wout_selfcare_mis = (bakad1 == . & bakad2 == . & bakad3 == . & fakad1 == . & fakad2 == . & fakad3 == .)

***************
* Languages
**************

gen eng = 0
foreach i in 169 170 171 172 173 {
	foreach j in ebeny_b mbeny_b hbeny_b {
		replace eng = 1 if `j' == `i'
}
}
lab var eng "speaks English"

gen ger = 0
foreach j in ebeny_b mbeny_b hbeny_b {
replace ger = 1 if `j' == 7
}
lab var ger "speaks German"

* religion
gen relig = 1
replace relig = 0 if vallasv == 0 | vallasv == 888 | vallasv == .
lab var relig "religious"

*****************************
* Spouse
*****************************

cap drop marr_
gen marr_ = 0
replace marr_ = 1 if hazas == 1 | eltkap == 1

gen hazas_mis = (hazevH == . & hazhoH == . & hazas == 1)
tab hazas_mis, missing
gen eltars_mis = (eltev == . & eltho == . & eltkap == 1)
tab eltars_mis, missing

gsort flat_id -marr_ eltars_mis
replace eltev = eltev[_n-1] if flat_id == 3225457 & eltev == . & marr_ == 1
replace eltho = eltho[_n-1] if flat_id == 3225457 & eltho == . & marr_ == 1

gen kapcsev = .
gen kapcsho = .
replace kapcsev = hazevH if hazevH != . & hazas == 1
replace kapcsev = eltev if eltev != . & eltkap == 1
replace kapcsho = hazhoH if hazhoH != . & hazas == 1
replace kapcsho = eltho if eltho != . & eltkap == 1
replace kapcsev = max(hazevH , eltev) if hazevH != . & eltev != . & hazas == 1 & eltkap == 1

sort family_id
cap drop marriage_id
egen marriage_id = group(family_id marr_ kapcsev)

sort flat_id marriage_id 
gen egyuttel = 0
by flat_id: replace egyuttel = 1 if marriage_id == marriage_id[_n-1] | marriage_id == marriage_id[_n+1] 
tab egyuttel, missing
replace marriage_id = . if egyuttel == 0

gen married = ((hazas == 1 & egyuttel == 1) | ((eltkap == 1 & egyuttel == 1)))
lab var married "Married or has companion"

gen married_m = (married == 1 & neme == 1)
gen married_f = (married == 1 & neme == 2)

gen marr_irelo = .
gen marr_irelsz = .
gen marr_fminH = .
gen marr_beodb = .
replace beodb=. if gakt!=11

sort marriage_id
by marriage_id: replace marr_irelo = irelo[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_irelo = irelo[2] if marriage_id != . & person_id[2] != person_id[_n] ///
	&  marr_irelo == .

by marriage_id: replace marr_irelsz = irelsz_b[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_irelsz = irelsz_b[2] if marriage_id != . & person_id[2] != person_id[_n] ///
	&  marr_irelsz == .

by marriage_id: replace marr_fminH = fminH[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_fminH = fminH[2] if marriage_id != . & person_id[2] != person_id[_n] ///
	&  marr_fminH == .

by marriage_id: replace marr_beodb = beodb[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_beodb = beodb[2] if marriage_id != . & person_id[2] != person_id[_n] ///
	&  marr_beodb == .
	
cap drop marr_educ	
gen marr_educ = .

replace marr_educ = 1 if marr_irelo < 8 

replace marr_educ = 2 if marr_irelo >= 8 & marr_irelsz == 1 

replace marr_educ = 3 if marr_irelsz >= 2 & marr_irelsz <= 5

replace marr_educ = 4 if marr_irelsz >= 6 & marr_irelsz <= 10 

replace marr_educ = 5 if marr_irelsz >= 11 & marr_irelsz <= 15

replace marr_educ = 0 if marr_educ == .

lab def marr_educre 0 "not married/no companion" 1 "less than 8" 2 "8" 3 "vocational" ///
4 "maturity" 5 "tertiary"
lab val marr_educ marr_educre

*dummyk
gen marr_u8 = 0
replace marr_u8 = 1 if marr_educ == 1
lab var marr_u8 "Partner's educ less than 8 classes"

gen marr_c8 = 0
replace marr_c8 = 1 if marr_educ == 2
lab var marr_c8 "Partner's educ 8 classes"

gen marr_voc = 0
replace marr_voc = 1 if marr_educ == 3
lab var marr_voc "Partner's educ vocational"

gen marr_mat = 0
replace marr_mat = 1 if marr_educ == 4
lab var marr_mat "Partner's educ maturity"

gen marr_tert = 0
replace marr_tert = 1 if marr_educ == 5
lab var marr_tert "Partner's educ tertiary"

****************************
* Employed dummy
****************************
cap drop emp
cap drop emp2
cap drop srch
gen emp = gakt == 11 & fminH != 2 & fminH != 6 & fminH != 7 & (marr_fminH == 2 & marr_beodb == 1 & fminH == 1) != 1
	// nem egyeni vallalkozo, nem kozmunkás, nem segito csaladtag, parjanak nincs 1-2 fos vallalkozasa
gen emp2 = gakt == 11
gen srch = keres==1
lab var emp "employed (narrow def.)"
lab var emp2 "employed (wide def.)"

gen emp_wide = gakt == 11 & fminH != 6 & fminH != 7 & (marr_fminH == 2 & marr_beodb == 1 & fminH == 1) != 1

****************************

* Partner employed
cap drop marr_emp*
gen marr_emp = .
sort marriage_id
by marriage_id: replace marr_emp = emp[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_emp = emp[2] if marriage_id != . & person_id[2] != person_id[_n] & marr_emp == .
replace marr_emp = 0 if marr_emp == .
lab var marr_emp "Partner's employed"

cap drop n_oth_emp
egen n_oth_emp = sum(emp), by(flat_id)
replace n_oth_emp = n_oth_emp - 1 if emp == 1
replace n_oth_emp = n_oth_emp - 1 if marr_emp == 1


******************************************
* pensioner, soc. care. ...

gen pens = (gakt == 32 | gakt == 33 | gakt == 34)
lab var pens " pensioner"

gen wealth =  (gakt == 35)
lab var wealth " wealth"

gen soccare = (gakt == 36)
lab var soccare "social care"

sort marriage_id
foreach i in pens wealth soccare {
	cap drop marr_`i'
	gen marr_`i' = .
	by marriage_id: replace marr_`i' = `i'[1] if marriage_id != . & person_id[1] != person_id[_n]
	by marriage_id: replace marr_`i' = `i'[2] if marriage_id != . & person_id[2] != person_id[_n] & marr_`i' == .
	lab var marr_`i' "Partner's income: `i'"
	replace marr_`i' = 0 if marr_`i' == . //a missingekböl egyest csinál, hiszen automatikusan interakciós tag
}


foreach i in pens wealth soccare {
	cap drop n_oth_`i'

	sort flat_id
	egen n_oth_`i' = sum(`i'), by(flat_id)

	replace n_oth_`i' = n_oth_`i' - 1 if `i' == 1
	replace n_oth_`i' = n_oth_`i' - 1 if marr_`i' == 1
}

*Number of children

cap drop child0
cap drop child1_3
cap drop child4_6
cap drop child7_14
cap drop child15_18

gen child0 = (kev == 0) & lcslas_b == 4
gen child1_3 = (kev > 0 & kev <= 3) & lcslas_b == 4
gen child4_6 = (kev >= 4 & kev <= 6) & lcslas_b == 4
gen child7_14 = (kev >= 7 & kev <= 14) & lcslas_b == 4
gen child15_18 = (kev >= 15 & kev <= 18) & lcslas_b == 4

sort flat_id
foreach i in child0 child1_3 child4_6 child7_14 child15_18 {
	cap drop n_`i'
	egen n_`i' = sum(`i'), by(flat_id)
}
lab var n_child0 "Number of children with age 0"
lab var n_child1_3 "Number of children with age 1-3"
lab var n_child4_6 "Number of children with age 4-6"
lab var n_child7_14 "Number of children with age 7-14"
lab var n_child15_18 "Number of children with age 15-18"

by flat_id: egen n_flat = max(szsor)


* Public sector dummy
gen kozszfera_mis = 0
replace kozszfera_mis = 1 if munkkod == .
gen kozszfera = 0
replace kozszfera = 1 if munkkod == 84 | munkkod == 85 |munkkod == 86 |munkkod == 87 |munkkod == 88 | munkkod == 91 
// 84:Közigazgatás, védelem; kötelező társadalombiztosítás
// 85:Oktatás
// 86:Humán-egészségügyi ellátás
// 87:Bentlakásos, nem kórházi ápolás
// 88:Szociális ellátás bentlakás nélkül
// 91:Könyvtári, levéltári, múzeumi, egyéb kulturális tevékenység

*******************************
* Municipality type
*******************************
gen bp = (teltip == 1)
lab var bp "Budapest"
gen megye_cent = (teltip == 2)
lab var megye_cent "Megye center"
gen town = (teltip == 3)
lab var town "Town"
gen vill_5000 = (teltip == 4 & lncsop >= 8)
lab var vill_5000 "Village 5000+ pop"
gen vill_2000 = (teltip == 4 & lncsop < 7 & lncsop >= 6)
lab var vill_2000 "Village 2000-4999 pop"
gen vill_1000 = (teltip == 4 & lncsop < 5 & lncsop >= 4)
lab var vill_1000 "Village 1000-1999 pop"
gen vill_0 = (teltip == 4 & lncsop < 4)
lab var vill_0 "Village -999 pop"

*******************************
* Commuting
*******************************

gen jaras2 =

preserve
	keep terul jaras
	
	duplicates drop
	rename terul holtel
	rename jaras jaras_holtel
	save jaras_holtel.dta, replace
restore

merge m:1 holtel using jaras_holtel.dta, nogen

gen commuter = jaras!=jaras_holtel if emp==1

save becker_cenzus2011.dta, replace

********************************************************************
* Sample restrictions
********************************************************************


drop if kev < 15 | kev > 60
*not a student (nappali tagozatos)
drop if gakt == 14 | gakt == 22 | gakt == 24 | gakt == 43
*drop if tanov!=0
* Max vocational educ.
keep if low_educ2 == 1


* !!!!!!!!!!!!!!!!!!!!!!!!!
* we exclude the self-employed and their assisting family members, employed persons in family businesses, public works program participants, and full-time students
drop if fminH == 6 | fminH == 7 | (marr_fminH == 2 & marr_beodb == 1 & fminH == 1) // | fminH==2 



************************************
* merging dwelling info
*************************************
merge m:1 terul szlok cimssz using lakas_becker.dta, keep(3) nogen

replace lat = ln(lat)
gen lat_mis = lat==.

* full control-set
global X kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis ///
eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 ///
n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_bathr_mis wout_wc ///
wout_wc_mis home_runn_wat wout_runn_wat wat_mis low_status vlow_status status_mis  ///
bp megye_cent vill_5000 vill_2000 vill_1000 vill_0	kozszfera kozszfera_mis


keep $X megye regio kisterseg igrang lncsop teltipus terul* emp* jaras* roma* neme low_educ* person_id flat_id munkkod foglkod_feor08_4 beodb fminH marr_fminH marr_beodb holtel srch gakt fminH commuter

*labels
lab var kev "Age"
lab var neme "Female"
lab var lat "Flat size (m2), natural logarithm"
lab var wout_bathr "Without bathroom"
lab var wout_bathr_mis "Bathroom info missing"
lab var wout_wc "Without wc"
lab var wout_wc_mis "Wc info missing"
lab var home_runn_wat "Running water from home source"
lab var wat_mis "Water info missing"
lab var wout_runn_wat "No running water"
lab var low_status "Low status neighbourhood"
lab var vlow_status "Telep"
lab var status_mis "Neighborhood info missing"
lab var kevsq "Age squared"
lab var lterm_ill_disab_mis "Illness info missing"
lab var n_oth_emp "No. employed in flat (besides person)"
lab var n_oth_pens "No. pensioners in flat (besides person)"
lab var n_oth_wealth "No. living from wealth in flat (besides person)"
lab var n_oth_soccare "No. under social care in flat (besides person)"
lab var n_flat "No. people living in flat"
lab var commuter "Works in an other NUTS4 region"


*******************************
*Transport
*******************************

**közlekedési állapot változójának csatolása
*ezekböl majd kapcs2-t hagyom ki
rename terul terul_2011
merge m:1 terul_2011 using becker_kozl.dta, keepusing(kapcs kapcs0 kapcs1 kapcs2 kapcs3 kapcs4 kapcs_mis) keep(1 3)
rename terul_2011 terul


*Budapest problem
replace kapcs = 4 if _ == 1
replace kapcs4 = 1 if kapcs == 4
drop _

foreach i in kapcs0 kapcs1 kapcs2 kapcs3 kapcs_mis {
	replace `i' = 0 if kapcs == 4
}

cap drop X


preserve
keep if emp==1
keep jaras kozszfera neme

collapse (mean) kozszf_arany=kozszfera, by(jaras neme)
save public_sector.dta, replace
restore

******************************
**** District level informations from elsewhere

	gen region = jaras
	
	merge m:1 region using districts.dta, keep(1 3) nogen	

save becker_database_c2011.dta, replace


















