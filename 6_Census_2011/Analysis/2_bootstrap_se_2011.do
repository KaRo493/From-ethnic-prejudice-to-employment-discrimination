/*------------------------------------------------------------------------------ 

	Employment Regressions - 2011
	
	2step bootstrap SE

------------------------------------------------------------------------------*/



cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\output_2024_KR" 
global data "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"

global reps = 500

use "${data}/becker_database_c2011.dta", clear

	gen f30x = essfirm30

keep kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_wc  home_runn_wat wout_runn_wat  low_status vlow_status J stJ f30x emp neme roma jaras

	*kontrollok	
	global X kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status 	

drop if fminH==2
	
compress

save "${data}/becker_bootstrap.dta", replace

set more off

** male/female (only males now)
forval i = 1/2 {
	
use "${data}/becker_bootstrap.dta", clear
	
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
				

				bootstrap _b[roma_`treat'_`z'] _b[roma_`treat'_`z'_f30x], rep( ${reps} ) saving(BTS/`treat'/beta_`treat'_`z'_neme`i'.dta, replace): areg emp roma `treat'_`z' f30x roma_`treat'_`z' roma_f30x `treat'_`z'_f30x roma_`treat'_`z'_f30x $X , absorb(jaras) vce(cluster jaras) 	
				
			drop `treat'_`z'*
			}
		}
}
********************************************************************************
** Coeffs into one dataset		
		
** rJ1 ************
clear
local i = 1
forval z=1/30{
	append using BTS/rJ1/beta_rJ1_`i'_neme`z'.dta
}
rename _bs_1 roma_rJ1
rename _bs_2 roma_rJ1_K

sum roma_rJ1_K, d
hist roma_rJ1_K

save "BS_beta_rJ1_g`i'.dta", replace


			
			