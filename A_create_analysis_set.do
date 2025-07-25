/*

this is the code that creates the dataset I'll 
use to replicate Mason & Cope 1987 on full samples.

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
use "${route}/data/raw_data/ipums_extract.dta", clear

rename (serial pernum) (serial1900 pernum1900)

merge m:1 serial1900 pernum1900 ///
	using "C:/Users/toom/Desktop/mason_cope_rep/data/raw_data/fs_birth_vars.dta" ///
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
compress
save "${route}/data/A_analysis_set.dta", replace
*/




