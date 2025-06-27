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
    DB: RobberyDatabase,
    DBStatement: LoadRobberies,
    DBStatement: AddRobbery,
    DBStatement: UpdateRecord,
    DBStatement: RemoveRobbery;

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

public OnFilterScriptInit()
{
    print("  [Robberies] Initializing...");
    for(new i, mp = GetPlayerPoolSize(); i <= mp; i++) if(IsPlayerConnected(i)) Robbery_InitPlayer(i);
    for(new i; i < MAX_ROBBERIES; i++)
    {
        RobberyData[i][OccupiedBy] = RobberyData[i][Timer] = RobberyData[i][Checkpoint] = -1;
        RobberyData[i][Label] = Text3D: -1;
    }

    // Open Database
    RobberyDatabase = db_open("robbery_db.db");
    db_query(RobberyDatabase, "CREATE TABLE IF NOT EXISTS robberies (ID INTEGER, Name TEXT, PosX FLOAT, PosY FLOAT, PosZ FLOAT, Interior INTEGER, Virtual INTEGER, Amount INTEGER, RequiredTime INTEGER, SafeTime INTEGER, RecAmount INTEGER, RecBy TEXT)");

    // Prepare Statements
    LoadRobberies = db_prepare(RobberyDatabase, "SELECT * FROM robberies");
    AddRobbery = db_prepare(RobberyDatabase, "INSERT INTO robberies (ID, Name, PosX, PosY, PosZ, Interior, Virtual, Amount, RequiredTime, SafeTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    UpdateRecord = db_prepare(RobberyDatabase, "UPDATE robberies SET RecAmount=?, RecBy=? WHERE ID=?");
    RemoveRobbery = db_prepare(RobberyDatabase, "DELETE FROM robberies WHERE ID=?");

    // Load Robberies
    new id, name[32], Float: pos[3], intid, vwid, amount, reqt, safet, recamount, recby[MAX_PLAYER_NAME];
    stmt_bind_result_field(LoadRobberies, 0, DB::TYPE_INTEGER, id);
    stmt_bind_result_field(LoadRobberies, 1, DB::TYPE_STRING, name, 32);
    stmt_bind_result_field(LoadRobberies, 2, DB::TYPE_FLOAT, pos[0]);
    stmt_bind_result_field(LoadRobberies, 3, DB::TYPE_FLOAT, pos[1]);
    stmt_bind_result_field(LoadRobberies, 4, DB::TYPE_FLOAT, pos[2]);
    stmt_bind_result_field(LoadRobberies, 5, DB::TYPE_INTEGER, intid);
    stmt_bind_result_field(LoadRobberies, 6, DB::TYPE_INTEGER, vwid);
    stmt_bind_result_field(LoadRobberies, 7, DB::TYPE_INTEGER, amount);
    stmt_bind_result_field(LoadRobberies, 8, DB::TYPE_INTEGER, reqt);
    stmt_bind_result_field(LoadRobberies, 9, DB::TYPE_INTEGER, safet);
    stmt_bind_result_field(LoadRobberies, 10, DB::TYPE_INTEGER, recamount);
    stmt_bind_result_field(LoadRobberies, 11, DB::TYPE_STRING, recby, MAX_PLAYER_NAME);

    if(stmt_execute(LoadRobberies))
    {
        print("  [Robberies] Loading robbery data...");

        new label[160], loaded;
        while(stmt_fetch_row(LoadRobberies))
        {
            RobberyData[id][Name] = name;

            RobberyData[id][PosX] = pos[0];
            RobberyData[id][PosY] = pos[1];
            RobberyData[id][PosZ] = pos[2];
            RobberyData[id][IntID] = intid;
            RobberyData[id][VWID] = vwid;

            RobberyData[id][Amount] = amount;
            RobberyData[id][ReqTime] = reqt;
            RobberyData[id][SafeTime] = safet;

            RobberyData[id][RecordAmount] = 0;
            RobberyData[id][RecordBy] = recby;

            RobberyData[id][Checkpoint] = CreateDynamicCP(pos[0], pos[1], pos[2], 1.25, vwid, intid, .streamdistance = 5.0);

            format(label, sizeof(label), "Robbery(%d)\n\n{FFFFFF}%s\n{2ECC71}%s - %s {FFFFFF}every {F1C40F}5 {FFFFFF}seconds.\n{2ECC71}Available", id, name, formatInt(floatround(amount / 4)), formatInt(amount));
            RobberyData[id][Label] = CreateDynamic3DTextLabel(label, 0xF1C40FFF, pos[0], pos[1], pos[2] + 0.25, 10.0, _, _, 1, vwid, intid);

            RobberyData[id][Exists] = true;
            loaded++;
        }

        printf("  [Robberies] Loaded %d robberies.", loaded);
    }

    return 1;
}

public OnFilterScriptExit()
{
    for(new i, mp = GetPlayerPoolSize(); i <= mp; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        Robbery_ResetPlayer(i);
        PlayerTextDrawDestroy(i, RobberyText[i]);
    }

    db_close(RobberyDatabase);
    print("  [Robberies] Unloaded.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    Robbery_InitPlayer(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    Robbery_ResetPlayer(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(IsPlayerConnected(killerid) && PlayerRobberyData[playerid][MoneyStolen] > 0)
    {
        new string[144], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string, sizeof(string), "[ROBBERY] {FFFFFF}You killed the robber {F1C40F}%s(%d) {FFFFFF}and took the money they stole. {2ECC71}(%s)", name, playerid, formatInt(PlayerRobberyData[playerid][MoneyStolen]));
        SendClientMessage(killerid, 0x3498DBFF, string);

        Robbery_Cooldown(PlayerRobberyData[playerid][RobID]);
    }

    Robbery_ResetPlayer(playerid);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate != PLAYER_STATE_WASTED) Robbery_ResetPlayer(playerid);
    return 1;
}

#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PRESSED(KEY_NO) && PlayerRobberyData[playerid][RobberyTimer] != -1) Robbery_ResetPlayer(playerid, 1);
    return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(!IsPlayerInAnyVehicle(playerid))
    {
        for(new i; i < MAX_ROBBERIES; i++)
        {
            if(!RobberyData[i][Exists]) continue;
            if(checkpointid == RobberyData[i][Checkpoint])
            {
                SetPVarInt(playerid, "robberyID", i);

                if(!IsPlayerConnected(RobberyData[i][OccupiedBy]) && RobberyData[i][Timer] == -1)
                {
                    new title[64];
                    format(title, sizeof(title), "{F1C40F}Robbery: {FFFFFF}%s", RobberyData[i][Name]);
                    ShowPlayerDialog(playerid, DIALOG_ROBBERY, DIALOG_STYLE_MSGBOX, title, "Do you want to rob this place?", "Rob", "Close");
                }

                break;
            }
        }
    }

    return 1;
}

public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
    if(PlayerRobberyData[playerid][RobberyTimer] != -1)
    {
        if(PlayerRobberyData[playerid][MoneyStolen] > 0)
        {
            new id = PlayerRobberyData[playerid][RobID];
            if(id != -1) Robbery_Cooldown(id);

            new string[128];
            format(string, sizeof(string), "~n~~n~~n~~b~~h~~h~Robbery Cancelled~n~~w~Money Stolen: ~g~~h~~h~%s", formatInt(PlayerRobberyData[playerid][MoneyStolen]));
            GameTextForPlayer(playerid, string, 3000, 3);
            GivePlayerMoney(playerid, PlayerRobberyData[playerid][MoneyStolen]);
        }

        Robbery_ResetPlayer(playerid);
    }

    SetPVarInt(playerid, "robberyID", -1);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        /* ---------------------------------------------------------------------- */
        case DIALOG_ROBBERY:
        {
            if(!response) return 1;
            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You can't do this in a vehicle.");
            new id = GetPVarInt(playerid, "robberyID");
            if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You're not in a robbery checkpoint.");
            if(IsPlayerConnected(RobberyData[id][OccupiedBy])) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}This robbery place is occupied.");
            if(!IsPlayerInDynamicCP(playerid, RobberyData[id][Checkpoint])) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}You're not in the robbery checkpoint.");
            new Float: x, Float: y, Float: z, Float: a;
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);

            x += (1.25 * floatsin(-a, degrees));
            y += (1.25 * floatcos(-a, degrees));
            PlayerRobberyData[playerid][SafeObject][0] = CreateDynamicObject(19618, x, y, z-0.55, 0.0, 0.0, a, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

            a += 90.0;
            x += (0.42 * floatsin(-a, degrees)) + (-0.22 * floatsin(-(a - 90.0), degrees));
            y += (0.42 * floatcos(-a, degrees)) + (-0.22 * floatcos(-(a - 90.0), degrees));
            PlayerRobberyData[playerid][SafeObject][1] = CreateDynamicObject(19619, x, y, z-0.55, 0.0, 0.0, a + 270.0, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

            PlayerRobberyData[playerid][MoneyStolen] = 0;
            PlayerRobberyData[playerid][RobID] = id;
            PlayerRobberyData[playerid][RobTime] = RobberyData[id][SafeTime];
            PlayerRobberyData[playerid][RobStage] = STAGE_CRACKING;
            PlayerRobberyData[playerid][RobberyTimer] = SetTimerEx("Robbery", 1000, true, "ii", playerid, id);
            RobberyData[id][OccupiedBy] = playerid;

            SetPlayerAttachedObject(playerid, ATTACH_INDEX, 18634, 6, 0.054000, 0.013999, -0.087999, -94.399963, -25.899974, 175.799911);
            ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

            new string[128];
            format(string, sizeof(string), "~b~~h~Robbery~n~~n~~w~Cracking safe...~n~Complete in ~r~%s", ConvertToMinutes(RobberyData[id][SafeTime]));
            PlayerTextDrawSetString(playerid, RobberyText[playerid], string);
            PlayerTextDrawShow(playerid, RobberyText[playerid]);

            if(RobberyData[id][RecordAmount] > 0)
            {
                format(string, sizeof(string), "[ROBBERY] {F1C40F}%s {FFFFFF}holds the record for this place with {2ECC71}%s {FFFFFF}stolen.", RobberyData[id][RecordBy], formatInt(RobberyData[id][RecordAmount]));
                SendClientMessage(playerid, 0x3498DBFF, string);
            }

            SendClientMessage(playerid, 0x3498DBFF, "[ROBBERY] {FFFFFF}You can press {F1C40F}~k~~CONVERSATION_NO~ {FFFFFF}to cancel the robbery.");
            Streamer_Update(playerid);
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_ADD_ROBBERY_1:
        {
            if(!IsPlayerAdmin(playerid) || !response) return 1;
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_1, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 1)", "{E74C3C}Input can't be empty.\n\n{FFFFFF}Write a name for the robbery:", "Next", "Close");
            SetPVarString(playerid, "robberyName", inputtext);
            ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_2, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 2)", "Safe cracking duration (in seconds):", "Next", "Back");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_ADD_ROBBERY_2:
        {
            if(!IsPlayerAdmin(playerid)) return 1;
            if(!response) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_1, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 1)", "Write a name for the robbery:", "Next", "Close");
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_2, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 2)", "{E74C3C}Input can't be empty.\n\n{FFFFFF}Safe cracking duration (in seconds):", "Next", "Back");
            SetPVarInt(playerid, "robberySafeDur", strval(inputtext));
            ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_3, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 3)", "Robbery duration (in seconds - must be multiples of 5):", "Next", "Back");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_ADD_ROBBERY_3:
        {
            if(!IsPlayerAdmin(playerid)) return 1;
            if(!response) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_2, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 2)", "Safe cracking duration (in seconds):", "Next", "Back");
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_3, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 3)", "{E74C3C}Input can't be empty.\n\n{FFFFFF}Robbery duration (in seconds - must be multiples of 5):", "Next", "Back");
            new dur = strval(inputtext);
            if(dur < 1 || (dur % 5) != 0) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_3, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 3)", "{E74C3C}Invalid duration.\n\n{FFFFFF}Robbery duration (in seconds - must be multiples of 5):", "Next", "Back");
            SetPVarInt(playerid, "robberyDur", dur);
            ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_FINAL, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 4)", "Money amount:", "Finish", "Back");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_ADD_ROBBERY_FINAL:
        {
            if(!IsPlayerAdmin(playerid)) return 1;
            if(!response) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_3, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 3)", "Robbery duration (in seconds - must be multiples of 5):", "Next", "Back");
            if(isnull(inputtext)) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_FINAL, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 4)", "{E74C3C}Input can't be empty.\n\n{FFFFFF}Money amount:", "Finish", "Back");
            if(strval(inputtext) < 1) return ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_FINAL, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 4)", "{E74C3C}Invalid amount.\n\n{FFFFFF}Money amount:", "Finish", "Back");

            new id = Robbery_FindFreeID();
            if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Can't create any more robberies.");
            new Float: x, Float: y, Float: z, vwid = GetPlayerVirtualWorld(playerid), intid = GetPlayerInterior(playerid), string[160];
            GetPlayerPos(playerid, x, y, z);

            GetPVarString(playerid, "robberyName", RobberyData[id][Name], 32);
            RobberyData[id][PosX] = x;
            RobberyData[id][PosY] = y;
            RobberyData[id][PosZ] = z;
            RobberyData[id][IntID] = intid;
            RobberyData[id][VWID] = vwid;
            RobberyData[id][Amount] = strval(inputtext);
            RobberyData[id][ReqTime] = GetPVarInt(playerid, "robberyDur");
            RobberyData[id][SafeTime] = GetPVarInt(playerid, "robberySafeDur");
            RobberyData[id][RecordAmount] = 0;
            RobberyData[id][RecordBy][0] = EOS;

            RobberyData[id][OccupiedBy] = -1;
            RobberyData[id][Cooldown] = 0;
            RobberyData[id][Timer] = -1;

            RobberyData[id][Checkpoint] = CreateDynamicCP(x, y, z, 1.25, vwid, intid, .streamdistance = 5.0);

            format(string, sizeof(string), "Robbery(%d)\n\n{FFFFFF}%s\n{2ECC71}%s - %s {FFFFFF}every {F1C40F}5 {FFFFFF}seconds.\n{2ECC71}Available", id, RobberyData[id][Name], formatInt(floatround(RobberyData[id][Amount] / 4)), formatInt(RobberyData[id][Amount]));
            RobberyData[id][Label] = CreateDynamic3DTextLabel(string, 0xF1C40FFF, x, y, z + 0.25, 10.0, _, _, 1, vwid, intid);

            RobberyData[id][Exists] = true;

            stmt_bind_value(AddRobbery, 0, DB::TYPE_INTEGER, id);
            stmt_bind_value(AddRobbery, 1, DB::TYPE_STRING, RobberyData[id][Name], 32);
            stmt_bind_value(AddRobbery, 2, DB::TYPE_FLOAT, x);
            stmt_bind_value(AddRobbery, 3, DB::TYPE_FLOAT, y);
            stmt_bind_value(AddRobbery, 4, DB::TYPE_FLOAT, z);
            stmt_bind_value(AddRobbery, 5, DB::TYPE_INTEGER, intid);
            stmt_bind_value(AddRobbery, 6, DB::TYPE_INTEGER, vwid);
            stmt_bind_value(AddRobbery, 7, DB::TYPE_INTEGER, RobberyData[id][Amount]);
            stmt_bind_value(AddRobbery, 8, DB::TYPE_INTEGER, RobberyData[id][ReqTime]);
            stmt_bind_value(AddRobbery, 9, DB::TYPE_INTEGER, RobberyData[id][SafeTime]);
            if(stmt_execute(AddRobbery)) SendClientMessage(playerid, 0x3498DBFF, "[ROBBERY] {FFFFFF}Robbery created.");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
        case DIALOG_REMOVE_ROBBERY:
        {
            if(!IsPlayerAdmin(playerid) || !response) return 1;
            new id = strval(inputtext);
            if(!RobberyData[id][Exists]) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Robbery doesn't exist.");
            for(new i, mp = GetPlayerPoolSize(); i <= mp; i++)
            {
                if(!IsPlayerConnected(i)) continue;
                if(PlayerRobberyData[i][RobID] == id) Robbery_ResetPlayer(i);
            }

            if(RobberyData[id][Timer] != -1) KillTimer(RobberyData[id][Timer]);
            DestroyDynamicCP(RobberyData[id][Checkpoint]);
            DestroyDynamic3DTextLabel(RobberyData[id][Label]);

            RobberyData[id][OccupiedBy] = RobberyData[id][Timer] = RobberyData[id][Checkpoint] = -1;
            RobberyData[id][Label] = Text3D: -1;
            RobberyData[id][Exists] = false;

            stmt_bind_value(RemoveRobbery, 0, DB::TYPE_INTEGER, id);
            if(stmt_execute(RemoveRobbery)) SendClientMessage(playerid, 0x3498DBFF, "[ROBBERY] {FFFFFF}Robbery removed.");
            return 1;
        }
        /* ---------------------------------------------------------------------- */
    }

    return 0;
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

forward ResetPlace(id);
public ResetPlace(id)
{
    new string[160];
    if(RobberyData[id][Cooldown] > 1) {
        RobberyData[id][Cooldown]--;

        format(string, sizeof(string), "Robbery(%d)\n\n{FFFFFF}%s\n{2ECC71}%s - %s {FFFFFF}every {F1C40F}5 {FFFFFF}seconds.\n{E74C3C}Available in %s", id, RobberyData[id][Name], formatInt(floatround(RobberyData[id][Amount] / 4)), formatInt(RobberyData[id][Amount]), ConvertToMinutes(RobberyData[id][Cooldown]));
        UpdateDynamic3DTextLabelText(RobberyData[id][Label], 0xF1C40FFF, string);
    }else if(RobberyData[id][Cooldown] == 1) {
        KillTimer(RobberyData[id][Timer]);
        RobberyData[id][Cooldown] = 0;
        RobberyData[id][Timer] = -1;

        format(string, sizeof(string), "Robbery(%d)\n\n{FFFFFF}%s\n{2ECC71}%s - %s {FFFFFF}every {F1C40F}5 {FFFFFF}seconds.\n{2ECC71}Available", id, RobberyData[id][Name], formatInt(floatround(RobberyData[id][Amount] / 4)), formatInt(RobberyData[id][Amount]));
        UpdateDynamic3DTextLabelText(RobberyData[id][Label], 0xF1C40FFF, string);
    }

    return 1;
}

CMD:createrobbery(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new id = Robbery_FindFreeID();
    if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Can't create any more robberies.");
    ShowPlayerDialog(playerid, DIALOG_ADD_ROBBERY_1, DIALOG_STYLE_INPUT, "{F1C40F}Robbery: {FFFFFF}Add (step 1)", "Write a name for the robbery:", "Next", "Close");
    return 1;
}

CMD:removerobbery(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}Only RCON admins can use this command.");
    new string[1024], total;
    format(string, sizeof(string), "ID\tName\n");

    for(new i; i < MAX_ROBBERIES; i++)
    {
        if(!RobberyData[i][Exists]) continue;
        format(string, sizeof(string), "%s%d\t%s\n", string, i, RobberyData[i][Name]);
        total++;
    }

    if(total == 0) {
        SendClientMessage(playerid, 0xE74C3CFF, "ERROR: {FFFFFF}No created robberies.");
    }else{
        ShowPlayerDialog(playerid, DIALOG_REMOVE_ROBBERY, DIALOG_STYLE_TABLIST_HEADERS, "{F1C40F}Robbery: {FFFFFF}Remove", string, "Remove", "Close");
    }

    return 1;
}
