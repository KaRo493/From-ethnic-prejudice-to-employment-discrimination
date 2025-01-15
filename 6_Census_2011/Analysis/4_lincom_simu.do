/* 

	Becker
	
	LINCOM predikciok


*/

cd "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\output_2024_KR" 
global data "X:\PROJECTS\Project2_Foglalkoztatási különbségek\becker\DATA"



global date "20240527"

use "${data}/becker_database_20240517.dta", clear

*compress

drop if fminH==2

gen f30x=essfirm30

merge m:1 jaras using "${data}/jarasok5.dta", nogen keepus(rJ1 rJ2_b rJ3_b) keep(1 3)
rename rJ2_b rJ2
replace rJ2 = rJ2/100
rename rJ3_b rJ3
replace rJ3 = rJ3/100

	*kontrollok	
	global X kev kevsq u8 voc lterm_ill disab lterm_ill_disab lterm_ill_disab_mis eng ger relig married marr_u8 marr_voc marr_mat marr_tert marr_emp marr_pens marr_wealth marr_soccare n_child0 n_child1_3 n_child4_6 n_child7_14 n_child15_18 n_oth_emp n_oth_pens n_oth_wealth n_oth_soccare wout_selfcare n_flat lat wout_bathr wout_wc home_runn_wat wout_runn_wat low_status vlow_status bp megye_cent vill_5000 vill_2000 vill_1000 vill_0 kapcs0 kapcs1 kapcs3 kapcs4 kapcs_mis
	

set more off

** lincom result tables
foreach treat in rJ1 rJ2 rJ3 {
	forval i = 1/2 {
	mat def A_`i'_`treat' = J(4,6,.)
	mat colname A_`i'_`treat' = _20 _25 _30 _35 _40 _45
	mat rowname A_`i'_`treat' = _min5 _0 _5 _10
	
	mat def A_`i'_`treat'_se = J(4,6,.)
	mat colname A_`i'_`treat'_se = _20 _25 _30 _35 _40 _45
	mat rowname A_`i'_`treat'_se = _min5 _0 _5 _10
	
	mat def A_`i'_`treat'_t = J(4,6,.)
	mat colname A_`i'_`treat'_t = _20 _25 _30 _35 _40 _45
	mat rowname A_`i'_`treat'_t= _min5 _0 _5 _10
}
}
forval i = 1/2 {
	mat def A_`i'_J = J(4,5,.)
	mat colname A_`i'_J = _20 _25 _30 _35 _40
	mat rowname A_`i'_J = _15 _20 _25 _30
	
	mat def A_`i'_J_se = J(4,5,.)
	mat colname A_`i'_J_se = _20 _25 _30 _35 _40
	mat rowname A_`i'_J_se = _15 _20 _25 _30
	
	mat def A_`i'_J_t = J(4,5,.)
	mat colname A_`i'_J_t = _20 _25 _30 _35 _40
	mat rowname A_`i'_J_t = _15 _20 _25 _30
}

** resid J **********************************


qui forval i = 1/2 {
		
		foreach treat in rJ1 rJ2 rJ3 {		
			
			cap drop roma_* 	
			cap drop `treat'_f30x
			cap drop roma_`treat'*
			gen roma_f30x = roma * f30x	
			gen roma_`treat' = roma * `treat'
			gen `treat'_f30x = `treat' * f30x
			gen roma_`treat'_f30x = roma * `treat' * f30x
		
		** estimation
		areg emp roma `treat' f30x roma_`treat' roma_f30x `treat'_f30x roma_`treat'_f30x $X if neme==`i', absorb(jaras) vce(cluster jaras) 	
	
		** prediction
		
		local kt = 1
			forval k = 0.2(0.05)0.45 {
			local jt = 1
				forval j = -0.05(0.05)0.1 {
						
					lincom roma+`j'*roma_`treat'+`k'*roma_f30x+`j'*`k'*roma_`treat'_f30x
					local esti=r(estimate)
					local sde=r(se)
					local _t=r(t)
					local t=`esti'/`sde'
					
					mat A_`i'_`treat'[`jt',`kt'] = `esti'
					mat A_`i'_`treat'_se[`jt',`kt'] = `sde'
					mat A_`i'_`treat'_t[`jt',`kt'] = `_t'
				
				local ++jt
				}
			local ++kt
			}
		}
}

** J ******************************************

qui forval i = 1/2 {
		
		foreach treat in J {		
			
			cap drop roma_* 	
			cap drop `treat'_f30x
			cap drop roma_`treat'*
			gen roma_f30x = roma * f30x	
			gen roma_`treat' = roma * `treat'
			gen `treat'_f30x = `treat' * f30x
			gen roma_`treat'_f30x = roma * `treat' * f30x
		
		** estimation
		areg emp roma `treat' f30x roma_`treat' roma_f30x `treat'_f30x roma_`treat'_f30x $X if neme==`i', absorb(jaras) vce(cluster jaras) 	
	
		** prediction
		
		local kt = 1
			forval k = 0.2(0.05)0.40 {
			local jt = 1
				forval j = 0.15(0.05)0.30 {
						
					lincom roma+`j'*roma_`treat'+`k'*roma_f30x+`j'*`k'*roma_`treat'_f30x
					local esti=r(estimate)
					local sde=r(se)
					
					mat A_`i'_`treat'[`jt',`kt'] = `esti'
					mat A_`i'_`treat'_se[`jt',`kt'] = `sde'
				
				local ++jt
				}
			local ++kt
			}
		}
}


** OP
forval i = 1/2 {
	foreach treat in J rJ1 rJ2 rJ3 {	
	
	putexcel set predictions_neme`i'_${date}, sheet(`treat') modify
	putexcel A1 = matrix(A_`i'_`treat'), names
	putexcel A10 = matrix(A_`i'_`treat'_se), names
	}
}





