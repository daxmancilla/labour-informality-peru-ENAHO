*==============================================================================
* Labour informality among private-sector employees in Peru, 2018-2022
* 00_master.do: sets the paths and runs the whole pipeline
*------------------------------------------------------------------------------
* Author: Dax Mancilla
* Data:   ENAHO, Encuesta Nacional de Hogares (INEI), 2018-2022
*==============================================================================

clear all
set more off
version 16

*------------------------------------------------------------------------------
* 1. Paths (edit these two lines only)
*------------------------------------------------------------------------------
global root  "C:/path/to/labour-informality-peru"   // folder of this repository
global enaho "C:/path/to/enaho"                     // ENAHO microdata, one subfolder per year (e.g. enaho/2022/)

global code   "$root/code"
global data   "$root/data"
global output "$root/output"
cap mkdir "$data"
cap mkdir "$output"

*------------------------------------------------------------------------------
* 2. User-written packages (run once)
*------------------------------------------------------------------------------
* ssc install outreg2
* ssc install xtable
* net install spost13_ado, from(https://jslsoc.sitehost.iu.edu/stata)   // fitstat

*------------------------------------------------------------------------------
* 3. Pipeline
*------------------------------------------------------------------------------
do "$code/01_build_dataset.do"    // merge ENAHO modules and build the variables
do "$code/02_descriptive.do"      // survey-weighted descriptive tables
do "$code/03_estimation.do"       // logit models, marginal effects and diagnostics
