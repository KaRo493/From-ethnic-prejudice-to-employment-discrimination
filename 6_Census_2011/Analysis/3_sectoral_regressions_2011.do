/*------------------------------------------------------------------------------ 

	Sector share placebos

------------------------------------------------------------------------------*/


cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\output_2024_KR" 
global data "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"


global date "20240625"


use "${data}/becker_database_20240619.dta", clear

* sectoral shares
merge m:1 jaras using "${data}/becker_nagy_teáor_járás_wide_20220406.dta", nogen keep(1 3)

	*kontrollok	
	global X kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis 	
	
rename teaor_arany_epito epito
rename teaor_arany_mg mg
rename teaor_arany_szolg szolg


keep kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status bp megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis J stJ emp neme roma jaras epito mg szolg

compress

save "${data}/becker_database_sect_BS2024.dta", replace
	
	
set more off

log using bs_${date}, replace


forval i = 1/2 {
	
	use "${data}/becker_database_sect_BS2024.dta", clear
	keep if neme==`i'
	
	**************************************
	*REGRESSIONS
	**************************************
		
		foreach treat in rJ1 {
			forval z=1/30 {
			
			foreach ag in epito mg szolg {
			
			**** E ****
			merge m:1 jaras using "${data}/2step_`treat'.dta", nogen keep(1 3) keepus( `treat'_`z' )			
			
			cap drop roma_* 	
			cap drop `treat'_`z'_`ag'
			cap drop roma_`treat'_`z'*
			gen roma_`ag' = roma * `ag'	
			gen roma_`treat'_`z' = roma * `treat'_`z'
			gen `treat'_`z'_`ag' = `treat'_`z' * `ag'
			gen roma_`treat'_`z'_`ag' = roma * `treat'_`z' * `ag'
				

				bootstrap _b[roma_`treat'_`z'] _b[roma_`treat'_`z'_`ag'], rep( ${reps} ) saving(BTS/Sectors/beta_`ag'_`z'_neme`i'.dta, replace): areg emp roma roma_`treat'_`z' roma_`ag' roma_`treat'_`z'_`ag' $X , absorb(jaras) vce(cluster jaras) 	
				
			drop `treat'_`z'*
			}
			}
		}
}

********************************************************************************
** APPENDING RESULTS		
		
** rJ1 ************
foreach ag in epito mg szolg {
forval i=1/2 {
clear
	forval z=1/30 {
		append using BTS/Sectors/beta_`ag'_`z'_neme`i'.dta
	}
rename _bs_1 roma_rJ1
rename _bs_2 roma_rJ1_S

sum roma_rJ1_S, d
hist roma_rJ1_S

save "BS_beta_`ag'_neme`i'_${date}.dta", replace
}
}

log close
			
