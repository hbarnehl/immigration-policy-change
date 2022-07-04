*Data preparation of ESS file*


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Public Opinion - ESS\ESS1-8e01.dta"
*rename immigration variables*
rename imueclt imcult
rename imbgeco imeco
rename imwbcnt imgood
*delete countries that have years missing and that are not in DEMIG*
drop if inlist(cntry, "BG", "CY", "GR", "HR")
drop if inlist(cntry, "IS", "IT", "LT", "LU", "SK", "TR", "UA")
drop if inlist(cntry, "EE", "IL", "RU")
*delete latest ESS round*
drop if essround == 8
*generate variable "year"*
recode essround (1 = 2002)(2 = 2004)(3 = 2006)(4 = 2008)(5 = 2010)(6 = 2012)(7 = 2014), gen(year)
*drop unnecessary variables
drop cname
drop cedition
drop cproddat
drop name
drop edition
drop dweight
drop pspwght
drop pweight
drop essround
*generate country averages for average immigration opinion*
collapse (mean) imcult imeco imgood, by(cntry year)
*generate average of immigration opinion variables*
gen imav = (imeco+imcult+imgood)/3
*unify country variable
rename cntry country
encode country, gen(countryx)
numlabel, add
recode countryx (3=17)(4=3)(5=7)(6=4)(7=15)(8=5)(9=6)(10=18)(11=8)(12=9)(13=10)(14=11)(15=12)(16=13)(17=16)(18=14)
label define countryx 1 "1. Austria" 2 "2. Belgium" 3 "3. Czech Republic" 4 "4. Denmark" 5 "5. Finland" 6 "6. France" 7 "7. Germany" 8 "8. Hungary" 9 "9. Ireland" 10 "10. Netherlands" 11 "11. Norway" 12 "12. Poland" 13 "13. Portugal" 14 "14. Slovenia" 15 "15. Spain" 16 "16. Sweden" 17 "17. Switzerland" 18 "18. United Kingdom", replace
drop country
rename countryx country

********************************************************************************
*Data preparation of Cumulative Eurobarometer *


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Salience - Eurobarometer\Cumulative Eurobarometer.dta"
*collapse observations to sums per countryear
collapse (sum) crime public econ inflat tax unempl terror defence housing imm healthcare edu pension envi other dunno energy none debt, by (country year)
*exclude countryyears without observations
drop if crime+ public +econ +inflat +tax +unempl +terror +defence +housing +imm +healthcare +edu +pension +envi +other +dunno +energy +none +debt ==0
*create ranking of immigration
bysort year country: gen byte immcrime = imm>crime
bysort year country: gen byte immpub = imm>public
bysort year country: gen byte immecon = imm>econ
bysort year country: gen byte imminflat = imm>inflat
bysort year country: gen byte immtax = imm>tax
bysort year country: gen byte immunempl = imm>unempl
bysort year country: gen byte immterror = imm>terror
bysort year country: gen byte immdefence = imm>defence
bysort year country: gen byte immhousing = imm>housing
bysort year country: gen byte immhealth = imm>healthcare
bysort year country: gen byte immedu = imm>edu
bysort year country: gen byte immpension = imm>pension
bysort year country: gen byte immenvi = imm>envi
bysort year country: gen byte immother = imm>other
bysort year country: gen byte immenergy = imm>energy
bysort year country: gen byte immdebt = imm>debt
bysort country year: gen immrank = immcrime + immpub + immecon +imminflat +immtax +immunempl +immterror +immdefence +immhousing +immhealth +immedu +immpension +immenvi +immother +immenergy +immdebt
recode immrank (0=1)
gen rank = 17 - immrank

*******************************************************************************
*Data Preparation CHES dataset*


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Party Positions - CHES\1999-2014_CHES_dataset_means-3.dta"
*exclude unnecessary variables
keep country year expert party_id party vote seat electionyear family govt immigrate_policy immigra_salience
*give easier names
rename immigrate_policy imres
rename immigra_salience imsal
*add labels
numlabel, add
*exclude countries that are not in DEMIG
drop if inlist(country, 4, 8, 20, 22, 24, 25, 27, 28, 31, 37, 38, 40)
*make government participation a dichotomous file, all half year become no participation
recode govt (.5 = 0)
*unifying country variable
recode country (13=1 Austria)(1=2 Belgium)(3=7 Germany)(2=4 Denmark)(5=15 Spain)(6=6 France)(7=9 Ireland)(10=10 Netherlands)(11=18 United)(12 = 13 Portugal)(14=5 Finland)(16=16 Sweden)(21=3 Czech )(23=8 Hungary)(26=12 Poland)(29=14 Slovenia), gen(nation)
drop country
rename nation country
*clean dataset 
drop expert family
sort country election
*drop double entries
drop if country==18 & year ==2014
drop if country == 9 & year ==2006
drop if country == 6 & year == 2002
drop if country == 5 & year == 1999
drop if country == 2 & year == 2002

*create average immigration score for parliament
bysort party_id:egen partyav = mean(imres)
gen parlshare = seat/100
bysort country election: gen parlav = partyav*parlshare

*create average immigration score for government
gen govseat = seat if govt ==1
bysort country election:egen govshare = pc(govseat), prop
gen govavs = partyav*govshare if govt==1

*create average immigration score for opposition
gen opposeat = seat if govt == 0
bysort country election:egen opposhare = pc(opposeat), prop
gen oppoav = partyav*opposhare if govt==0

*create dichotomous dummy variable "Anti-Immigrant Party"
recode partyav (0 / 6 = 0)(6 / 10 = 1), gen(antiim)

*create new dataset with weighed average of immigrant position parliament and government
collapse (sum) parlav govav oppoav, by(country election)
rename election year

*******************************************************************************
*Data Preparation DEMIG Data [FOR WEIGHTED AVERAGES]


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Immigration Change - DEMIG\demig-policy-database_version-1-3.dta" 
*exclude all entries that are missing proper value for change in restrictiveness*
drop if change_restrict == 999
drop if change_restrict == 9
*exclude all entries before 1980*
keep if year >= 2002
*add labels to numeric values, makes easier to see which country is connected to which label*
numlabel, add
*exclude non-EU countries*
drop if inlist(country, 1, 2, 5, 6, 7, 8, 10, 14, 16, 18, 19, 20, 22, 23, 24, 25, 26, 27, 29, 33, 34, 36, 37, 41, 42, 44, 45)
*drop non-applicable target_origins (EU citizens & citizens
drop if inlist(target_origin, 3, 4)
*drop if policy area not applicable (integration,exit & non-applicable)
drop if inlist(pol_area, 3, 4, 5)
*unify country codings with other datasets
recode country (3=1)(4=2)(9=3)(11=4)(12=5)(13=6)(15=7)(17=8)(21=9)(28=10)(30=11)(31=12)(32=13)(35=14)(38=15)(39=16)(40=17)(43=18)
label define country_clean 1 "1. Austria" 2 "2. Belgium" 3 "3. Czech Republic" 4 "4. Denmark" 5 "5. Finland" 6 "6. France" 7 "7. Germany" 8 "8. Hungary" 9 "9. Ireland" 10 "10. Netherlands" 11 "11. Norway" 12 "12. Poland" 13 "13. Portugal" 14 "14. Slovenia" 15 "15. Spain" 16 "16. Sweden" 17 "17. Switzerland" 18 "18. United Kingdom" 19 "19. India" 20 "20. Indonesia" 21 "21. Ireland" 22 "22. Israel" 23 "23. Italy" 24 "24. Japan" 25 "25. Luxembourg" 26 "26. Mexico" 27 "27. Morocco" 28 "28. Netherlands" 29 "29. New Zealand" 30 "30. Norway" 31 "31. Poland" 32 "32. Portugal" 33 "33. Russia" 34 "34. Slovak Republic" 35 "35. Slovenia" 36 "36. South Africa" 37 "37. South Korea" 38 "38. Spain" 39 "39. Sweden" 40 "40. Switzerland" 41 "41. Turkey" 42 "42. Ukraine" 43 "43. United Kingdom" 44 "44. United States of America" 45 "45. Yugoslavia", replace
*generate weighted change in restrictiveness label
gen wchange = (change_r*change_l)

*Selection of different target groups
*dataset for change with refugees only
gen Refugees=wchange if target_g ==12
*dataset for change with refugees/irregular migrants (all migr., irr., irr. fam., ref.)
gen Refugee_Irregular=wchange if inlist(target_g, 2, 11, 12, 8)
*dataset for change with labour migrants (all migrants, all migrant workers
gen All_Labour=wchange if inlist(target_g, 2, 3, 4, 5, 6, 7)
*dataset for change with labour migrants/irregular migrants 
gen Labour_Irregular=wchange if inlist(target_g, 2, 3, 4, 5, 6, 7, 8, 11)
*dataset for change only with irregular migrants (irregular migrants and their families)
gen Irregular=wchange if inlist(target_g, 11, 8)
*dataset for all (just excluding diaspora, specific categories and international students)
gen All=wchange if inlist(target_g, 13, 14, 9)
*dataset for labour+refugees+irregulars without skilled workers
gen Low_Irr_Ref=wchange if inlist(target_g, 2, 3, 4, 6, 8, 11, 12)
*dataset for low-skilled labour+irregulars
gen Low_Irr=wchange if inlist(target_g, 2, 3, 4, 6, 8, 11)
*dataset for low-skilled labour
gen Low=wchange if inlist(target_g, 2, 3, 4, 6)

*create average change per country/year
collapse Refugees  Refugee_Irregular  All_Labour  Labour_Irregular  Irregular  All  Low_Irr_Ref  Low_Irr  Low , by(country year)
*fill in gaps
recode * (.=0)

********************************************************************************
*Data Preparation DEMIG Data [FOR FREQUENCIES]*


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Immigration Change - DEMIG\demig-policy-database_version-1-3.dta" 
*exclude all entries that are missing proper value for change in restrictiveness*
drop if change_restrict == 999
drop if change_restrict == 9
*exclude all entries before 1980*
keep if year >= 2002
*add labels to numeric values, makes easier to see which country is connected to which label*
numlabel, add
*exclude non-EU countries*
drop if inlist(country, 1, 2, 5, 6, 7, 8, 10, 14, 16, 18, 19, 20, 22, 23, 24, 25, 26, 27, 29, 33, 34, 36, 37, 41, 42, 44, 45)
*drop non-applicable target_origins (EU citizens & citizens
drop if inlist(target_origin, 3, 4)
*drop if policy area not applicable (integration,exit & non-applicable)
drop if inlist(pol_area, 3, 4, 5)
*unify country codings with other datasets
recode country (3=1)(4=2)(9=3)(11=4)(12=5)(13=6)(15=7)(17=8)(21=9)(28=10)(30=11)(31=12)(32=13)(35=14)(38=15)(39=16)(40=17)(43=18)
label define country_clean 1 "1. Austria" 2 "2. Belgium" 3 "3. Czech Republic" 4 "4. Denmark" 5 "5. Finland" 6 "6. France" 7 "7. Germany" 8 "8. Hungary" 9 "9. Ireland" 10 "10. Netherlands" 11 "11. Norway" 12 "12. Poland" 13 "13. Portugal" 14 "14. Slovenia" 15 "15. Spain" 16 "16. Sweden" 17 "17. Switzerland" 18 "18. United Kingdom" 19 "19. India" 20 "20. Indonesia" 21 "21. Ireland" 22 "22. Israel" 23 "23. Italy" 24 "24. Japan" 25 "25. Luxembourg" 26 "26. Mexico" 27 "27. Morocco" 28 "28. Netherlands" 29 "29. New Zealand" 30 "30. Norway" 31 "31. Poland" 32 "32. Portugal" 33 "33. Russia" 34 "34. Slovak Republic" 35 "35. Slovenia" 36 "36. South Africa" 37 "37. South Korea" 38 "38. Spain" 39 "39. Sweden" 40 "40. Switzerland" 41 "41. Turkey" 42 "42. Ukraine" 43 "43. United Kingdom" 44 "44. United States of America" 45 "45. Yugoslavia", replace

*dataset for change with refugees only
keep if target_g ==12
*dataset for change with refugees/irregular migrants (all migr., irr., irr. fam., ref.)
keep if inlist(target_g, 2, 11, 12, 8)
*dataset for change with labour migrants (all migrants, all migrant workers
keep if inlist(target_g, 2, 3, 4, 5, 6, 7)
*dataset for change with labour migrants/irregular migrants 
keep if inlist(target_g, 2, 3, 4, 5, 6, 7, 8, 11)
*dataset for change only with irregular migrants (irregular migrants and their families)
keep if inlist(target_g, 11, 8)
*dataset for all (just excluding diaspora, specific categories and international students)
drop if inlist(target_g, 13, 14, 9)
*dataset for low skilled labour+refugees+irregulars
keep if inlist(target_g, 2, 3, 4, 6, 8, 11, 12)
*dataset for low-skilled labour+irregulars
keep if inlist(target_g, 2, 3, 4, 6, 8, 11)
*dataset for low-skilled labour
keep if inlist(target_g, 2, 3, 4, 6)

*create frequencies
contract year country change_restrict
gen ch = change +1
drop change
reshape wide _freq, i(country year) j(ch)

*rename variables
rename _freq0 lessrest
rename _freq2 morerest
drop _fre

********************************************************************************
*Final Merged Dataset Data Preparation [FOR WEIGHTED AVERAGE]


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Immigration Change - DEMIG\Weighted Datasets\Weighted Averages.dta", clear
*merge datasets
merge 1:1 country year using "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Salience - Eurobarometer\Eurobarometerready.dta"
drop _merge
merge 1:1 country year using "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Public Opinion - ESS\ESSready.dta"
drop _merge
merge 1:1 country year using "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Party Positions - CHES\CHESready.dta"
sort country year
drop _merge
drop imgood

*Fill in missing values

*imav
by country: ipolate imav year, gen(opinionav)
gsort country -year
by country:replace opinionav = opinionav[_n-1] if opinionav >= .

*imcult and imeco
by country: ipolate imcult year, gen(culture)
by country: ipolate imeco year, gen(economy)
by country:replace culture = culture[_n-1] if culture >= .
by country:replace economy = economy[_n-1] if economy >= .
drop imcult imeco imav

*govavs and parlav
sort country year
by country:replace govavs = govavs[_n-1] if govavs>= .
by country:replace parlav = parlav[_n-1] if parlav>= .
by country:replace oppoav = oppoav[_n-1] if oppoav>= .

*rank
by country: ipolate rank year, gen(salience)
gsort country -year
by country:replace salience = salience[_n-1] if salience >= .
sort country year
gen lnsalience = log(salience)
drop rank

*prepare dependent variables
recode all_labour (. = 0)
recode all (. = 0)
recode labour_irr (. = 0)
recode refugee (. = 0)
recode refugee_irr (. = 0)
recode irr (. = 0)
recode low_irr (. = 0)
recode low_irr_ref(. = 0)

*drop years before analysis
drop if year < 2002


********************************************************************************
*Final Merged Dataset Data Preparation [FOR FREQUENCIES]


use "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Immigration Change - DEMIG\Frequencies\Freqs.dta"
recode * (.=0)
*merge datasets
merge 1:1 country year using "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Salience - Eurobarometer\Eurobarometerready.dta"
drop _merge
merge 1:1 country year using "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Public Opinion - ESS\ESSready.dta"
drop _merge
merge 1:1 country year using "C:\Users\goldu\Google Drive\Universität\Year 3\Block V\Thesis Project\Datasets\Party Positions - CHES\CHESready.dta"
sort country year
drop _merge
drop imgood

*Fill in missing values

*imav
by country: ipolate imav year, gen(opinionav)
gsort country -year
by country:replace opinionav = opinionav[_n-1] if opinionav >= .
gen opinion = 10-opinionav


*imcult and imeco
by country: ipolate imcult year, gen(culture)
by country: ipolate imeco year, gen(economy)
by country:replace culture = culture[_n-1] if culture >= .
by country:replace economy = economy[_n-1] if economy >= .
drop imcult imeco imav

*govavs and parlav
sort country year
by country:replace govavs = govavs[_n-1] if govavs>= .
by country:replace parlav = parlav[_n-1] if parlav>= .
by country:replace oppoav = oppoav[_n-1] if oppoav>= .

*rank
by country: ipolate rank year, gen(salience)
gsort country -year
by country:replace salience = salience[_n-1] if salience >= .
sort country year
gen lnsalience = log(salience)
drop rank

*change
recode *(.=0)

*drop years before analysis
drop if year < 2002

poisson irr_less opinion sal if country != 11 & country != 17
poisson irr_less c.opinion##c.sal if country != 11 & country != 17
poisson irr_less oppo gov if country != 11 & country != 17
poisson irr_less opinion sal oppo gov if country != 11 & country != 17


