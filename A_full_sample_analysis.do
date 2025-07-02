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
/* done
use "${route}/raw_data/ipums_extract.dta", clear

rename (serial pernum) (serial1900 pernum1900)

merge m:1 serial1900 pernum1900 ///
	using "C:\Users\toom\Desktop\mason_cope_rep\raw_data\fs_birth_vars.dta" ///
	, keep(3) nogen
	
// 237,473 obs. of 75,824,712 (0.31%) we can't link to FS got dropped above
*/

************************************
*create the markers for missing info
************************************
/* done
gen anymiss = ///
	pr_birth_month=="N/A" | ///
	pr_birth_year==.      | ///
	pr_age==.
	
gen monmiss = pr_birth_month=="N/A"

gen byrmiss = pr_birth_year==.

gen agemiss = pr_age==.

// for some reason, the IPUMS vars are never missing,
// even though there are definitely people for whom
// the manuscript has no value. If this weren't the
// case, we wouldn't need to bring in the FS data.
*/


*****************************************************
*create the markers for within-person inconsistencies
*****************************************************
/* done
*we can do this one for both IPUMS & FS:

gen fs_imp_byr = 1900 - pr_age
replace fs_imp_byr = fs_imp_byr + 1 ///
	if inlist(pr_birth_month, ///
		"Jun", ///
		"Jul", ///
		"Aug", ///
		"Sep", ///
		"Oct", ///
		"Nov", ///
		"Dec")

// so basically, age 10 at June 1900 census says either born
// in 1890 if month is before June and 1891 if June or after.
// this does make 1900 - 0 --> 1901 for a few obs, but that's
// an error anyways because they shouldn't be on the Census
// if they were born after 1 June 1900... so not a problem.
// if this is the case, it'll be an inconsistency, which is
// what we're looking for! we'll do the same now for IPUMS:

gen ip_imp_byr = 1900 - age
replace ip_imp_byr = ip_imp_byr + 1 ///
	if birthmo >= 6 // that's June!
	
// now just mark the two types of inconsistencies:
	
gen fs_incon = (fs_imp_byr != pr_birth_year)
gen ip_incon = (ip_imp_byr != birthyr)

tab fs_incon ip_incon

// done deal!

*/



