*==============================================================*
* Cleaning: E-commerce Packaging Waste in Pune and Delhi survey
* Input : the Google Forms export (.xlsx), 113 rows x 27 columns
* Output: packaging_clean.dta  (+ packaging_clean.csv)
*==============================================================*
version 14
clear all
set more off

* >>> EDIT THIS: folder that contains your Excel file <<<
cd "C:/Users/YourName/Documents"

local infile "E-commerce Packaging Waste in Pune and Delhi.xlsx"

*--------------------------------------------------------------*
* 1. Import (skip the long question-text header row)
*--------------------------------------------------------------*
import excel using "`infile'", sheet("Form responses 1") cellrange(A2) clear

* Columns A..Z, AA -> short names (27 of each)
rename (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA) ///
       (submitted age_group gender residence orders products platforms ///
        rk_price rk_speed rk_quality rk_packaging rk_returns ///
        opted_minimal excess_pack materials cos_effort campaigns ///
        disposal reduce_waste contacted_co pay_premium accept_slower ///
        incentives legal_req policy_pref return_prog challenge)

*--------------------------------------------------------------*
* 2. Basic hygiene: trim spaces, ID, date, duplicates
*--------------------------------------------------------------*
ds, has(type string)
foreach v of varlist `r(varlist)' {
    replace `v' = strtrim(stritrim(`v'))
}

sort submitted
gen int resp_id = _n
label var resp_id "Respondent ID"

format submitted %tc
gen submit_date = dofc(submitted)
format submit_date %td
label var submit_date "Date of submission"

duplicates report age_group gender residence orders products platforms
duplicates tag submitted, gen(dup_ts)
assert dup_ts == 0
drop dup_ts

* Make sure the ranking columns are numeric and within 1-5
foreach v of varlist rk_* {
    capture confirm numeric variable `v'
    if _rc destring `v', replace force
    assert inrange(`v', 1, 5) if !missing(`v')
}
label var rk_price     "Rank: price & discounts (1 = most important)"
label var rk_speed     "Rank: speed of delivery"
label var rk_quality   "Rank: product quality"
label var rk_packaging "Rank: packaging sustainability"
label var rk_returns   "Rank: return & refund policies"

*--------------------------------------------------------------*
* 3. Demographics (alphabetical order is already the right order)
*--------------------------------------------------------------*
encode age_group, gen(age_cat)
encode gender,    gen(gender_cat)
encode residence, gen(residence_cat)
encode orders,    gen(orders_cat)       // 1-3, 4-6, 7-10, More than 10

* Handy flag: the two study cities only (drops "Other")
gen byte two_city = inlist(residence, "Maharashtra", "Delhi")
label var two_city "1 = Maharashtra or Delhi"

*--------------------------------------------------------------*
* 4. Ordered single-choice questions -> numeric with labels
*--------------------------------------------------------------*
* Excess packaging
gen byte excess_n = .
replace excess_n = 0 if excess_pack == "Never"
replace excess_n = 1 if excess_pack == "Rarely"
replace excess_n = 2 if excess_pack == "Sometimes"
replace excess_n = 3 if excess_pack == "Often"
replace excess_n = 4 if excess_pack == "Always"
label define excess_l 0 "Never" 1 "Rarely" 2 "Sometimes" 3 "Often" 4 "Always"
label values excess_n excess_l
label var excess_n "Frequency of excessive packaging"

* Opted for minimal / eco packaging
gen byte opted_n = .
replace opted_n = 0 if strpos(opted_minimal, "not aware") > 0
replace opted_n = 1 if strpos(opted_minimal, "prefer standard") > 0
replace opted_n = 2 if opted_minimal == "Sometimes"
replace opted_n = 3 if opted_minimal == "Yes, always"
label define opted_l 0 "Not aware" 1 "Aware, prefers standard" 2 "Sometimes" 3 "Yes, always"
label values opted_n opted_l
label var opted_n "Opted for minimal/eco packaging"

* Companies making genuine efforts ("Not sure" -> extended missing .a)
gen byte effort_n = .
replace effort_n = 0 if strpos(cos_effort, "not doing enough") > 0
replace effort_n = 1 if strpos(cos_effort, "Somewhat") > 0
replace effort_n = 2 if strpos(cos_effort, "Yes, significantly") > 0
replace effort_n = .a if cos_effort == "Not sure"
label define effort_l 0 "Not doing enough" 1 "Somewhat" 2 "Yes, significantly"
label values effort_n effort_l
label var effort_n "Companies making genuine effort"

* Seen sustainable-packaging campaigns
gen byte campaign_n = .
replace campaign_n = 0 if strpos(campaigns, "never") > 0
replace campaign_n = 1 if campaigns == "Sometimes"
replace campaign_n = 2 if strpos(campaigns, "frequently") > 0
label define camp_l 0 "Never" 1 "Sometimes" 2 "Frequently"
label values campaign_n camp_l
label var campaign_n "Seen sustainable packaging campaigns"

* Willingness to pay Rs 5-20 premium
gen byte premium_n = .
replace premium_n = 0 if strpos(pay_premium, "No,") == 1
replace premium_n = 1 if strpos(pay_premium, "Maybe") == 1
replace premium_n = 2 if strpos(pay_premium, "Yes") == 1
replace premium_n = .a if pay_premium == "Not sure"
label define prem_l 0 "No" 1 "Maybe, if minimal" 2 "Yes, definitely"
label values premium_n prem_l
label var premium_n "Willing to pay Rs 5-20 premium"
gen byte pay_yes = (premium_n == 2) if !missing(premium_n)
label var pay_yes "1 = definitely willing to pay"

* Accept slower delivery
gen byte slower_n = .
replace slower_n = 0 if strpos(accept_slower, "No,") == 1
replace slower_n = 1 if strpos(accept_slower, "only if") > 0
replace slower_n = 2 if strpos(accept_slower, "non-urgent") > 0
label define slow_l 0 "No" 1 "Only if minimal difference" 2 "Yes, non-urgent items"
label values slower_n slow_l
label var slower_n "Accept slower delivery"

* Legal requirement for platforms ("Not sure" -> .a)
gen byte legal_n = .
replace legal_n = 0 if strpos(legal_req, "No,") == 1
replace legal_n = 1 if strpos(legal_req, "industry cooperation") > 0
replace legal_n = 2 if strpos(legal_req, "strict policies") > 0
replace legal_n = .a if legal_req == "Not sure"
label define legal_l 0 "No" 1 "Yes, with industry cooperation" 2 "Yes, strict policies"
label values legal_n legal_l
label var legal_n "Should law require less packaging waste"

* Would join a return/reuse program
gen byte return_n = .
replace return_n = 0 if strpos(return_prog, "No,") == 1
replace return_n = 1 if strpos(return_prog, "Maybe") == 1
replace return_n = 2 if strpos(return_prog, "Yes, definitely") == 1
label define ret_l 0 "No" 1 "Maybe, if convenient" 2 "Yes, definitely"
label values return_n ret_l
label var return_n "Would join packaging return program"

*--------------------------------------------------------------*
* 5. Nominal single-choice questions -> short labels, then encode
*--------------------------------------------------------------*
gen str20 s = ""
replace s = "Household trash" if strpos(disposal, "household trash") > 0
replace s = "Reuse"           if strpos(disposal, "Reuse") > 0
replace s = "Kabadiwala"      if strpos(disposal, "kabadiwala") > 0
replace s = "Recycle"         if strpos(disposal, "recycle") > 0
encode s, gen(disposal_cat)
label var disposal_cat "What respondent does with packaging"
drop s

gen str30 s = ""
replace s = "Avoids/eco choices" if strpos(reduce_waste, "Yes, I avoid") > 0
replace s = "Sometimes"          if strpos(reduce_waste, "Sometimes") > 0
replace s = "Not thought about"  if strpos(reduce_waste, "thought much") > 0
replace s = "Not a problem"      if strpos(reduce_waste, "see it as a problem") > 0
encode s, gen(reduce_cat)
label var reduce_cat "Actively tries to reduce packaging waste"
drop s

gen str30 s = ""
replace s = "Multiple times"    if strpos(contacted_co, "multiple times") > 0
replace s = "Once or twice"     if strpos(contacted_co, "once or twice") > 0
replace s = "No, would consider" if strpos(contacted_co, "would consider") > 0
replace s = "No, pointless"     if strpos(contacted_co, "make a difference") > 0
encode s, gen(contacted_cat)
label var contacted_cat "Contacted company about packaging"
drop s

gen str30 s = ""
replace s = "Consumer awareness" if strpos(challenge, "consumer awareness") > 0
replace s = "No alternatives"    if strpos(challenge, "sustainable alternatives") > 0
replace s = "High cost"          if strpos(challenge, "High cost") > 0
replace s = "Weak policy"        if strpos(challenge, "Weak government") > 0
encode s, gen(challenge_cat)
label var challenge_cat "Biggest challenge"
drop s

*--------------------------------------------------------------*
* 6. Multi-select questions -> 0/1 dummies (one per option)
*    strpos() avoids splitting on commas inside option text
*--------------------------------------------------------------*
* Products
gen byte prod_fashion     = strpos(products, "Fashion") > 0
gen byte prod_grocery     = strpos(products, "Groceries") > 0
gen byte prod_health      = strpos(products, "Health") > 0
gen byte prod_electronics = strpos(products, "Electronics") > 0
gen byte prod_home        = strpos(products, "Home & Kitchen") > 0
gen byte prod_other = (prod_fashion + prod_grocery + prod_health + ///
                       prod_electronics + prod_home == 0) & products != ""

* Platforms (free-text "other" answers: lower-case and match variants)
gen plat_l = lower(platforms)
gen byte plat_amazon   = strpos(plat_l, "amazon") > 0
gen byte plat_flipkart = strpos(plat_l, "flipkart") > 0
gen byte plat_myntra   = strpos(plat_l, "myntra") > 0
gen byte plat_blinkit  = strpos(plat_l, "blinkit") > 0 | strpos(plat_l, "blink it") > 0
gen byte plat_zepto    = strpos(plat_l, "zepto") > 0
gen byte plat_bigbask  = strpos(plat_l, "bigbasket") > 0 | strpos(plat_l, "big basket") > 0
gen byte plat_nykaa    = strpos(plat_l, "nykaa") > 0
gen byte plat_meesho   = strpos(plat_l, "meesho") > 0
gen byte plat_ajio     = strpos(plat_l, "ajio") > 0
gen byte plat_food     = strpos(plat_l, "swiggy") > 0 | strpos(plat_l, "zomato") > 0
egen byte plat_main = rowtotal(plat_amazon plat_flipkart plat_myntra plat_blinkit ///
                               plat_zepto plat_bigbask plat_nykaa plat_meesho ///
                               plat_ajio plat_food)
gen byte plat_other = (plat_main == 0) & platforms != ""
drop plat_l plat_main

* Packaging materials noticed
gen byte mat_plastic   = strpos(materials, "Plastic") > 0
gen byte mat_cardboard = strpos(materials, "Cardboard") > 0
gen byte mat_paper     = strpos(materials, "Paper-based") > 0
gen byte mat_biodeg    = strpos(materials, "Biodegradable") > 0

* What would encourage sustainable choices
gen byte inc_discount = strpos(incentives, "Discounts") > 0
gen byte inc_label    = strpos(incentives, "Clear labeling") > 0
gen byte inc_govreg   = strpos(incentives, "Government regulations") > 0
gen byte inc_campaign = strpos(incentives, "Social awareness") > 0
gen byte inc_none     = strpos(incentives, "None of the above") > 0

* Most effective policy (up to two choices)
gen byte pol_plasticlimit = strpos(policy_pref, "Government-imposed") > 0
gen byte pol_reuse        = strpos(policy_pref, "Return-and-reuse") > 0
gen byte pol_taxbreak     = strpos(policy_pref, "Special tax") > 0
gen byte pol_community    = strpos(policy_pref, "Community recycling") > 0
gen byte pol_activism     = strpos(policy_pref, "Customer-led") > 0

* Sanity checks: policy question allows max two picks
egen byte n_pol = rowtotal(pol_*)
tab n_pol

*--------------------------------------------------------------*
* 7. Labels for the dummies, then keep original text and save
*--------------------------------------------------------------*
label define yesno 0 "No" 1 "Yes"
foreach v of varlist prod_* plat_* mat_* inc_* pol_* {
    label values `v' yesno
}

order resp_id submitted submit_date age_cat gender_cat residence_cat two_city orders_cat
compress
save "packaging_clean.dta", replace
export delimited using "packaging_clean.csv", replace

*--------------------------------------------------------------*
* 8. Quick checks
*--------------------------------------------------------------*
count
misstable summarize
tab residence_cat
tab premium_n residence_cat if two_city, col nofreq
summarize rk_price rk_speed rk_quality rk_packaging rk_returns
foreach v of varlist plat_* mat_* inc_* pol_* {
    quietly summarize `v'
    display %-20s "`v'" "  share = " %5.3f r(mean)
}
