@;----------------------------------------------------------------
@;	Analista: Pere Mill�n
@;	Data:   Mar,Abr/2020       		Versi�: 1.0
@;-----------------------------------------------------------------
@;	Nom fitxer: FCdates.s
@;  Descripcio: implementaci� de les rutines per 
@;				treballar amb dates i calendaris.
@;-----------------------------------------------------------------
@;   programador/a 1: pedro.espadas@estudiants.urv.cat
@;   programador/a 2: xxx.xxx@estudiants.urv.cat
@;   programador/a 3: xxx.xxx@estudiants.urv.cat
@; ----------------------------------------------------------------

.include "FCdivmod.i"

@; Declaraci� de s�mbols per treballar amb m�scares
@;
@; 			Camps: 0000aaaaaaaaaaaaaaammmmddddd0000

@;		M�SCARES :

DATE_YEAR_MASK      = 0b00001111111111111110000000000000
DATE_YEAR_SIGN_MASK = 0b00001000000000000000000000000000
DATE_MONTH_MASK     = 0b00000000000000000001111000000000
DATE_DAY_MASK       = 0b00000000000000000000000111110000

	@; Per poder fer "extensi� de signe negatiu" de l'any: 
DATE_YEAR_SIGN_EXT  = 0b11110000000000000000000000000000


@;		POSICI� DE BITS INICIAL/LSB I FINAL/MSB :

DATE_YEAR_MSB  = 27
DATE_YEAR_LSB  = 13
DATE_MONTH_MSB = 12
DATE_MONTH_LSB =  9
DATE_DAY_MSB   =  8
DATE_DAY_LSB   =  4



@;--- .data. Non-zero Initialized data ---
.data
	diesPerMes:	.byte	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


@;-- .text. codi de les rutinas ---
.text	
		.align 2
		.arm


@; ========================================================
@;   Crear valors a partir dels seus components
@; ========================================================

@; fc_date create_date ( bool despresCrist, u16 any, u8 mes, u8 dia ) :
@;	  Crea un fc_date amb els valors donats
@;	  (els par�metres fora de rang, es queden amb el valor v�lid m�s proper)
@;  Par�metres:
@;      R0: despresCrist (0: abans de Crist; diferent de 0: despr�s de Crist)
@;      R1: magnitud de l'any (rang v�lid: 1-9999)
@;      R2: mes (rang v�lid: 1-12)
@;      R3: dia (rang v�lid: 1-28/29/30/31, segons mes i any)
@;	Resultat:
@;		R0: valor fc_date amb els camps inicialitzats segons par�metres
		.global create_date
create_date:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		@; Ajustat de valors
		@; Any
		cmp r1, #1
		movlt r1, #1  @; Si any < 1 --> any = 1
		
		ldr r4, =9999  @; Carreguem constant (limitaci� de ARM)
		cmp r1, r4  
		movhi r1, r4  @; Si any > 9999 --> any = 9999
		
		@; Mes
		cmp r2, #1  
		movlt r2, #1  @; Si mes < 1 --> mes = 1
		
		cmp r2, #12
		movhi r2, #12  @; Si mes > 12 --> mes = 12
		
		@; Dia
		cmp r3, #1
		movlt r3, #1  @; Si dia < 1 --> dia = 1
		
		@; caldr� veure quants dies t� aquest mes per veure els dies superiors
		
		@; calcular any en Ca2. 
		cmp r0, #1
		beq .LFiAbansDeCrist  @; Si es despr�s del naixement de Jes�s no cal fer res
		neg r0, r0  @; Ca2
		.LFiAbansDeCrist:
		
		@; //RF  FALTA CODIIII
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar



@; ========================================================
@;   Rutines de consulta de valors de camps
@; ========================================================


@; bool is_after_Christ ( fc_date data_completa ) :
@;	  Retorna true (1) si la data indicada �s despr�s de Crist, o 0 en cas contrari
@;  Par�metres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: 1 si la data indicada �s despr�s de Crist; 0 altrament
		.global is_after_Christ
is_after_Christ:
		push {r1, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		and r1, r0, #DATE_YEAR_SIGN_MASK  @; Apliquem m�scara de "signe"
		cmp r1, #0  @; Veiem si queda un 0 o no
		moveq r0, #1  @; Si queda 0 no hi ha signe per tant despr�s de Crist
		movne r0, #0  @; Sino pues 1 perque si que �s despr�s de Crist
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u16 get_year_magnitude ( fc_date data_completa ) :
@;	  Retorna el valor absolut (magnitud) del camp 'any' de la fc_date indicada
@;  Par�metres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor absolut (magnitud) del camp 'any' de la fc_date indicada (1..9999)
		.global get_year_magnitude
get_year_magnitude:
		push {r1-r3, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		ldr r3, =DATE_YEAR_MASK  @; Carreguem constant (limitaci� ARM)
		and r2, r0, r3  @; Ens quedem amb la info de l'any a r2
		
		and r1, r0, #DATE_YEAR_SIGN_MASK  @; Apliquem m�scara de despres de Crist
		cmp r1, #0  @; Mirem si es 0 (si es 0 es despr�s de crist)
		beq .LAnyDespresDeCrist
		
		@; Aqui tractem si es un any despr�s de Jes�s
		orr r2, r2, #DATE_YEAR_SIGN_EXT  @; Afegim els bits d'extensi�
		mov r2, r2, asr #DATE_YEAR_LSB  @; Posem bits a lloc amb extensi� de signe
		neg r2, r2  @; Ca2
		b .LFiGetYear  @; Marxem
		
		.LAnyDespresDeCrist:  @; Tractem si es despr�s de Crist
		mov r2, r2, lsr #DATE_YEAR_LSB  @; Posem bits al lloc

		.LFiGetYear:
		mov r0, r2  @; Tornem info a r0 per fer el retorn de la rutina
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==
		pop {r1-r3, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; s16 get_year_Ca2 ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'any' (Ca2) de la fc_date indicada
@;  Par�metres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor (Ca2) del camp 'any' de la fc_date indicada (-9999..-1, 1..9999)
		.global get_year_Ca2
get_year_Ca2:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		ldr r2, =DATE_YEAR_MASK  @; Carreguem constant (limitaci� ARM)
		and r1, r0, r2  @; Ens quedem amb el camp year a r1
		and r2, r1, #DATE_YEAR_SIGN_MASK  @; Ens quedem amb el signe 
		cmp r2, #0  @; Mirem si no te signe
		beq .LGetYearDespresDeCrist  
		
		@; Aqui tractem si t� signe i per tant es un any abans de Crist
		orr r1, r1, #DATE_YEAR_SIGN_EXT  @; Afegim els bits d'extensi�
		mov r1, r1, asr #DATE_YEAR_LSB  @; Posem bits a lloc amb extensi� de signe
		b .LFiGetYearCa2  @; Anem al final de la funci�

		.LGetYearDespresDeCrist:
		mov r1, r1, lsr #DATE_YEAR_LSB  @; Movem al lloc
		
		.LFiGetYearCa2:
		@;ldr r2, =0x0000FFFF  @; Carreguem constant (limitaci� ARM)
		@; and r1, r1, r2  @; Forcem retornar un half-word
		mov r0, r1  @; Per a fer el retorn de la funci�
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 get_month ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'mes' de la fc_date indicada
@;  Par�metres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor del camp 'mes' de la fc_date indicada (1..12)
		.global get_month
get_month:
		push {lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		and r0, r0, #DATE_MONTH_MASK
		mov r0, r0, lsr #DATE_MONTH_LSB

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 get_day ( fc_date data_completa ) :
@;	  Retorna el valor del camp 'dia' de la fc_date indicada
@;  Par�metres:
@;      R0: valor fc_date
@;	Resultat:
@;		R0: valor del camp 'dia' de la fc_date indicada (1..28/29/30/31)
		.global get_day
get_day:
		push {lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		and r0, r0, #DATE_DAY_MASK
		mov r0, r0, lsr #DATE_DAY_LSB

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {pc}	@; recuperar de pila registres modificats i retornar




@; =============================================================
@;   Altres rutines de dates
@; =============================================================


@; bool is_leap_year ( s16 any_Ca2 ) :
@;	  Retorna true (1) si l'any indicat �s de trasp�s/bixest, o 0 en cas contrari
@;  Par�metres:
@;      R0: valor de l'any (Ca2)
@;	Resultat:
@;		R0: 1 si l'any indicat �s de trasp�s/bixest; 0 altrament
		.global is_leap_year
is_leap_year:
		push {r1-r5, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		mov r3, r0  @; Movem al registre r3 per comoditat
		cmp r3, #-46  @; Comparem amb -46
		movlt r0, #0  @; No es any bixest
		blt .LFiIsLeapYear  @; Fi funci�
		
		@;Aqu� continuem si es major o igual que -46
		and r2, r3, #0b11  @; Si r2 = 0, any multiple de 4
		cmp r2, #0  @; Mirem si es 0
		moveq r2, #1  @; Si es 0 fiquem true
		movne r2, #0  @; Sino pues fiquem false
		ldr r4, =1582  @; Carreguem constant (limiaci� ARM)
		cmp r3, r4  @; comparem amb 1582
		movle r0, r2  @; Si any menor o igual a 1582 carreguem a r0 si es multiple de 4 o no
		ble .LFiIsLeapYear  @; I retornem
		
		@; Aqu� continuem si l'any es major que 1582
		@; Malabars de registres per a cridar a la funci� per fer any % 100
		mov r0, r3  @; Carreguem any a r0 (primer argument)
		mov r1, #100  @; carreguem quocient a r1 (segon argument)
		bl FCmod  @; r0 = any % 100
		cmp r0, #0
		moveq r4, #1  @; Si es igual llavors es m�ltiple de 100 (true)
		movne r4, #0  @; Si es diferent llavors posem a false
		
		@; Malabars de registres per a cridar a la funci� per fer any % 400
		mov r0, r3  @; Carreguem any a r0 (primer argument)
		mov r1, #400  @; carreguem quocient a r1 (segon argument)
		bl FCmod  @; r0 = any % 400
		cmp r0, #0
		moveq r5, #1  @; Si es igual llavors es m�ltiple de 400 (true)
		movne r5, #0  @; Si es diferent llavors ho posem a false
		
		@; r2: Multiplicitat amb 4
		@; r4: Multiplicitat amb 100
		@; r5: Multiplicitat amb 400
		
		mvn r4, r4  @; neguem multiplicitat amb 100
		and r0, r2, r4  @; Fem la and. Se'ns maten tots els 1 useless que em creat a l'anterior instrucci�
		orr r0, r0, r5  @; Resultat final
		
		.LFiIsLeapYear:
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r5, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 days_in_month ( u8 mes, s16 any_Ca2 ) :
@;	  Retorna el n�mero de dies d'aquell mes (0 en cas de m�s o any fora de rang)
@;  Par�metres:
@;      R0: valor del mes (rang esperat 1..12)
@;		R1: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: n�mero de dies d'aquell mes (1..28/29/30/31) o 0 en cas de fora de rang
		.global days_in_month
days_in_month:
		push {r1-r3, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		mov r2, r0  @; Guardem mes a un altre lloc per comoditat
		mov r0, #0  @; resultat incorrecte fins que no es demostri el contrari
		
		@; Any
		ldr r3, =-9999  @; Carreguem constant (limitaci� de ARM)
		cmp r1, r3
		blt .LFiDaysInMonth  @; Fi funci�
		
		ldr r3, =9999  @; Carreguem constant (limitaci� de ARM)
		cmp r1, r3  
		bhi .LFiDaysInMonth  @; Fi funci�
		
		cmp r1, #0
		beq .LFiDaysInMonth  @; Fi funci�
		
		@; Mes
		cmp r2, #1  
		blt .LFiDaysInMonth  @; Fi funci�
		
		cmp r2, #12
		bhi .LFiDaysInMonth  @; Fi funci�
		
		@; En aquest punt els arguments son valids i estem al else
		sub r2, #1  @; Resta 1 a mes per a poder indexar amb ell a l'array
		ldr r3, =diesPerMes  @; Carreguem @ del array diesPerMes
		add r3, r2  @; Desplacem el punter fins la posicio que ens interessa
		ldrb r0, [r3]  @; Carreguem un byte a r0 corresponent als dies d'aquell mes
		cmp r2, #1  @; Mirem si es febrer. Hem restat 1, per aixo mirem amb 1
		bne .LFiDaysInMonth  @; Si no ho es hem acabat
		
		@; Aqui tenim el suposit que es Febrer
		@; Fem malabars per cridar a la funci�
		mov r3, r0  @; Guardem dies del mes (en aquest punt sera 28) a r3
		mov r0, r1  @; Carreguem any per a passarli a la funci�
		bl is_leap_year  @; Cridem a la funci� per saber si es bixest o no
		add r0, r0, r3  @; Sumem el resultat i jasta... estalviem diverses instruccions
		
		.LFiDaysInMonth:
		
		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r3, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; s8 get_century_Ca2 ( s16 any_Ca2 ) :
@;	  Retorna el n�mero de segle al qual pertany l'any indicat (0 en cas d'any fora de rang)
@;  Par�metres:
@;		R0: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: segle al qual pertany l'any indicat (-100..-1 / +1..+100) o 0 en cas d'any fora de rang
		.global get_century_Ca2
get_century_Ca2:
		push {r1-r2, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==
		
		mov r1, r0  @; Movem any a r1 per comoditat
		mov r0, #0  @; Parametres incorrectes fins que no es demostri el contrari
		
		@; Any
		ldr r2, =-9999  @; Carreguem constant (limitaci� de ARM)
		cmp r1, r2
		blt .LFiGetCentury  @; Fi funci�
		
		ldr r2, =9999  @; Carreguem constant (limitaci� de ARM)
		cmp r1, r2  
		bgt .LFiGetCentury  @; Fi funci�
		
		cmp r1, #0
		beq .LFiGetCentury  @; Fi funci�
		
		@; A partir d'aqui estem amb par�metres correctes
		
		cmp r1, #0  
		neglt r1, r1  @; Si es un negatiu el convertim a positiu
		movlt r2, #-1  @; Carreguem un -1 per a despr�s
		movgt r2, #1  @; Carreguem un 1 per a despr�s
		
		@; Malabars de registres per cridar a la divisi�
		mov r0, r1  @; Carreguem any
		sub r0, #1  @; Restem un 1
		mov r1, #100  @; Carreguem quocient
		bl FCdiv  @; A r0 tenim el resultat de la divisi�
		add r0, #1  @; Sumem 1 per corregir
		mov r1, r0  @; Carreguem a un altre registre per a mul (limitaci� ARM)
		mul r0, r1, r2  @; Multipliquem segons el que hagim carregat a r2 previament
		
		.LFiGetCentury:

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r2, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; u8 week_day ( u8 dia, u8 mes, s16 any_Ca2 ) :
@;	  Retorna el dia de la setmana d'aquella data (1:dilluns..7:diumenge o 0 si data fora de rang)
@;  Par�metres:
@;      R0: valor del dia (rang esperat 1..28/29/30/31)
@;      R1: valor del mes (rang esperat 1..12)
@;		R2: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;	Resultat:
@;		R0: dia de la setmana d'aquella data (1:dilluns..7:diumenge o 0 si data fora de rang)
		.global week_day
week_day:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==

		@; Malabars de registres per a cridar a la funci�
		mov r3, r0  @; r3 --> dies
		mov r4, r1  @; r4 --> mes (necessitem guardar-ho perque sino ho perdrem)
		mov r0, r1  @; Per a cridar la func
		mov r1, r2  @; Per a cridar la func. r2 --> any (no el matxacarem)
		bl days_in_month  @; r0 --> days in month
		mov r1, r0  @; r1 --> days in month
		
		@; Checkegem par�metres
		mov r0, #0  @; Els parametres son incorrectes fins que no es demostri el contrari
		
		cmp r1, #0  @; Comparem retorn amb 0 (codi error)
		beq .LFiWeekDay
		
		cmp r3, #1  @; Comparem dies per si son menors de 1
		blt .LFiWeekDay  @; Si ho s�n marxem de la funci�
		
		cmp r3, r1  @; Mirem si els dies proporcionats estan fora de rang
		bgt .LFiWeekDay  
		
		@; Aqu� els par�metres son correctes
		@; Malabars de registres per a cridar a la funcio de divisio
		mov r0, r3  @; Carreguem primer dies
		mov r1, r4  @; Carreguem segon mes
		@; a r2 ja hi tenim l'any ben colocat
		bl julian_day  @; r0 = numero de dies passats des del calendari juli�
		mov r1, #7  @; Carreguem un 7 de quocient
		bl FCmod  @; r0 modul amb 7
		add r0, #1  @; Corregim sumant 1 per a que 1 --> dilluns ... 7 --> diumenge
		
		.LFiWeekDay:

		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar




@; =============================================================
@;   Rutines per generar calendaris mensuals
@; =============================================================


@; bool create_binary_calendar ( u8 mes, s16 any_Ca2, s8 calendari[7][7] ) :
@;	  Genera el calendari del mes i any indicats sobre la matriu donada, amb valors num�rics
@;  Par�metres:
@;      R0: valor del mes (rang esperat 1..12)
@;		R1: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;		R2: matriu on s'ha d'escriure el calendari (pas per refer�ncia)
@;	Resultat:
@;		R0: 1 si s'ha pogut generar el calendari; 0 en cas de mes o any fora de rang
@;
@;  Format del calendari (per a mar� 2020): cada casella de la matriu cont� valors -1..31
@;	   +--+--+--+--+--+--+--+
@;	   | 0| 3| 0| 2| 0| 2| 0|	Mes: 0 3	AC(-1)/DC(0)	Any: 2 0 2 0 (Mes i any a fila 0)
@;	   | 0  0  0  0  0  0  1|	1a setmana de Mar� (el mes comen�a diumenge, resta de dies a 0)
@;	   | 2  3  4  5  6  7  8|	2a setmana de Mar�, dies 2-8
@;	   | 9 10 11 12 13 14 15|	3a setmana de Mar�, dies 9-15
@;	   |16 17 18 19 20 21 22|	4a setmana de Mar�, dies 16-22
@;	   |23 24 25 26 27 28 29|	5a setmana de Mar�, dies 23-29
@;	   |30 31  0  0  0  0  0|	6a setmana de Mar�, dies 30 i 31, resta de dies amb 0
@;
		.global create_binary_calendar
create_binary_calendar:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar


@; -------------------------------------------------------- 


@; bool create_ascii_calendar ( u8 mes, s16 any_Ca2, u8 language, char calendari[8][20] ) :
@;    Genera el calendari del mes i any indicats, en l'idioma indicat, 
@;    sobre la matriu donada, amb car�cters ASCII.
@;  Par�metres:
@;      R0: valor del mes (rang esperat 1..12)
@;		R1: valor de l'any (Ca2, rang esperat -9999..-1 / 1..9999) 
@;		R2: idioma ( 0: catal�, 1: castellano, 2: english, 3: fran�ais )
@;		R3: matriu on s'ha d'escriure el calendari (pas per refer�ncia)
@;	Resultat:
@;		R0: 1 si s'ha pogut generar el calendari; 0 en cas de mes o any fora de rang
@;
@;  Format del calendari (per a mar� 2020): cada casella de la matriu cont� car�cters ASCII
@;	   +--------------------+
@;	   |Mar� 2020 DC        |	Nom del mes, any, AC/DC (a fila 0)
@;	   |dl dt dc dj dv ds du|	Inicials dels dies de la setmana (a fila 1)
@;	   |                   1|	1a setmana de Mar� (el mes comen�a diumenge, resta de dies a 0)
@;	   | 2  3  4  5  6  7  8|	2a setmana de Mar�, dies 2-8
@;	   | 9 10 11 12 13 14 15|	3a setmana de Mar�, dies 9-15
@;	   |16 17 18 19 20 21 22|	4a setmana de Mar�, dies 16-22
@;	   |23 24 25 26 27 28 29|	5a setmana de Mar�, dies 23-29
@;	   |30 31               |	6a setmana de Mar�, dies 30 i 31, resta de dies amb 0
@;
		.global create_ascii_calendar
create_ascii_calendar:
		push {r1-r12, lr}	@; guardar a pila possibles registres modificats 
		
		@; ==vvvvvvvv== INICI codi assemblador de la rutina ==vvvvvvvv==


		@; ==^^^^^^^^== FINAL codi assemblador de la rutina ==^^^^^^^^==

		pop {r1-r12, pc}	@; recuperar de pila registres modificats i retornar



.data
	@; Strings per al calendari ASCII 

monthNames:    @; adreces dels strings amb els noms dels mesos: char *monthNames[4][12]
	.align 2
	.word Gener, Febrer, Marc, Abril, Maig, Juny, Juliol, Agost, Setembre, Octubre, Novembre, Desembre
	.word Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre
	.word January, February, March, April, May, June, July, August, September, October, November, December
	.word Janvier, Fevrier, Mars, Avril, Mai, Juin, Juillet, Aout, Septembre, Octobre, Novembre, Decembre

weekDaysNames:
	.ascii "DlDtDcDjDvDsDu"
	.ascii "LuMaMiJuViS�Do"
	.ascii "MoTuWeThFrSaSu"
	.ascii "LuMaMeJeVeSaDi"

		@; Noms individuals dels mesos
Gener:      .asciz "Gener"
Enero:      .asciz "Enero"
January:    .asciz "January"
Janvier:    .asciz "Janvier"
Febrer:     .asciz "Febrer"
Febrero:    .asciz "Febrero"
February:   .asciz "February"
Fevrier:    .asciz "F�vrier"
Marc:       .asciz "Mar�"
Marzo:      .asciz "Marzo"
March:      .asciz "March"
Mars:       .asciz "Mars"
Abril:      .asciz "Abril"
April:      .asciz "April"
Avril:      .asciz "Avril"
Maig:       .asciz "Maig"
Mayo:       .asciz "Mayo"
May:        .asciz "May"
Mai:        .asciz "Mai"
Juny:       .asciz "Juny"
Junio:      .asciz "Junio"
June:       .asciz "June"
Juin:       .asciz "Juin"
Juliol:     .asciz "Juliol"
Julio:      .asciz "Julio"
July:       .asciz "July"
Juillet:    .asciz "Juillet"
Agost:      .asciz "Agost"
Agosto:     .asciz "Agosto"
August:     .asciz "August"
Aout:       .asciz "Ao�t"
Setembre:   .asciz "Setembre"
Septiembre: .asciz "Septiembre"
September:  .asciz "September"
Septembre:  .asciz "Septembre"
Octubre:    .asciz "Octubre"
October:    .asciz "October"
Octobre:    .asciz "Octobre"
Novembre:   .asciz "Novembre"
Noviembre:  .asciz "Noviembre"
November:   .asciz "November"
Desembre:   .asciz "Desembre"
Diciembre:  .asciz "Diciembre"
December:   .asciz "December"
Decembre:   .asciz "D�cembre"


.end
