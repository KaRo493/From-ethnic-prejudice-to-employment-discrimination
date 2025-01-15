/*------------------------------------------------------------------------------ 

	Employment Regressions - 2011

------------------------------------------------------------------------------*/

cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\output_2024_KR" 
global data "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"


global date "20240524"


use "${data}/becker_database_c2011.dta", clear

	gen f30x = essfirm30


*controls
	global X kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status bp megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis
	
	global X2 kev kevsq kozszf_arany lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_emp marr_pens marr_wealth marr_soccare n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare lat bp megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis

*save "${data}/becker_database_${date}.dta", replace	
	
set more off

cap erase becker_OLS_${date}.xls
cap erase becker_OLS_${date}.txt

**************************************
*Employment including the self employed (Robustness)
**************************************
gen emp_se = emp
replace emp_se = 1 if fminH==2 & gakt==11


** male/female (only males now)
qui forval i = 1/2 {

preserve
	
	keep if neme==`i'
	
	**************************************
	*REGRESSIONS
	**************************************
		cap erase "becker_OLS_nem`i'_${date}.xls"
		cap erase "becker_OLS_nem`i'_${date}.txt"
	
		foreach treat in J rJ1 {
			
			cap drop roma_* 	
			cap drop E_f30x
			cap drop roma_E*
			gen roma_f30x = roma * f30x	
			gen roma_E = roma * `treat'
			*gen E_f30x = `treat' * f30x
			gen roma_E_f30x = roma * `treat' * f30x
				

			areg emp_se roma roma_E roma_f30x roma_E_f30x $X , absorb(jaras) vce(cluster jaras) 	
			outreg2 using becker_OLS_EmpSE_nem`i'_${date}.xls, stats(coef tstat) addtext(E, `treat') append

			
		}
restore		
}


**************************************
* Using main employment definition
**************************************

drop if fminH==2

** Simple employment gaps
qui forval i = 1/2 {

			reg emp roma if neme==`i', r 	
			outreg2 using becker_GAP_nem`i'_${date}.xls, stats(coef tstat) keep(roma) addtext(Kontrol, nem, FE, nem)		
			
			reg emp roma $X if neme==`i', r 	
			outreg2 using becker_GAP_nem`i'_${date}.xls, stats(coef tstat) keep(roma) addtext(Kontrol, igen, FE, nem)		
				
			areg emp roma $X if neme==`i', absorb(jaras) vce(cluster jaras) 	
			outreg2 using becker_GAP_nem`i'_${date}.xls, stats(coef tstat) keep(roma) addtext(Kontrol, igen, FE, jaras)				
			
}

** main spec.
qui forval i = 1/2 {

preserve
	
	keep if neme==`i'
	
	**************************************
	*REGRESSIONS
	**************************************
		cap erase "becker_OLS_nem`i'_${date}.xls"
		cap erase "becker_OLS_nem`i'_${date}.txt"
	
		foreach treat in J rJ1 {
			
			cap drop roma_* 	
			cap drop E_f30x
			cap drop roma_E*
			gen roma_f30x = roma * f30x	
			gen roma_E = roma * `treat'
			*gen E_f30x = `treat' * f30x
			gen roma_E_f30x = roma * `treat' * f30x
				

			areg emp roma roma_E roma_f30x roma_E_f30x $X , absorb(jaras) vce(cluster jaras) 	
			outreg2 using becker_OLS_nem`i'_${date}.xls, stats(coef tstat) addtext(E, `treat')	append

			
		}
restore		
}






