#define FILTERSCRIPT



#include <a_samp>
#include <YSI\y_ini>
#include <a_mysql>

#define MYSQL_HOST "localhost"
#define MYSQL_USER "root"
#define MYSQL_DB "sfcnr"
#define MYSQL_PASSWORD ""



#define PATH "/toys/%s.ini"

enum pInfo
{
	pVIP,
	pindex,
	pmodelid,
	pboneid,
	Float:pfOffsetX,
	Float:pfOffsetY,
	Float:pfOffsetZ,
	Float:pfRotX,
	Float:pfRotY,
	Float:pfRotZ,
	Float:pfScaleX,
	Float:pfScaleY,
	Float:pfScaleZ
}
new PlayerInfo[MAX_PLAYERS][pInfo];
#define COL_GREEN2         "{33CC00}" //this is color
#define COL_WHITE          "{FFFFFF}" //this too
#define DIALOG_ATTACH_INDEX             13500
#define DIALOG_ATTACH_INDEX_SELECTION   DIALOG_ATTACH_INDEX+1
#define DIALOG_ATTACH_EDITREPLACE       DIALOG_ATTACH_INDEX+2
#define DIALOG_ATTACH_MODEL_SELECTION   DIALOG_ATTACH_INDEX+3
#define DIALOG_ATTACH_BONE_SELECTION    DIALOG_ATTACH_INDEX+4

enum AttachmentEnum
{
    attachmodel,
    attachname[24]
}

new AttachmentObjects[][AttachmentEnum] = {
{18632, "FishingRod"},
{18633, "GTASAWrench1"},
{18634, "GTASACrowbar1"},
{18635, "GTASAHammer1"},
{18636, "PoliceCap1"},
{18637, "PoliceShield1"},
{18638, "HardHat1"},
{18639, "BlackHat1"},
{18640, "Hair1"},
{18975, "Hair2"},
{19136, "Hair4"},
{19274, "Hair5"},
{18641, "Flashlight1"},
{18642, "Taser1"},
{18643, "LaserPointer1"},
{19080, "LaserPointer2"},
{19081, "LaserPointer3"},
{19082, "LaserPointer4"},
{19083, "LaserPointer5"},
{19084, "LaserPointer6"},
{18644, "Screwdriver1"},
{18645, "MotorcycleHelmet1"},
{18865, "MobilePhone1"},
{18866, "MobilePhone2"},
{18867, "MobilePhone3"},
{18868, "MobilePhone4"},
{18869, "MobilePhone5"},
{18870, "MobilePhone6"},
{18871, "MobilePhone7"},
{18872, "MobilePhone8"},
{18873, "MobilePhone9"},
{18874, "MobilePhone10"},
{18875, "Pager1"},
{18890, "Rake1"},
{18891, "Bandana1"},
{18892, "Bandana2"},
{18893, "Bandana3"},
{18894, "Bandana4"},
{18895, "Bandana5"},
{18896, "Bandana6"},
{18897, "Bandana7"},
{18898, "Bandana8"},
{18899, "Bandana9"},
{18900, "Bandana10"},
{18901, "Bandana11"},
{18902, "Bandana12"},
{18903, "Bandana13"},
{18904, "Bandana14"},
{18905, "Bandana15"},
{18906, "Bandana16"},
{18907, "Bandana17"},
{18908, "Bandana18"},
{18909, "Bandana19"},
{18910, "Bandana20"},
{18911, "Mask1"},
{18912, "Mask2"},
{18913, "Mask3"},
{18914, "Mask4"},
{18915, "Mask5"},
{18916, "Mask6"},
{18917, "Mask7"},
{18918, "Mask8"},
{18919, "Mask9"},
{18920, "Mask10"},
{18921, "Beret1"},
{18922, "Beret2"},
{18923, "Beret3"},
{18924, "Beret4"},
{18925, "Beret5"},
{18926, "Hat1"},
{18927, "Hat2"},
{18928, "Hat3"},
{18929, "Hat4"},
{18930, "Hat5"},
{18931, "Hat6"},
{18932, "Hat7"},
{18933, "Hat8"},
{18934, "Hat9"},
{18935, "Hat10"},
{18936, "Helmet1"},
{18937, "Helmet2"},
{18938, "Helmet3"},
{18939, "CapBack1"},
{18940, "CapBack2"},
{18941, "CapBack3"},
{18942, "CapBack4"},
{18943, "CapBack5"},
{18944, "HatBoater1"},
{18945, "HatBoater2"},
{18946, "HatBoater3"},
{18947, "HatBowler1"},
{18948, "HatBowler2"},
{18949, "HatBowler3"},
{18950, "HatBowler4"},
{18951, "HatBowler5"},
{18952, "BoxingHelmet1"},
{18953, "CapKnit1"},
{18954, "CapKnit2"},
{18955, "CapOverEye1"},
{18956, "CapOverEye2"},
{18957, "CapOverEye3"},
{18958, "CapOverEye4"},
{18959, "CapOverEye5"},
{18960, "CapRimUp1"},
{18961, "CapTrucker1"},
{18962, "CowboyHat2"},
{18963, "CJElvisHead"},
{18964, "SkullyCap1"},
{18965, "SkullyCap2"},
{18966, "SkullyCap3"},
{18967, "HatMan1"},
{18968, "HatMan2"},
{18969, "HatMan3"},
{18970, "HatTiger1"},
{18971, "HatCool1"},
{18972, "HatCool2"},
{18973, "HatCool3"},
{18974, "MaskZorro1"},
{18976, "MotorcycleHelmet2"},
{18977, "MotorcycleHelmet3"},
{18978, "MotorcycleHelmet4"},
{18979, "MotorcycleHelmet5"},
{19006, "GlassesType1"},
{19007, "GlassesType2"},
{19008, "GlassesType3"},
{19009, "GlassesType4"},
{19010, "GlassesType5"},
{19011, "GlassesType6"},
{19012, "GlassesType7"},
{19013, "GlassesType8"},
{19014, "GlassesType9"},
{19015, "GlassesType10"},
{19016, "GlassesType11"},
{19017, "GlassesType12"},
{19018, "GlassesType13"},
{19019, "GlassesType14"},
{19020, "GlassesType15"},
{19021, "GlassesType16"},
{19022, "GlassesType17"},
{19023, "GlassesType18"},
{19024, "GlassesType19"},
{19025, "GlassesType20"},
{19026, "GlassesType21"},
{19027, "GlassesType22"},
{19028, "GlassesType23"},
{19029, "GlassesType24"},
{19030, "GlassesType25"},
{19031, "GlassesType26"},
{19032, "GlassesType27"},
{19033, "GlassesType28"},
{19034, "GlassesType29"},
{19035, "GlassesType30"},
{19036, "HockeyMask1"},
{19037, "HockeyMask2"},
{19038, "HockeyMask3"},
{19039, "WatchType1"},
{19040, "WatchType2"},
{19041, "WatchType3"},
{19042, "WatchType4"},
{19043, "WatchType5"},
{19044, "WatchType6"},
{19045, "WatchType7"},
{19046, "WatchType8"},
{19047, "WatchType9"},
{19048, "WatchType10"},
{19049, "WatchType11"},
{19050, "WatchType12"},
{19051, "WatchType13"},
{19052, "WatchType14"},
{19053, "WatchType15"},
{19085, "EyePatch1"},
{19086, "ChainsawDildo1"},
{19090, "PomPomBlue"},
{19091, "PomPomRed"},
{19092, "PomPomGreen"},
{19093, "HardHat2"},
{19094, "BurgerShotHat1"},
{19095, "CowboyHat1"},
{19096, "CowboyHat3"},
{19097, "CowboyHat4"},
{19098, "CowboyHat5"},
{19099, "PoliceCap2"},
{19100, "PoliceCap3"},
{19101, "ArmyHelmet1"},
{19102, "ArmyHelmet2"},
{19103, "ArmyHelmet3"},
{19104, "ArmyHelmet4"},
{19105, "ArmyHelmet5"},
{19106, "ArmyHelmet6"},
{19107, "ArmyHelmet7"},
{19108, "ArmyHelmet8"},
{19109, "ArmyHelmet9"},
{19110, "ArmyHelmet10"},
{19111, "ArmyHelmet11"},
{19112, "ArmyHelmet12"},
{19113, "SillyHelmet1"},
{19114, "SillyHelmet2"},
{19115, "SillyHelmet3"},
{19116, "PlainHelmet1"},
{19117, "PlainHelmet2"},
{19118, "PlainHelmet3"},
{19119, "PlainHelmet4"},
{19120, "PlainHelmet5"},
{19137, "CluckinBellHat1"},
{19138, "PoliceGlasses1"},
{19139, "PoliceGlasses2"},
{19140, "PoliceGlasses3"},
{19141, "SWATHelmet1"},
{19142, "SWATArmour1"},
{19160, "HardHat3"},
{19161, "PoliceHat1"},
{19162, "PoliceHat2"},
{19163, "GimpMask1"},
{19317, "bassguitar01"},
{19318, "flyingv01"},
{19319, "warlock01"},
{19330, "fire_hat01"},
{19331, "fire_hat02"},
{19346, "hotdog01"},
{19347, "badge01"},
{19348, "cane01"},
{19349, "monocle01"},
{19350, "moustache01"},
{19351, "moustache02"},
{19352, "tophat01"},
{19487, "tophat02"},
{19488, "HatBowler6"},
{19513, "whitephone"},
{19515, "GreySwatArm"},
{3044, "Cigar"},
{1210, "Briefcase"}
};

new AttachmentBones[][24] = {
{"Spine"},
{"Head"},
{"Left upper arm"},
{"Right upper arm"},
{"Left hand"},
{"Right hand"},
{"Left thigh"},
{"Right thigh"},
{"Left foot"},
{"Right foot"},
{"Right calf"},
{"Left calf"},
{"Left forearm"},
{"Right forearm"},
{"Left clavicle"},
{"Right clavicle"},
{"Neck"},
{"Jaw"}
};


new dbHandle;
public OnFilterScriptInit()
{

	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);



	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}


public OnPlayerDisconnect(playerid, reason)
{

return 1;
}

public OnPlayerSpawn(playerid)
{
	OnPlayerLogin(playerid);
    // Attach a white hat to the head of the player and paint it green
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{

    if(strcmp(cmdtext, "/viptoys", true) == 0)
    {
    	PlayerInfo[playerid][pVIP] = cache_get_field_content_int(0, "VIP");
        if(PlayerInfo[playerid][pVIP] <= 0)

        return SendClientMessage(playerid, -1,"{FF0000}[ERROR]{FFFFFF} You're not a V.I.P, to become one, donate at InexorableGaming.com");
        
        else if(PlayerInfo[playerid][pVIP] >= 1)
        
        
        for(new x;x<MAX_PLAYER_ATTACHED_OBJECTS;x++)
        {
        new string[128];
		if(IsPlayerAttachedObjectSlotUsed(playerid, x)) format(string, sizeof(string), "%s%d (Used)\n", string, x);
  		else format(string, sizeof(string), "%s%d\n", string, x);
  		ShowPlayerDialog(playerid, DIALOG_ATTACH_INDEX_SELECTION, DIALOG_STYLE_LIST, \
        "{FF0000}Attachment Modification - Index Selection", string, "Select", "Cancel");
        return 1;
  		
        }
        
    }


    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_ATTACH_INDEX_SELECTION:
        {
            if(response)
            {
                if(IsPlayerAttachedObjectSlotUsed(playerid, listitem))
                {
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_EDITREPLACE, DIALOG_STYLE_MSGBOX, \
                    "{FF0000}Attachment Modification", "Do you wish to edit the attachment in that slot, or delete it?", "Edit", "Delete");
                }
                else
                {
                    new string[4000+1];
                    for(new x;x<sizeof(AttachmentObjects);x++)
                    {
                        format(string, sizeof(string), "%s%s\n", string, AttachmentObjects[x][attachname]);
                    }
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_MODEL_SELECTION, DIALOG_STYLE_LIST, \
                    "{FF0000}Attachment Modification - Model Selection", string, "Select", "Cancel");
                }
                SetPVarInt(playerid, "AttachmentIndexSel", listitem);
            }
            return 1;
        }
        case DIALOG_ATTACH_EDITREPLACE:
        {
            if(response) EditAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
            else RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
            DeletePVar(playerid, "AttachmentIndexSel");
            return 1;
        }
        case DIALOG_ATTACH_MODEL_SELECTION:
        {
            if(response)
            {
                if(GetPVarInt(playerid, "AttachmentUsed") == 1) EditAttachedObject(playerid, listitem);
                else
                {
                    SetPVarInt(playerid, "AttachmentModelSel", AttachmentObjects[listitem][attachmodel]);
                    new string[256+1];
                    for(new x;x<sizeof(AttachmentBones);x++)
                    {
                        format(string, sizeof(string), "%s%s\n", string, AttachmentBones[x]);
                    }
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_BONE_SELECTION, DIALOG_STYLE_LIST, \
                    "{FF0000}Attachment Modification - Bone Selection", string, "Select", "Cancel");
                }
            }
            else DeletePVar(playerid, "AttachmentIndexSel");
            return 1;
        }
        case DIALOG_ATTACH_BONE_SELECTION:
        {
            if(response)
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"), GetPVarInt(playerid, "AttachmentModelSel"), listitem+1);
                EditAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
                SendClientMessage(playerid, 0xFFFFFFFF, "Hint: Use {FFFF00}~k~~PED_SPRINT~{FFFFFF} to look around.");
            }
            DeletePVar(playerid, "AttachmentIndexSel");
            DeletePVar(playerid, "AttachmentModelSel");
            return 1;
        }
    }
    return 0;
}



OnPlayerLogin(playerid)
{
    new
        uFile[35];
    format(uFile, 35, PATH, GetName(playerid));
    INI_ParseFile(uFile, "LoadToys", .bExtra = true, .extra = playerid);
	SetPlayerAttachedObject(playerid,
	INT:PlayerInfo[playerid][pindex],
	INT:PlayerInfo[playerid][pmodelid],
	INT:PlayerInfo[playerid][pboneid],
	Float:PlayerInfo[playerid][pfOffsetX],
	Float:PlayerInfo[playerid][pfOffsetY],
	Float:PlayerInfo[playerid][pfOffsetZ],
	Float:PlayerInfo[playerid][pfRotX],
	Float:PlayerInfo[playerid][pfRotY],
	Float:PlayerInfo[playerid][pfRotZ],
	Float:PlayerInfo[playerid][pfScaleX],
	Float:PlayerInfo[playerid][pfScaleY],
	Float:PlayerInfo[playerid][pfScaleZ]);
    return 1;
}



stock UserPath(playerid)
{
    new string[128],playername[MAX_PLAYER_NAME];
    GetPlayerName(playerid,playername,sizeof(playername));
    format(string,sizeof(string),PATH,playername);
    return string;
}

stock GetName(playerid) //function for getting player name, this is faster than GetPlayerName(I don't mean in miliseconds, just I don't need to create new variable and than use GetPlayerName, I just use this function
{ //opening barrel
    new
        pName[MAX_PLAYER_NAME]; //variable for player name, max.player name is 24

    GetPlayerName(playerid, pName, MAX_PLAYER_NAME); //getting player name
    return pName; //returning player name;
} //closing barrel

forward LoadToys(playerid,name[],value[]);
public LoadToys(playerid,name[],value[])
{

	if (!strcmp(name, "sindex")){ PlayerInfo[playerid][pindex] = strval(value); }
	if (!strcmp(name, "pmodelid")){ PlayerInfo[playerid][pmodelid] = strval(value); }
	if (!strcmp(name, "pboneid")){ PlayerInfo[playerid][pboneid] = strval(value); }
	if (!strcmp(name, "pfOffsetX")){ PlayerInfo[playerid][pfOffsetX] = strval(value); }
	if (!strcmp(name, "pfOffsetY")){ PlayerInfo[playerid][pfOffsetY] = strval(value); }
	if (!strcmp(name, "pfOffsetY")){ PlayerInfo[playerid][pfOffsetZ] = strval(value); }
	if (!strcmp(name, "pfRotX")){ PlayerInfo[playerid][pfRotX] = strval(value); }
	if (!strcmp(name, "pfRotY")){ PlayerInfo[playerid][pfRotY] = strval(value); }
	if (!strcmp(name, "pfRotZ")){ PlayerInfo[playerid][pfRotZ] = strval(value); }
	if (!strcmp(name, "pfScaleX")){ PlayerInfo[playerid][pfScaleX] = strval(value); }
	if (!strcmp(name, "pfScaleY")){ PlayerInfo[playerid][pfScaleY] = strval(value); }
	if (!strcmp(name, "pfScaleZ")){ PlayerInfo[playerid][pfScaleZ] = strval(value); }

    INI_Int("pindex",PlayerInfo[playerid][pindex]);
	INI_Int("pmodelid",PlayerInfo[playerid][pmodelid]);
	INI_Int("pboneid",PlayerInfo[playerid][pboneid]);
	INI_Float("pfOffsetX",PlayerInfo[playerid][pfOffsetX]);
	INI_Float("pfOffsetY",PlayerInfo[playerid][pfOffsetY]);
	INI_Float("pfOffsetZ",PlayerInfo[playerid][pfOffsetZ]);
	INI_Float("pfRotX",PlayerInfo[playerid][pfRotX]);
	INI_Float("pfRotY",PlayerInfo[playerid][pfRotY]);
	INI_Float("pfRotZ",PlayerInfo[playerid][pfRotZ]);
	INI_Float("pfScaleX",PlayerInfo[playerid][pfScaleX]);
	INI_Float("pfScaleY",PlayerInfo[playerid][pfScaleY]);
	INI_Float("pfScaleZ",PlayerInfo[playerid][pfScaleZ]);

    return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid,Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ,Float:fRotX, Float:fRotY, Float:fRotZ,Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{

    new INI:File = INI_Open(UserPath(playerid));
	INI_WriteInt(File,"pindex",index);
	INI_WriteInt(File,"pmodelid",modelid);
	INI_WriteInt(File,"pboneid",boneid);
	INI_WriteFloat(File,"pfOffsetX",fOffsetX);
	INI_WriteFloat(File,"pfOffsetY",fOffsetY);
	INI_WriteFloat(File,"pfOffsetZ",fOffsetZ);
	INI_WriteFloat(File,"pfRotX",fRotX);
	INI_WriteFloat(File,"pfRotY",fRotY);
	INI_WriteFloat(File,"pfRotZ",fRotZ);
	INI_WriteFloat(File,"pfScaleX",fScaleX);
	INI_WriteFloat(File,"pfScaleY",fScaleY);
	INI_WriteFloat(File,"pfScaleZ",fScaleZ);
    INI_Close(File);

	PlayerInfo[playerid][pindex] = index;
	PlayerInfo[playerid][pmodelid] = modelid;
	PlayerInfo[playerid][pboneid] = boneid;
	PlayerInfo[playerid][pfOffsetX] = fOffsetX;
	PlayerInfo[playerid][pfOffsetY] = fOffsetY;
	PlayerInfo[playerid][pfOffsetZ] = fOffsetZ;
	PlayerInfo[playerid][pfRotX] = fRotX;
	PlayerInfo[playerid][pfRotY] = fRotY;
	PlayerInfo[playerid][pfRotZ] = fRotZ;
	PlayerInfo[playerid][pfScaleX] = fScaleX;
	PlayerInfo[playerid][pfScaleY] = fScaleY;
	PlayerInfo[playerid][pfScaleZ] = fScaleZ;

    SetPlayerAttachedObject(playerid,index,modelid,boneid,fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ);
    SendClientMessage(playerid, 0xFFFFFFFF, "You finished editing an attached object");

    return 1;
}