# Labour informality among private-sector employees in Peru, 2018-2022

Stata code to measure and model labour informality among private-sector employees in Peru with household survey microdata (ENAHO, INEI). The pipeline merges the survey modules, builds the labour market variables, produces survey-weighted descriptive tables and estimates logit models with average marginal effects for 2019, 2020 and 2022.

## Question

Which individual, household and job characteristics are associated with informal employment among private-sector employees, and how did these associations change around the COVID-19 shock?

## Data

**Encuesta Nacional de Hogares (ENAHO)**, Instituto Nacional de Estadística e Informática (INEI), annual survey, 2018 to 2022. The microdata are public and can be downloaded from the [INEI microdata portal](https://proyectos.inei.gob.pe/microdatos/). They are not included in this repository.

Modules used for each year:

| Module | File | Content |
|---|---|---|
| 100 | `enaho01-YYYY-100.dta` | Dwelling and household |
| 200 | `enaho01-YYYY-200.dta` | Household members |
| 300 | `enaho01a-YYYY-300.dta` | Education |
| 500 | `enaho01a-YYYY-500.dta` | Employment and income |
| Sumaria | `sumaria-YYYY.dta` | Household income, expenditure and poverty |

Save the files with one folder per year:

```
enaho/
├── 2018/
│   ├── enaho01-2018-100.dta
│   ├── enaho01-2018-200.dta
│   ├── enaho01a-2018-300.dta
│   ├── enaho01a-2018-500.dta
│   └── sumaria-2018.dta
├── 2019/
...
```

## Method

- **Informality:** INEI definition (variable `ocupinf`).
- **Sample:** usual residents (INEI filter for employment indicators) whose main job is as a private-sector employee.
- **Descriptive tables:** survey-weighted estimates with the ENAHO design (employment weight `fac500a`, primary sampling units and strata made unique by year because the years are pooled).
- **Model:** logit of informality on potential experience and its square, education, age group, sex, ethnic self-identification, mother tongue, access to water and internet, weekly hours, firm size and economic activity. Estimated separately for 2019, 2020 and 2022 with sampling weights and standard errors clustered by primary sampling unit. Results are reported as average marginal effects.
- **Extended model:** adds labour income, household expenditure and poverty status. These variables are likely determined together with informality, so their coefficients describe associations, not causal effects.
- **Diagnostics (2022):** pseudo R², Hosmer-Lemeshow test, classification table, sensitivity and specificity by cut-off, and ROC curve.

## Main variables

| Variable | Description |
|---|---|
| `informal` | 1 = informal job, 0 = formal job |
| `exper` | Potential experience: age minus years of schooling minus 5 |
| `escol` | Years of schooling |
| `nivel_educ` | Highest education level completed |
| `gedad` | Age group (15-29, 30-59, 60+) |
| `etnia2` | Indigenous or Afro-Peruvian self-identification |
| `lengua` | Mother tongue |
| `tam_emp2` | Firm size |
| `ramas2` | Economic activity (grouped) |
| `horas` | Usual weekly hours worked |
| `ingreso` | Monthly labour income (soles) |
| `pobre` | Household in monetary poverty |

Value labels follow the Spanish categories of the INEI questionnaire.

## How to run

1. Download the ENAHO modules listed above.
2. Open `code/00_master.do` and edit the two paths: `root` (this repository) and `enaho` (the microdata folder).
3. Install the user-written packages once: `outreg2`, `xtable` and `spost13` (for `fitstat`). The commands are in the master do-file.
4. Run `code/00_master.do`. The data sets are saved in `data/` and the tables and figures in `output/`.

## Repository structure

```
labour-informality-peru/
├── code/
│   ├── 00_master.do          # paths and full pipeline
│   ├── 01_build_dataset.do   # merges ENAHO modules and builds variables
│   ├── 02_descriptive.do     # survey-weighted descriptive tables
│   └── 03_estimation.do      # logit, marginal effects and diagnostics
├── data/                     # created by the code (not tracked)
└── output/                   # created by the code (not tracked)
```

## Author

Dax Mancilla, economist (M.Sc. Applied Economics, Universidad Complutense de Madrid). [LinkedIn](https://linkedin.com/in/dax-mancilla-575b0814a)
