#define FILTERSCRIPT

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <a_mysql>
#include <mSelection>

//=======CUSTOM SETTINGS=======//
#undef MAX_OBJECTS
#define MAX_OBJECTS 5
#define MINX 0.25
#define MINY 0.25
#define MINZ 0.25
#define MAXX 3.00
#define MAXY 3.00
#define MAXZ 3.00
//=============================//


//===========CHANGES===========//
#define MYSQL_USERS_TABLE "Users"
#define MYSQL_ID_FIELDNAME "ID"
#define MYSQL_NAME_FIELDNAME "Name"
#define MYSQL_ID_INDEX 0
//=============================//

new objectlist = mS_INVALID_LISTID;
enum oData { bool:used1, index1, modelid1, bone1, Float:fOffsetX1, Float:fOffsetY1, Float:fOffsetZ1, Float:fRotX1, Float:fRotY1, Float:fRotZ1, Float:fScaleX1, Float:fScaleY1, Float:fScaleZ1 }
new oInfo[MAX_PLAYERS][MAX_OBJECTS][oData];
new inindex[MAX_PLAYERS], inmodel[MAX_PLAYERS], pID[MAX_PLAYERS];

/*public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Advanced Objects System Loaded v2.3");
	print(" Editor: Shinja");
	print("--------------------------------------\n");
	mysql_tquery(1, "CREATE TABLE IF NOT EXISTS `Objects` (`ID` int(5) NOT NULL,`Index` int(2) NOT NULL,`Model` int(7) NOT NULL,`Bone` int(2) NOT NULL,`OffsetX` float NOT NULL,`OffsetY` float NOT NULL,`OffsetZ` float NOT NULL,`RotX` float NOT NULL,`RotY` float NOT NULL,`RotZ` float NOT NULL,`ScaleX` float NOT NULL,`ScaleY` float NOT NULL,`ScaleZ` float NOT NULL)");
	objectlist = LoadModelSelectionMenu("objects.txt");
	return 1;
}
*/
//public OnFilterScriptExit() { mysql_close(); return 1; }

/*public OnPlayerConnect(playerid)
{
	new name[24]; GetPlayerName(playerid, name, 24);
    for(new i, j=MAX_OBJECTS; i<j; i++) { oInfo[playerid][i][used1] = false; }
    new query[100]; mysql_format(1, query, sizeof(query), "SELECT `%e` FROM `%e` WHERE `%e` = '%e' LIMIT 1", MYSQL_ID_FIELDNAME, MYSQL_USERS_TABLE, MYSQL_NAME_FIELDNAME, name);
	mysql_tquery(1, query, "LoadPlayerID", "i", playerid);
    return 1;
}*/

forward LoadPlayerID(playerid);
public LoadPlayerID(playerid)
{
	if(cache_num_rows())
	{
		pID[playerid] = cache_get_row_int(0, MYSQL_ID_INDEX);
		new query[100];
		mysql_format(1, query, sizeof(query), "SELECT * FROM `Objects` WHERE `ID` = %d", pID[playerid]);
		mysql_tquery(1, query, "OnObjectLoad", "i", playerid);
	}
	return 1;
}

forward OnObjectLoad(playerid);
public OnObjectLoad(playerid)
{
	for(new i, j=cache_num_rows(); i<j; i++) {
		new in = cache_get_row_int(i, 1);
		oInfo[playerid][in][index1] = in;
		oInfo[playerid][in][modelid1] = cache_get_row_int(i, 2);
		oInfo[playerid][in][bone1] = cache_get_row_int(i, 3);
		oInfo[playerid][in][fOffsetX1] = cache_get_row_float(i, 4);
		oInfo[playerid][in][fOffsetY1] = cache_get_row_float(i, 5);
		oInfo[playerid][in][fOffsetZ1] = cache_get_row_float(i, 6);
		oInfo[playerid][in][fRotX1] = cache_get_row_float(i, 7);
		oInfo[playerid][in][fRotY1] = cache_get_row_float(i, 8);
		oInfo[playerid][in][fRotZ1] = cache_get_row_float(i, 9);
		oInfo[playerid][in][fScaleX1] = cache_get_row_float(i, 10);
		oInfo[playerid][in][fScaleY1] = cache_get_row_float(i, 11);
		oInfo[playerid][in][fScaleZ1] = cache_get_row_float(i, 12);
		oInfo[playerid][in][used1] = true;
	}
}

/*public OnPlayerSpawn(playerid)
{
    for(new i,j=MAX_OBJECTS; i<j; i++) { if(oInfo[playerid][i][used1] == true) SetPlayerAttachedObject(playerid, oInfo[playerid][i][index1], oInfo[playerid][i][modelid1], oInfo[playerid][i][bone1], oInfo[playerid][i][fOffsetX1], oInfo[playerid][i][fOffsetY1], oInfo[playerid][i][fOffsetZ1], oInfo[playerid][i][fRotX1], oInfo[playerid][i][fRotY1], oInfo[playerid][i][fRotZ1], oInfo[playerid][i][fScaleX1], oInfo[playerid][i][fScaleY1], oInfo[playerid][i][fScaleZ1]); }
    return 1;
}
*/
/*public  OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 70:
	    {
	        if(!response) return 0;
         	new string1[10], string2[75]; inindex[playerid] = listitem;
			if(oInfo[playerid][listitem][used1] == false) return ShowModelSelectionMenu(playerid, objectlist, "Select An Object");
			format(string1, sizeof(string1), "Slot %d", listitem+1);
			format(string2, sizeof(string2), "{33FF00}You have {33FF00}Selected slot %d\nDo you wanna remove or edit it?", listitem+1);
			ShowPlayerDialog(playerid, 71, DIALOG_STYLE_MSGBOX, string1, string2, "Edit", "Remove");
		}
		case 71:
		{
			if(response) return EditAttachedObject(playerid, inindex[playerid]);
			RemovePlayerAttachedObject(playerid, inindex[playerid]);
			oInfo[playerid][inindex[playerid]][used1] = false;
			new string[80], query[100];
			format(string, sizeof(string), "You have {FF0000}removed {FFFFFF}this object. Slot %d is now {0DFF00}free!", inindex[playerid]+1);
			SendClientMessage(playerid, -1, string);
			mysql_format(1, query, sizeof(query), "DELETE FROM `Objects` WHERE `ID` = %d AND `Index` = %d", pID[playerid], inindex[playerid]);
			mysql_tquery(1, query);
		}
		case 72:
		{
			if(response) {
			SetPlayerAttachedObject(playerid, inindex[playerid], inmodel[playerid], listitem+1);
			oInfo[playerid][inindex[playerid]][index1] = inindex[playerid];
		 	oInfo[playerid][inindex[playerid]][modelid1] = inmodel[playerid];
		 	oInfo[playerid][inindex[playerid]][bone1] = listitem+1;
		 	oInfo[playerid][inindex[playerid]][used1] = true;
			EditAttachedObject(playerid, inindex[playerid]); }
		}
	}
	return 0;
}
*/
public OnPlayerModelSelection(playerid, response, listid, modelid)
{
	if(listid == objectlist)
	{
	    if(response)
		{
	        inmodel[playerid] = modelid;
		    ShowPlayerDialog(playerid, 72, DIALOG_STYLE_LIST, "{0DFF00}Bone", "Spine\nHead\nLeft Upper Arm\nRight Upper Arm\nLeft Hand\nRight Hand\nLeft Tight\nRight Tight\nLeft Foot\nRight Foot\nRight Calf\nLeft Calf\nLeft Forearm\nRight Forearm\nLeft Shoulder\nRight Shoulder\nNeck\nJaw", "Select", "Cancel");
		}
    	return 1;
	}
	return 1;
}

/*CMD:vipobjects(playerid)
{
	

    new string[300], s[40];
	format(string, sizeof(string), "{84B4C4}Slot 1\t%s\n", oInfo[playerid][0][used1] == true ? ("{E62E2E}Used") : ("{0DFF00}Empty"));
	for(new i=1,j=MAX_OBJECTS; i<j; i++) {
		format(s, sizeof(s), "{84B4C4}Slot %d\t%s\n", i+1, oInfo[playerid][i][used1] == true ? ("{E62E2E}Used") : ("{0DFF00}Empty"));
		strcat(string, s); }
	ShowPlayerDialog(playerid, 70, DIALOG_STYLE_TABLIST, "{33FF00}Objects", string, "Select", "Cancel");
	return 1;
}*/

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    if(response) {
        fScaleX = (fScaleX < MINX) ? (MINX) : ((fScaleX > MAXX) ? (MAXX) : (fScaleX));
		fScaleY = (fScaleY < MINY) ? (MINY) : ((fScaleY > MAXY) ? (MAXY) : (fScaleY));
		fScaleZ = (fScaleZ < MINZ) ? (MINZ) : ((fScaleZ > MAXZ) ? (MAXZ) : (fScaleZ));
        oInfo[playerid][index][fOffsetX1] = fOffsetX;
        oInfo[playerid][index][fOffsetY1] = fOffsetY;
        oInfo[playerid][index][fOffsetZ1] = fOffsetZ;
        oInfo[playerid][index][fRotX1] = fRotX;
        oInfo[playerid][index][fRotY1] = fRotY;
        oInfo[playerid][index][fRotZ1] = fRotZ;
        oInfo[playerid][index][fScaleX1] = fScaleX;
        oInfo[playerid][index][fScaleY1] = fScaleY;
        oInfo[playerid][index][fScaleZ1] = fScaleZ; }
	new query[60];
    SendClientMessage(playerid, -1, "Object {0DFF00}Saved!");
    SetPlayerAttachedObject(playerid, index, modelid, boneid, oInfo[playerid][index][fOffsetX1], oInfo[playerid][index][fOffsetY1], oInfo[playerid][index][fOffsetZ1], oInfo[playerid][index][fRotX1], oInfo[playerid][index][fRotY1], oInfo[playerid][index][fRotZ1], oInfo[playerid][index][fScaleX1], oInfo[playerid][index][fScaleY1], oInfo[playerid][index][fScaleZ1]);
	mysql_format(1, query, sizeof(query), "SELECT * FROM `Objects` WHERE `Index` = %d AND `ID` = %d", index, pID[playerid]);
	mysql_tquery(1, query, "OnObjectSave", "iiii", playerid, index, modelid, boneid);
	return 1;
}

forward OnObjectSave(playerid, index, modelid, boneid);
public OnObjectSave(playerid, index, modelid, boneid)
{
    new query[150];
	if(!cache_num_rows()){
		mysql_format(1, query, sizeof(query), "INSERT INTO `Objects` (`ID`,`Index`,`Model`,`Bone`,`OffsetX`,`OffsetY`,`OffsetZ`) VALUES (%d,%d,%d,%d,%f,%f,%f)",pID[playerid], index, modelid, boneid, oInfo[playerid][index][fOffsetX1], oInfo[playerid][index][fOffsetY1], oInfo[playerid][index][fOffsetZ1]);
		mysql_tquery(1, query);
		mysql_format(1, query, sizeof(query), "UPDATE `Objects` SET `RotX` = %f, `RotY` = %f, `RotZ` = %f, `ScaleX` = %f, `ScaleY` = %f, `ScaleZ` = %f WHERE `ID` = %d AND `Index` = %d",oInfo[playerid][index][fRotX1], oInfo[playerid][index][fRotY1], oInfo[playerid][index][fRotZ1], oInfo[playerid][index][fScaleX1], oInfo[playerid][index][fScaleY1], oInfo[playerid][index][fScaleZ1], pID[playerid], oInfo[playerid][index][index1]);
		mysql_tquery(1, query);}
	mysql_format(1, query, sizeof(query), "UPDATE `Objects` SET `Model` = %d,`Bone` = %d,`OffsetX` = %f,`OffsetY` = %f,`OffsetZ` = %f WHERE `ID` = %d AND `Index` = %d",modelid, boneid, oInfo[playerid][index][fOffsetX1], oInfo[playerid][index][fOffsetY1], oInfo[playerid][index][fOffsetZ1], pID[playerid], oInfo[playerid][index][index1]);
	mysql_tquery(1, query);
	mysql_format(1, query, sizeof(query), "UPDATE `Objects` SET `RotX` = %f, `RotY` = %f, `RotZ` = %f, `ScaleX` = %f, `ScaleY` = %f, `ScaleZ` = %f WHERE `ID` = %d AND `Index` = %d",oInfo[playerid][index][fRotX1], oInfo[playerid][index][fRotY1], oInfo[playerid][index][fRotZ1], oInfo[playerid][index][fScaleX1], oInfo[playerid][index][fScaleY1], oInfo[playerid][index][fScaleZ1], pID[playerid], oInfo[playerid][index][index1]);
	mysql_tquery(1, query);
}