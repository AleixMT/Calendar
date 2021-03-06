/*----------------------------------------------------------------
|	Autor: Pere Mill�n (DEIM, URV)
|	Data:  Mar� 2020					Versi�: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: FCdivmod.h
|   Descripci�: declaraci� de rutines de divisi� entera
|			    i residu (m�dul) amb operands naturals de 32 bits.
| ----------------------------------------------------------------*/

#ifndef FCDIVMOD_H
#define FCDIVMOD_H

#include "FCtypes.h"	/* u32 ... */


	/* rutina completa de divisi�: calcula quocient i residu (m�dul) */
extern u8 div_mod ( u32 num, u32 den, u32 *quo, u32 *mod );
		/*
			*quo = num / den	Quocient
			*mod = num % den 	Residu, m�dul
			Retorna possibles errors DIVMOD_ERROR_XXXX
		*/
			/* Possibles errors retornats per div_mod */
#define DIVMOD_ERROR_NOERROR    0	/* No s'ha detectat cap error, resultats Ok */
#define DIVMOD_ERROR_DIVBYZERO  1	/* S'ha intentat dividir entre 0 */
#define DIVMOD_ERROR_NOTALIGN4  2	/* quo o den no estan alineats a adre�a m�ltiple de 4 */
#define DIVMOD_ERROR_SAMEADDR   3	/* quo i den apunten a la mateixa adre�a */


	/* rutines per obtenir nom�s quocient o residu (m�dul). Criden a div_mod */
extern u32 FCdiv ( u32 num, u32 den );	/* Retorna num / den o DIVMOD_RESULT_ERROR en cas d'error */
extern u32 FCmod ( u32 num, u32 den );	/* Retorna num % den o DIVMOD_RESULT_ERROR en cas d'error */

			/* Possible resultat erroni de FCdiv o FCmod */
#define DIVMOD_RESULT_ERROR 0xFF000000


#endif /* FCDIVMOD_H */

