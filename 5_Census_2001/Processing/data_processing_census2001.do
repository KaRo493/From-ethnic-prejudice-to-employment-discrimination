/*
Ebben a fájlban a Becker-projekthez szükséges változók elkészítése történik meg
CENZUS_2011 -->BECKER-projekt alapfájl.
Definiálunk roma, alacsony iskolázottság, foglalkoztatott változókat, és számos magyarázó változót
az alábbiakban leírt módon.

Ehhez a 2001-es javított népszámlálási adatokat használom fel.


Ujrafuttatva, nokre is. Szuk definiciokkal. Minta is szuk....
Karolyi Robert
2022.03.17.

*/



clear all
set more off
cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"


***************************************************
*LAKAS JELLEMZOK
**************************************************

use "X:\INPUT_KSH\Nepszamlalas\MTA_altal_tisztitott_adatok\Nepszamlalas_tisztitott_20140224\2001\Lakas_2001_H.dta", clear

keep terul szlok cimssz ingasz ltip lat furdoH wcH vizeH lakovH

gen wout_bathr = (furdoH == 0)
*gen wout_bathr_mis = (furdoH == .)

gen wout_wc = (wcH == 0)
*gen wout_wc_mis = (wcH == .)

gen home_runn_wat = (vizeH == 2)
*gen wat_mis = (vizeH == .)
gen wout_runn_wat = (vizeH == 3)

gen low_status = (lakovH == 9)
*gen status_mis = (lakovH == .)
gen vlow_status = (lakovH == 10)

save lakas2001_becker.dta, replace



***************************************************
*EGYÉNI JELLEMZÖK
***************************************************


*legfrissebb népszámlálásból frissítve: 2015.03.16-án
use "X:\INPUT_KSH\Nepszamlalas\MTA_altal_tisztitott_adatok\Nepszamlalas_tisztitott_20140224\2001\Szemely_2001_H.dta", clear

*sorszámok elkészítése
egen person_id = group(terul_2001 szlok cimssz szsor)

*nem intézeti
drop if jc==8

egen flat_id = group(terul_2001 szlok cimssz)
egen family_id = group(terul_2001 szlok cimssz hsor lcssor) 

*Budapestet egy járásba helyezem
replace jaras = 23 if jaras <= 23
label define Ljaras_2011 23 "Budapest", modify
lab val jaras Ljaras_2011

gen ksh4 = floor(terul_2011/10)
merge m:1 ksh4 using tel_jaras175.dta, keepus(j_kod) keep(1 3) nogen
replace jaras = j_kod if jaras!=j_kod
drop j_kod



****************************
*ROMA VÁLTOZÓ
****************************


*** !!!!!
*** narrow def: 

cap drop roma
gen roma = 0
foreach i in 56 125 {
	foreach vr in enemz mnemz hnemz ecsbeny mcsbeny hcsbeny eanye manye hanye {
	replace roma = 1 if `vr'==`i'
	}
}
lab var roma "Roma (wide def: any nat., language)"

tab roma



*******************************
*MAGYARÁZÓ VÁLTOZÓK
*******************************

*életkor négyzete
gen kevsq = kev^2

*iskolai végzettség: FRISSÍTVE irelszH alapján
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



****************************
*ALACSONY VÉGZETTSÉG VÁLTOZÓ és BETEGSÉG
****************************

gen low_educ1 = 0
gen low_educ2 = 0


*kétféle alacsony végzettség
replace low_educ1 = 1 if u8 == 1 | c8 == 1
replace low_educ2 = 1 if u8 == 1 | c8 == 1 | voc == 1
lab var low_educ1 "under or completed 8 grades"
lab var low_educ2 "under or completed 8 grades + vocational"

/*tartós betegség
gen lterm_ill = 0
replace lterm_ill = (tfogya1H != 99 & tfogya1H != . & tfogya1H!=0)
lab var lterm_ill "long-term ill"
gen lterm_ill_disab_mis = (tfogya1H == 99 | tfogya1H == .)
*/

*disabled
gen disab = 0
replace disab = (tfogya1H != 99 & tfogya1H != . & tfogya1H!=0)
lab var disab "disabled"
gen disab_mis = (tfogya1H == 99 | tfogya1H == .)

/*tartós betegség és fogyatékosság
gen lterm_ill_disab = 0
replace lterm_ill_disab = 1 if fmegb == 1
replace lterm_ill_disab = 0 if fmegb == 0 | fmegb == 2 | fmegb == 3
lab var lterm_ill_disab "long-term ill and disabled"

*Van-e a lakásban tartós beteg / disabatékos / (5. oldalról)
gen wout_selfcare = (bakad1 == 1 | bakad2 == 1 | bakad3 == 1 | fakad1 == 1 | fakad2 == 1 | fakad3 == 1)
gsort flat_id -wout_selfcare 
by flat_id : replace wout_selfcare = wout_selfcare[1]
lab var wout_selfcare "can't take care of himself"
gen wout_selfcare_mis = (bakad1 == . & bakad2 == . & bakad3 == . & fakad1 == . & fakad2 == . & fakad3 == .)
*/


***************
*NYELVEK
**************

*beszél-e angolul
gen eng = 0
foreach i in 169 170 171 172 173 {
	foreach j in ebeny mbeny hbeny {
		replace eng = 1 if `j' == `i'
}
}
lab var eng "speaks English"

*beszél németül
gen ger = 0
foreach j in ebeny mbeny hbeny {
replace ger = 1 if `j' == 179
}
lab var ger "speaks German"

*vallásos-e
gen relig = 1
replace relig = 0 if vallas == 997 | vallas == 998 | vallas == 999
lab var relig "religious"



*****************************
*HÁZASTÁRS VAGY ÉLETTÁRS és együttélö!
*****************************

*ksh-def alapján a házas/életársas
cap drop marr_
gen marr_ = 0
replace marr_ = 1 if cspot == 2


gen hazas_mis = (hazevH == . & hazhoH == . & cspot == 2)
tab hazas_mis, missing
gen eltars_mis = (eltev == . & eltho == . & eltkap == 1)
tab eltars_mis, missing

replace eltkap = 1 if eltkap==.
gen kapcsev = .
gen kapcsho = .
replace kapcsev = hazevH if hazevH != . & cspot == 2
replace kapcsev = eltev if eltev != . & eltkap == 1
replace kapcsho = hazhoH if hazhoH != . & cspot == 2
replace kapcsho = eltho if eltho != . & eltkap == 1
replace kapcsev = max(hazevH , eltev) if hazevH != . & eltev != . & cspot == 2 & eltkap == 1

*megadjuk, hogy családon belül ha valakik def szerint együttélö házasok, és egyezik a kapcsolatuk kezdetének éve, akkor egy pár 
sort family_id
cap drop marriage_id
egen marriage_id = group(family_id marr_ kapcsev)

*EGYÜTTÉLÉS
sort flat_id marriage_id 
gen egyuttel = 0
*együttélö, ha a sorbarendezést követöen vagy az elötte lévö, vagy az utána lévö married sorszam azonos az övével
*azaz akkor 1-es, ha van mellette azonos családban azonos házassági állapotú azonos kapcsolat kezdetü ember
by flat_id: replace egyuttel = 1 if marriage_id == marriage_id[_n-1] | marriage_id == marriage_id[_n+1] 
tab egyuttel, missing
*föleg szüleikkel élö gyerekek, akiknek már van élettársuk, nyilván itt a nem házasok nem élettársasak nincsenek benne a 0-sok között
*mert azoknak missing a marriage_id már
*browse if egyuttel == 0
replace marriage_id = . if egyuttel == 0

*HAZAS VAGY ÉLETTÁRSA VAN: JÓ VERZIÓ!!!!
gen married = ((cspot == 2 & egyuttel == 1) | ((eltkap == 1 & egyuttel == 1)))
lab var married "Married or has companion"

gen married_m = (married == 1 & neme == 1)
gen married_f = (married == 1 & neme == 2)

gen marr_irelo = .
gen marr_irelsz = .
gen marr_fminH = .
gen marr_beodb = .
replace beodb=. if gakt!=110

*egy sorszám alatt két ember lehet, vagy az elso lesz a házastárs, vagy a második
sort marriage_id
by marriage_id: replace marr_irelo = irelo[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_irelo = irelo[2] if marriage_id != . & person_id[2] != person_id[_n] ///
	&  marr_irelo == .

by marriage_id: replace marr_irelsz = irelszH[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_irelsz = irelszH[2] if marriage_id != . & person_id[2] != person_id[_n] ///
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

replace marr_educ = 2 if marr_irelo >= 8 & (marr_irelsz == 1 | marr_irelsz == 2)

replace marr_educ = 3 if marr_irelsz >= 3 & marr_irelsz <= 4

replace marr_educ = 4 if marr_irelsz >= 5 & marr_irelsz <= 8

replace marr_educ = 5 if marr_irelsz >= 9 & marr_irelsz <= 10

replace marr_educ = 0 if marr_educ == .

lab def marr_educre1 0 "not married/no companion" 1 "less than 8" 2 "8" 3 "vocational" ///
4 "maturity" 5 "tertiary"
lab val marr_educ marr_educre1

*házas vagy élettársának végzettsége, ha van házas- vagy élettársa

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
*FOGLALKOZTATOTT VÁLTOZÓ
****************************
cap drop emp
*cap drop emp2
gen emp = gakt == 110 & fminH != 2 & fminH != 6 & fminH != 7 & (marr_fminH == 2 & marr_beodb == 1 & fminH == 1) != 1
	// nem egyeni vallalkozo, nem kozmunkás, nem segito csaladtag, parjanak nincs 1-2 fos vallalkozasa
*gen emp2 = gakt == 11
*gen srch = keres==1
lab var emp "employed (narrow def.)"
*lab var emp2 "employed (wide def.)"
****************************


*együttélö társ dolgozik-e: DOLGOZIK-E A HÁZASTÁRS
cap drop marr_emp*
gen marr_emp = .
sort marriage_id
by marriage_id: replace marr_emp = emp[1] if marriage_id != . & person_id[1] != person_id[_n]
by marriage_id: replace marr_emp = emp[2] if marriage_id != . & person_id[2] != person_id[_n] & marr_emp == .
*annál maradt missing, akinek nincs se felesége, se élettársa együttélö
replace marr_emp = 0 if marr_emp == .
lab var marr_emp "Partner's employed"



*******************************
*LAKÁSBAN LAKÓ SZEMÉLYEK ADATAI
*******************************


*LAKÁSBAN DOLGOZÓ MÁS EMBEREK SZÁMA
cap drop n_oth_emp
*megszámolja, hogy a lakásban hányan dolgoznak összesen
egen n_oth_emp = sum(emp), by(flat_id)
*levonja magát, ha dolgozik (emp definicio alapján)
replace n_oth_emp = n_oth_emp - 1 if emp == 1
*levonjuk, ha házastársa dolgozik
replace n_oth_emp = n_oth_emp - 1 if marr_emp == 1




******************************************
*ALAPVÁLTOZÓK: NYUGDIJAS, VAGYONBOL ÉLÖ, SZOCSEGÉLYBÖL ÉLÖ

gen pens = (gakt == 130 | gakt == 230 | gakt == 330 )
lab var pens " pensioner"

*gen wealth =  (gakt == 35)
*lab var wealth " wealth"

gen soccare = (gakt == 251 | gakt == 351)
lab var soccare "social care"

sort marriage_id
foreach i in pens soccare {
	cap drop marr_`i'
	gen marr_`i' = .
	by marriage_id: replace marr_`i' = `i'[1] if marriage_id != . & person_id[1] != person_id[_n]
	by marriage_id: replace marr_`i' = `i'[2] if marriage_id != . & person_id[2] != person_id[_n] & marr_`i' == .
	lab var marr_`i' "Partner's income: `i'"
	replace marr_`i' = 0 if marr_`i' == . //a missingekböl egyest csinál, hiszen automatikusan interakciós tag
}


foreach i in pens soccare {
	*LAKÁSBAN DOLGOZÓ MÁS EMBEREK SZÁMA
	cap drop n_oth_`i'
	*megszámolja, hogy a lakásban hányan `i' összesen
	sort flat_id
	egen n_oth_`i' = sum(`i'), by(flat_id)
	*levonja magát, ha `i'
	replace n_oth_`i' = n_oth_`i' - 1 if `i' == 1
	*levonjuk, ha házastársa `i'
	replace n_oth_`i' = n_oth_`i' - 1 if marr_`i' == 1
}

*18 vagy fiatalabb személyek száma megbontva kategóriákra

cap drop child0
cap drop child1_3
cap drop child4_6
cap drop child7_14
cap drop child15_18
*gyerekek korosztályonként: JAVÍTVA --> feltétel: gyerekstátusz
gen child0 = (kev == 0) & lcslas == 4
gen child1_3 = (kev > 0 & kev <= 3) & lcslas == 4
gen child4_6 = (kev >= 4 & kev <= 6) & lcslas == 4
gen child7_14 = (kev >= 7 & kev <= 14) & lcslas == 4
gen child15_18 = (kev >= 15 & kev <= 18) & lcslas == 4

*lakásonként összeadja a gyerekek számát korosztályonként
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

*hanyan laknak egy lakásban
by flat_id: egen n_flat = max(szsor)


* keszitsunk kozszfera dummy-t
gen kozszfera_mis = 0
replace kozszfera_mis = 1 if faga == .
gen kozszfera = 0
replace kozszfera = 1 if faga<900 & faga>=800 | faga==925 //(faga>=640 & faga<650) | faga==730 | 


*******************************
*telepulestipus (town lesz a referencia)
*******************************

bysort terul_2001: egen popu = count(szlok)

gen bp = (teltip == 1)
lab var bp "Budapest"
gen megye_cent = (teltip == 2)
lab var megye_cent "Megye center"
gen town = (teltip == 3)
lab var town "Town"
gen vill_5000 = (teltip == 4 & popu>=5000)
lab var vill_5000 "Village 5000+ pop"
gen vill_2000 = (teltip == 4 & popu < 5000 & popu>=2000)
lab var vill_2000 "Village 2000-4999 pop"
gen vill_1000 = (teltip == 4 & popu < 2000 & popu>=1000)
lab var vill_1000 "Village 1000-1999 pop"
gen vill_0 = (teltip == 4 & popu<1000)
lab var vill_0 "Village -999 pop"

save becker_cenzus2001.dta, replace


********************************************************************
*BECKER-projekt mintakorlátozás: 15-60, nem nappali, max szakmunkás
********************************************************************


drop if kev < 15 | kev > 60
*ne legyen nappali tagozatos
drop if gakt == 119| gakt == 416 | gakt == 418 | gakt == 419
*drop if tanov!=0
*csak a max szakmunkás végzettségüek kellenek
keep if low_educ2 == 1


* !!!!!!!!!!!!!!!!!!!!!!!!!
* ne legyen egyeni vall, kozmunkas, segito csaladtag es olyan, akinek az elettarsa/hazastarsa kisvallalkozast vezet, amiben o potencialisan benne lehet
drop if fminH == 2 | fminH == 6 | fminH == 7 | (marr_fminH == 2 & marr_beodb == 1 & fminH == 1)



************************************
*LAKÁSjellemzök hozzáillesztése
*************************************
gen terul = terul_2001
merge m:1 terul szlok cimssz using lakas2001_becker.dta, keep(3) nogen

*lakóterület nagyságát logolom
replace lat = ln(lat)
gen lat_mis = lat==.

*kontrollváltozók
global X kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis ///
eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 ///
n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_bathr_mis wout_wc ///
wout_wc_mis home_runn_wat wout_runn_wat wat_mis low_status vlow_status status_mis  ///
bp megye_cent vill_5000 vill_2000 vill_1000 vill_0	kozszfera kozszfera_mis


*mi maradjon meg?
keep $X megye regio kisterseg igrang lncsop teltipus terul* emp* jaras* roma* neme low_educ* person_id flat_id munkkod foglkod_feor08_4 beodb fminH marr_fminH marr_beodb holtel srch

*változók megcímkézése
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



**közlekedési állapot változójának csatolása
*ezekböl majd kapcs2-t hagyom ki
merge m:1 terul_2011 using becker_kozl.dta, keepusing(kapcs kapcs0 kapcs1 kapcs2 kapcs3 kapcs4 kapcs_mis) keep(1 3)


*Budapest kijavítása
replace kapcs = 4 if _ == 1
replace kapcs4 = 1 if kapcs == 4
drop _
*közlekedéshez tartozó dummyk létrehozása 
foreach i in kapcs0 kapcs1 kapcs2 kapcs3 kapcs_mis {
	replace `i' = 0 if kapcs == 4
}

cap drop X


save becker_2001_database_20220412.dta, replace

keep if emp==1
keep jaras kozszfera neme

collapse (mean) kozszf_arany=kozszfera, by(jaras neme)
save public_sector.dta, replace


*****************************
**** Egyeb helyekrol: JOBBIK, F30, SEGREGATION

use becker_2001_database_20220412.dta, clear

	gen jkod = jaras
	rename jaras_2011 jaras
	*betöltöm a vállalati méret szerinti fogl-eloszlást
	merge m:1 jkod using becker_jaras_essfirm_eloszlas_bp_160203.dta, keep(3) nogen
		gen f30x = essfirm30
	*betöltöm a párttámogatottságot
	merge m:1 jkod using jobbik_2022.dta, keep(3) nogen
	* szegregacio !! polgardi jaras missing !!!!
	merge m:1 jaras using segr_20180516/S_jarasi.dta, keep(1 3) nogen
	* eloitelet:
	merge m:1 jaras using "${data}/jarasok5.dta", nogen keepus(rJ1 rJ2_b rJ3_b) keep(1 3)
	rename rJ2_b rJ2
	replace rJ2 = rJ2/100
	rename rJ3_b rJ3
	replace rJ3 = rJ3/100
	* kozszfera
	rename jaras jaras_2011
	merge m:1 jaras_2011 neme using public_sector.dta, keep(1 3) nogen
	


save, replace





