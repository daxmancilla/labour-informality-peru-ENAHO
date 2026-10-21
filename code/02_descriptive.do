*==============================================================================
* Labour informality among private-sector employees in Peru, 2018-2022
* 02_descriptive.do: survey-weighted descriptive tables
*------------------------------------------------------------------------------
* Author: Dax Mancilla
* Input:  $data/base_final.dta
* Output: $output/descriptive_tables.xlsx (one sheet per table)
* Needs:  xtable (ssc install xtable)
*==============================================================================

use "$data/base_final.dta", clear

*------------------------------------------------------------------------------
* 1. Survey design and analysis sample
*------------------------------------------------------------------------------
* Clusters and strata are made unique by year, because the years are pooled
egen psu       = group(anio conglome)
egen strata_id = group(anio estrato)
svyset psu [pweight=fac500a], strata(strata_id) vce(linearized) singleunit(centered)

* Usual residents working as private-sector employees
gen sample = (residentes==1 & cat_ocup==1)

global xls "$output/descriptive_tables.xlsx"

*------------------------------------------------------------------------------
* 2. Tables
*------------------------------------------------------------------------------

* T1. Informality by department, 2022
svy, subpop(if sample==1 & anio==2022): tab dpto2 informal, cv percent format(%4.1f) row
xtable dpto2 informal [iw=fac500a] if sample==1 & anio==2022, filename("$xls") col row sheet(t01_department, replace) format(%12.0f)

* T2. Informality by year, 2018-2022
svy, subpop(if sample==1): tab informal anio, cv percent format(%4.1f) col
xtable informal anio [iw=fac500a] if sample==1, filename("$xls") col row sheet(t02_year, replace) format(%12.0f)

* T3. Informal employees by sex, 2022
svy, subpop(if sample==1 & anio==2022 & informal==1): tab sexo, cv percent format(%4.1f) col
xtable informal sexo [iw=fac500a] if sample==1 & anio==2022, filename("$xls") col row sheet(t03_sex, replace) format(%12.0f)

* T4. Informal employees by age group, 2022
svy, subpop(if sample==1 & anio==2022 & informal==1): tab gedad, cv percent format(%4.1f) col
xtable informal gedad [iw=fac500a] if sample==1 & anio==2022, filename("$xls") col row sheet(t04_age, replace) format(%12.0f)

* T5. Informality by education level, 2022
svy, subpop(if sample==1 & anio==2022): tab informal nivel_educ, cv percent format(%4.1f) col
xtable informal nivel_educ [iw=fac500a] if sample==1 & anio==2022, filename("$xls") col row sheet(t05_education, replace) format(%12.0f)

* T6. Informality by ethnic self-identification, 2022
svy, subpop(if sample==1 & anio==2022): tab informal etnia, cv percent format(%4.1f) col
xtable informal etnia [iw=fac500a] if sample==1 & anio==2022, filename("$xls") col row sheet(t06_ethnicity, replace) format(%12.0f)

* T7. Informality by mother tongue, 2022
svy, subpop(if sample==1 & anio==2022): tab informal lengua, cv percent format(%4.1f) col
xtable informal lengua [iw=fac500a] if sample==1 & anio==2022, filename("$xls") col row sheet(t07_language, replace) format(%12.0f)

* T8. Informality by economic activity, 2019, 2020 and 2022
svy, subpop(if sample==1 & anio==2022): tab informal ramas2, cv percent format(%4.1f) col
xtable informal ramas2 anio [iw=fac500a] if sample==1 & inlist(anio,2019,2020,2022), filename("$xls") col row sheet(t08_activity, replace) format(%12.0f)

* T9. Informality by firm size, 2019, 2020 and 2022
svy, subpop(if sample==1 & anio==2022): tab informal tam_emp2, cv percent format(%4.1f) col
xtable informal tam_emp2 anio [iw=fac500a] if sample==1 & inlist(anio,2019,2020,2022), filename("$xls") col row sheet(t09_firm_size, replace) format(%12.0f)

* T10. Mean monthly labour income by informality status and year
svy, subpop(if sample==1): mean ingreso, over(anio informal)
xtable informal anio [iw=fac500a] if sample==1, filename("$xls") c(mean ingreso) col row sheet(t10_income_year, replace) format(%12.0f)

* T11-T13. Income gaps between formal and informal employees, 2022
svy, subpop(if sample==1 & anio==2022): mean ingreso, over(informal sexo)
xtable informal sexo [iw=fac500a] if sample==1 & anio==2022, filename("$xls") c(mean ingreso) col row sheet(t11_income_sex, replace) format(%12.0f)

svy, subpop(if sample==1 & anio==2022): mean ingreso, over(informal nivel_educ)
xtable informal nivel_educ [iw=fac500a] if sample==1 & anio==2022, filename("$xls") c(mean ingreso) col row sheet(t12_income_education, replace) format(%12.0f)

svy, subpop(if sample==1 & anio==2022): mean ingreso, over(informal gedad)
xtable informal gedad [iw=fac500a] if sample==1 & anio==2022, filename("$xls") c(mean ingreso) col row sheet(t13_income_age, replace) format(%12.0f)
