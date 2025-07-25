/*

this is the code that replicates the full sample
(not just LA) stuff from Mason & Cope 1987.

*/

discard
clear all
global route "C:/Users/toom/Desktop/mason_cope_rep"


************************************
*replicate Table 1 from Mason & Cope
************************************
// pending
use "${route}/data/A_analysis_set.dta", clear

/* their columns:
	of incons, incon == 1 year
		of incon == 1 year, reports June
		of incon == 1 year, all other months
	
	of incons, incon > 1 year
		of incon > 1 year, multiple of 10
		of incon > 1 year, any other value
		
	count of incons, excluding missings
	total sample size, of all obs.
*/

cap log close
log using "${route}/output/table1.txt", text replace nomsg

// let's do it for IPUMS first:
*of incons, incon == 1 year -- 3,349,173 / 7,144,537 -- 46.88%
*of incons, incon > 1 year -- 3,795,364 / 7,144,537 -- 53.12%
gen gap1 = ip_gap==1
tab gap1 if ip_gap!=0 & ip_miss==0
drop gap1

*of incon == 1 year, reports June -- 632,870 / 3,349,173 -- 18.90%
*of incon == 1 year, all other months -- 2,716,303 / 3,349,173 -- 81.10%
gen june1 = birthmo==6 & ip_gap==1
tab june1 if ip_gap==1
drop june1

*of incon > 1 year, multiple of 10 -- 1,197,673 / 3,795,364 -- 31.56%
*of incon > 1 year, any other value -- 2,597,691 / 3,795,364 -- 68.44%
gen gap10 = mod(ip_gap,10)==0
tab gap10 if ip_gap > 1 & ip_miss==0
drop gap10

*count of incons, excluding missings -- 7,144,537 / 74,903,815 -- 9.54%
*total sample size, of all obs. -- 74,903,815 / 75,587,239 -- 99.10%
tab ip_incon
tab ip_miss
// there are 683,424 missing for the IPUMS set.


// now it's FS time!:
*of incons, incon == 1 year -- 40,161,237 / 40,161,301 -- 100.00%
*of incons, incon > 1 year -- 64 / 40,161,301 -- 0.00%
gen gap1 = fs_gap==1
tab gap1 if fs_gap!=0 & fs_miss==0
drop gap1

*of incon == 1 year, reports June -- 5,412,218 / 40,161,237 -- 13.48%
*of incon == 1 year, all other months -- 34,749,019 / 40,161,237 -- 86.52%
gen june1 = pr_birth_month=="Jun" & fs_gap==1
tab june1 if fs_gap==1
drop june1

*of incon > 1 year, multiple of 10 -- 44 / 64 -- 68.75%
*of incon > 1 year, any other value -- 20 / 64 -- 31.25%
gen gap10 = mod(fs_gap,10)==0
tab gap10 if fs_gap > 1 & fs_miss==0
drop gap10

*count of incons, excluding missings -- 40,161,301 / 73,830,220 -- 54.40%
*total sample size, of all obs. -- 73,830,220 / 75,587,239 -- 97.68%
tab fs_incon 
tab fs_miss
// there are 1,757,019 missing for the FS set.

cap log close
*/


************************************
*replicate Table 2 from Mason & Cope
************************************
// pending
use "${route}/data/A_analysis_set.dta", clear

// this table is insane because all of the variables in the table are collinear?? but they say they ran a logit??

// frick it, just run a real good one for realsies









