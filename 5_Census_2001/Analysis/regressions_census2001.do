/* 

	Becker
	
	Regressions: 
		2001 remake
		
	Karolyi Robert


*/



cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\output_2024_KR" 
global data "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"

global reps = 500

global date "20240625"

*log using bs_20220214, replace

use "${data}/becker_2001_database_20220412.dta", clear

** K 2001:
gen jaras175 = jaras_2011
merge m:1 jaras175 using "${data}/K2001.dta", nogen

*compress

gen kevsq = kev*kev

	*kontrollok	
	global X kev kevsq u8 voc disab eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_soccare n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status bp megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis


keep kev kevsq u8 voc disab eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_soccare  n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status bp megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis J stJ f30x emp neme roma jaras_2011

compress

rename jaras_2011 jaras

save "${data}/becker_database2001_BS2024.dta", replace


set more off

log using bs2001_${date}, replace

** male/female (only females now)
forval i = 1/2 {
	
	use "${data}/becker_database2001_BS2024.dta", clear
	keep if neme==`i'

	**************************************
	*REGRESSIONS
	**************************************
		
		foreach treat in rJ1 {
			forval z=1/30 {
			
			**** E ****
			merge m:1 jaras using "${data}/2step_`treat'.dta", nogen keep(1 3) keepus( `treat'_`z' )			
			
			cap drop roma_* 	
			cap drop `treat'_`z'_f30x
			cap drop roma_`treat'_`z'*
			gen roma_f30x = roma * f30x	
			gen roma_`treat'_`z' = roma * `treat'_`z'
			gen `treat'_`z'_f30x = `treat'_`z' * f30x
			gen roma_`treat'_`z'_f30x = roma * `treat'_`z' * f30x
				

				bootstrap _b[roma_`treat'_`z'] _b[roma_`treat'_`z'_f30x], rep( ${reps} ) saving(BTS/2001/beta_`treat'_`z'_neme`i'.dta, replace): areg emp roma `treat'_`z' f30x roma_`treat'_`z' roma_f30x `treat'_`z'_f30x roma_`treat'_`z'_f30x $X , absorb(jaras) vce(cluster jaras) 	
				
			drop `treat'_`z'*
			}
		}
}

********************************************************************************
** APPENDING RESULTS		
		
** rJ1 ************

forval z=1/2 {
clear
	forval i=1/30 {
		append using BTS/2001/beta_rJ1_`i'_neme`z'.dta
	}
rename _bs_1 roma_rJ1
rename _bs_2 roma_rJ1_K

sum roma_rJ1_K, d
hist roma_rJ1_K

save "BS2001_beta_rJ1_neme`z'_${date}.dta", replace
}

log close
