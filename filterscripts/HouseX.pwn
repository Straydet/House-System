/*

		Sistema de Casas v1.0 by Straydet


		Idea Original (JaKe Elite) - https://sampforum.blast.hk/showthread.php?tid=550690 - [https://pastebin.com/1VXkWRCA]

		Desarrollador/Traduccion (Straydet) - Desarrollo de Casas, Interiores, Comandos, Stocks y demás.


	    Nota: Este sistema de Casas, contiene interiores personalizados del filterscript 'MapX'
	    También puedes añadir tu propio interior personalizado desde el filterscript 'MapX' y el array 'Interior Lists'
	    En caso de encontrar un bug/error puede notificarlo asi también como sugerencias para el sistema.
	    Si quiere modificar/editar debe al menos conocer el lenguaje 'Pawn', ya que puede causar errores/bugs por no saber lo que hace.

*/
//==========================[Includes]========================================//
#include 			<     a_samp       > //SAMP Team
#include            <      zcmd        > //Zeex
#include            <    streamer      > //Incognito
#include            <     sscanf2      > //Y_Less
#include            <      dini        > //DracoBlue
#include            <     foreach      > //Y_Less

//==========================[File Path]=======================================//

#define             HOUSE_PATH                  "HouseSystem/Houses/house_%d.ini"
#define             USER_PATH                   "HouseSystem/User/%s.ini"

//==========================[Configuration]===================================//
#define             MAX_HOUSE_NAME              256
#define             MAX_HOUSES                  350


//Puedes cambiar esto [Solo asegúrate de saber lo que estás haciendo].
#define             SALE_PICKUP                 1273
#define             NOTSALE_PICKUP              19522
#define 			NOTSALE_ICON         		32
#define 			SALE_ICON            		31

#define             STREAM_DISTANCES            35.0
//No lo aumentes, ya que entrará en conflicto con los demás objetos del flujo, etc.


//Tiempo de enfriamiento para la carga de objetos (Si es necesario, aumentelo o disminuyalo)
#define 			HOUSE_FREEZE_TIME 			5000 // milisegundos (5 segundos)

// Macros para simplificar detección de teclas
#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
    
//============================[Colors]========================================//
#define  			white              			"{FFFFFF}"
#define  			red        					"{FF0000}"
#define  			green              			"{33CC33}"
#define             yellow                      "{FFFF00}"

#define 			COLOR_RED  					0xFF0000C8
#define 			COLOR_YELLOW 				0xFFFF00AA
#define 			COLOR_GREEN         		0x33CC33C8
#define 			COLOR_WHITE         		0xFFFFFFFF
//===========================[Dialogs]========================================//
#define             DIALOG_HMENU                6000
#define             DIALOG_BUYHOUSE             DIALOG_HMENU+1
#define             DIALOG_HMAIN                DIALOG_HMENU+2
#define             DIALOG_HINTERIOR_LIST       DIALOG_HMENU+3
#define             DIALOG_HINTERIOR_BUY        DIALOG_HMENU+4
#define             DIALOG_SELLHOUSE            DIALOG_HMENU+5
#define             DIALOG_SAVEMONEY            DIALOG_HMENU+6
#define             DIALOG_WITHDRAWMONEY        DIALOG_HMENU+7
#define             DIALOG_SETNOTE              DIALOG_HMENU+8
#define             DIALOG_MIHOUSE              DIALOG_HMENU+9
#define             DIALOG_MIHOUSE_OPT          DIALOG_HMENU+10
#define             DIALOG_HKEY_ENTER           DIALOG_HMENU+11
#define             DIALOG_HKEY_CHANGE          DIALOG_HMENU+22
#define             DIALOG_HOUSES_LIST          7000
//=============================[Enums]========================================//
enum HouseInfo
{
    hName[MAX_HOUSE_NAME],
    hOwner[256],
    hIName[256],
    hPrice,
    hSale,
    hInterior,
    hWorld,
    hLocked,
    Float:hEnterPos[4],
    Float:hPickupP[3],
    Float:ExitCPPos[3],
    hMapIcon,
    hPickup,
    hCP,
    hLevel,
    Text3D:hLabel,
    MoneyStore,
    hNotes[256],
    hExitPickup,
    Text3D:hExitLabel,
    hKey[64]
};

enum InteriorInfo
{
	Name[128],
	Float:SpawnPointX,
	Float:SpawnPointY,
	Float:SpawnPointZ,
	Float:SpawnPointA,
	Float:ExitPointX,
	Float:ExitPointY,
	Float:ExitPointZ,
	i_Int,
	i_Price,
	Notes[128]
};

enum HousePInfo
{
	OwnedHouses,
	Float:p_SpawnPoint[4],
	p_Interior,
	p_Spawn
};

//======================[Arrays, Variables.]==================================//
/*
sX = SpawnPosicion
eX = SalidaPosicion (Pickup)
*/
//Interior Lists
new intInfo[][InteriorInfo] =
{
    {"House #0", 2324.3469, -1145.8812, 1050.7101, 359.6399, 2324.4570, -1148.8044, 1050.7101, 12, 1500, "Ninguna"},
    {"House #1", 235.3069, 1190.0491, 1080.2578, 359.9533, 235.3969, 1187.6935, 1080.2578, 3, 1000, "Ninguna"},
    {"House #2", 222.9837, 1239.8391, 1082.1406, 92.7009, 225.8877, 1240.0209, 1082.1406, 2, 1000, "Ninguna"},
    {"House #3", 223.3313, 1290.3979, 1082.1328, 0.2667, 223.3452, 1287.8087, 1082.1406, 1, 9500, "Ninguna"},
    {"House #4", 225.7910, 1025.7743, 1084.0078, 0.2900, 225.6310, 1022.4800, 1084.0146, 7, 2900, "Ninguna"},
    {"House #5", 295.1922, 1475.5353, 1080.2578, 3.4232, 295.2854, 1473.0117, 1080.2578, 15, 9800, "Ninguna"},
    {"House #6", 2265.8953, -1210.4926, 1049.0234, 88.7521, 2269.4565, -1210.4597, 1047.5625, 10, 1000, "Ninguna"},
    {"House #7", 2233.4465, -1111.4419, 1050.8828, 3.1700, 2233.7129, -1115.2614, 1050.8828, 5, 3000, "Ninguna"},
    {"House #8", 2530.1094, -1679.2772, 1015.4986, 359.6395, 2525.2393, -1679.3699, 1015.4986, 1, 3500, "Ninguna"},
    {"House #9", 317.9371, 1118.0695, 1083.8828, 1.3314, 318.5647, 1115.5923, 1083.8828, 5, 3200, "Ninguna"},
    {"House #10", 2496.0076, -1695.8928, 1014.7422, 181.1864, 2495.9934, -1692.9742, 1014.7422, 3, 4500, "Ninguna"},
    {"House #11", 1298.9324, -793.3831, 1084.0078, 0.4147, 1298.9706, -795.9689, 1084.0078, 5, 5500, "Ninguna"},
    {"House #12", 2365.0667, -1131.3645, 1050.8750, 0.1014, 2365.3577, -1134.2891, 1050.8750, 8, 1200, "Ninguna"},
    {"Departamento 1", -1142.9526, 1430.6383, 1401.0282, 267.6597, -1148.2664, 1432.1860, 1401.5660, 36, 2000, "Ninguna"},
    {"Departamento 2", 244.1752, -1850.2295, 3333.9329, 294.5152, 243.7174, -1851.3875, 3333.9329, 37, 2500, "Ninguna"},
    {"Departamento 3", 211.6702, 1756.0118, 3334.2429, 329.2915, 210.6278, 1754.2572, 3334.2429, 38, 2800, "Ninguna"},
    {"Casa Moderna 1", 67.0248, -239.8471, 1201.7629, 267.4664, 64.5993, -239.8475, 1201.7629, 39, 3000, "Ninguna"},
    {"Casa Moderna 2", 1387.5006, -1212.5721, 177.5789, 181.4627, 1387.4860, -1209.9766, 177.5789, 40, 3200, "Ninguna"},
    {"Casa Moderna 3", -1448.5817, 2043.6860, -43.9739, 207.2718, -1449.6552, 2046.2687, -43.9739, 41, 3400, "Ninguna"},
    {"Casa Moderna 4", 1393.7373, -9.5962, 1000.9383, 107.3378, 1396.1211, -9.8181, 1000.9383, 42, 3400, "Ninguna"},
    {"Casa Moderna 5", 1392.8760, -1364.4639, 330.1432, 91.0025, 1396.9095, -1364.5214, 330.1432, 43, 3400, "Ninguna"},
    {"Casa Moderna 6", 2750.9055, 430.9461, 1578.6890, 90.2100, 2753.3022, 430.9959, 1578.6868, 44, 3400, "Ninguna"},
    {"Casa Moderna 7", 2439.7485, -97.4109, 1146.8767, 217.0486, 2439.1670, -95.8994, 1146.8845, 45, 3400, "Ninguna"},
    {"Casa Moderna 8", 1972.3832, -1550.5780, 2451.3450, 3.7292, 1972.5031, -1553.1559, 2451.3450, 46, 3400, "Ninguna"},
    {"Casa Moderna 9", 967.4210, 395.6250, 2269.6460, 270.6365, 963.3203, 395.6005, 2269.6460, 47, 3400, "Ninguna"},
    {"Casa Moderna 10", 248.5964, 2.4313, 1500.9999, 216.3878, 249.0233, 5.4341, 1500.9999, 48, 3400, "Ninguna"},
    {"Casa Moderna 11", 1237.0313, -671.0509, 1085.6919, 179.4648, 1237.0698, -667.2637, 1085.6919, 49, 3400, "Ninguna"},
    {"Casa Moderna 12", 324.3894, -1582.5145, 10.1469, 170.3362, 324.2910, -1578.9889, 10.1469, 50, 3400, "Ninguna"},
    {"Casa Moderna 13", 852.8431, 1997.9960, 1011.0809, 268.6847, 850.9685, 1997.9104, 1011.0809, 51, 3400, "Ninguna"},
    {"Casa Moderna 14", 337.3736, 332.8612, 998.2280, 263.2561, 334.3680, 332.8737, 998.2280, 52, 3400, "Ninguna"},
    {"Casa Moderna 15", 393.5239, 1132.1851, 1084.9272, 168.4639, 393.5378, 1133.6205, 1084.9272, 53, 3400, "Ninguna"},
    {"Casa Moderna 16", 1007.1925, 2412.1726, 1501.0779, 89.9876, 1011.5837, 2412.2214, 1501.0779, 54, 3400, "Ninguna"},
    {"Casa Moderna 17", -2683.8853, 1810.1521, 1501.0859, 90.9485, -2678.3345, 1810.3235, 1501.0859, 55, 3400, "Ninguna"},
    {"Casa Moderna 18", -599.9443, 109.0059, 965.9570, 0.6240, -599.8683, 105.5259, 965.9570, 56, 3400, "Ninguna"}
    //{House Name[], Float:sX, Float:sY, Float:sZ, Float:sA, Float:eX, Float:eY, Float:eZ, interior, price, notes[]}
};

new hInfo[MAX_HOUSES][HouseInfo];
new jpInfo[MAX_PLAYERS][HousePInfo];

new h_Loaded = 0;
new h_ID[MAX_PLAYERS];
new h_Inside[MAX_PLAYERS];
new h_Selection[MAX_PLAYERS];
new h_Selected[MAX_PLAYERS];
new hPreviewInterior[MAX_PLAYERS];
//============================================================================//
//=======================[Public functions and others]=======================//
public OnFilterScriptInit()
{
    DisableInteriorEnterExits();

	for(new i=0; i<MAX_HOUSES; i++)
	{
	    if(fexist(HousePath(i)))
	    {
	        LoadHouse(i);
	        h_Loaded ++;
	    }
	}
	
	print("\n");
    print("+===========================================+");
    print("\n");
	printf("... Casas cargadas por el Sistema [%d casas de %d]", h_Loaded, MAX_HOUSES);
	print("\n");
    print("+===========================================+");
    print("\n");
    
	return 1;
}
//----------------------------------------------------------------------------//
public OnFilterScriptExit()
{
    for(new a=0; a<MAX_HOUSES; a++)
    {
        DestroyDynamicPickup(hInfo[a][hPickup]);
        DestroyDynamicMapIcon(hInfo[a][hMapIcon]);
        DestroyDynamic3DTextLabel(hInfo[a][hLabel]);
        DestroyDynamicPickup(hInfo[a][hExitPickup]);
        DestroyDynamic3DTextLabel(hInfo[a][hExitLabel]);
    }
	return 1;
}
//----------------------------------------------------------------------------//
public OnPlayerConnect(playerid)
{
	h_ID[playerid] = -1;
	h_Inside[playerid] = -1;
	h_Selection[playerid] = 0;
	h_Selected[playerid] = -1;

	if(!fexist(PlayerPath(playerid)))
	{
		jpInfo[playerid][OwnedHouses] = 0;
		jpInfo[playerid][p_SpawnPoint][0] = 0.0;
		jpInfo[playerid][p_SpawnPoint][1] = 0.0;
		jpInfo[playerid][p_SpawnPoint][2] = 0.0;
		jpInfo[playerid][p_SpawnPoint][3] = 0.0;
		jpInfo[playerid][p_Interior] = 0;
		jpInfo[playerid][p_Spawn] = 0;
		
		dini_Create(PlayerPath(playerid));
		
		Player_Save(playerid);
		Player_Load(playerid);
	}
	else
	{
	    Player_Load(playerid);
	}
	return 1;
}
//----------------------------------------------------------------------------//
public OnPlayerDisconnect(playerid, reason)
{
	h_ID[playerid] = -1;
	h_Inside[playerid] = -1;
	h_Selection[playerid] = 0;
	h_Selected[playerid] = -1;
	
	if(fexist(PlayerPath(playerid))) Player_Save(playerid);
	return 1;
}
//----------------------------------------------------------------------------//
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (PRESSED(KEY_NO)) // Tecla N
    {
        // Si el jugador está dentro de una casa, salir
        if(h_Inside[playerid] != -1)
        {
            new i = h_Inside[playerid];
            if(IsPlayerInRangeOfPoint(playerid, 1.5,
                hInfo[i][ExitCPPos][0],
                hInfo[i][ExitCPPos][1],
                hInfo[i][ExitCPPos][2]))
            {
                SetPlayerPos(playerid,
                    hInfo[i][hPickupP][0],
                    hInfo[i][hPickupP][1],
                    hInfo[i][hPickupP][2]);
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                h_Inside[playerid] = -1;

            }
        }
        else // Si está fuera, entrar o mostrar diálogo
        {
            new i = h_ID[playerid];
            if(i != -1)
            {
                if(IsPlayerInRangeOfPoint(playerid, 1.5,
                    hInfo[i][hPickupP][0],
                    hInfo[i][hPickupP][1],
                    hInfo[i][hPickupP][2]))
                {
                    if(hInfo[i][hSale] == 0) // Casa en venta y muestra diálogo
                    {
                        new string[256];
                        format(string, sizeof(string),
                            "Casa #: %d\nEsta casa esta en venta por\n\n{2ECC71}(Dinero: %s)\n(Score: %s)",
                            i,
                            FormatNumber(hInfo[i][hPrice]),
                            FormatNumber(hInfo[i][hLevel])
                        );

                        ShowPlayerDialog(playerid, DIALOG_BUYHOUSE, DIALOG_STYLE_MSGBOX,
                            "CASA EN VENTA",
                            string,
                            "Comprar",
                            "Cerrar"
                        );
                    }
                    else if(hInfo[i][hLocked] == 0) // Casa comprada y abierta entra
                    {
                        SetPlayerPos(playerid,
                            hInfo[i][hEnterPos][0],
                            hInfo[i][hEnterPos][1],
                            hInfo[i][hEnterPos][2]);
                        SetPlayerFacingAngle(playerid, hInfo[i][hEnterPos][3]);
                        SetPlayerInterior(playerid, intInfo[hInfo[i][hInterior]][i_Int]);
                        SetPlayerVirtualWorld(playerid, hInfo[i][hWorld]);
                        h_Inside[playerid] = i;
                        
                        HouseFreeze(playerid);

                        // Mostrar mensaje especial según dueño o visitante
                        if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
                        {
                            SendClientMessage(playerid, COLOR_WHITE, "===============================================");
                            new line[128];
                            format(line, sizeof(line), "~ NOTA: %s", hInfo[i][hNotes]);
                            SendClientMessage(playerid, COLOR_WHITE, line);
                            SendClientMessage(playerid, COLOR_WHITE, "===============================================");
                            new line2[128];
                            format(line2, sizeof(line2), "** Entraste a tu casa {FFFFFF}ID: %d, {FFFF00}presiona {FFFFFF}'Y' {FFFF00}para abrir el menú de tu casa", i);
                            SendClientMessage(playerid, COLOR_YELLOW, line2);
                        }
                        else
                        {
                            SendClientMessage(playerid, COLOR_WHITE, "================================================");
                            new line[128];
                            format(line, sizeof(line), "~ NOTA: %s", hInfo[i][hNotes]);
                            SendClientMessage(playerid, COLOR_WHITE, line);
                            SendClientMessage(playerid, COLOR_WHITE, "================================================");
                            new line2[128];
                            format(line2, sizeof(line2), "** Bienvenido a la casa de: {FFFFFF}%s", hInfo[i][hOwner]);
                            SendClientMessage(playerid, COLOR_YELLOW, line2);
                        }
                    }
					else // Casa comprada pero cerrada
					{
					    // Si es el dueño, entra aunque esté cerrada
					    if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
					    {
					        SetPlayerPos(playerid,
					            hInfo[i][hEnterPos][0],
					            hInfo[i][hEnterPos][1],
					            hInfo[i][hEnterPos][2]);
					        SetPlayerFacingAngle(playerid, hInfo[i][hEnterPos][3]);
					        SetPlayerInterior(playerid, intInfo[hInfo[i][hInterior]][i_Int]);
					        SetPlayerVirtualWorld(playerid, hInfo[i][hWorld]);
					        h_Inside[playerid] = i;
					        
					        HouseFreeze(playerid);

					        SendClientMessage(playerid, COLOR_WHITE, "===============================================");
                            new line[128];
                            format(line, sizeof(line), "~ NOTA: %s", hInfo[i][hNotes]);
                            SendClientMessage(playerid, COLOR_WHITE, line);
                            SendClientMessage(playerid, COLOR_WHITE, "===============================================");
                            new line2[128];
                            format(line2, sizeof(line2), "** Entraste a tu casa {FFFFFF}ID: %d, {FFFF00}presiona {FFFFFF}'Y' {FFFF00}para abrir el menú de tu casa", i);
                            SendClientMessage(playerid, COLOR_YELLOW, line2);
					    }
					    else
					    {
					        // Mostrar diálogo de seguridad para invitados
					        new info[128];
					        format(info, sizeof(info), "{FFFFFF}Ingrese la clave de seguridad para ingresar a la casa de: {F5F583}%s", hInfo[i][hOwner]);

					        ShowPlayerDialog(playerid, DIALOG_HKEY_ENTER, DIALOG_STYLE_INPUT,
					            "SEGURIDAD",
					            info,
					            "Enviar",
					            "Cerrar"
					        );

					        SetPVarInt(playerid, "HouseToEnter", i);
					    }
					}
                }
            }
        }
    }
    //------------------------------------------------------------------------//
	if(PRESSED(KEY_YES))
	{
	    new i = h_ID[playerid];
	    if(i != -1 && h_Inside[playerid] != -1)
	    {
	        if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) == 0)
	        {
	            ShowHouseMainMenu(playerid);
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
	        }
	    }
	}
    return 1;
}
//----------------------------------------------------------------------------//
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new x=0; x<MAX_HOUSES; x++)
	{
	    if(pickupid == hInfo[x][hPickup])
	    {
	        h_ID[playerid] = x;
     	}
	}
	return 1;
}
//----------------------------------------------------------------------------//
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_BUYHOUSE)
    {
        if(response) // Botón "Comprar"
        {
            new string[128];
            new i = h_ID[playerid];

            if(i == -1) return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No estás cerca de ninguna casa.");
            if(!IsPlayerInRangeOfPoint(playerid, 1.5,
                hInfo[i][hPickupP][0],
                hInfo[i][hPickupP][1],
                hInfo[i][hPickupP][2]))
                return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No estás cerca de ninguna casa.");

            // Validaciones
            if(hInfo[i][hSale] == 1) return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Esta casa no está en venta.");
            if(GetPlayerMoney(playerid) < hInfo[i][hPrice]) return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No tienes suficiente dinero para comprar esta casa.");
            if(GetPlayerScore(playerid) < hInfo[i][hLevel]) return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No tienes suficiente score para comprar esta casa.");
            if(jpInfo[playerid][OwnedHouses] == 1) return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Ya posees una casa, no puedes comprar otra.");

            // Asignar la casa al jugador
            jpInfo[playerid][OwnedHouses] = 1;
            jpInfo[playerid][p_SpawnPoint][0] = hInfo[i][hEnterPos][0];
            jpInfo[playerid][p_SpawnPoint][1] = hInfo[i][hEnterPos][1];
            jpInfo[playerid][p_SpawnPoint][2] = hInfo[i][hEnterPos][2];
            jpInfo[playerid][p_SpawnPoint][3] = hInfo[i][hEnterPos][3];
            jpInfo[playerid][p_Interior] = hInfo[i][hInterior];

            hInfo[i][hSale] = 1;
            hInfo[i][hLocked] = 0;
            format(hInfo[i][hOwner], 256, "%s", p_Name(playerid));

            // Cobrar al jugador
            GivePlayerMoney(playerid, -hInfo[i][hPrice]);

            // Mensaje de confirmación
            format(string, sizeof(string), "* {FFFFFF}Has comprado esta casa por $%s.", FormatNumber(hInfo[i][hPrice]));
            SendClientMessage(playerid, COLOR_YELLOW, string);

            // Guardar y recargar la casa
            SaveHouse(i);
            DestroyDynamicPickup(hInfo[i][hPickup]);
            DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
            DestroyDynamic3DTextLabel(hInfo[i][hLabel]);
            LoadHouse(i);
        }
        else // Botón "Cerrar"
        {
            SendClientMessage(playerid, COLOR_YELLOW, "* {FFFFFF}Has cerrado el menú de compra.");
        }
    }
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_HMAIN)
    {
        if(!response) return 1; // Cancelar

        switch(listitem)
        {
            case 0:
            {
                // Sin acción
            }
            case 1:
            {
                new i = h_ID[playerid];
                if(i == -1 || h_Inside[playerid] == -1) return 1;

                // Verificar dueño
                if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
                {
                    SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
                    return 1;
                }

                // Toggle estado
                hInfo[i][hLocked] = (hInfo[i][hLocked] == 1) ? 0 : 1;

                SaveHouse(i);
                
			    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
			    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

			    LoadHouse(i);
                // Reabrir menú actualizado
                ShowHouseMainMenu(playerid);
            }
            case 2:
			{
				// Sin acción
			}
			case 3: // Cambiar Interior
			{
			    new list[512];
			    list[0] = '\0';

			    for(new idx = 0; idx < sizeof(intInfo); idx++)
			    {
			        format(list, sizeof(list), "%s%s\n", list, intInfo[idx][Name]);
			    }

			    ShowPlayerDialog(playerid, DIALOG_HINTERIOR_LIST, DIALOG_STYLE_LIST,
			        "Selecciona un Interior",
			        list,
			        "Ver",
			        "Cancelar"
			    );
			}
            case 4: // Vender casa por la mitad del precio
			{
			    new i = h_ID[playerid];
			    if(i == -1 || h_Inside[playerid] == -1) return 1;

			    if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
			    {
			        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
			        return 1;
			    }

			    new precioVenta = hInfo[i][hPrice] / 2;
			    new info[128];
			    format(info, sizeof(info), "¿Quieres vender tu casa por: {2ECC71}$%d?", precioVenta);

			    ShowPlayerDialog(playerid, DIALOG_SELLHOUSE, DIALOG_STYLE_MSGBOX,
			        "VENDER CASA",
			        info,
			        "Vender",
			        "Cancelar"
			    );
			}
            case 5: // Expulsar jugadores de la casa
			{
			    new i = h_ID[playerid];
			    if(i == -1 || h_Inside[playerid] == -1) return 1;

			    if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
			    {
			        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
			        return 1;
			    }

			    // Expulsar jugadores dentro de la casa (menos al dueño)
			    new expulsados = 0;
			    for(new p = 0; p < MAX_PLAYERS; p++)
			    {
			        if(IsPlayerConnected(p) && h_Inside[p] == i)
			        {
			            if(strcmp(hInfo[i][hOwner], p_Name(p), true) != 0) // no es el dueño
			            {
			                SetPlayerPos(p,
			                    hInfo[i][hPickupP][0],
			                    hInfo[i][hPickupP][1],
			                    hInfo[i][hPickupP][2]);
			                SetPlayerInterior(p, 0);
			                SetPlayerVirtualWorld(p, 0);
			                h_Inside[p] = -1;

			                SendClientMessage(p, COLOR_YELLOW, "* {FFFFFF}Has sido expulsado de la casa por el dueño.");
			                expulsados++;
			            }
			        }
			    }

			    if(expulsados > 0)
			    {
			        SendClientMessage(playerid, COLOR_GREEN, "* {FFFFFF}Has expulsado a los jugadores de tu casa.");
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No hay jugadores dentro de tu casa.");
			    }
			}
            case 6: // Guardar dinero
			{
			    new i = h_ID[playerid];
			    if(i == -1 || h_Inside[playerid] == -1) return 1;

			    if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
			    {
			        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
			        return 1;
			    }

			    new info[256];
			    format(info, sizeof(info),
			        "Tienes en tu caja fuerte: {2ECC71}$%d\n\n{FFFFFF}Escribe la cantidad que quieres guardar",
			        hInfo[i][MoneyStore]);

			    ShowPlayerDialog(playerid, DIALOG_SAVEMONEY, DIALOG_STYLE_INPUT,
			        "GUARDAR DINERO",
			        info,
			        "Guardar",
			        "X"
			    );
			}
			case 7: // Retirar dinero
			{
			    new i = h_ID[playerid];
			    if(i == -1 || h_Inside[playerid] == -1) return 1;

			    if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
			    {
			        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
			        return 1;
			    }

			    new info[256];
			    format(info, sizeof(info),
			        "Tienes en tu caja fuerte: {2ECC71}$%d\n\n{FFFFFF}Escribe la cantidad que quieres retirar",
			        hInfo[i][MoneyStore]);

			    ShowPlayerDialog(playerid, DIALOG_WITHDRAWMONEY, DIALOG_STYLE_INPUT,
			        "RETIRAR DINERO",
			        info,
			        "Retirar",
			        "X"
			    );
			}
            case 8: // Dejar una nota
			{
			    new i = h_ID[playerid];
			    if(i == -1 || h_Inside[playerid] == -1) return 1;

			    if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
			    {
			        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
			        return 1;
			    }

			    new info[256];
			    format(info, sizeof(info),
			        "Nota actual:\n(%s)\n\n{FFFFFF}Escribe la nota que quieras dejar",
			        hInfo[i][hNotes]);

			    ShowPlayerDialog(playerid, DIALOG_SETNOTE, DIALOG_STYLE_INPUT,
			        "NOTA",
			        info,
			        "Cambiar",
			        "X"
			    );
			}
            case 9: // Cambiar Clave
            {
                new i = h_ID[playerid];
                if(i == -1 || h_Inside[playerid] == -1) return 1;

                if(strcmp(hInfo[i][hOwner], p_Name(playerid), true) != 0)
                {
                    SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No eres el propietario de esta casa.");
                    return 1;
                }

                new info[256];
                format(info, sizeof(info),
                    "Ingresa la nueva clave de seguridad para entrar a tu casa\nClave actual: (%s)\n{FFFFFF}Puedes dar esta clave para que tus amigos entren a tu casa",
                    hInfo[i][hKey]);

                ShowPlayerDialog(playerid, DIALOG_HKEY_CHANGE, DIALOG_STYLE_INPUT,
                    "SEGURIDAD",
                    info,
                    "Enviar",
                    "X"
                );
            }
            case 10: // Salir de la casa
            {
                new i = h_ID[playerid];
                if(i == -1 || h_Inside[playerid] == -1)
                {
                    SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No estás dentro de ninguna casa.");
                    return 1;
                }

                // Teletransportar al pickup de entrada
                SetPlayerPos(playerid,
                    hInfo[i][hPickupP][0],
                    hInfo[i][hPickupP][1],
                    hInfo[i][hPickupP][2]);
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);

                h_Inside[playerid] = -1;

                SendClientMessage(playerid, COLOR_YELLOW, "* {FFFFFF}Has salido de la casa.");
            }
			
        }
    }
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_HINTERIOR_LIST)
	{
	    if(!response) return 1;

	    new i = h_ID[playerid];
	    new interiorSeleccionado = listitem;

	    // Guardar interior original
	    hPreviewInterior[playerid] = hInfo[i][hInterior];

	    // Teletransportar al jugador al interior seleccionado (preview)
	    SetPlayerInterior(playerid, intInfo[interiorSeleccionado][i_Int]);
	    SetPlayerPos(playerid,
	        intInfo[interiorSeleccionado][SpawnPointX],
	        intInfo[interiorSeleccionado][SpawnPointY],
	        intInfo[interiorSeleccionado][SpawnPointZ]
	    );
	    SetPlayerFacingAngle(playerid, intInfo[interiorSeleccionado][SpawnPointA]);
	    
		HouseFreeze(playerid);
	    // Mostrar el Mensaje de compra
	    new info[128];
	    format(info, sizeof(info), "¿Quieres comprar este interior por: $%d?", intInfo[interiorSeleccionado][i_Price]);

	    ShowPlayerDialog(playerid, DIALOG_HINTERIOR_BUY, DIALOG_STYLE_MSGBOX,
	        "COMPRAR INTERIOR",
	        info,
	        "Comprar",
	        "Cancelar"
	    );

	    // Guardar el interior que se estaba viendo
	    hPreviewInterior[playerid] = interiorSeleccionado;
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_HINTERIOR_BUY)
	{
	    new i = h_ID[playerid];
	    new preview = hPreviewInterior[playerid];

	    if(!response) // Cancelar
	    {
	        // Volver al interior original
	        SetPlayerInterior(playerid, intInfo[hInfo[i][hInterior]][i_Int]);
	        SetPlayerPos(playerid,
	            intInfo[hInfo[i][hInterior]][SpawnPointX],
	            intInfo[hInfo[i][hInterior]][SpawnPointY],
	            intInfo[hInfo[i][hInterior]][SpawnPointZ]
	        );
	        SetPlayerFacingAngle(playerid, intInfo[hInfo[i][hInterior]][SpawnPointA]);
	        
	        HouseFreeze(playerid);
	        return 1;
	    }

	    // Comprar
	    new precio = intInfo[preview][i_Price];
	    if(GetPlayerMoney(playerid) < precio)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No tienes suficiente dinero.");
	        // Volver al interior original
	        SetPlayerInterior(playerid, intInfo[hInfo[i][hInterior]][i_Int]);
	        SetPlayerPos(playerid,
	            intInfo[hInfo[i][hInterior]][SpawnPointX],
	            intInfo[hInfo[i][hInterior]][SpawnPointY],
	            intInfo[hInfo[i][hInterior]][SpawnPointZ]
	        );
	        SetPlayerFacingAngle(playerid, intInfo[hInfo[i][hInterior]][SpawnPointA]);
	        
	        HouseFreeze(playerid);
	        return 1;
	    }

	    // Cobrar y asignar nuevo interior (guardamos el índice del array)
	    GivePlayerMoney(playerid, -precio);
	    hInfo[i][hInterior] = preview;

		// Actualiza posiciones de entrada/salida con el interior comprado
		hInfo[i][hEnterPos][0] = intInfo[preview][SpawnPointX];
		hInfo[i][hEnterPos][1] = intInfo[preview][SpawnPointY];
		hInfo[i][hEnterPos][2] = intInfo[preview][SpawnPointZ];
		hInfo[i][hEnterPos][3] = intInfo[preview][SpawnPointA];

		hInfo[i][ExitCPPos][0] = intInfo[preview][ExitPointX];
		hInfo[i][ExitCPPos][1] = intInfo[preview][ExitPointY];
		hInfo[i][ExitCPPos][2] = intInfo[preview][ExitPointZ];

		// Guarda y regenera
		SaveHouse(i);

		// Destruye lo que depende del interior
		DestroyDynamicPickup(hInfo[i][hExitPickup]);
		DestroyDynamic3DTextLabel(hInfo[i][hExitLabel]);
		DestroyDynamicMapIcon(hInfo[i][hMapIcon]);
		DestroyDynamic3DTextLabel(hInfo[i][hLabel]);

		LoadHouse(i);

		SendClientMessage(playerid, COLOR_GREEN, "* {FFFFFF}Has comprado un nuevo interior para tu casa.");
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_SELLHOUSE)
	{
	    new i = h_ID[playerid];
	    if(i == -1) return 1;

	    if(!response) return 1; // Cancelar

	    new precioVenta = hInfo[i][hPrice] / 2;
	    GivePlayerMoney(playerid, precioVenta);

	    // Expulsar jugadores dentro de la casa
	    for(new p = 0; p < MAX_PLAYERS; p++)
	    {
	        if(IsPlayerConnected(p) && h_Inside[p] == i)
	        {
	            SetPlayerPos(p,
	                hInfo[i][hPickupP][0],
	                hInfo[i][hPickupP][1],
	                hInfo[i][hPickupP][2]);
	            SetPlayerInterior(p, 0);
	            SetPlayerVirtualWorld(p, 0);
	            h_Inside[p] = -1;

	            SendClientMessage(p, COLOR_YELLOW, "* {FFFFFF}Has sido expulsado porque la casa fue vendida.");
	        }
	    }

	    // Resetear datos del jugador dueño
	    jpInfo[playerid][OwnedHouses] = 0;
	    jpInfo[playerid][p_SpawnPoint][0] = 0.0;
	    jpInfo[playerid][p_SpawnPoint][1] = 0.0;
	    jpInfo[playerid][p_SpawnPoint][2] = 0.0;
	    jpInfo[playerid][p_SpawnPoint][3] = 0.0;
	    jpInfo[playerid][p_Interior] = 0;
	    jpInfo[playerid][p_Spawn] = 0;

	    // Resetear datos de la casa
	    hInfo[i][hSale] = 0;
	    hInfo[i][hLocked] = 0;
	    hInfo[i][MoneyStore] = 0;
	    format(hInfo[i][hOwner], 256, "Ninguno");
	    format(hInfo[i][hName], 256, "Ninguno");
	    format(hInfo[i][hNotes], 256, "Ninguna");              // Limpiar nota
	    format(hInfo[i][hKey], 64, "%s", GenerateRandomKey(6)); // Nueva clave
	    hInfo[i][hWorld] = 1000 + i; // Mantener VW único

	    SaveHouse(i);

	    // Destruir pickups/labels/mapicon
	    DestroyDynamicPickup(hInfo[i][hPickup]);
	    DestroyDynamic3DTextLabel(hInfo[i][hLabel]);
	    DestroyDynamicPickup(hInfo[i][hExitPickup]);
	    DestroyDynamic3DTextLabel(hInfo[i][hExitLabel]);
	    DestroyDynamicMapIcon(hInfo[i][hMapIcon]);

	    // Regenerar la casa como en venta
	    LoadHouse(i);

	    SendClientMessage(playerid, COLOR_GREEN, "* {FFFFFF}Has vendido tu casa por la mitad del precio.");
	}
	//--------------------------------------------------------------------------
	if(dialogid == DIALOG_SAVEMONEY)
	{
	    new i = h_ID[playerid];
	    if(i == -1) return 1;

	    if(!response) return 1; // Cancelar

	    // Validar que solo sean números
	    if(!IsNumeric(inputtext))
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Debes ingresar solo numeros.");
	        return 1;
	    }

	    new cantidad = strval(inputtext);

	    // Validar rango
	    if(cantidad < 1 || cantidad > 10000000)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La cantidad debe ser entre $1 y $10.000.000");
	        return 1;
	    }

	    // Validar que el jugador tenga suficiente dinero
	    if(GetPlayerMoney(playerid) < cantidad)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No tienes suficiente dinero.");
	        return 1;
	    }

	    // Guardar dinero en la casa
	    GivePlayerMoney(playerid, -cantidad);
	    hInfo[i][MoneyStore] += cantidad;

	    new msg[128];
	    format(msg, sizeof(msg), "* {FFFFFF}Has guardado $%d de dinero en tu casa ID: %d", cantidad, i);
	    SendClientMessage(playerid, COLOR_GREEN, msg);

	    SaveHouse(i);
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_WITHDRAWMONEY)
	{
	    new i = h_ID[playerid];
	    if(i == -1) return 1;

	    if(!response) return 1; // Cancelar

	    // Validar que solo sean números
	    if(!IsNumeric(inputtext))
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Debes ingresar solo numeros.");
	        return 1;
	    }

	    new cantidad = strval(inputtext);

	    // Validar rango
	    if(cantidad < 1 || cantidad > 10000000)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La cantidad debe ser entre $1 y $10,000,000.");
	        return 1;
	    }

	    // Validar que la casa tenga suficiente dinero
	    if(hInfo[i][MoneyStore] < cantidad)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La caja fuerte no tiene suficiente dinero.");
	        return 1;
	    }

	    // Retirar dinero de la casa
	    hInfo[i][MoneyStore] -= cantidad;
	    GivePlayerMoney(playerid, cantidad);

	    new msg[128];
	    format(msg, sizeof(msg), "* {FFFFFF}Has retirado $%d de dinero en tu casa ID: %d", cantidad, i);
	    SendClientMessage(playerid, COLOR_GREEN, msg);

	    SaveHouse(i);
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_SETNOTE)
	{
	    new i = h_ID[playerid];
	    if(i == -1) return 1;

	    if(!response) return 1; // Cancelar

	    // Validar que no esté vacío
	    if(strlen(inputtext) == 0)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No has introducido ningun texto!");
	        return 1;
	    }

	    // Validar longitud
	    if(strlen(inputtext) < 4 || strlen(inputtext) > 24)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La nota debe tener entre 4 y 24 caracteres.");
	        return 1;
	    }

	    // Validar espacios invisibles (al inicio o final)
	    if(inputtext[0] == ' ' || inputtext[strlen(inputtext) - 1] == ' ')
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La nota no puede contener espacios invisibles!");
	        return 1;
	    }

	    // Validar caracteres prohibidos { }
	    if(strfind(inputtext, "{", true) != -1 || strfind(inputtext, "}", true) != -1)
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La nota contiene caracteres prohibidos: '{' y '}'");
	        return 1;
	    }

	    // Validar caracteres permitidos con stock
	    if(!IsValidNameX(inputtext))
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La nota contiene caracteres no permitidos.");
	        return 1;
	    }

	    // Guardar la nota
	    format(hInfo[i][hNotes], 256, "%s", inputtext);
	    SaveHouse(i);

	    new msg[128];
	    format(msg, sizeof(msg), "* {FFFFFF}Has cambiado exitosamente la nota de tu casa ID: %d", i);
	    SendClientMessage(playerid, COLOR_GREEN, msg);
	}

	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_MIHOUSE)
	{
	    if(!response) return 1;

	    new pname[24];
	    GetPlayerName(playerid, pname, sizeof(pname));

	    new count = 0;
	    for(new i = 0; i < MAX_HOUSES; i++)
	    {
	        if(hInfo[i][hSale] == 1 && strcmp(hInfo[i][hOwner], pname, true) == 0)
	        {
	            if(count == listitem)
	            {
	                SetPVarInt(playerid, "SelectedHouse", i);

	                new caption[64];
	                format(caption, sizeof(caption), "| CASA ID - (%d) |", i);

	                ShowPlayerDialog(playerid, DIALOG_MIHOUSE_OPT, DIALOG_STYLE_LIST,
	                    caption,
	                    "* Ir a mi casa",
	                    ">>",
	                    "X"
	                );
	                break;
	            }
	            count++;
	        }
	    }
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_MIHOUSE_OPT)
	{
	    if(!response) return 1;

	    new selectedHouse = GetPVarInt(playerid, "SelectedHouse");

	    if(listitem == 0) // Opción "Ir a mi casa"
	    {
	        SetPlayerPos(playerid,
	            hInfo[selectedHouse][hPickupP][0],
	            hInfo[selectedHouse][hPickupP][1],
	            hInfo[selectedHouse][hPickupP][2]
	        );
	        SetPlayerInterior(playerid, 0);
	        SetPlayerVirtualWorld(playerid, 0);

	        SendClientMessage(playerid, COLOR_GREEN, "* {FFFFFF}Has sido teletransportado a tu casa.");
	    }
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_HKEY_CHANGE)
	{
	    if(!response) return 1;

	    // Validar que no esté vacío
	    if(strlen(inputtext) == 0)
	        return SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No has introducido ninguna clave!");

	    // Validar longitud
	    if(strlen(inputtext) < 3 || strlen(inputtext) > 16)
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave debe tener entre 3 y 16 caracteres.");

	    // Validar espacios invisibles (al inicio o final)
	    if(inputtext[0] == ' ' || inputtext[strlen(inputtext) - 1] == ' ')
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave no puede empezar ni terminar con espacios!");

	    // Validar caracteres prohibidos { }
	    if(strfind(inputtext, "{", true) != -1 || strfind(inputtext, "}", true) != -1)
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave contiene caracteres prohibidos: '{' y '}'");

	    // Validar caracteres permitidos con stock
	    if(!IsValidNameX(inputtext))
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave contiene caracteres no permitidos.");

	    // Si pasa todas las validaciones, guardar la clave
	    new i = h_ID[playerid];
	    format(hInfo[i][hKey], 64, "%s", inputtext);
	    SaveHouse(i);

	    SendClientMessage(playerid, COLOR_GREEN, "* {FFFFFF}Has cambiado la clave de seguridad de tu casa.");
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_HKEY_ENTER)
	{
	    if(!response) return 1;

	    // Validar que no esté vacío
	    if(strlen(inputtext) == 0)
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Debes introducir una clave para entrar.");

	    // Validar espacios invisibles (al inicio o final)
	    if(inputtext[0] == ' ' || inputtext[strlen(inputtext) - 1] == ' ')
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave no puede empezar ni terminar con espacios.");

	    // Validar caracteres prohibidos { }
	    if(strfind(inputtext, "{", true) != -1 || strfind(inputtext, "}", true) != -1)
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave contiene caracteres prohibidos: '{' y '}'");

	    // Validar caracteres permitidos con stock
	    if(!IsValidNameX(inputtext))
	        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}La clave contiene caracteres no permitidos.");

	    new i = GetPVarInt(playerid, "HouseToEnter");

	    if(strcmp(inputtext, hInfo[i][hKey], true) == 0)
	    {
	        // Clave correcta entonces entrar
	        SetPlayerPos(playerid,
	            hInfo[i][hEnterPos][0],
	            hInfo[i][hEnterPos][1],
	            hInfo[i][hEnterPos][2]);
	        SetPlayerFacingAngle(playerid, hInfo[i][hEnterPos][3]);
	        SetPlayerInterior(playerid, intInfo[hInfo[i][hInterior]][i_Int]);
	        SetPlayerVirtualWorld(playerid, hInfo[i][hWorld]);
	        h_Inside[playerid] = i;
	        
	        HouseFreeze(playerid);

	        // Mostrar mensaje de visitante
	        SendClientMessage(playerid, COLOR_WHITE, "================================================");
	        new line[128];
	        format(line, sizeof(line), "~ NOTA: %s", hInfo[i][hNotes]);
	        SendClientMessage(playerid, COLOR_WHITE, line);
	        SendClientMessage(playerid, COLOR_WHITE, "================================================");
	        new line2[128];
	        format(line2, sizeof(line2), "** Bienvenido a la casa de: {FFFFFF}%s", hInfo[i][hOwner]);
	        SendClientMessage(playerid, COLOR_YELLOW, line2);
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Clave de seguridad incorrecta. No puedes entrar!");
	    }
	}
	//------------------------------------------------------------------------//
	if(dialogid == DIALOG_HOUSES_LIST)
	{
	    if(response) // Botón 1 (+Casas)
	    {
	        new page = GetPVarInt(playerid, "CasasPage");
	        page++;

	        new totalCasas = GetTotalCasas();
	        if(page * 20 >= totalCasas)
	        {
	            SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No hay más casas para mostrar.");
	            return 1;
	        }

	        SetPVarInt(playerid, "CasasPage", page);
	        ShowCasasDialog(playerid, page);
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_YELLOW, "* {FFFFFF}Has cerrado el listado de casas.");
	    }
	}
	return 1;
}
//============================[Comandos Jugador Casa]===========================//
CMD:micasa(playerid, params[])
{
    if(h_Inside[playerid] != -1)
    {
        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No puedes usar este comando dentro de una casa.");
        return 1;
    }

    new string[1024];
    string[0] = '\0';

    new pname[24];
    GetPlayerName(playerid, pname, sizeof(pname));

    // Recorremos todas las casas y verificamos si el jugador es el propietario
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(hInfo[i][hSale] == 1 && strcmp(hInfo[i][hOwner], pname, true) == 0)
        {
            new line[128];
            format(line, sizeof(line), "ID %d (Nota: %s)\n", i, hInfo[i][hNotes]);
            strcat(string, line);
        }
    }

    if(strlen(string) == 0)
    {
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}No posees ninguna casa.");
    }

    ShowPlayerDialog(playerid, DIALOG_MIHOUSE, DIALOG_STYLE_LIST,
        "{33FF33}Tus Casas",
        string,
        ">>",
        "X"
    );
    return 1;
}

//----------------------------------------------------------------------------//
CMD:casas(playerid, params[])
{
    new total = GetTotalCasas();
    if(total == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Actualmente no existen casas en el servidor.");
        return 1;
    }

    SetPVarInt(playerid, "CasasPage", 0);
    ShowCasasDialog(playerid, 0);
    return 1;
}
//============================[Comandos Admin Casa]===========================//
// Crear casa
CMD:crearcasa(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No tienes permiso para esto!");

    new hid, level, price, interior;
    new Float:p_Pos[3];

    if(sscanf(params, "iiii", hid, level, price, interior))
        return SendClientMessage(playerid, COLOR_YELLOW, "* Uso: {FFFFFF}/crearcasa [Casa ID] [Score] [Precio] [Interior ID]");

    if(hid < 0 || hid > MAX_HOUSES)
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}ID de casa fuera de rango.");
    if(interior < 0 || interior >= sizeof(intInfo))
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Interior inválido.");
    if(level < 0)
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}El Score no puede ser negativo.");
    if(fexist(HousePath(hid)))
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Este slot de casa ya está ocupado.");

    GetPlayerPos(playerid, p_Pos[0], p_Pos[1], p_Pos[2]);

    format(hInfo[hid][hName], 256, "Ninguno");
    format(hInfo[hid][hOwner], 256, "Ninguno");
    hInfo[hid][hLevel] = level;
    hInfo[hid][hPrice] = price;
    hInfo[hid][hSale] = 0;
    hInfo[hid][hInterior] = interior;
    hInfo[hid][hWorld] = 1000 + hid;
    hInfo[hid][hLocked] = 1;

    hInfo[hid][hEnterPos][0] = intInfo[interior][SpawnPointX];
    hInfo[hid][hEnterPos][1] = intInfo[interior][SpawnPointY];
    hInfo[hid][hEnterPos][2] = intInfo[interior][SpawnPointZ];
    hInfo[hid][hEnterPos][3] = intInfo[interior][SpawnPointA];

    hInfo[hid][hPickupP][0] = p_Pos[0];
    hInfo[hid][hPickupP][1] = p_Pos[1];
    hInfo[hid][hPickupP][2] = p_Pos[2];

    hInfo[hid][ExitCPPos][0] = intInfo[interior][ExitPointX];
    hInfo[hid][ExitCPPos][1] = intInfo[interior][ExitPointY];
    hInfo[hid][ExitCPPos][2] = intInfo[interior][ExitPointZ];

    format(hInfo[hid][hIName], 256, "%s", intInfo[interior][Name]);
    format(hInfo[hid][hNotes], 256, "Ninguna");
    format(hInfo[hid][hKey], 64, "%s", GenerateRandomKey(6));
    hInfo[hid][MoneyStore] = 0;

    dini_Create(HousePath(hid));
    SaveHouse(hid);

    DestroyDynamicPickup(hInfo[hid][hPickup]);
    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);
    LoadHouse(hid);

    new string[128];
    format(string, sizeof(string), "* {FFFFFF}Casa ID %d creada. Precio $%d, Score %d, VW %d, Interior %d", hid, price, level, hInfo[hid][hWorld], interior);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

// Remover/Eliminar casa - (admin)
CMD:removercasa(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No tienes permiso para esto!");

    new hid;
    if(sscanf(params, "i", hid))
        return SendClientMessage(playerid, COLOR_YELLOW, "* Uso: {FFFFFF}/removercasa [Casa ID]");
    if(!fexist(HousePath(hid)))
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Esta casa no existe.");

    // Resetear datos del propietario en archivo .ini
    new file[128];
    format(file, sizeof(file), USER_PATH, hInfo[hid][hOwner]);
	dini_IntSet(file, "Houses", jpInfo[playerid][OwnedHouses]=0);
	dini_FloatSet(file, "X", jpInfo[playerid][p_SpawnPoint][0]=0.0);
	dini_FloatSet(file, "Y", jpInfo[playerid][p_SpawnPoint][1]=0.0);
	dini_FloatSet(file, "Z", jpInfo[playerid][p_SpawnPoint][2]=0.0);
	dini_FloatSet(file, "A", jpInfo[playerid][p_SpawnPoint][3]=0.0);
	dini_IntSet(file, "Interior", jpInfo[playerid][p_Interior]=0);
	dini_IntSet(file, "Spawn", jpInfo[playerid][p_Spawn]=0);

    // Resetear datos de la casa
    format(hInfo[hid][hOwner], 256, "Ninguno");
    format(hInfo[hid][hName], 256, "Ninguno");
    format(hInfo[hid][hNotes], 256, "Ninguna");
    format(hInfo[hid][hKey], 64, "%s", GenerateRandomKey(6));
    hInfo[hid][hSale] = 0;
    hInfo[hid][hLocked] = 0;
    hInfo[hid][MoneyStore] = 0;
    hInfo[hid][hWorld] = 1000 + hid;

    fremove(HousePath(hid));
    SaveHouse(hid);

    // Destruir pickups/labels/mapicon
    DestroyDynamicPickup(hInfo[hid][hPickup]);
    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);
    LoadHouse(hid);

    new string[128];
    format(string, sizeof(string), "* {FFFFFF}Casa ID %d eliminada correctamente.", hid);
    SendClientMessage(playerid, COLOR_RED, string);

    return 1;
}


// Ir a casa (Admin)
CMD:gotocasa(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No tienes permiso para esto!");

    new hid;
    if(sscanf(params, "i", hid))
        return SendClientMessage(playerid, COLOR_YELLOW, "* Uso: {FFFFFF}/gotocasa [Casa ID]");
    if(!fexist(HousePath(hid)))
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Esta casa no existe.");

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, hInfo[hid][hPickupP][0], hInfo[hid][hPickupP][1], hInfo[hid][hPickupP][2]);

    new string[128];
    format(string, sizeof(string), "* {FFFFFF}Has sido teletransportado a la Casa ID %d (Propietario: %s)", hid, hInfo[hid][hOwner]);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

// Mover casa (Admin)
CMD:movercasa(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No tienes permiso para esto!");

    new hid;
    new Float:p_Pos[3];
    if(sscanf(params, "i", hid))
        return SendClientMessage(playerid, COLOR_YELLOW, "* Uso: {FFFFFF}/movercasa [Casa ID]");
    if(!fexist(HousePath(hid)))
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Esta casa no existe.");

    GetPlayerPos(playerid, p_Pos[0], p_Pos[1], p_Pos[2]);

    hInfo[hid][hPickupP][0] = p_Pos[0];
    hInfo[hid][hPickupP][1] = p_Pos[1];
    hInfo[hid][hPickupP][2] = p_Pos[2];

    SaveHouse(hid);

    DestroyDynamicPickup(hInfo[hid][hPickup]);
    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);
    LoadHouse(hid);

    new string[128];
    format(string, sizeof(string), "* {FFFFFF}Casa ID %d movida a tu ubicacion.", hid);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}


// Vender casa (admin)
CMD:vendercasa(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, COLOR_RED, "* Error: {FFFFFF}No tienes permiso para esto!");

    new hid;
    if(sscanf(params, "i", hid))
        return SendClientMessage(playerid, COLOR_YELLOW, "* Uso: {FFFFFF}/vendercasa [Casa ID]");
    if(!fexist(HousePath(hid)))
        return SendClientMessage(playerid, COLOR_RED, "* {FFFFFF}Esta casa no existe.");

    // Resetear datos del propietario en archivo .ini
    new file[128];
    format(file, sizeof(file), USER_PATH, hInfo[hid][hOwner]);
	dini_IntSet(file, "Houses", jpInfo[playerid][OwnedHouses]=0);
	dini_FloatSet(file, "X", jpInfo[playerid][p_SpawnPoint][0]=0.0);
	dini_FloatSet(file, "Y", jpInfo[playerid][p_SpawnPoint][1]=0.0);
	dini_FloatSet(file, "Z", jpInfo[playerid][p_SpawnPoint][2]=0.0);
	dini_FloatSet(file, "A", jpInfo[playerid][p_SpawnPoint][3]=0.0);
	dini_IntSet(file, "Interior", jpInfo[playerid][p_Interior]=0);
	dini_IntSet(file, "Spawn", jpInfo[playerid][p_Spawn]=0);

    // Resetear datos de la casa
    format(hInfo[hid][hOwner], 256, "Ninguno");
    format(hInfo[hid][hName], 256, "Ninguno");
    format(hInfo[hid][hNotes], 256, "Ninguna");
    format(hInfo[hid][hKey], 64, "%s", GenerateRandomKey(6));
    hInfo[hid][hSale] = 0;
    hInfo[hid][hLocked] = 0;
    hInfo[hid][MoneyStore] = 0;
    hInfo[hid][hWorld] = 1000 + hid;

    SaveHouse(hid);

    // Destruir pickups/labels/mapicon
    DestroyDynamicPickup(hInfo[hid][hPickup]);
    DestroyDynamicMapIcon(hInfo[hid][hMapIcon]);
    DestroyDynamic3DTextLabel(hInfo[hid][hLabel]);
    LoadHouse(hid);

    new string[128];
    format(string, sizeof(string), "* {FFFFFF}Casa ID %d ha sido vendida por el administrador.", hid);
    SendClientMessage(playerid, COLOR_RED, string);

    return 1;
}
//==================================[Stocks]==================================//
// Función que libera al jugador
forward HouseUnfreeze(playerid);
public HouseUnfreeze(playerid)
{
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 1);
    GameTextForPlayer(playerid, "~r~~h~Cargado!", 2500, 3);
    return 1;
}

// Función que congela al jugador
stock HouseFreeze(playerid)
{
    TogglePlayerControllable(playerid, 0);
    SetCameraBehindPlayer(playerid);
    GameTextForPlayer(playerid, "~w~Cargando...", HOUSE_FREEZE_TIME, 3);
    SetTimerEx("HouseUnfreeze", HOUSE_FREEZE_TIME, false, "i", playerid);
    return 1;
}
//----------------------------------------------------------------------------//
stock Player_Save(playerid)
{
	dini_IntSet(PlayerPath(playerid), "Houses", jpInfo[playerid][OwnedHouses]);
	dini_FloatSet(PlayerPath(playerid), "X", jpInfo[playerid][p_SpawnPoint][0]);
	dini_FloatSet(PlayerPath(playerid), "Y", jpInfo[playerid][p_SpawnPoint][1]);
	dini_FloatSet(PlayerPath(playerid), "Z", jpInfo[playerid][p_SpawnPoint][2]);
	dini_FloatSet(PlayerPath(playerid), "A", jpInfo[playerid][p_SpawnPoint][3]);
	dini_IntSet(PlayerPath(playerid), "Interior", jpInfo[playerid][p_Interior]);
	dini_IntSet(PlayerPath(playerid), "Spawn", jpInfo[playerid][p_Spawn]);
	return 1;
}
//----------------------------------------------------------------------------//
stock Player_Load(playerid)
{
	jpInfo[playerid][OwnedHouses] = dini_Int(PlayerPath(playerid), "Houses");
	jpInfo[playerid][p_SpawnPoint][0] = dini_Float(PlayerPath(playerid), "X");
	jpInfo[playerid][p_SpawnPoint][1] = dini_Float(PlayerPath(playerid), "Y");
	jpInfo[playerid][p_SpawnPoint][2] = dini_Float(PlayerPath(playerid), "Z");
	jpInfo[playerid][p_SpawnPoint][3] = dini_Float(PlayerPath(playerid), "A");
	jpInfo[playerid][p_Interior] = dini_Int(PlayerPath(playerid), "Interior");
	jpInfo[playerid][p_Spawn] = dini_Int(PlayerPath(playerid), "Spawn");
	return 1;
}
//----------------------------------------------------------------------------//
stock p_Name(playerid)
{
	new pName[24];
	GetPlayerName(playerid, pName, 24);
	return pName;
}
//----------------------------------------------------------------------------//
stock SaveHouse(houseid)
{
	dini_Set(HousePath(houseid), "Name", hInfo[houseid][hName]);
	dini_Set(HousePath(houseid), "Owner", hInfo[houseid][hOwner]);
	dini_Set(HousePath(houseid), "InteriorName", hInfo[houseid][hIName]);
	dini_Set(HousePath(houseid), "Notes", hInfo[houseid][hNotes]);
	dini_Set(HousePath(houseid), "Key", hInfo[houseid][hKey]);
	dini_IntSet(HousePath(houseid), "Level", hInfo[houseid][hLevel]);
	dini_IntSet(HousePath(houseid), "Price", hInfo[houseid][hPrice]);
	dini_IntSet(HousePath(houseid), "Sale", hInfo[houseid][hSale]);
	dini_IntSet(HousePath(houseid), "Interior", hInfo[houseid][hInterior]);
	dini_IntSet(HousePath(houseid), "World", hInfo[houseid][hWorld]);
	dini_IntSet(HousePath(houseid), "Locked", hInfo[houseid][hLocked]);
	dini_FloatSet(HousePath(houseid), "xPoint", hInfo[houseid][hEnterPos][0]);
	dini_FloatSet(HousePath(houseid), "yPoint", hInfo[houseid][hEnterPos][1]);
	dini_FloatSet(HousePath(houseid), "zPoint", hInfo[houseid][hEnterPos][2]);
	dini_FloatSet(HousePath(houseid), "aPoint", hInfo[houseid][hEnterPos][3]);
	dini_FloatSet(HousePath(houseid), "enterX", hInfo[houseid][hPickupP][0]);
	dini_FloatSet(HousePath(houseid), "enterY", hInfo[houseid][hPickupP][1]);
	dini_FloatSet(HousePath(houseid), "enterZ", hInfo[houseid][hPickupP][2]);
	dini_FloatSet(HousePath(houseid), "exitX", hInfo[houseid][ExitCPPos][0]);
	dini_FloatSet(HousePath(houseid), "exitY", hInfo[houseid][ExitCPPos][1]);
	dini_FloatSet(HousePath(houseid), "exitZ", hInfo[houseid][ExitCPPos][2]);
	dini_IntSet(HousePath(houseid), "MoneySafe", hInfo[houseid][MoneyStore]);
	printf("... Se ha guardado el ID de la Casa %d del Sistema.", houseid);
	return 1;
}
//----------------------------------------------------------------------------//
stock LoadHouse(houseid)
{
	format(hInfo[houseid][hName], 256, "%s", dini_Get(HousePath(houseid), "Name"));
	format(hInfo[houseid][hOwner], 256, "%s", dini_Get(HousePath(houseid), "Owner"));
	format(hInfo[houseid][hIName], 256, "%s", dini_Get(HousePath(houseid), "InteriorName"));
	format(hInfo[houseid][hNotes], 256, "%s", dini_Get(HousePath(houseid), "Notes"));
	format(hInfo[houseid][hKey], 64, "%s", dini_Get(HousePath(houseid), "Key"));
	hInfo[houseid][hLevel] = dini_Int(HousePath(houseid), "Level");
	hInfo[houseid][hPrice] = dini_Int(HousePath(houseid), "Price");
	hInfo[houseid][hSale] = dini_Int(HousePath(houseid), "Sale");
	hInfo[houseid][hInterior] = dini_Int(HousePath(houseid), "Interior");
	hInfo[houseid][hWorld] = dini_Int(HousePath(houseid), "World");
	hInfo[houseid][hLocked] = dini_Int(HousePath(houseid), "Locked");
	hInfo[houseid][hEnterPos][0] = dini_Float(HousePath(houseid), "xPoint");
	hInfo[houseid][hEnterPos][1] = dini_Float(HousePath(houseid), "yPoint");
	hInfo[houseid][hEnterPos][2] = dini_Float(HousePath(houseid), "zPoint");
	hInfo[houseid][hEnterPos][3] = dini_Float(HousePath(houseid), "aPoint");
	hInfo[houseid][hPickupP][0] = dini_Float(HousePath(houseid), "enterX");
	hInfo[houseid][hPickupP][1] = dini_Float(HousePath(houseid), "enterY");
	hInfo[houseid][hPickupP][2] = dini_Float(HousePath(houseid), "enterZ");
	hInfo[houseid][ExitCPPos][0] = dini_Float(HousePath(houseid), "exitX");
	hInfo[houseid][ExitCPPos][1] = dini_Float(HousePath(houseid), "exitY");
	hInfo[houseid][ExitCPPos][2] = dini_Float(HousePath(houseid), "exitZ");
	hInfo[houseid][MoneyStore] = dini_Int(HousePath(houseid), "MoneySafe");

	new string[256];
	
	if(hInfo[houseid][hSale] == 0)
	{
	    format(string, sizeof(string),
	        "{FFFFFF} Casa en Venta\n\n\
	        Casa # {FFFF00}%d\n\
	        {FFFFFF}Interior %d\n\
	        {FFFFFF}Costo\n\
	        {FFFFFF}Score: {FFFF00}%s\n\
	        {FFFFFF}Dinero: {33FF33}$%s\n\n\
	        {FFFFFF}Presiona 'N' para entrar a la casa",
	        houseid,
	        hInfo[houseid][hInterior],
	        FormatNumber(hInfo[houseid][hLevel]),
	        FormatNumber(hInfo[houseid][hPrice])
	    );

	    hInfo[houseid][hMapIcon] = CreateDynamicMapIcon(
	        hInfo[houseid][hPickupP][0],
	        hInfo[houseid][hPickupP][1],
	        hInfo[houseid][hPickupP][2],
	        SALE_ICON, -1, 0, 0, -1, STREAM_DISTANCES, MAPICON_LOCAL
	    );

	    hInfo[houseid][hPickup] = CreateDynamicPickup(
	        SALE_PICKUP, 1,
	        hInfo[houseid][hPickupP][0],
	        hInfo[houseid][hPickupP][1],
	        hInfo[houseid][hPickupP][2],
	        0, 0, -1, STREAM_DISTANCES
	    );
	}
	else
	{
	    if(hInfo[houseid][hLocked] == 0) // Casa abierta
	    {
	        format(string, sizeof(string),
	            "{FFFFFF}Propietario: %s\n\n\
	             {FFFFFF}Casa # {FFFF00}%d\n\n\
	             {33FF33}Abierta\n\
	             {FFFFFF}Presiona 'N' para entrar a la casa",
	            hInfo[houseid][hOwner],
	            houseid
	        );
	    }
	    else // Casa cerrada
	    {
	        format(string, sizeof(string),
	            "{FFFFFF}Propietario: %s\n\n\
	             {FFFFFF}Casa # {FFFF00}%d\n\n\
	             {FF0000}Cerrada\n\
	             {FFFFFF}Presiona 'N' para entrar a la casa",
	            hInfo[houseid][hOwner],
	            houseid
	        );
	    }

	    hInfo[houseid][hMapIcon] = CreateDynamicMapIcon(
	        hInfo[houseid][hPickupP][0],
	        hInfo[houseid][hPickupP][1],
	        hInfo[houseid][hPickupP][2],
	        NOTSALE_ICON, -1, 0, 0, -1, STREAM_DISTANCES, MAPICON_LOCAL
	    );
	    
	    hInfo[houseid][hPickup] = CreateDynamicPickup(
	        NOTSALE_PICKUP, 1,
	        hInfo[houseid][hPickupP][0],
	        hInfo[houseid][hPickupP][1],
	        hInfo[houseid][hPickupP][2],
	        0, 0, -1, STREAM_DISTANCES
	    );
	}

    hInfo[houseid][hLabel] = CreateDynamic3DTextLabel(string, -1, hInfo[houseid][hPickupP][0], hInfo[houseid][hPickupP][1], hInfo[houseid][hPickupP][2], STREAM_DISTANCES, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, STREAM_DISTANCES);
	// Crea un pickup en la salida
	hInfo[houseid][hExitPickup] = CreateDynamicPickup(
	    1272,
	    1,
	    hInfo[houseid][ExitCPPos][0],
	    hInfo[houseid][ExitCPPos][1],
	    hInfo[houseid][ExitCPPos][2],
	    hInfo[houseid][hWorld],
	    intInfo[hInfo[houseid][hInterior]][i_Int],
	    -1,
	    STREAM_DISTANCES
	);

	// Crea un label encima del pickup
	hInfo[houseid][hExitLabel] = CreateDynamic3DTextLabel(
	    "{FFFFFF}Presiona 'N' para salir",
	    -1,
	    hInfo[houseid][ExitCPPos][0],
	    hInfo[houseid][ExitCPPos][1],
	    hInfo[houseid][ExitCPPos][2] + 0.5,
	    STREAM_DISTANCES,
	    INVALID_PLAYER_ID,
	    INVALID_VEHICLE_ID,
	    1,
	    hInfo[houseid][hWorld],
	    intInfo[hInfo[houseid][hInterior]][i_Int],
	    -1,
	    STREAM_DISTANCES
	);

	return 1;
}
//----------------------------------------------------------------------------//
stock HousePath(houseid)
{
	new hfile[128];
	format(hfile, 128, HOUSE_PATH, houseid);
	return hfile;
}
//----------------------------------------------------------------------------//
stock PlayerPath(playerid)
{
	new pfile[128];
	format(pfile, 128, USER_PATH, p_Name(playerid));
	return pfile;
}
//----------------------------------------------------------------------------//
stock FormatNumber(value)
{
    new str[32];
    format(str, sizeof(str), "%d", value);

    new len = strlen(str);
    new result[64];
    new count = 0;

    for(new i = len - 1, j = 0; i >= 0; i--, j++)
    {
        result[j] = str[i];
        count++;
        if(count == 3 && i > 0)
        {
            j++;
            result[j] = '.';
            count = 0;
        }
    }
    result[strlen(result)] = '\0';

    new final[64];
    for(new i = strlen(result) - 1, j = 0; i >= 0; i--, j++)
    {
        final[j] = result[i];
    }
    final[strlen(result)] = '\0';

    return final;
}
//----------------------------------------------------------------------------//
stock ShowHouseMainMenu(playerid)
{
    new i = h_ID[playerid];
    if(i == -1 || h_Inside[playerid] == -1) return 0;

    new string[512];
	format(string, sizeof(string),
	    "Casa #: %d\n\
	    Estado: %s\n\
	    Interior #: %d\n\
	    Cambiar Interior\n\
	    Vender casa por la mitad del precio: {2ECC71}($%d)\n\
	    Expulsar jugadores de la casa\n\
	    Guardar dinero\n\
	    Retirar dinero\n\
	    Dejar una nota\n\
	    Cambiar Clave\n\
	    Salir de la casa",
	    i,
	    (hInfo[i][hLocked] == 1) ? ("{FF0000}Cerrada") : ("{33FF33}Abierta"),
	    hInfo[i][hInterior],
	    hInfo[i][hPrice] / 2
	);

    ShowPlayerDialog(playerid, DIALOG_HMAIN, DIALOG_STYLE_LIST,
        "MENU CASA",
        string,
        ">>",
        "X"
    );
    return 1;
}
//----------------------------------------------------------------------------//
stock IsNumeric(const string[])
{
    for(new i = 0; i < strlen(string); i++)
    {
        if(string[i] < '0' || string[i] > '9') return 0;
    }
    return 1;
}
//----------------------------------------------------------------------------//
stock IsValidNameX(const str[])
{
    for (new i = 0; i < strlen(str); i++)
    {
        switch (str[i])
        {
            case 'a'..'z', 'A'..'Z', '0'..'9', '$', '@', 'Ø', ' ': continue;
            default: return 0;
        }
    }
    return 1;
}
//----------------------------------------------------------------------------//
stock GenerateRandomKey(len = 6)
{
    new key[64];
    new charset[] = "ABCDKCCzwKyY9rmBJGu48FrkNMro4AWtCkc1feGYxRYe4Y6vwxyz0123456789";
    new charsetSize = sizeof(charset) - 1;

    for(new i = 0; i < len; i++)
    {
        key[i] = charset[random(charsetSize)];
    }
    key[len] = '\0';
    return key;
}

//----------------------------------------------------------------------------//
stock ShowCasasDialog(playerid, page)
{
    new string[2048];
    format(string, sizeof(string), "{FFFFFF}#\t{FFEB7A}Propietario\t{98F442}Dinero\t{FFFF00}Score\n");

    new start = page * 20; // 20 casas por pagina
    new end = start + 20;
    if(end > MAX_HOUSES) end = MAX_HOUSES;

    for(new i = start; i < end; i++)
    {
        if(fexist(HousePath(i)))
        {
            new owner[64];
            if(strcmp(hInfo[i][hOwner], "Ninguno", true) == 0)
                format(owner, sizeof(owner), "{82FF98}En venta");
            else
                format(owner, sizeof(owner), "{87CEF5}%s", hInfo[i][hOwner]);

            new line[256];
            format(line, sizeof(line), "%d\t%s\t$%s\t%s\n",
                i,
                owner,
                FormatNumber(hInfo[i][hPrice]),
                FormatNumber(hInfo[i][hLevel])
            );
            strcat(string, line);
        }
    }

    ShowPlayerDialog(playerid, DIALOG_HOUSES_LIST, DIALOG_STYLE_TABLIST_HEADERS,
        "CASAS",
        string,
        "+Casas",
        "Cerrar"
    );
}
//----------------------------------------------------------------------------//
stock GetTotalCasas()
{
    new total = 0;
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(fexist(HousePath(i))) total++;
    }
    return total;
}
//----------------------------------------------------------------------------//
