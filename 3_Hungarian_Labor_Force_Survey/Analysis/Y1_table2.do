set more off
cd c:/kolloj/becker/SF
use Y1.dta,clear

*This one estimates the probability of Roma to be employed in teamwork and customer contact jobs.
*Sample: 15-60, firm L>1, PW excluded
*Source: LFS 2015-2020, waves which include the Roma var

*Koren M, Pető R (2020) Business disruptions from social distancing. PLOS ONE 15(9): e0239113. *https://doi.org/10.1371/journal.pone.0239113. https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0239113

*Estimation sample
#delimit;
d teamwork_interact_index customer_interact_index small_50* small_20* small_10 roma ferfi kor edu3; 
sum teamwork_interact_index customer_interact_index small_50* small_20* small_10 roma ferfi kor edu3 
if educH<4 & teamwork_interact_index<.;
#delimit cr

*Regressions
regr teamwork_interact_index roma##small_50a ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr teamwork_interact_index roma##small_50b ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr teamwork_interact_index roma##small_20a ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr teamwork_interact_index roma##small_20b ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr teamwork_interact_index roma##small_10 ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)

regr customer_interact_index roma##small_50a ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr customer_interact_index roma##small_50b ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr customer_interact_index roma##small_20a ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr customer_interact_index roma##small_20b ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)
regr customer_interact_index roma##small_10 ferfi kor edu3 i.iyear if educH<4 [aw=weight11], rob cluster(id)

set more on 
