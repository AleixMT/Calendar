/*----------------------------------------------------------------
|	Autor: Pere Mill�n (DEIM, URV)
|	Data:  Mar� 2020					Versi�: 1.0
|-----------------------------------------------------------------|
|	Nom fitxer: julianday.c
|   Descripci�: c�lcul del dia juli� d'una data donada.
| ----------------------------------------------------------------*/


#include "FCtypes.h"


	/* Codi obtingut de https://pdc.ro.nu/jd-code.html */
long gregorian_calendar_to_jd(int y, int m, int d)
{
		/* �s correcte per a dates posteriors a 15/oct/1582 (calendari Gregori�) */
		/* Per a dates anteriors (calendari Juli�) el resultat �s "aproximat" */
	y += 8000;
	if (m<3) 
	{
		y--;
		m += 12;
	}
	return (y*365) + (y/4) - (y/100) + (y/400) - 1200820
              + (m*153+3)/5 - 92
              + d-1
	;
}


s32 julian_day ( u8 dia, u8 mes, s16 any_Ca2 )	/* Dia juli� de la data indicada */
{
	long jd;

	jd = gregorian_calendar_to_jd(any_Ca2, mes, dia);
	
	/* To-do: ajustar a dates del calendari Juli� (abans 4/oct/1582) */

	return jd;
}





