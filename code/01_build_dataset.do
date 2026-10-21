*==============================================================================
* Labour informality among private-sector employees in Peru, 2018-2022
* 01_build_dataset.do: merges the ENAHO modules and builds the analysis variables
*------------------------------------------------------------------------------
* Author: Dax Mancilla
* Input:  ENAHO modules 100, 200, 300, 500 and sumaria, 2018-2022 ($enaho/<year>/)
* Output: $data/enaho_full.dta (all variables) and $data/base_final.dta
* Note:   value labels are kept in Spanish, as in the INEI questionnaire
*==============================================================================

global key_hh  conglome vivienda hogar
global key_ind conglome vivienda hogar codperso

*==============================================================================
* 1. Merge the modules, year by year, and stack the years
*==============================================================================
tempfile panel

forvalues x = 2018/2022 {

    tempfile m300 m500 m100 m200 msum

    * Module 300: education
    use if inlist(p204,1,2) using "$enaho/`x'/enaho01a-`x'-300.dta", clear
    rename _all, lower
    keep $key_ind p300a p301a p301b p301b1 p301a1 p301c p301d p302a p302b p303 p304a p304b p304c p304d p305 p306 p307* p308a p308b p308c p308d p310 *311* *312* fac*
    destring $key_ind, replace
    save `m300'

    * Module 500: employment
    use if inlist(p204,1,2) using "$enaho/`x'/enaho01a-`x'-500.dta", clear
    rename _all, lower
    keep $key_ind p501 p505 p506 p507 p508 p509 p510 p510a p510b p511a p512a p512b p514 p515* ocu500 p517 p521 p521a p552 i513t i518 p519 i520 d529t d536 d540t d543 d544t i524a1 i530a i538a1 i541a p558* p546 d5564c d5565c ocupinf emplpsec fac*
    destring $key_ind, replace
    save `m500'

    * Module 100: dwelling and household
    use if inlist(result,1,2) using "$enaho/`x'/enaho01-`x'-100.dta", clear
    rename _all, lower
    keep $key_hh p101 p102 p103 p103a p104 p105a p106a p110 p1121 p1132 p1133 p113a p1141 p1142 p1143 p1144 nbi* fac* mes ubigeo dominio estrato
    destring $key_hh, replace
    save `m100'

    * Module 200: household members
    use if inlist(p204,1,2) & p203!=0 using "$enaho/`x'/enaho01-`x'-200.dta", clear
    rename _all, lower
    keep $key_ind p203* p204 p205 p206 p207 p208a p209 fac*
    destring $key_ind, replace
    save `m200'

    * Sumaria: poverty, income and expenditure
    use "$enaho/`x'/sumaria-`x'.dta", clear
    rename _all, lower
    keep $key_hh pobreza* linea linpe percepho mieperho totmieho estrsocial fac* inghog1d gashog2d
    destring $key_hh, replace
    save `msum'

    * Merge
    use `m300', clear
    merge 1:1 $key_ind using `m200', gen(merge200) keep(1 3)
    merge 1:1 $key_ind using `m500', gen(merge500) keep(1 3)
    merge m:1 $key_hh  using `m100', gen(merge100) keep(1 3)
    merge m:1 $key_hh  using `msum', gen(mergesum) keep(1 3)
    gen anio = `x'
    order anio mes, first

    if `x' > 2018 {
        append using `panel', force
    }
    save `panel', replace
}

use `panel', clear

*==============================================================================
* 2. Socio-demographic variables
*==============================================================================

* Area and geographic domain
recode estrato (1/5=1 "Urbano") (6/8=2 "Rural"), gen(area)
recode dominio (8=1 "Lima Metropolitana") (1/3=2 "Costa") (4/6=3 "Sierra") (7=4 "Selva"), gen(dominior)
lab var area     "Ámbito geográfico"
lab var dominior "Dominio geográfico"

* Departments
gen dpto = substr(ubigeo,1,2)
destring dpto, replace
lab def dpto 1"Amazonas" 2"Ancash" 3"Apurímac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Prov. Const. del Callao" 8"Cusco" 9"Huancavelica" 10"Huánuco" 11"Ica" 12"Junín" 13"La Libertad" 14"Lambayeque" 15"Lima y Callao" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martín" 23"Tacna" 24"Tumbes" 25"Ucayali"
lab val dpto dpto
lab var dpto "Departamentos"

* Departments, splitting Metropolitan Lima and Lima provinces
gen dpto2 = dpto if dpto<16
replace dpto2 = 16 if dpto==15 & dominio!=8
replace dpto2 = dpto+1 if dpto>=16
lab def dpto2 1"Amazonas" 2"Ancash" 3"Apurímac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Prov. Const. del Callao" 8"Cusco" 9"Huancavelica" 10"Huánuco" 11"Ica" 12"Junín" 13"La Libertad" 14"Lambayeque" 15"Lima Metropolitana" 16"Lima Provincias" 17"Loreto" 18"Madre de Dios" 19"Moquegua" 20"Pasco" 21"Piura" 22"Puno" 23"San Martín" 24"Tacna" 25"Tumbes" 26"Ucayali"
lab val dpto2 dpto2

* Usual residents (INEI filter for employment indicators)
gen miembro = p204
gen residentes = (((p204==1 & p205==2) | (p204==2 & p206==1)) & p501!=.)
lab var residentes "Filtro de residentes habituales (para empleo, PET)"

* Sex
recode p207 (2=0 "Mujeres") (1=1 "Hombres"), gen(sexo)
lab var sexo "Sexo: Mujeres=0; Hombres=1"

* Age groups
rename p208a edad
recode edad (15/29=1 "De 15 a 29 años") (30/59=2 "De 30 a 59 años") (60/max=3 "De 60 a más años") (else=.), gen(gedad)
lab var edad  "Edad en años"
lab var gedad "Grupos de edad"

* Marital status
gen     civil = 1 if inlist(p209,6)
replace civil = 2 if inlist(p209,1,2)
replace civil = 3 if inlist(p209,3,4,5)
lab def civil 1"Soltero" 2"Con pareja" 3"Tuvo pareja"
lab val civil civil
lab var civil "Estado civil"

* Mother tongue
gen     lengua = 1 if inlist(p300a,1,2,3,10,11,12,13,14,15)
replace lengua = 2 if inlist(p300a,4)
replace lengua = 3 if inlist(p300a,5,6,7)
lab def lengua 1"Indígena" 2"Castellano" 3"Otra lengua extranjera"
lab val lengua lengua
lab var lengua "Lengua materna"

* Ethnic self-identification
gen     etnia = 1 if inlist(p558c,5)
replace etnia = 2 if inlist(p558c,6)
replace etnia = 3 if inlist(p558c,1,2,3,9)
replace etnia = 4 if inlist(p558c,4)
replace etnia = 5 if inlist(p558c,7,8)
lab def etnia 1"Blanco" 2"Mestizo" 3"Indígenas" 4"Afrodescendientes" 5"Otros/No sabe/No responde"
lab val etnia etnia
lab var etnia "Autopercepción étnica"

recode etnia (1/2=0 "Blanco/mestizo") (3/4=1 "Indígena y afrodescendientes") (else=.), gen(etnia2)
lab var etnia2 "Autopercepción étnica (agrupada)"

* Children in the family nucleus
bys anio $key_hh p203a: gen  aux_1 = (p203b==3)
bys anio $key_hh p203a: egen aux_2 = total(aux_1)
gen     conhijos = (inlist(p203b,1,2) & aux_2>0)
gen     nhijos   = aux_2 if inlist(p203b,1,2)
replace nhijos   = 0 if nhijos==.
drop aux_*
lab def conhijos 0"Sin hijo" 1"Con hijo"
lab val conhijos conhijos
lab var conhijos "Tenencia de hijos en núcleo familiar"

*==============================================================================
* 3. Household variables (module 100)
*==============================================================================
recode p110 (4/8=1 "Sin agua por red pública o pilón") (1/3=0 "Con agua por red pública o pilón"), gen(agua)
lab var agua "Falta de acceso a agua por red pública o pilón"

recode p1121 (0=1 "Sin electricidad") (1=0 "Con electricidad"), gen(elec)
lab var elec "Falta de acceso a electricidad"

recode p1144 (0=1 "Sin internet") (1=0 "Con internet"), gen(internet)
lab var internet "Falta de acceso a internet en el hogar"

*==============================================================================
* 4. Education (module 300)
*==============================================================================
recode p301a (1/4 12=1 "Primaria o menos") (5/6=2 "Secundaria") (7/11=3 "Educación superior"), gen(nivel_educ)
lab var nivel_educ "Nivel educativo culminado"

* Years of schooling
gen     escol = 0  if (p301a==1 | p301a==2)
replace escol = 0  if (p301a==3 & p301b==0)
forvalues g = 1/5 {
    replace escol = `g' if (p301a==3 & p301b==`g')
}
replace escol = 6  if (p301a==4 & inlist(p301b,5,6))
replace escol = 7  if (p301a==5 & p301b==1)
replace escol = 8  if (p301a==5 & p301b==2)
replace escol = 9  if (p301a==5 & p301b==3)
replace escol = 10 if (p301a==5 & inlist(p301b,4,5))
replace escol = 11 if (p301a==6 & inlist(p301b,5,6))
replace escol = 12 if (p301a==7 & p301b==1)
replace escol = 13 if (p301a==7 & p301b==2)
replace escol = 14 if (p301a==7 & inlist(p301b,3,4))
replace escol = 14 if (p301a==8 & inlist(p301b,3,4))
replace escol = 15 if (p301a==8 & p301b==5)
replace escol = 12 if (p301a==9 & p301b==1)
replace escol = 13 if (p301a==9 & p301b==2)
replace escol = 14 if (p301a==9 & p301b==3)
replace escol = 15 if (p301a==9 & inlist(p301b,4,5,6))
replace escol = 16 if (p301a==10 & inlist(p301b,4,5,6,7))
replace escol = 17 if (p301a==11 & p301b==1)
replace escol = 18 if (p301a==11 & p301b==2)
* Primary education reported in grades (p301c) instead of years
forvalues g = 1/5 {
    replace escol = `g' if (p301a==3 & p301c==`g')
}
replace escol = 6  if (p301a==4 & inlist(p301c,5,6))
replace escol = .  if (p301a==. | p301b==12)
lab var escol "Años de escolaridad"

*==============================================================================
* 5. Labour variables (module 500)
*==============================================================================

* Informality (INEI definition, variable ocupinf)
recode ocupinf (1=1 "Informal") (2=0 "Formal"), gen(informal)
lab var informal "Situación de informalidad"
tab anio informal [iw=fac500a]

* Potential experience
gen exper = edad - escol - 5
replace exper = 0 if exper<=0
lab var exper "Experiencia potencial (años)"
gen exper2 = exper^2
lab var exper2 "Experiencia potencial al cuadrado"

* Employment status (main job)
gen     sempleo = 1  if (ocu500==1 & (p507==1 | p509==1))
replace sempleo = 2  if (ocu500==1 & (p507==3 & inrange(p510,3,7)))
replace sempleo = 3  if (ocu500==1 & (p507==3 & inlist(p510,1,2)))
replace sempleo = 4  if (ocu500==1 & (p507==4 & inrange(p510,3,7)))
replace sempleo = 5  if (ocu500==1 & (p507==4 & inlist(p510,1,2)))
replace sempleo = 6  if (ocu500==1 & (p507==2 | (p507==1 & p509==2)))
replace sempleo = 7  if (ocu500==1 & inlist(p507,5,7))
replace sempleo = 8  if (ocu500==1 & p507==6)
replace sempleo = 9  if (ocu500==1 & p507==.)
replace sempleo = 10 if inlist(ocu500,2,3,4)
lab def sempleo 1"Empleador" 2"Empleado privado" 3"Empleado público" 4"Obrero privado" 5"Obrero público" 6"Independiente" 7"Trab. familiar no remunerado" 8"Trabajador del hogar" 9"No especificado" 10"No ocupado"
lab val sempleo sempleo
lab var sempleo "Situación en el empleo (ocup. princ.)"

gen     cat_ocup = .
replace cat_ocup = 1  if (ocu500==1 & inlist(sempleo,2,4))
replace cat_ocup = 2  if (ocu500==1 & inlist(sempleo,3,5))
replace cat_ocup = 3  if (ocu500==1 & sempleo==8)
replace cat_ocup = 4  if (ocu500==1 & sempleo==1)
replace cat_ocup = 5  if (ocu500==1 & sempleo==6)
replace cat_ocup = 6  if (ocu500==1 & sempleo==7)
replace cat_ocup = 9  if (ocu500==1 & sempleo==.)
replace cat_ocup = 10 if inlist(ocu500,2,3,4)
lab def cat_ocup 1"Asalariado privado" 2"Asalariado público" 3"Trabajador del hogar" 4"Empleador" 5"Independiente" 6"Trab. familiar no remunerado" 9"No especificado" 10"No ocupado"
lab val cat_ocup cat_ocup
lab var cat_ocup "Categoría ocupacional (ocup. princ.)"

* Firm size
gen     tam_emp = 1  if ocu500==1 & p512b==1
replace tam_emp = 2  if ocu500==1 & inrange(p512b,2,10)
replace tam_emp = 3  if ocu500==1 & (inrange(p512b,11,50) | p512a==2)
replace tam_emp = 4  if ocu500==1 & (inrange(p512b,51,100) | p512a==3)
replace tam_emp = 5  if ocu500==1 & (inrange(p512b,101,500) | p512a==4)
replace tam_emp = 6  if ocu500==1 & (inrange(p512b,501,9998) | p512a==5 | p510==1)
replace tam_emp = 7  if ocu500==1 & ((p512a==1 & p512b==.) | (p512a==9 & p512b==9999))
replace tam_emp = 7  if ocu500==1 & tam_emp==.
replace tam_emp = 10 if inlist(ocu500,2,3,4)
lab def tam_emp 1"1 trabajador" 2"2 a 10 trab." 3"11 a 50 trab." 4"51 a 100 trab." 5"101 a 500 trab." 6"501 a más trab." 7"No especificado" 10"No ocupado"
lab val tam_emp tam_emp
lab var tam_emp "Tamaño de empresa (ocup. princ.)"

recode tam_emp (1=1) (2=2) (3/4=3) (5/6=4) (7=5) (10=10) if ocu500==1, gen(tam_emp2)
lab def tam_emp2 1"Trabaja solo" 2"Microempresa (hasta 10 trab.)" 3"Pequeña y mediana empresa (11 a 100 trab.)" 4"Gran empresa (101 y más trab.)" 5"No especificado" 10"No ocupado"
lab val tam_emp2 tam_emp2
lab var tam_emp2 "Tamaño de empresa (ocup. princ.)"

* Pension affiliation
gen     pension = 1 if (p558a1==1 | p558a2==2 | p558a3==3 | p558a4==4)
replace pension = 0 if (p558a5==5)
lab def pension 1"Afiliado" 0"No afiliado"
lab val pension pension
lab var pension "Afiliado a un sistema de pensiones"

* Weekly hours
egen    horas = rsum(i513t i518) if (ocu500==1 & p519==1)
replace horas = i520 if (ocu500==1 & p519==2)
replace horas = .    if ocu500!=1
lab var horas "Horas normales semanales (ocup. princ. y secun.)"

gen     horas_prin = i513t if (ocu500==1 & p519==1)
replace horas_prin = i520  if (ocu500==1 & p519==2)
replace horas_prin = .     if ocu500!=1
lab var horas_prin "Horas normales semanales (ocup. princ.)"

gen     rangohora = .
replace rangohora = 1 if ocu500==1 & horas<15
replace rangohora = 2 if ocu500==1 & horas>=15 & horas<35
replace rangohora = 3 if ocu500==1 & horas>=35 & horas<48
replace rangohora = 4 if ocu500==1 & horas==48
replace rangohora = 5 if ocu500==1 & horas>48 & horas<60
replace rangohora = 6 if ocu500==1 & horas>=60 & horas<.
replace rangohora = 7 if ocu500==1 & horas==.
replace rangohora = 8 if inlist(ocu500,2,3,4)
lab def rangohora 1"Menos de 15 horas" 2"De 15 a 34 horas" 3"De 35 a 47 horas" 4"48 horas" 5"De 49 a 59 horas" 6"De 60 a más horas" 7"No especifica" 8"No ocupado"
lab val rangohora rangohora
lab var rangohora "Rango de horas normales semanales"

recode rangohora (1/2=1 "Menos de 35 horas") (3/5=2 "De 35 a 59 horas") (6=3 "De 60 a más horas") (7=4 "No especifica") (8=5 "No ocupado"), gen(rangohora2)
lab var rangohora2 "Rango de horas normales semanales (agrupado)"

* Monthly labour income
foreach v in d529t d536 d540t d543 d544t {
    replace `v' = . if `v'==999999
}
egen ing_pri = rsum(i524a1 d529t i530a d536) if ocu500==1
egen ing_sec = rsum(i538a1 d540t i541a d543) if ocu500==1
gen  ing_ext = d544t
egen ingreso = rsum(ing_pri ing_sec ing_ext) if ocu500==1
foreach v in ingreso ing_pri ing_sec ing_ext {
    replace `v' = `v'/12
}
lab var ingreso "Ingreso laboral mensual (ocup. princ. y secun.)"
lab var ing_pri "Ingreso laboral mensual (ocup. princ.)"
lab var ing_sec "Ingreso laboral mensual (ocup. secun.)"
lab var ing_ext "Ingreso laboral mensual (extraordinarios)"

* Minimum wage (RMV) in force each month
gen     rmv = 850  if anio==2018 & inlist(mes,"01","02","03")
replace rmv = 930  if anio==2018 & !inlist(mes,"01","02","03")
replace rmv = 930  if inlist(anio,2019,2020,2021)
replace rmv = 930  if anio==2022 & inlist(mes,"01","02","03","04")
replace rmv = 1025 if anio==2022 & !inlist(mes,"01","02","03","04")
lab var rmv "Remuneración Mínima Vital"

* Income relative to the minimum wage
gen     rango_ing = 2 if ingreso <  rmv
replace rango_ing = 3 if ingreso >= rmv   & ingreso <= rmv*2
replace rango_ing = 4 if ingreso >  rmv*2 & ingreso <= 100000
replace rango_ing = 1 if ingreso==0 | cat_ocup==6
replace rango_ing = 5 if inlist(ocu500,2,3,4)
lab def rango_ing 1"Sin ingresos" 2"Menos de 1 RMV" 3"1-2 RMV" 4"Más de 2 RMV" 5"No ocupado"
lab val rango_ing rango_ing
lab var rango_ing "Ingreso laboral según RMV"

recode rango_ing (1=1 "Sin ingresos") (2=2 "Menos de 1 RMV") (3/4=3 "De 1 RMV a más") (5=4 "No ocupado"), gen(rango_ing2)
lab var rango_ing2 "Ingreso laboral según RMV (agrupado)"

* Economic activity (CIIU Rev. 3, main job)
replace p506 = 1549 if p506==1059
replace p506 = 7499 if p506==7199
gen     ramas = .
replace ramas = 1  if ocu500==1 & inlist(p506,111,112,113,121,122,130,140,150,200,500)
replace ramas = 2  if ocu500==1 & inlist(p506,1010,1020,1030,1110,1120,1200,1310,1320,1410,1421,1422,1429)
replace ramas = 3  if ocu500==1 & inrange(p506,1511,3729)
replace ramas = 4  if ocu500==1 & inlist(p506,4010,4020,4030,4100)
replace ramas = 5  if ocu500==1 & inlist(p506,4510,4520,4530,4540,4550)
replace ramas = 6  if ocu500==1 & inrange(p506,5010,5529)
replace ramas = 7  if ocu500==1 & inrange(p506,6010,6429)
replace ramas = 8  if ocu500==1 & inrange(p506,6511,7499)
replace ramas = 9  if ocu500==1 & inrange(p506,7511,9900)
replace ramas = 10 if ocu500==1 & (p506==9999 | p506==.)
lab def ramas 1"Agricultura, silvicultura, caza y pesca" 2"Explotación de minas y canteras" 3"Industria manufacturera" 4"Electricidad, gas y agua" 5"Construcción" 6"Comercio, restaurantes y hoteles" 7"Transporte, almacenamiento y comunicaciones" 8"Servicios financieros y a empresas" 9"Servicios comunales, sociales y personales" 10"Actividades no especificadas"
lab val ramas ramas
lab var ramas "Actividad económica (ocup. princ.)"

recode ramas (1/2=1 "Extractiva") (4 7/9=2 "Servicios") (3=3 "Industria") (6=4 "Comercio") (5=5 "Construcción") (else=.), gen(ramas2)
lab var ramas2 "Actividad económica (agrupada)"

*==============================================================================
* 6. Household income, poverty and social stratum (sumaria)
*==============================================================================
gen ingreso_hogar = inghog1d/(12*mieperho)
gen gasto_hogar   = gashog2d/(12*mieperho)
lab var ingreso_hogar "Ingreso bruto mensual per cápita del hogar"
lab var gasto_hogar   "Gasto bruto mensual per cápita del hogar"

recode pobreza    (1/2=1 "Pobre") (3=0 "No pobre"), gen(pobre)
recode pobrezav   (1/2=1 "Pobre") (3=2 "Vulnerable no pobre") (4=3 "No vulnerable"), gen(pobrev)
recode estrsocial (1/2=1 "Estrato A") (3/4=2 "Estrato B") (5/6=3 "Estrato C"), gen(social)

*==============================================================================
* 7. Save
*==============================================================================
save "$data/enaho_full.dta", replace

keep anio mes $key_ind ubigeo dominio estrato mieperho totmieho area dominior dpto dpto2 miembro residentes sexo edad gedad civil lengua etnia etnia2 conhijos nhijos agua elec internet nivel_educ escol informal exper exper2 cat_ocup tam_emp2 pension horas horas_prin rangohora2 ingreso rmv rango_ing2 ramas ramas2 ingreso_hogar gasto_hogar pobrev social pobre factor07 fac500a

save "$data/base_final.dta", replace
