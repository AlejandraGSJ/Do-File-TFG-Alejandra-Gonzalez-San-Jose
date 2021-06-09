clear
**** asterisco y barras para anotaciones
cd "/Users/Alejandra/Desktop/A/TFG/BASES DE DATOS/STATA" // COMILLAS PARA PONER RUTA
import excel using "DATOS TFG 2002-2020.xlsx", firstrow //use para archivos stata y si es excel es: import excel

destring FUTLOCAL FUTPREF FUTPREF2 ACTIVM ACTIVH DESEMPH DESEMP DESEMPM EMPLEOM EMPLEOH POBTOT LLAM016TOT LLAM016EXT LLAM016UNK DENUNCIAS DELITOS PIBPC INMIGRANTES ORIENTAPOL RICOPOBRE DESEMP PIBPCREL DESEMPHREL EMPLEOMREL POBKM2 KM2 DESEMPREL DESEMPESP PERC_INMIGRANTES PERC_DELITOS, replace force
gen ln_016= log(LLAM016TOT)
gen ln_denuncias= log(DENUNCIAS)
gen ln_desemph= log(DESEMPH)
gen ln_empleom= log(EMPLEOM)
gen ln_delitos= log(DELITOS)
gen ln_inmigrantes= log(INMIGRANTES)
gen ln_pibpc= log(PIBPC)
gen ln_desemp= log(DESEMP)
gen ln_desemph_REL= log(DESEMPHREL)
gen ln_empleom_REL= log(EMPLEOMREL)
gen ln_pibpc_REL= log(PIBPCREL)
gen ln_desemp_REL= log(DESEMPREL)
gen ln_perc_inmigrantes= log(PERC_INMIGRANTES)
gen ln_perc_delitos=log(PERC_DELITOS)


**CREAR PANEL**
*** CODIFICAR LAS PROVINCIAS
encode PROVINCIA, gen (id)
xtset id AÑO  // COMANDO DATOS DE PANEL

correlate PERC_INMIGRANTES PERC_DELITOS
correlate INMIGRANTES DELITOS
correlate PIBPC INMIGRANTES
correlate PIBPC DELITOS
correlate PIBPCREL PERC_DELITOS

//SERIE TEMPORAL - ARELLANO-BOND// ** Arellano, M., and S. Bond. 1991.  Some tests of specification for panel data: Monte Carlo evidence and an application to employment equations.  Review of Economic Studies
        *58: 277-297.//

xtabond LLAM016TOT DENUNCIAS, lags(1) noconstant
estimates store ab1
estat sargan
xtabond LLAM016TOT DENUNCIAS l.DENUNCIAS, lags(1) twostep vce(robust) noconstant
estimates store ab2
estat abond
xtabond LLAM016TOT DENUNCIAS l.DENUNCIAS, lags(2) twostep vce(robust) noconstant endogenous(DENUNCIAS,lag(0,1))
estimates store ab3
xtabond LLAM016TOT DENUNCIAS l.DENUNCIAS, lags(2) twostep vce(robust) noconstant pre(DENUNCIAS)
estimates store ab4
esttab ab1 ab2 ab3 ab4 using Arellano_and_Bond_016.tex, se star(* 0.1 ** 0.05 *** 0.01) label stats (N r2_a,labels("Observaciones" "R2 ajustado")) booktabs  title(Modelo de Arellano y Bond para "Llamadas al 016")

//OLS//

xtreg DENUNCIAS DESEMPH PIBPC ln_empleom FUTPREF PERC_DELITOS PERC_INMIGRANTES, be
xtreg ln_016 ln_desemph PIBPC EMPLEOM FUTPREF PERC_DELITOS, be
xtreg DENUNCIAS DESEMPH PIBPC ln_empleom FUTPREF PERC_DELITOS, be

xtreg DENUNCIAS l.LLAM016TOT PIBPCREL DESEMPREL EMPLEOMREL FUTPREF PERC_INMIGRANTES, be
estimates store b1
xtreg ln_016 l.DENUNCIAS ln_desemph PIBPC EMPLEOM FUTPREF PERC_INMIGRANTES, be
estimates store b2
esttab b1 b2 using Modelos_De_Estimadores_Intragrupos.tex, se star(* 0.1 ** 0.05 *** 0.01) label stats (N r2_a,labels("Observaciones" "R2 ajustado")) booktabs  title(Estimador Intragrupos)

**** Relación entre las Denuncias y las Llamadas al 016 ****

xtreg DENUNCIAS l.LLAM016TOT PIBPCREL DESEMPREL EMPLEOMREL PERC_INMIGRANTES, be
estimates store b1

esttab b1 b2 using Denuncias_Llamadas016_Intragrupos.tex, se star(* 0.1 ** 0.05 *** 0.01) label stats (N r2_a,labels("Observaciones" "R2 ajustado")) booktabs  title(Estimación de la Relación entre Denuncias y Llamadas al 016)


//FIXED EFFECTS//

xtreg ln_016 DESEMP PIBPC ln_empleom, fe
estimates store fe1
xtreg ln_016 DESEMP PIBPC ln_empleom FUTPREF, fe
estimates store fe2
xtreg ln_016 DESEMP PIBPC ln_empleom FUTPREF ORIENTAPOL, fe
estimates store fe3
xtreg ln_016 DESEMP PIBPC ln_empleom FUTPREF ORIENTAPOL PERC_INMIGRANTES , fe
estimates store fe4
xtreg ln_016 DESEMP PIBPC ln_empleom FUTPREF ORIENTAPOL PERC_INMIGRANTES RICOPOBRE, fe
estimates store fe6
xtreg ln_016 DESEMP PIBPC ln_empleom FUTPREF ORIENTAPOL PERC_INMIGRANTES RICOPOBRE POBKM2, fe
estimates store fe7

esttab fe1 fe2 fe3 fe4 fe6 fe7 using Efectos_Fijos_LLAM_016.tex, se star(* 0.1 ** 0.05 *** 0.01) label stats (N r2,labels("Observaciones" "R2 ajustado")) booktabs  title(Estimación del log(Llamadas al 016) por Efectos Fijos)


xtreg ln_denuncias DESEMPH ln_pibpc_REL ln_empleom_REL, fe
estimates store fe1
xtreg ln_denuncias DESEMPH ln_pibpc_REL ln_empleom_REL FUTPREF, fe
estimates store fe2
xtreg ln_denuncias DESEMPH ln_pibpc_REL ln_empleom_REL FUTPREF PERC_INMIGRANTES, fe
estimates store fe3
xtreg ln_denuncias DESEMPH ln_pibpc_REL ln_empleom_REL FUTPREF PERC_INMIGRANTES ORIENTAPOL, fe
estimates store fe4
xtreg ln_denuncias DESEMPH ln_pibpc_REL ln_empleom_REL FUTPREF PERC_INMIGRANTES ORIENTAPOL  POBKM2, fe
estimates store fe5

esttab fe1 fe2 fe3 fe4 fe5 using LnDenuncias_Efectos_Fijos.tex, se star(* 0.1 ** 0.05 *** 0.01) label stats (N r2,labels("Observaciones" "R2 ajustado")) booktabs  title(Estimación del LN(Denuncias) por Efectos Fijos)


