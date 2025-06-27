#define 	FILTERSCRIPT
#include 	<a_samp>
#include    <a_mysql>
#include    <streamer>
#include    <sscanf2>
#include    <YSI\y_iterate>
#include    <zcmd>

#define     MAX_HOUSES          (100)
#define     MAX_HOUSE_NAME      (48)
#define     MAX_HOUSE_PASSWORD  (16)
#define     MAX_INT_NAME        (32)
#define     DIALOG_HOUSE        (7500)
#define     INVALID_HOUSE_ID    (-1)

#define     LOCK_MODE_NOLOCK    (0)
#define     LOCK_MODE_PASSWORD  (1)
#define     LOCK_MODE_OWNER     (2)

#define     SELECT_MODE_EDIT    (0)
#define     SELECT_MODE_SELL    (1)

#define		SQL_HOST			"localhost"
#define		SQL_USER			"root"
#define		SQL_PASSWORD		""
#define		SQL_DBNAME			"sfcnr"

enum    e_house
{
	Name[MAX_HOUSE_NAME],
	Owner[MAX_PLAYER_NAME],
	Password[MAX_HOUSE_PASSWORD],
	Float: houseX,
	Float: houseY,
	Float: houseZ,
	Price,
	Interior,
	LockMode,
	SafeMoney,
	LastEntered,
	Text3D: HouseLabel,
	HousePickup,
	HouseIcon,
	bool: Save
};

enum    e_interior
{
	IntName[MAX_INT_NAME],
	Float: intX,
	Float: intY,
	Float: intZ,
	intID,
	Text3D: intLabel,
	intPickup
};

enum    e_furnituredata
{
	ModelID,
	Name[32],
	Price
};

enum    e_furniture
{
	SQLID,
	HouseID,
	ArrayID,
	Float: furnitureX,
	Float: furnitureY,
	Float: furnitureZ,
	Float: furnitureRX,
	Float: furnitureRY,
	Float: furnitureRZ
};

new
	SQLHandle,
	HouseTimer,
	HouseData[MAX_HOUSES][e_house],
	Iterator: Houses<MAX_HOUSES>,
	InHouse[MAX_PLAYERS] = {INVALID_HOUSE_ID, ...},
	SelectMode[MAX_PLAYERS] = {SELECT_MODE_EDIT, ...};

new
    HouseInteriors[][e_interior] = {
    // int name, x, y, z, intid
		{"Interior 1", 2233.4900, -1114.4435, 1050.8828, 5},
		{"Interior 2", 2196.3943, -1204.1359, 1049.0234, 6},
		{"Interior 3", 2318.1616, -1026.3762, 1050.2109, 9},
		{"Interior 4", 421.8333, 2536.9814, 10.0000, 10},
		{"Interior 5", 225.5707, 1240.0643, 1082.1406, 2},
		{"Interior 6", 2496.2087, -1692.3149, 1014.7422, 3},
		{"Interior 7", 226.7545, 1114.4180, 1080.9952, 5},
		{"Interior 8", 2269.9636, -1210.3275, 1047.5625, 10}
    };

new
	HouseFurnitures[][e_furnituredata] = {
	// modelid, furniture name, price
	    {3111, "Building Plan", 500},
	    {2894, "Book", 20},
	    {2277, "Cat Picture", 100},
	    {1753, "Leather Couch", 150},
	    {1703, "Black Couch", 200},
	    {1255, "Lounger", 75},
	    {19581, "Frying Pan", 10},
	    {19584, "Sauce Pan", 12},
	    {19590, "Woozie's Sword", 1000},
	    {19525, "Wedding Cake", 50},
	    {1742, "Bookshelf", 80},
	    {1518, "TV 1", 130},
	    {19609, "Drum Kit", 500},
		{19787, "Small LCD TV", 2000},
		{19786, "Big LCD TV", 4000},
		{2627, "Treadmill", 130}
	};
	
new
	LockNames[3][32] = {"{2ECC71}Not Locked", "{E74C3C}Password Locked", "{E74C3C}Owner Only"};

stock convertNumber(value)
{
	// http://forum.sa-mp.com/showthread.php?p=843781#post843781
    new string[24];
    format(string, sizeof(string), "%d", value);

    for(new i = (strlen(string) - 3); i > (value < 0 ? 1 : 0) ; i -= 3)
    {
        strins(string[i], ",", 0);
    }
    
    return string;
}

stock RemovePlayerWeapon(playerid, weapon)
{
    new weapons[13], ammo[13];
    for(new i; i < 13; i++) GetPlayerWeaponData(playerid, i, weapons[i], ammo[i]);
    ResetPlayerWeapons(playerid);
    for(new i; i < 13; i++)
    {
        if(weapons[i] == weapon) continue;
        GivePlayerWeapon(playerid, weapons[i], ammo[i]);
    }
    
    return 1;
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float: a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid)) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

stock SendToHouse(playerid, id)
{
    if(!Iter_Contains(Houses, id)) return 0;
    SetPVarInt(playerid, "HousePickupCooldown", tickcount()+8000);
    InHouse[playerid] = id;
	SetPlayerVirtualWorld(playerid, id);
 	SetPlayerInterior(playerid, HouseInteriors[ HouseData[id][Interior] ][intID]);
  	SetPlayerPos(playerid, HouseInteriors[ HouseData[id][Interior] ][intX], HouseInteriors[ HouseData[id][Interior] ][intY], HouseInteriors[ HouseData[id][Interior] ][intZ]);

	new string[128], name[MAX_PLAYER_NAME];
	format(string, sizeof(string), "Welcome to %s's house, %s{FFFFFF}!", HouseData[id][Owner], HouseData[id][Name]);
	SendClientMessage(playerid, 0xFFFFFFFF, string);
	
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	if(!strcmp(HouseData[id][Owner], name))
	{
		HouseData[id][LastEntered] = gettime();
		HouseData[id][Save] = true;
		SendClientMessage(playerid, 0xFFFFFFFF, "Use {3498DB}/house {FFFFFF}to open the house menu.");
	}
	
	return 1;
}

stock ShowHouseMenu(playerid)
{
	new name[24];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	if(strcmp(HouseData[ InHouse[playerid] ][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");

	new string[256], id = InHouse[playerid];
	format(string, sizeof(string), "House Name: %s\nPassword: %s\nLock: %s\nHouse Safe {2ECC71}($%s)\nFurnitures\nGuns\nSell House {2ECC71}($%s)", HouseData[id][Name], HouseData[id][Password], LockNames[ HouseData[id][LockMode] ], convertNumber(HouseData[id][SafeMoney]), convertNumber(floatround(HouseData[id][Price]*0.85)));
	ShowPlayerDialog(playerid, DIALOG_HOUSE+2, DIALOG_STYLE_LIST, HouseData[id][Name], string, "Select", "Close");
	return 1;
}

stock ResetHouse(id)
{
    if(!Iter_Contains(Houses, id)) return 0;
	format(HouseData[id][Name], MAX_HOUSE_NAME, "House For Sale");
	format(HouseData[id][Owner], MAX_PLAYER_NAME, "-");
	format(HouseData[id][Password], MAX_HOUSE_PASSWORD, "-");
	HouseData[id][LockMode] = LOCK_MODE_NOLOCK;
	HouseData[id][SafeMoney] = 0;
	HouseData[id][LastEntered] = 0;
    HouseData[id][Save] = true;
    
    new label[200];
    format(label, sizeof(label), "{2ECC71}House For Sale (ID: %d)\n{FFFFFF}%s\n{F1C40F}Price: {2ECC71}$%s", id, HouseInteriors[ HouseData[id][Interior] ][IntName], convertNumber(HouseData[id][Price]));
	UpdateDynamic3DTextLabelText(HouseData[id][HouseLabel], 0xFFFFFFFF, label);
	Streamer_SetIntData(STREAMER_TYPE_PICKUP, HouseData[id][HousePickup], E_STREAMER_MODEL_ID, 1273);
	Streamer_SetIntData(STREAMER_TYPE_MAP_ICON, HouseData[id][HouseIcon], E_STREAMER_TYPE, 31);
    
    foreach(new i : Player)
    {
        if(InHouse[i] == id)
        {
            SetPVarInt(i, "HousePickupCooldown", tickcount()+8000);
        	SetPlayerVirtualWorld(i, 0);
	        SetPlayerInterior(i, 0);
	        SetPlayerPos(i, HouseData[ InHouse[i] ][houseX], HouseData[ InHouse[i] ][houseY], HouseData[ InHouse[i] ][houseZ]);
	        InHouse[i] = INVALID_HOUSE_ID;
        }
   	}

    new query[64], data[e_furniture];
    mysql_format(SQLHandle, query, sizeof(query), "DELETE FROM houseguns WHERE HouseID=%d", id);
    mysql_tquery(SQLHandle, query, "", "");

    for(new i; i < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); ++i)
    {
        if(!IsValidDynamicObject(i)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_OBJECT, i, E_STREAMER_EXTRA_ID, data);
		if(data[SQLID] > 0 && data[HouseID] == id) DestroyDynamicObject(i);
    }

    mysql_format(SQLHandle, query, sizeof(query), "DELETE FROM housefurnitures WHERE HouseID=%d", id);
    mysql_tquery(SQLHandle, query, "", "");
	return 1;
}

stock SaveHouse(id)
{
    if(!Iter_Contains(Houses, id)) return 0;
	new query[256];
	mysql_format(SQLHandle, query, sizeof(query), "UPDATE houses SET HouseName='%e', HouseOwner='%e', HousePassword='%e', HouseLock=%d, HouseMoney=%d, LastEntered=%d WHERE ID=%d",
	HouseData[id][Name], HouseData[id][Owner], HouseData[id][Password], HouseData[id][LockMode], HouseData[id][SafeMoney], HouseData[id][LastEntered], id);
	mysql_tquery(SQLHandle, query, "", "");
	HouseData[id][Save] = false;
	return 1;
}

forward ResetAndSaveHouses();
forward LoadHouses();
forward LoadFurnitures();

public ResetAndSaveHouses()
{
	foreach(new i : Houses)
	{
	    if(HouseData[i][LastEntered] > 0 && gettime()-HouseData[i][LastEntered] > 604800) ResetHouse(i);
	    if(HouseData[i][Save]) SaveHouse(i);
	}
	
	return 1;
}

public LoadHouses()
{
	new rows = cache_num_rows();
 	new query[50], Cache:housecache;
	mysql_format(query, sizeof(query), "SELECT * FROM `house`");
	housecache = mysql_query(dbHandle, query, true);
	new rows = cache_num_rows(koneksi), tempString[25], tempInt, msg[768];
	if(rows > 0)
	{
  			id = cache_get_field_content_int(loaded, "ID");
	    	cache_get_field_content(loaded, "HouseName", HouseData[id][Name], .max_len = MAX_HOUSE_NAME);
		    cache_get_field_content(loaded, "HouseOwner", HouseData[id][Owner], .max_len = MAX_PLAYER_NAME);
		    cache_get_field_content(loaded, "HousePassword", HouseData[id][Password], .max_len = MAX_HOUSE_PASSWORD);
		    HouseData[i][houseX] = cache_get_field_content_float(loaded, "HouseX");
		    HouseData[i][houseY] = cache_get_field_content_float(loaded, "HouseY");
		    HouseData[i][houseZ] = cache_get_field_content_float(loaded, "HouseZ");
		    HouseData[i][Price] = cache_get_field_content_int(loaded, "HousePrice");
		    HouseData[i][Interior] = cache_get_field_content_int(loaded, "HouseInterior");
		    HouseData[i][LockMode] = cache_get_field_content_int(loaded, "HouseLock");
		    HouseData[i][SafeMoney] = cache_get_field_content_int(loaded, "HouseMoney");
		    HouseData[i][LastEntered] = cache_get_field_content_int(loaded, "LastEntered");

			if(!strcmp(HouseData[id][Owner], "-")) {
   				format(label, sizeof(label), "{2ECC71}House For Sale (ID: %d)\n{FFFFFF}%s\n{F1C40F}Price: {2ECC71}$%s", id, HouseInteriors[ HouseData[id][Interior] ][IntName], convertNumber(HouseData[id][Price]));
				HouseData[id][HousePickup] = CreateDynamicPickup(1273, 1, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ]);
				HouseData[id][HouseIcon] = CreateDynamicMapIcon(HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ], 31, 0);
 			}else{
				format(label, sizeof(label), "{E67E22}%s's House (ID: %d)\n{FFFFFF}%s\n{FFFFFF}%s\n%s", HouseData[id][Owner], id, HouseData[id][Name], HouseInteriors[ HouseData[id][Interior] ][IntName], LockNames[ HouseData[id][LockMode] ]);
				HouseData[id][HousePickup] = CreateDynamicPickup(19522, 1, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ]);
				HouseData[id][HouseIcon] = CreateDynamicMapIcon(HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ], 32, 0);
			}

			HouseData[id][HouseLabel] = CreateDynamic3DTextLabel(label, 0xFFFFFFFF, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ]+0.35, 15.0, .testlos = 1);
   			Iter_Add(Houses, id);
		    loaded++;
	    }
	    
	    printf(" Loaded %d houses.", loaded);
	}
	
	return 1;
}

public LoadFurnitures()
{
	new rows = cache_num_rows();
 	if(rows)
  	{
   		new id, loaded, data[e_furniture];
     	while(loaded < rows)
      	{
       		data[SQLID] = cache_get_field_content_int(loaded, "ID");
         	data[HouseID] = cache_get_field_content_int(loaded, "HouseID");
         	data[ArrayID] = cache_get_field_content_int(loaded, "FurnitureID");
          	data[furnitureX] = cache_get_field_content_float(loaded, "FurnitureX");
           	data[furnitureY] = cache_get_field_content_float(loaded, "FurnitureY");
            data[furnitureZ] = cache_get_field_content_float(loaded, "FurnitureZ");
            data[furnitureRX] = cache_get_field_content_float(loaded, "FurnitureRX");
            data[furnitureRY] = cache_get_field_content_float(loaded, "FurnitureRY");
            data[furnitureRZ] = cache_get_field_content_float(loaded, "FurnitureRZ");

			id = CreateDynamicObject(
   				HouseFurnitures[ data[ArrayID] ][ModelID],
       			data[furnitureX], data[furnitureY], data[furnitureZ],
          		data[furnitureRX], data[furnitureRY], data[furnitureRZ],
				cache_get_field_content_int(loaded, "FurnitureVW"), cache_get_field_content_int(loaded, "FurnitureInt")
			);

			Streamer_SetArrayData(STREAMER_TYPE_OBJECT, id, E_STREAMER_EXTRA_ID, data);
   			loaded++;
 		}
 		
 		printf(" Loaded %d furnitures.", loaded);
   	}
   	
	return 1;
}

public OnFilterScriptInit()
{
	for(new i; i < MAX_HOUSES; ++i)
	{
		HouseData[i][HouseLabel] = Text3D: INVALID_3DTEXT_ID;
		HouseData[i][HousePickup] = -1;
		HouseData[i][HouseIcon] = -1;
		HouseData[i][Save] = false;
	}
	
	for(new i; i < sizeof(HouseInteriors); ++i)
	{
	    HouseInteriors[i][intLabel] = CreateDynamic3DTextLabel("Leave House", 0xE67E22FF, HouseInteriors[i][intX], HouseInteriors[i][intY], HouseInteriors[i][intZ]+0.35, 10.0, .testlos = 1, .interiorid = HouseInteriors[i][intID]);
		HouseInteriors[i][intPickup] = CreateDynamicPickup(1318, 1, HouseInteriors[i][intX], HouseInteriors[i][intY], HouseInteriors[i][intZ], .interiorid = HouseInteriors[i][intID]);
	}
	
	DisableInteriorEnterExits();
	SQLHandle = mysql_connect(SQL_HOST, SQL_USER, SQL_DBNAME, SQL_PASSWORD);
	mysql_tquery(SQLHandle, "SELECT * FROM houses", "LoadHouses", "");
	mysql_tquery(SQLHandle, "SELECT * FROM housefurnitures", "LoadFurnitures", "");
	
	HouseTimer = SetTimer("ResetAndSaveHouses", 10 * 60000, true);
	return 1;
}

public OnFilterScriptExit()
{
	foreach(new i : Houses)
	{
	    if(HouseData[i][Save]) SaveHouse(i);
	}
	
	KillTimer(HouseTimer);
	return 1;
}

public OnPlayerConnect(playerid)
{
    InHouse[playerid] = INVALID_HOUSE_ID;
    SelectMode[playerid] = SELECT_MODE_EDIT;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	InHouse[playerid] = INVALID_HOUSE_ID;
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(GetPVarInt(playerid, "HousePickupCooldown") < tickcount())
	{
	    if(InHouse[playerid] == INVALID_HOUSE_ID) {
			foreach(new i : Houses)
			{
			    if(pickupid == HouseData[i][HousePickup])
			    {
			        SetPVarInt(playerid, "HousePickupCooldown", tickcount()+8000);
			        SetPVarInt(playerid, "PickupHouseID", i);
					if(!strcmp(HouseData[i][Owner], "-")) {
						new string[64];
						format(string, sizeof(string), "This house is for sale!\n\nPrice: {2ECC71}$%s", convertNumber(HouseData[i][Price]));
						ShowPlayerDialog(playerid, DIALOG_HOUSE, DIALOG_STYLE_MSGBOX, "House For Sale", string, "Buy", "Close");
					}else{
					    switch(HouseData[i][LockMode])
					    {
					        case LOCK_MODE_NOLOCK: SendToHouse(playerid, i);
					        case LOCK_MODE_PASSWORD: ShowPlayerDialog(playerid, DIALOG_HOUSE+1, DIALOG_STYLE_INPUT, "House Password", "This house is password protected.\n\nEnter house password:", "Done", "Close");

					        case LOCK_MODE_OWNER:
					        {
								new name[MAX_PLAYER_NAME];
								GetPlayerName(playerid, name, MAX_PLAYER_NAME);
								if(!strcmp(HouseData[i][Owner], name)) {
								    SetPVarInt(playerid, "HousePickupCooldown", tickcount()+8000);
						            SendToHouse(playerid, i);
								}else{
								    SendClientMessage(playerid, 0xE74C3CFF, "Sorry, only the owner can enter this house.");
								}
					        }
					    }
					}

			        return 1;
			    }
			}
		}else{
			for(new i; i < sizeof(HouseInteriors); ++i)
			{
			    if(pickupid == HouseInteriors[i][intPickup])
			    {
			        SetPVarInt(playerid, "HousePickupCooldown", tickcount()+8000);
			        SetPlayerVirtualWorld(playerid, 0);
			        SetPlayerInterior(playerid, 0);
			        SetPlayerPos(playerid, HouseData[ InHouse[playerid] ][houseX], HouseData[ InHouse[playerid] ][houseY], HouseData[ InHouse[playerid] ][houseZ]);
			        InHouse[playerid] = INVALID_HOUSE_ID;
			        return 1;
			    }
			}
		}
	}
	
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_HOUSE)
	{
		if(!response) return 1;
		new id = GetPVarInt(playerid, "PickupHouseID");
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ])) return SendClientMessage(playerid, 0xE74C3CFF, "You're not near any house.");
		if(HouseData[id][Price] > GetPlayerMoney(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't afford this house.");
		GivePlayerMoney(playerid, -HouseData[id][Price]);
		GetPlayerName(playerid, HouseData[id][Owner], MAX_PLAYER_NAME);
		HouseData[id][Save] = true;
		
		new label[200];
		format(label, sizeof(label), "{E67E22}%s's House (ID: %d)\n{FFFFFF}%s\n{FFFFFF}%s\n%s", HouseData[id][Owner], id, HouseData[id][Name], HouseInteriors[ HouseData[id][Interior] ][IntName], LockNames[ HouseData[id][LockMode] ]);
		UpdateDynamic3DTextLabelText(HouseData[id][HouseLabel], 0xFFFFFFFF, label);
		Streamer_SetIntData(STREAMER_TYPE_PICKUP, HouseData[id][HousePickup], E_STREAMER_MODEL_ID, 19522);
		Streamer_SetIntData(STREAMER_TYPE_MAP_ICON, HouseData[id][HouseIcon], E_STREAMER_TYPE, 32);
		SendToHouse(playerid, id);
		return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+1)
	{
	    if(!response) return 1;
	    new id = GetPVarInt(playerid, "PickupHouseID");
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ])) return SendClientMessage(playerid, 0xE74C3CFF, "You're not near any house.");
		if(!(1 <= strlen(inputtext) <= MAX_HOUSE_PASSWORD)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+1, DIALOG_STYLE_INPUT, "House Password", "This house is password protected.\n\nEnter house password:\n\n{E74C3C}The password you entered is either too short or too long.", "Try Again", "Close");
		if(strcmp(HouseData[id][Password], inputtext)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+1, DIALOG_STYLE_INPUT, "House Password", "This house is password protected.\n\nEnter house password:\n\n{E74C3C}Wrong password.", "Try Again", "Close");
		SendToHouse(playerid, id);
		return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+2)
	{
	    if(!response) return 1;
	    new id = InHouse[playerid], name[24];
	    if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");

		if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_HOUSE+3, DIALOG_STYLE_INPUT, "House Name", "Write a new name for this house:", "Change", "Back");
		if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_HOUSE+4, DIALOG_STYLE_INPUT, "House Password", "Write a new password for this house:", "Change", "Back");
		if(listitem == 2) ShowPlayerDialog(playerid, DIALOG_HOUSE+5, DIALOG_STYLE_LIST, "House Lock", "Not Locked\nPassword Lock\nOwner Only", "Change", "Back");
		if(listitem == 3)
		{
		    new string[128];
		    format(string, sizeof(string), "Take Money From Safe {2ECC71}($%s)\nPut Money To Safe {2ECC71}($%s)", convertNumber(HouseData[id][SafeMoney]), convertNumber(GetPlayerMoney(playerid)));
			ShowPlayerDialog(playerid, DIALOG_HOUSE+6, DIALOG_STYLE_LIST, "House Safe", string, "Choose", "Back");
		}
		
		if(listitem == 4) ShowPlayerDialog(playerid, DIALOG_HOUSE+11, DIALOG_STYLE_LIST, "Furnitures", "Buy Furniture\nEdit Furniture\nSell Furniture\nSell All Furnitures", "Choose", "Back");
        if(listitem == 5) ShowPlayerDialog(playerid, DIALOG_HOUSE+9, DIALOG_STYLE_LIST, "Guns", "Put Gun\nTake Gun", "Choose", "Back");
		if(listitem == 6)
		{
		    new money = floatround(HouseData[id][Price] * 0.85) + HouseData[id][SafeMoney];
		    GivePlayerMoney(playerid, money);
			ResetHouse(id);
		}
		
		return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+3)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		if(!(1 <= strlen(inputtext) <= MAX_HOUSE_NAME)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+3, DIALOG_STYLE_INPUT, "House Name", "Write a new name for this house:\n\n{E74C3C}The name you entered is either too short or too long.", "Change", "Back");
        format(HouseData[id][Name], MAX_HOUSE_NAME, "%s", inputtext);
        HouseData[id][Save] = true;
        
        new label[200];
		format(label, sizeof(label), "{E67E22}%s's House (ID: %d)\n{FFFFFF}%s\n{FFFFFF}%s\n%s", HouseData[id][Owner], id, HouseData[id][Name], HouseInteriors[ HouseData[id][Interior] ][IntName], LockNames[ HouseData[id][LockMode] ]);
		UpdateDynamic3DTextLabelText(HouseData[id][HouseLabel], 0xFFFFFFFF, label);
        ShowHouseMenu(playerid);
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+4)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		if(!(1 <= strlen(inputtext) <= MAX_HOUSE_PASSWORD)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+3, DIALOG_STYLE_INPUT, "House Name", "Write a new name for this house:\n\n{E74C3C}The name you entered is either too short or too long.", "Change", "Back");
        format(HouseData[id][Password], MAX_HOUSE_PASSWORD, "%s", inputtext);
        HouseData[id][Save] = true;
        ShowHouseMenu(playerid);
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+5)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		HouseData[id][LockMode] = listitem;
		HouseData[id][Save] = true;

		new label[200];
		format(label, sizeof(label), "{E67E22}%s's House (ID: %d)\n{FFFFFF}%s\n{FFFFFF}%s\n%s", HouseData[id][Owner], id, HouseData[id][Name], HouseInteriors[ HouseData[id][Interior] ][IntName], LockNames[ HouseData[id][LockMode] ]);
		UpdateDynamic3DTextLabelText(HouseData[id][HouseLabel], 0xFFFFFFFF, label);
        ShowHouseMenu(playerid);
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+6)
	{
	    if(!response) return ShowHouseMenu(playerid);
		if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_HOUSE+7, DIALOG_STYLE_INPUT, "Safe: Take Money", "Write the amount you want to take from safe:", "Take", "Back");
		if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_HOUSE+8, DIALOG_STYLE_INPUT, "Safe: Put Money", "Write the amount you want to put to safe:", "Put", "Back");
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+7)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
        new amount = strval(inputtext);
		if(!(1 <= amount <= 10000000)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+7, DIALOG_STYLE_INPUT, "Safe: Take Money", "Write the amount you want to take from safe:\n\n{E74C3C}Invalid amount. You can take between $1 - $10,000,000 at a time.", "Take", "Back");
		if(amount > HouseData[id][SafeMoney]) return ShowPlayerDialog(playerid, DIALOG_HOUSE+7, DIALOG_STYLE_INPUT, "Safe: Take Money", "Write the amount you want to take from safe:\n\n{E74C3C}You don't have that much money in your safe.", "Take", "Back");
		GivePlayerMoney(playerid, amount);
		HouseData[id][SafeMoney] -= amount;
		HouseData[id][Save] = true;
		ShowHouseMenu(playerid);
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+8)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
        new amount = strval(inputtext);
		if(!(1 <= amount <= 10000000)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+8, DIALOG_STYLE_INPUT, "Safe: Put Money", "Write the amount you want to put to safe:\n\n{E74C3C}Invalid amount. You can put between $1 - $10,000,000 at a time.", "Put", "Back");
		if(amount > GetPlayerMoney(playerid)) return ShowPlayerDialog(playerid, DIALOG_HOUSE+8, DIALOG_STYLE_INPUT, "Safe: Put Money", "Write the amount you want to put to safe:\n\n{E74C3C}You don't have that much money on you.", "Put", "Back");
		GivePlayerMoney(playerid, -amount);
		HouseData[id][SafeMoney] += amount;
		HouseData[id][Save] = true;
		ShowHouseMenu(playerid);
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+9)
	{
		if(!response) return ShowHouseMenu(playerid);
		new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		if(listitem == 0)
		{
			if(GetPlayerWeapon(playerid) == 0) return SendClientMessage(playerid, 0xE74C3CFF, "You can't put your fists in your house.");
			new query[128], weapon = GetPlayerWeapon(playerid), ammo = GetPlayerAmmo(playerid);
            RemovePlayerWeapon(playerid, weapon);
			mysql_format(SQLHandle, query, sizeof(query), "INSERT INTO houseguns VALUES (%d, %d, %d) ON DUPLICATE KEY UPDATE Ammo=Ammo+%d", id, weapon, ammo, ammo);
			mysql_tquery(SQLHandle, query, "", "");
			ShowHouseMenu(playerid);
		}
		
		if(listitem == 1)
		{
		    new query[80], Cache: weapons;
		    mysql_format(SQLHandle, query, sizeof(query), "SELECT WeaponID, Ammo FROM houseguns WHERE HouseID=%d ORDER BY WeaponID ASC", id);
			weapons = mysql_query(SQLHandle, query);
			new rows = cache_num_rows();
			if(rows) {
			    new list[512], weapname[32];
			    for(new i; i < rows; ++i)
			    {
			        GetWeaponName(cache_get_field_content_int(i, "WeaponID"), weapname, sizeof(weapname));
			        format(list, sizeof(list), "%s%d. %s - %d Ammo\n", list, i+1, weapname, cache_get_field_content_int(i, "Ammo"));
			    }
			    
			    ShowPlayerDialog(playerid, DIALOG_HOUSE+10, DIALOG_STYLE_LIST, "House Guns", list, "Take", "Back");
			}else{
				SendClientMessage(playerid, 0xE74C3CFF, "You don't have any guns in your house.");
			}
			
		    cache_delete(weapons);
		}
		
		return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+10)
	{
		if(!response) return ShowHouseMenu(playerid);
		new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
  		new query[96], Cache: weapon;
    	mysql_format(SQLHandle, query, sizeof(query), "SELECT WeaponID, Ammo FROM houseguns WHERE HouseID=%d ORDER BY WeaponID ASC LIMIT %d, 1", id, listitem);
		weapon = mysql_query(SQLHandle, query);
		new rows = cache_num_rows();
		if(rows) {
  			new string[64], weapname[32], weaponid = cache_get_field_content_int(0, "WeaponID");
  			GetWeaponName(weaponid, weapname, sizeof(weapname));
  			GivePlayerWeapon(playerid, weaponid, cache_get_field_content_int(0, "Ammo"));
			format(string, sizeof(string), "You've taken a %s from your house.", weapname);
			SendClientMessage(playerid, 0xFFFFFFFF, string);
			mysql_format(SQLHandle, query, sizeof(query), "DELETE FROM houseguns WHERE HouseID=%d AND WeaponID=%d", id, weaponid);
			mysql_tquery(SQLHandle, query, "", "");
		}else{
			SendClientMessage(playerid, 0xE74C3CFF, "Can't find that weapon.");
		}

		cache_delete(weapon);
		return 1;
	}
	
    if(dialogid == DIALOG_HOUSE+11)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		
		if(listitem == 0)
		{
		    new list[512];
		    for(new i; i < sizeof(HouseFurnitures); ++i)
		    {
		        format(list, sizeof(list), "%s%d. %s - $%s\n", list, i+1, HouseFurnitures[i][Name], convertNumber(HouseFurnitures[i][Price]));
		    }

		    ShowPlayerDialog(playerid, DIALOG_HOUSE+12, DIALOG_STYLE_LIST, "Buy Furniture", list, "Buy", "Back");
		}
		
		if(listitem == 1)
		{
			SelectMode[playerid] = SELECT_MODE_EDIT;
		    SelectObject(playerid);
		    SendClientMessage(playerid, 0xFFFFFFFF, "Click on the furniture you want to edit.");
		}
		
		if(listitem == 2)
		{
		    SelectMode[playerid] = SELECT_MODE_SELL;
		    SelectObject(playerid);
		    SendClientMessage(playerid, 0xFFFFFFFF, "Click on the furniture you want to sell.");
		}
		
		if(listitem == 3)
		{
		    new money, sold, data[e_furniture], query[64];
		    for(new i; i < Streamer_GetUpperBound(STREAMER_TYPE_OBJECT); ++i)
		    {
		        if(!IsValidDynamicObject(i)) continue;
				Streamer_GetArrayData(STREAMER_TYPE_OBJECT, i, E_STREAMER_EXTRA_ID, data);
				if(data[SQLID] > 0 && data[HouseID] == id)
				{
				    sold++;
				    money += HouseFurnitures[ data[ArrayID] ][Price];
					DestroyDynamicObject(i);
				}
		    }
		    
		    new string[64];
		    format(string, sizeof(string), "Sold %d furnitures for $%s.", sold, convertNumber(money));
		    SendClientMessage(playerid, -1, string);
		    GivePlayerMoney(playerid, money);
		    
		    mysql_format(SQLHandle, query, sizeof(query), "DELETE FROM housefurnitures WHERE HouseID=%d", id);
		    mysql_tquery(SQLHandle, query, "", "");
		}
		
	    return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+12)
	{
	    if(!response) return ShowHouseMenu(playerid);
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		if(HouseFurnitures[listitem][Price] > GetPlayerMoney(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't afford this furniture.");
		GivePlayerMoney(playerid, -HouseFurnitures[listitem][Price]);
		new Float: x, Float: y, Float: z;
		GetPlayerPos(playerid, x, y, z);
        GetXYInFrontOfPlayer(playerid, x, y, 3.0);
        new objectid = CreateDynamicObject(HouseFurnitures[listitem][ModelID], x, y, z, 0.0, 0.0, 0.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid)), query[256];
		mysql_format(SQLHandle, query, sizeof(query), "INSERT INTO housefurnitures SET HouseID=%d, FurnitureID=%d, FurnitureX=%f, FurnitureY=%f, FurnitureZ=%f, FurnitureVW=%d, FurnitureInt=%d", id, listitem, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
        new Cache: add = mysql_query(SQLHandle, query), data[e_furniture];
        data[SQLID] = cache_insert_id();
		data[HouseID] = id;
        data[ArrayID] = listitem;
		data[furnitureX] = x;
		data[furnitureY] = y;
		data[furnitureZ] = z;
		data[furnitureRX] = 0.0;
		data[furnitureRY] = 0.0;
		data[furnitureRZ] = 0.0;
		cache_delete(add);
		Streamer_SetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, data);
		EditDynamicObject(playerid, objectid);
		return 1;
	}
	
	if(dialogid == DIALOG_HOUSE+13)
	{
	    if(!response) return 1;
        new id = InHouse[playerid], name[24];
        if(id == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if(strcmp(HouseData[id][Owner], name)) return SendClientMessage(playerid, 0xE74C3CFF, "You're not the owner of this house.");
		new objectid = GetPVarInt(playerid, "SelectedFurniture"), query[64], data[e_furniture];
		Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, data);
		GivePlayerMoney(playerid, HouseFurnitures[ data[ArrayID] ][Price]);
		mysql_format(SQLHandle, query, sizeof(query), "DELETE FROM housefurnitures WHERE ID=%d", data[SQLID]);
		mysql_tquery(SQLHandle, query, "", "");
		DestroyDynamicObject(objectid);
		DeletePVar(playerid, "SelectedFurniture");
		return 1;
	}
	
	return 0;
}

public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float: x, Float: y, Float: z)
{
	switch(SelectMode[playerid])
	{
	    case SELECT_MODE_EDIT: EditDynamicObject(playerid, objectid);
	    case SELECT_MODE_SELL:
	    {
	        CancelEdit(playerid);
			new data[e_furniture], string[128];
			SetPVarInt(playerid, "SelectedFurniture", objectid);
			Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, data);
			format(string, sizeof(string), "Do you want to sell your %s?\nYou'll get {2ECC71}$%s.", HouseFurnitures[ data[ArrayID] ][Name], convertNumber(HouseFurnitures[ data[ArrayID] ][Price]));
			ShowPlayerDialog(playerid, DIALOG_HOUSE+13, DIALOG_STYLE_MSGBOX, "Confirm Sale", string, "Sell", "Close");
		}
	}
	
	return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float: x, Float: y, Float: z, Float: rx, Float: ry, Float: rz)
{
	switch(response)
	{
	    case EDIT_RESPONSE_CANCEL:
	    {
	        new data[e_furniture];
	        Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, data);
	        SetDynamicObjectPos(objectid, data[furnitureX], data[furnitureY], data[furnitureZ]);
	        SetDynamicObjectRot(objectid, data[furnitureRX], data[furnitureRY], data[furnitureRZ]);
	    }
	    
		case EDIT_RESPONSE_FINAL:
		{
		    new data[e_furniture], query[256];
		    Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, data);
		    data[furnitureX] = x;
		    data[furnitureY] = y;
		    data[furnitureZ] = z;
            data[furnitureRX] = rx;
            data[furnitureRY] = ry;
            data[furnitureRZ] = rz;
            SetDynamicObjectPos(objectid, data[furnitureX], data[furnitureY], data[furnitureZ]);
	        SetDynamicObjectRot(objectid, data[furnitureRX], data[furnitureRY], data[furnitureRZ]);
	        Streamer_SetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, data);
	        
	        mysql_format(SQLHandle, query, sizeof(query), "UPDATE housefurnitures SET FurnitureX=%f, FurnitureY=%f, FurnitureZ=%f, FurnitureRX=%f, FurnitureRY=%f, FurnitureRZ=%f WHERE ID=%d", data[furnitureX], data[furnitureY], data[furnitureZ], data[furnitureRX], data[furnitureRY], data[furnitureRZ], data[SQLID]);
	        mysql_tquery(SQLHandle, query, "", "");
		}
	}
	
	return 1;
}

CMD:house(playerid, params[])
{
	if(InHouse[playerid] == INVALID_HOUSE_ID) return SendClientMessage(playerid, 0xE74C3CFF, "You're not in a house.");
	ShowHouseMenu(playerid);
	return 1;
}

CMD:createhouse(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't use this command.");
	new interior, price;
	if(sscanf(params, "ii", price, interior)) return SendClientMessage(playerid, 0xE74C3CFF, "USAGE: /createhouse [price] [interior id]");
    if(!(0 <= interior <= sizeof(HouseInteriors)-1)) return SendClientMessage(playerid, 0xE74C3CFF, "Interior ID you entered does not exist.");
	new id = Iter_Free(Houses);
	if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "You can't create more houses.");
	SetPVarInt(playerid, "HousePickupCooldown", tickcount()+8000);
	format(HouseData[id][Name], MAX_HOUSE_NAME, "House For Sale");
	format(HouseData[id][Owner], MAX_PLAYER_NAME, "-");
	format(HouseData[id][Password], MAX_HOUSE_PASSWORD, "-");
	GetPlayerPos(playerid, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ]);
	HouseData[id][Price] = price;
	HouseData[id][Interior] = interior;
	HouseData[id][LockMode] = LOCK_MODE_NOLOCK;
	HouseData[id][SafeMoney] = 0;
	HouseData[id][LastEntered] = 0;
    HouseData[id][Save] = true;

    new label[200];
    format(label, sizeof(label), "{2ECC71}House For Sale (ID: %d)\n{FFFFFF}%s\n{F1C40F}Price: {2ECC71}$%s", id, HouseInteriors[interior][IntName], convertNumber(price));
	HouseData[id][HouseLabel] = CreateDynamic3DTextLabel(label, 0xFFFFFFFF, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ]+0.35, 15.0, .testlos = 1);
	HouseData[id][HousePickup] = CreateDynamicPickup(1273, 1, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ]);
	HouseData[id][HouseIcon] = CreateDynamicMapIcon(HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ], 31, 0);

	new query[256];
	mysql_format(SQLHandle, query, sizeof(query), "INSERT INTO houses SET ID=%d, HouseX=%f, HouseY=%f, HouseZ=%f, HousePrice=%d, HouseInterior=%d", id, HouseData[id][houseX], HouseData[id][houseY], HouseData[id][houseZ], price, interior);
	mysql_tquery(SQLHandle, query, "", "");
	Iter_Add(Houses, id);
	return 1;
}

CMD:hsetinterior(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't use this command.");
	new id, interior;
	if(sscanf(params, "ii", id, interior)) return SendClientMessage(playerid, 0xE74C3CFF, "USAGE: /hsetinterior [house id] [interior id]");
	if(!Iter_Contains(Houses, id)) return SendClientMessage(playerid, 0xE74C3CFF, "House ID you entered does not exist.");
	if(!(0 <= interior <= sizeof(HouseInteriors)-1)) return SendClientMessage(playerid, 0xE74C3CFF, "Interior ID you entered does not exist.");
	HouseData[id][Interior] = interior;
	
	new query[64], label[200];
	mysql_format(SQLHandle, query, sizeof(query), "UPDATE houses SET HouseInterior=%d WHERE ID=%d", interior, id);
	mysql_tquery(SQLHandle, query, "", "");
	
	if(!strcmp(HouseData[id][Owner], "-")) {
		format(label, sizeof(label), "{2ECC71}House For Sale (ID: %d)\n{FFFFFF}%s\n{F1C40F}Price: {2ECC71}$%s", id, HouseInteriors[interior][IntName], convertNumber(HouseData[id][Price]));
	}else{
		format(label, sizeof(label), "{E67E22}%s's House (ID: %d)\n{FFFFFF}%s\n{FFFFFF}%s\n%s", HouseData[id][Owner], id, HouseData[id][Name], HouseInteriors[interior][IntName], LockNames[ HouseData[id][LockMode] ]);
	}
	
	UpdateDynamic3DTextLabelText(HouseData[id][HouseLabel], 0xFFFFFFFF, label);
	SendClientMessage(playerid, -1, "Interior updated.");
	return 1;
}

CMD:hsetprice(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't use this command.");
	new id, price;
	if(sscanf(params, "ii", id, price)) return SendClientMessage(playerid, 0xE74C3CFF, "USAGE: /hsetprice [house id] [price]");
	if(!Iter_Contains(Houses, id)) return SendClientMessage(playerid, 0xE74C3CFF, "House ID you entered does not exist.");
	HouseData[id][Price] = price;

	new query[64], label[200];
	mysql_format(SQLHandle, query, sizeof(query), "UPDATE houses SET HousePrice=%d WHERE ID=%d", price, id);
	mysql_tquery(SQLHandle, query, "", "");

	if(!strcmp(HouseData[id][Owner], "-")) {
		format(label, sizeof(label), "{2ECC71}House For Sale (ID: %d)\n{FFFFFF}%s\n{F1C40F}Price: {2ECC71}$%s", id, HouseInteriors[ HouseData[id][Interior] ][IntName], convertNumber(price));
	}else{
		format(label, sizeof(label), "{E67E22}%s's House (ID: %d)\n{FFFFFF}%s\n{FFFFFF}%s\n%s", HouseData[id][Owner], id, HouseData[id][Name], HouseInteriors[ HouseData[id][Interior] ][IntName], LockNames[ HouseData[id][LockMode] ]);
	}

	UpdateDynamic3DTextLabelText(HouseData[id][HouseLabel], 0xFFFFFFFF, label);
	SendClientMessage(playerid, -1, "Price updated.");
	return 1;
}

CMD:resethouse(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't use this command.");
	new id;
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE74C3CFF, "USAGE: /resethouse [house id]");
	if(!Iter_Contains(Houses, id)) return SendClientMessage(playerid, 0xE74C3CFF, "House ID you entered does not exist.");
	ResetHouse(id);
	SendClientMessage(playerid, -1, "House reset.");
	return 1;
}

CMD:deletehouse(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "You can't use this command.");
	new id;
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, 0xE74C3CFF, "USAGE: /deletehouse [house id]");
	if(!Iter_Contains(Houses, id)) return SendClientMessage(playerid, 0xE74C3CFF, "House ID you entered does not exist.");
	ResetHouse(id);
	DestroyDynamic3DTextLabel(HouseData[id][HouseLabel]);
	DestroyDynamicPickup(HouseData[id][HousePickup]);
	DestroyDynamicMapIcon(HouseData[id][HouseIcon]);
	Iter_Remove(Houses, id);
	HouseData[id][HouseLabel] = Text3D: INVALID_3DTEXT_ID;
	HouseData[id][HousePickup] = -1;
	HouseData[id][HouseIcon] = -1;
	HouseData[id][Save] = false;
	
	new query[64];
	mysql_format(SQLHandle, query, sizeof(query), "DELETE FROM houses WHERE ID=%d", id);
	mysql_tquery(SQLHandle, query, "", "");
	SendClientMessage(playerid, -1, "House deleted.");
	return 1;
}
