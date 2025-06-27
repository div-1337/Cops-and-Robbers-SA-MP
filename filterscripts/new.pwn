#define     FILTERSCRIPT
#include    <a_samp>
#include    <streamer>      // by Incognito - http://forum.sa-mp.com/showthread.php?t=102865
#include    <sqlitei>       // by Slice - http://forum.sa-mp.com/showthread.php?t=303682
#include    <izcmd>         // by Yashas - http://forum.sa-mp.com/showthread.php?t=576114

#define     MAX_ROBBERIES       (40)
#define     ATTACH_INDEX        (4)     // required for SetPlayerAttachedObject
#define     PLACE_COOLDOWN      (3)     // a robbery place can't be robbed again for x minutes (Default: 3)

enum    _:E_ROBBERY_DIALOG
{
    DIALOG_ROBBERY = 10350,
    // admin
    DIALOG_ADD_ROBBERY_1,
    DIALOG_ADD_ROBBERY_2,
    DIALOG_ADD_ROBBERY_3,
    DIALOG_ADD_ROBBERY_FINAL,
    DIALOG_REMOVE_ROBBERY
}

enum    E_ROBBERY
{
    // robbery name
    Name[32],
    // pos data
    Float: PosX,
    Float: PosY,
    Float: PosZ,
    IntID,
    VWID,
    // robbery data
    Amount,
    ReqTime,
    SafeTime,
    // record
    RecordAmount,
    RecordBy[MAX_PLAYER_NAME],
    // temp
    OccupiedBy,
    Cooldown,
    Timer,
    Checkpoint,
    Text3D: Label,
    bool: Exists
}

enum    _:E_ROBBERY_STAGE
{
    STAGE_CRACKING,
    STAGE_OPENING,
    STAGE_ROBBING
}

enum    E_PLAYER_ROBBERY
{
    SafeObject[2],
    MoneyStolen,
    RobID,
    RobTime,
    RobStage,
    RobberyTimer
}

new
    RobberyData[MAX_ROBBERIES][E_ROBBERY];

new
    PlayerRobberyData[MAX_PLAYERS][E_PLAYER_ROBBERY],
    PlayerText: RobberyText[MAX_PLAYERS] = {PlayerText: -1, ...};

new
//    DB: RobberyDatabase,
  //  DBStatement: LoadRobberies,
    //DBStatement: AddRobbery,
    DBStatement: UpdateRecord;
    //DBStatement: RemoveRobbery;

formatInt(intVariable, iThousandSeparator = ',', iCurrencyChar = '$')
{
    /*
        By Kar
        https://gist.github.com/Kar2k/bfb0eafb2caf71a1237b349684e091b9/8849dad7baa863afb1048f40badd103567c005a5#file-formatint-function
    */
    static
        s_szReturn[ 32 ],
        s_szThousandSeparator[ 2 ] = { ' ', EOS },
        s_szCurrencyChar[ 2 ] = { ' ', EOS },
        s_iVariableLen,
        s_iChar,
        s_iSepPos,
        bool:s_isNegative
    ;

    format( s_szReturn, sizeof( s_szReturn ), "%d", intVariable );

    if(s_szReturn[0] == '-')
        s_isNegative = true;
    else
        s_isNegative = false;

    s_iVariableLen = strlen( s_szReturn );

    if ( s_iVariableLen >= 4 && iThousandSeparator)
    {
        s_szThousandSeparator[ 0 ] = iThousandSeparator;

        s_iChar = s_iVariableLen;
        s_iSepPos = 0;

        while ( --s_iChar > _:s_isNegative )
        {
            if ( ++s_iSepPos == 3 )
            {
                strins( s_szReturn, s_szThousandSeparator, s_iChar );

                s_iSepPos = 0;
            }
        }
    }
    if(iCurrencyChar) {
        s_szCurrencyChar[ 0 ] = iCurrencyChar;
        strins( s_szReturn, s_szCurrencyChar, _:s_isNegative );
    }
    return s_szReturn;
}

RandomEx(min, max) //Y_Less
    return random(max - min) + min;

ConvertToMinutes(time)
{
    // http://forum.sa-mp.com/showpost.php?p=3223897&postcount=11
    new string[15];//-2000000000:00 could happen, so make the string 15 chars to avoid any errors
    format(string, sizeof(string), "%02d:%02d", time / 60, time % 60);
    return string;
}

Robbery_FindFreeID()
{
    for(new i; i < MAX_ROBBERIES; i++) if(!RobberyData[i][Exists]) return i;
    return -1;
}

Robbery_Cooldown(id)
{
    RobberyData[id][Cooldown] = PLACE_COOLDOWN * 60;
    RobberyData[id][Timer] = SetTimerEx("ResetPlace", 1000, true, "i", id);

    new string[160];
    format(string, sizeof(string), "Robbery(%d)\n\n{FFFFFF}%s\n{2ECC71}%s - %s {FFFFFF}every {F1C40F}5 {FFFFFF}seconds.\n{E74C3C}Available in %s", id, RobberyData[id][Name], formatInt(floatround(RobberyData[id][Amount] / 4)), formatInt(RobberyData[id][Amount]), ConvertToMinutes(RobberyData[id][Cooldown]));
    UpdateDynamic3DTextLabelText(RobberyData[id][Label], 0xF1C40FFF, string);
    return 1;
}

Robbery_InitPlayer(playerid)
{
    PlayerRobberyData[playerid][SafeObject][0] = PlayerRobberyData[playerid][SafeObject][1] = PlayerRobberyData[playerid][RobID] = PlayerRobberyData[playerid][RobberyTimer] = -1;
    PlayerRobberyData[playerid][MoneyStolen] = PlayerRobberyData[playerid][RobTime] = PlayerRobberyData[playerid][RobStage] = 0;

    RobberyText[playerid] = CreatePlayerTextDraw(playerid, 40.000000, 295.000000, "_");
    PlayerTextDrawBackgroundColor(playerid, RobberyText[playerid], 255);
    PlayerTextDrawFont(playerid, RobberyText[playerid], 1);
    PlayerTextDrawLetterSize(playerid, RobberyText[playerid], 0.240000, 1.100000);
    PlayerTextDrawColor(playerid, RobberyText[playerid], -1);
    PlayerTextDrawSetOutline(playerid, RobberyText[playerid], 1);
    PlayerTextDrawSetProportional(playerid, RobberyText[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, RobberyText[playerid], 0);

    SetPVarInt(playerid, "robberyID", -1);

    // preload anims
    ApplyAnimation(playerid, "COP_AMBIENT", "null", 0.0, 0, 0, 0, 0, 0);
    ApplyAnimation(playerid, "ROB_BANK", "null", 0.0, 0, 0, 0, 0, 0);
    return 1;
}

Robbery_ResetPlayer(playerid, check = 0)
{
    new id = PlayerRobberyData[playerid][RobID];
    if(check && id != -1 && PlayerRobberyData[playerid][MoneyStolen] > 0) Robbery_Cooldown(id);
    if(id != -1 && RobberyData[id][OccupiedBy] == playerid) RobberyData[id][OccupiedBy] = -1;

    for(new i; i < 2; i++) if(IsValidDynamicObject(PlayerRobberyData[playerid][SafeObject][i])) DestroyDynamicObject(PlayerRobberyData[playerid][SafeObject][i]);
    KillTimer(PlayerRobberyData[playerid][RobberyTimer]);
    RemovePlayerAttachedObject(playerid, ATTACH_INDEX);
    if(!IsPlayerInAnyVehicle(playerid)) ClearAnimations(playerid);
    PlayerTextDrawHide(playerid, RobberyText[playerid]);
    Streamer_Update(playerid);

    PlayerRobberyData[playerid][SafeObject][0] = PlayerRobberyData[playerid][SafeObject][1] = PlayerRobberyData[playerid][RobberyTimer] = -1;
    PlayerRobberyData[playerid][MoneyStolen] = PlayerRobberyData[playerid][RobTime] = PlayerRobberyData[playerid][RobStage] = 0;

    SetPVarInt(playerid, "robberyID", -1);
    return 1;
}
#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

#endif

public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	SetGameModeText("Blank Script");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}


forward Robbery(playerid, id);
public Robbery(playerid, id)
{
    new string[128];
    if(PlayerRobberyData[playerid][RobTime] > 1) {
        PlayerRobberyData[playerid][RobTime]--;

        switch(PlayerRobberyData[playerid][RobStage])
        {
            case STAGE_CRACKING:
            {
                format(string, sizeof(string), "~b~~h~Robbery~n~~n~~w~Cracking safe...~n~Complete in ~r~%s", ConvertToMinutes(PlayerRobberyData[playerid][RobTime]));
                PlayerTextDrawSetString(playerid, RobberyText[playerid], string);
            }

            case STAGE_OPENING:
            {
                format(string, sizeof(string), "~b~~h~Robbery~n~~n~~w~Opening safe door...~n~Complete in ~r~%s", ConvertToMinutes(PlayerRobberyData[playerid][RobTime]));
                PlayerTextDrawSetString(playerid, RobberyText[playerid], string);
            }

            case STAGE_ROBBING:
            {
                if(PlayerRobberyData[playerid][RobTime] % 5 == 0)
                {
                    PlayerRobberyData[playerid][MoneyStolen] += RandomEx(floatround(RobberyData[id][Amount] / 4), RobberyData[id][Amount]);
                    PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
                }

                format(string, sizeof(string), "~b~~h~Robbery~n~~n~~w~Money Stolen: ~g~~h~~h~%s~n~Complete in ~r~%s", formatInt(PlayerRobberyData[playerid][MoneyStolen]), ConvertToMinutes(PlayerRobberyData[playerid][RobTime]));
                PlayerTextDrawSetString(playerid, RobberyText[playerid], string);
            }
        }
    }else if(PlayerRobberyData[playerid][RobTime] == 1) {
        switch(PlayerRobberyData[playerid][RobStage])
        {
            case STAGE_CRACKING:
            {
                new Float: x, Float: y, Float: z, Float: a;
                GetDynamicObjectPos(PlayerRobberyData[playerid][SafeObject][1], x, y, z);
                GetDynamicObjectRot(PlayerRobberyData[playerid][SafeObject][1], a, a, a);
                MoveDynamicObject(PlayerRobberyData[playerid][SafeObject][1], x, y, z+0.015, 0.005, 0.0, 0.0, a+230.0);

                PlayerRobberyData[playerid][RobTime] = 4;
                PlayerRobberyData[playerid][RobStage] = STAGE_OPENING;
                PlayerTextDrawSetString(playerid, RobberyText[playerid], "~b~~h~Robbery~n~~n~~w~Opening safe door...~n~Complete in ~r~00:04");
                RemovePlayerAttachedObject(playerid, ATTACH_INDEX);
                ApplyAnimation(playerid, "ROB_BANK", "CAT_Safe_Open", 4.0, 0, 0, 0, 0, 0, 1);
                PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
            }

            case STAGE_OPENING:
            {
                PlayerRobberyData[playerid][RobTime] = RobberyData[id][ReqTime];
                PlayerRobberyData[playerid][RobStage] = STAGE_ROBBING;
                SetPlayerAttachedObject(playerid, ATTACH_INDEX, 1550, 1, 0.029999, -0.265000, 0.017000, 6.199993, 88.800003, 0.0);
                format(string, sizeof(string), "~b~~h~Robbery~n~~n~~w~Money Stolen: ~g~~h~~h~$0~n~Complete in ~r~%s", ConvertToMinutes(RobberyData[id][ReqTime]));
                PlayerTextDrawSetString(playerid, RobberyText[playerid], string);
                ApplyAnimation(playerid, "ROB_BANK", "CAT_Safe_Rob", 4.0, 1, 0, 0, 0, 0, 1);
                PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
            }

            case STAGE_ROBBING:
            {
                Robbery_Cooldown(id);

                format(string, sizeof(string), "~n~~n~~n~~b~~h~~h~Robbery Complete~n~~w~Money Stolen: ~g~~h~~h~%s", formatInt(PlayerRobberyData[playerid][MoneyStolen]));
                GameTextForPlayer(playerid, string, 3000, 3);
                GivePlayerMoney(playerid, PlayerRobberyData[playerid][MoneyStolen]);
                PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);

                new name[MAX_PLAYER_NAME];
                GetPlayerName(playerid, name, MAX_PLAYER_NAME);
                format(string, sizeof(string), "[ROBBERY] {FFFFFF}%s(%d) robbed {2ECC71}%s {FFFFFF}from {F1C40F}%s.", name, playerid, formatInt(PlayerRobberyData[playerid][MoneyStolen]), RobberyData[id][Name]);
                SendClientMessageToAll(0x3498DBFF, string);

                if(PlayerRobberyData[playerid][MoneyStolen] > RobberyData[id][RecordAmount])
                {
                    RobberyData[id][RecordAmount] = PlayerRobberyData[playerid][MoneyStolen];
                    RobberyData[id][RecordBy] = name;

                    SendClientMessage(playerid, 0x3498DBFF, "[ROBBERY] {FFFFFF}You broke this robbery place's record!");

                    format(string, sizeof(string), "[ROBBERY] {FFFFFF}Because of that, you'll be rewarded with 15 percent bonus. {2ECC71}(%s)", formatInt(floatround(PlayerRobberyData[playerid][MoneyStolen] * 0.15)));
                    SendClientMessage(playerid, 0x3498DBFF, string);

                    GivePlayerMoney(playerid, floatround(PlayerRobberyData[playerid][MoneyStolen] * 0.15));

                    stmt_bind_value(UpdateRecord, 0, DB::TYPE_INTEGER, RobberyData[id][RecordAmount]);
                    stmt_bind_value(UpdateRecord, 1, DB::TYPE_STRING, RobberyData[id][RecordBy], MAX_PLAYER_NAME);
                    stmt_bind_value(UpdateRecord, 2, DB::TYPE_INTEGER, id);
                    stmt_execute(UpdateRecord);
                }

                Robbery_ResetPlayer(playerid);
            }
        }
    }

    return 1;
}
