/*

this is the code that replicates the 
full census stuff from Mason & Cope 1987

we have to bring in FS data for some of it
because the IPUMS variables are never missing
even though we KNOW they should be sometimes!

*/

discard
clear all
global route "C:/Users/toom/Desktop/mason_cope_rep"


******************************************
*pop the set open and get the FS stuff on!
******************************************
// done
use "${route}/raw_data/ipums_extract.dta", clear

rename (serial pernum) (serial1900 pernum1900)

merge m:1 serial1900 pernum1900 ///
	using "C:\Users\toom\Desktop\mason_cope_rep\raw_data\fs_birth_vars.dta" ///
	, keep(3) nogen
	
// 237,473 obs. of 75,824,712 (0.31%) we can't link to FS got dropped above
// leaves 75,587,239 matchable observations for the full sample.
*/

************************************
*create the markers for missing info
************************************
// done
recode birthyr (9999=.) // this is the IPUMS missing birthyr code

gen ip_miss = ///
	birthyr==. | ///
	birthmo==. | /// this one is never missing, but y'know
	age==.

gen fs_miss = ///
	pr_birth_month=="N/A" | ///
	pr_birth_year==.      | ///
	pr_age==.

// for some reason, IPUMS age/month vars always there,
// even though there are definitely people for whom
// the manuscript has miss. value. If this weren't the
// case, we wouldn't need to bring in the FS data.
*/


*****************************************************
*create the markers for within-person inconsistencies
*****************************************************
// done
*we can do this one for both IPUMS & FS:

gen fs_imp_byr = 1900 - pr_age
replace fs_imp_byr = fs_imp_byr - 1 ///
	if inlist(pr_birth_month, ///
		"Jun", ///
		"Jul", ///
		"Aug", ///
		"Sep", ///
		"Oct", ///
		"Nov", ///
		"Dec")
		
replace fs_imp_byr = . ///
	if pr_birth_month=="N/A" // have to adjust for missing months here

// so basically, age 10 at June 1900 census says either born
// in 1890 if month is before June and 1889 if June or after.
// we'll do the same now for IPUMS:

gen ip_imp_byr = 1900 - age
replace ip_imp_byr = ip_imp_byr - 1 ///
	if birthmo >= 6 // that's June!
	
// now just mark the two types of inconsistencies:

gen fs_gap = abs(fs_imp_byr - pr_birth_year)
gen ip_gap = abs(ip_imp_byr - birthyr)
	
gen fs_incon = (fs_imp_byr != pr_birth_year)
replace fs_incon = . if fs_miss==1

gen ip_incon = (ip_imp_byr != birthyr)
replace ip_incon = . if ip_miss==1

// done deal!
*/


************************************
*replicate Table 1 from Mason & Cope
************************************
// pending

/* 
their columns:
	of incons, incon == 1 year
		of incon == 1 year, reports June
		of incon == 1 year, all other months
	
	of incons, incon > 1 year
		of incon > 1 year, multiple of 10
		of incon > 1 year, any other value
		
	count of incons, excluding missings
	total sample size, of all obs.
*/

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
