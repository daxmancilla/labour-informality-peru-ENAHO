*==============================================================================
* Labour informality among private-sector employees in Peru, 2018-2022
* 03_estimation.do: logit models, average marginal effects and diagnostics
*------------------------------------------------------------------------------
* Author: Dax Mancilla
* Input:  $data/base_final.dta
* Output: $output/logit_coefficients.xls, $output/marginal_effects.xls,
*         $output/marginal_effects_extended.xls, $output/roc_2022.png
* Needs:  outreg2 (ssc install outreg2), fitstat (spost13)
*==============================================================================

use "$data/base_final.dta", clear

* Usual residents working as private-sector employees
gen sample = (residentes==1 & cat_ocup==1)

* Clusters made unique by year (standard errors clustered by PSU)
egen psu = group(anio conglome)

*------------------------------------------------------------------------------
* 1. Specifications (same reference categories in every year)
*------------------------------------------------------------------------------
* Core: individual, household and job characteristics
global x_core "c.exper##c.exper b3.nivel_educ b2.gedad b1.sexo i.etnia2 i.lengua i.agua i.internet horas b3.tam_emp2 b4.ramas2"

* Extended: adds labour income, household expenditure and poverty. These are
* likely determined together with informality, so read them as associations.
global x_ext "$x_core ingreso gasto_hogar i.pobre"

*------------------------------------------------------------------------------
* 2. Logit with sampling weights, by year
*------------------------------------------------------------------------------
foreach y in 2019 2020 2022 {
    foreach m in core ext {
        logit informal ${x_`m'} [pw=fac500a] if sample==1 & anio==`y', vce(cluster psu)
        estimates store logit_`m'_`y'

        * Average marginal effects
        margins, dydx(*) post
        estimates store ame_`m'_`y'
    }
}

outreg2 [logit_core_2019 logit_core_2020 logit_core_2022] using "$output/logit_coefficients.xls", replace dec(3)
outreg2 [ame_core_2019 ame_core_2020 ame_core_2022] using "$output/marginal_effects.xls", replace dec(3)
outreg2 [ame_ext_2019 ame_ext_2020 ame_ext_2022] using "$output/marginal_effects_extended.xls", replace dec(3)

*------------------------------------------------------------------------------
* 3. Diagnostics for the 2022 core model
*------------------------------------------------------------------------------
* These commands do not accept sampling weights, so the model is re-estimated
* without weights only to assess fit and classification.
logit informal $x_core if sample==1 & anio==2022

fitstat                                   // pseudo R2 and information criteria
estat gof, group(10)                      // Hosmer-Lemeshow test
estat classification                      // confusion matrix (cut-off 0.5)
lsens, genprob(cutoff_p) gensens(sensitivity) genspec(specificity)
lroc                                      // ROC curve and area under the curve
graph export "$output/roc_2022.png", replace
