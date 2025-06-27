/*
 *      LorencBank created by Lorenc
 *
 *          Uses SQLite and ZCMD
 *
 *       Released on the SAMP Forums.
 *
*/

#include                                                <a_samp>
#include                        <izcmd>
#include <streamer>
#include <sscanf2>


#define MAX_ATM_CP_SIZE 1
#define MAX_ATMCP 25



enum atm
{
	Float:cpX,
	Float:cpY,
	Float:cpZ
};
new ATMCP[MAX_ATMCP];
new Float: AtmCPs[][atm] =
{
{1.000, 1.000, 1.000},
{-1937.6260, 883.2705, 38.5078},// atmcp
{-2438.6035, 751.9985, 35.1719},// atmcp
{-2630.7825 ,630.6658, 14.4531}, // atmcp
{-2635.8201, 209.1930, 4.3583}, // atmcp
{-2640.3130, -38.2962, 4.3359}, // atmcp
{-2726.7610, -319.3815, 7.1875}, // atmcp
{-2516.9705, -624.3552 ,132.7883}, // atmcp
{-1981.1892, 144.0196, 27.6875}, // atmcp
{-1973.8827, 308.7638, 35.1719}, // atmcp
{-1990.9497, 744.6476, 45.4375} // atmcp
};


/* ** Configuration ** */
#define SERVER_DATABASE         "lorBank.db"
#define SERVER_NAME             "SFCNR"

#define DIALOG_VERSION
//#define COMMAND_VERSION
#define SHOW_CLICKED_BANK       // Cool feature, tab to click the player and show them there bank acc

#define DIALOG_TITLE            "{FFFFFF}San Fierro Cops and Robbers"
#define DIALOG_BANK_MENU        12          +1000
#define DIALOG_BANK_WITHDRAW    13          +1000
#define DIALOG_BANK_DEPOSIT     14          +1000
#define DIALOG_BANK_INFO                15          +1000

#if defined COMMAND_VERSION
        #if defined DIALOG_VERSION
                #error You cannot have both versions defined!
        #endif
#endif

#if !defined COMMAND_VERSION
        #if !defined DIALOG_VERSION
            #error One version must be marked!
        #endif
#endif


/* ** Colours ** */
#define COL_GREEN               "{6EF83C}"
#define COL_RED                 "{F81414}"
#define COL_LIGHTBLUE           "{00C0FF}"
#define COL_LGREEN              "{C9FFAB}"
#define COL_LRED                "{FFA1A1}"

#define COLOR_GREEN             0x00CC00FF
#define COLOR_RED               0xFF0000FF
#define COLOR_YELLOW            0xFFFF00FF
#define COLOR_ORANGE            0xEE9911FF
#define COLOR_BLUE              0x60CED4FF

/* ** Player Data ** */
enum PLAYER_DATA
{
        P_BANK_MONEY,
}

new gPlayerData                 [MAX_PLAYERS][PLAYER_DATA],
        DB:Database;

public OnFilterScriptInit()
{
        print("\nBank Script by Lorenc\n");
        Database = db_open(SERVER_DATABASE);
        db_free_result(db_query(Database, "CREATE TABLE IF NOT EXISTS `USERS` (`NAME`, `BANKMONEY`)"));
        
        
        
        for(new i = 0; i < sizeof(AtmCPs); i++)
        {
        ATMCP[i] = CreateDynamicCP(AtmCPs[i][cpX], AtmCPs[i][cpY], AtmCPs[i][cpZ], MAX_ATM_CP_SIZE, .worldid = 0);
        CreateDynamic3DTextLabel("ATM", 0xFF0000FF, AtmCPs[i][cpX], AtmCPs[i][cpY], AtmCPs[i][cpZ], 10.00, .worldid = 0);
        }
        
        
        
        
        
        
        return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{

	for(new i = 1; i < sizeof(ATMCP); i++)
	if(checkpointid == ATMCP[i])
	{
    ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST,""#DIALOG_TITLE" - Bank","Withdraw\nDeposit\nAccount Information","Select", "Cancel");
    }




	return 1;
}

public OnPlayerConnect(playerid)
{
        new Query[128], DBResult:Result;
        format(Query, sizeof(Query), "SELECT * FROM `USERS` WHERE `NAME` = '%s'", ReturnPlayerName(playerid));
        Result = db_query(Database, Query);
        if(db_num_rows(Result))
        {
            new Field[20];
            db_get_field_assoc(Result, "BANKMONEY", Field, 20);
            gPlayerData[playerid][P_BANK_MONEY] = strval(Field);
        }
        else
        {
            format(Query, sizeof(Query), "INSERT INTO `USERS` (`NAME`, `BANKMONEY`) VALUES('%s','0')", ReturnPlayerName(playerid));
            db_free_result(db_query(Database, Query));
        }
        return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SavePlayerBankAccount(playerid);
    return 1;
}

/*CMD:bank(playerid, params[])
{
        #if defined DIALOG_VERSION
        ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST,""#DIALOG_TITLE" - Bank","Withdraw\nDeposit\nAccount Information","Select", "Cancel");
        #endif
    	#if defined COMMAND_VERSION
        new string[128];
        if(isnull(params)) SendLBankMessage(playerid, "/bank [WITHDRAW/DEPOSIT/ACCOUNT]");
    	else if(!strcmp(params, "withdraw", true, 8))
    {
        new amount[24];
        strcpy2(amount, params, 0, 9);

        if(!IsNumeric(amount)) return SendLBankMessage(playerid, "Numeric Digits allowed only.");
        else if(strval(amount) > gPlayerData[playerid][P_BANK_MONEY]) return SendLBankMessage(playerid, "You cannot withdraw this much.");
        else if(strval(amount) < 0) return SendLBankMessage(playerid, "You cannot withdraw this much.");
        else
        {
        GivePlayerMoney(playerid, strval(amount));
        gPlayerData[playerid][P_BANK_MONEY] = gPlayerData[playerid][P_BANK_MONEY] - strval(amount);
        format(string, sizeof(string), "You have withdrawed $%d dollars.", strval(amount));
        SendLBankMessage(playerid, string);
        }
	}
        else if(!strcmp(params, "deposit", true, 7))
    {
        new amount[24];
        strcpy2(amount, params, 0, 8);

		if(!IsNumeric(amount)) return SendLBankMessage(playerid, "Numeric Digits allowed only.");
  		else if(strval(amount) > GetPlayerMoney(playerid)) return SendLBankMessage(playerid, "You cannot withdraw this much.");
    	else if(strval(amount) < 0) return SendLBankMessage(playerid, "You cannot withdraw this much.");
     	else
      	{
       	GivePlayerMoney(playerid, -strval(amount));
       	gPlayerData[playerid][P_BANK_MONEY] = gPlayerData[playerid][P_BANK_MONEY] + strval(amount);
        format(string, sizeof(string), "You have deposited $%d dollars.", strval(amount));
        SendLBankMessage(playerid, string);
                }
        }
        else if(!strcmp(params, "account", true, 7))
    {
        format(string, sizeof(string), "{FFFFFF}Your current bank account:\n\nBank Money: $%d\nCurrent Money: $%d", gPlayerData[playerid][P_BANK_MONEY], GetPlayerMoney(playerid));
        ShowPlayerDialog(playerid, 69+1000, DIALOG_STYLE_MSGBOX,""#DIALOG_TITLE" - Bank", string, "Ok", "");
        }
        else return SendLBankMessage(playerid, "/bank [WITHDRAW/DEPOSIT/ACCOUNT]");
        #endif
        return 1;
}
*/
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
        new string[128];
        if(dialogid == DIALOG_BANK_MENU)
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0:
                    {
                    format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to withdraw from your banking account\n\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                    ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT,"Bank",string, "Withdraw", "Back");
                    }
                    case 1:
                                {
                    format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to deposit from your banking account\n\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                    ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT,"Bank",string, "Deposit", "Back");
                                }
                        case 2:
                        {
                    format(string, sizeof(string), "{FFFFFF}Your Bank Information\n\t\t\nBalance: %d\nCurrent Money: %d", gPlayerData[playerid][P_BANK_MONEY], GetPlayerMoney(playerid));
                    ShowPlayerDialog(playerid, DIALOG_BANK_INFO, DIALOG_STYLE_MSGBOX,"Bank",string, "Ok", "Back");
                        }
                }
            }
        }
        if(dialogid == DIALOG_BANK_WITHDRAW)
        {
            if(response)
            {
                if(!strlen(inputtext))
                {
                    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You've entered an invalid amount.");
                    format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to withdraw from your banking account\n\t\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                    ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT,"Bank",string, "Withdraw", "Back");
                        }
                else if(strval(inputtext) > gPlayerData[playerid][P_BANK_MONEY])
                        {
                	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You don't have enough money to withdraw.");
                	format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to withdraw from your banking account\n\t\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                	ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT,"Bank",string, "Withdraw", "Back");
                        }
                else if(!IsNumeric(inputtext))
                        {
                	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You've entered an invalid amount.");
                 	format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to withdraw from your banking account\n\t\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                  	ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT,"Bank",string, "Withdraw", "Back");
                        }
                        else
                        {
                    gPlayerData[playerid][P_BANK_MONEY] = gPlayerData[playerid][P_BANK_MONEY] - strval(inputtext);
                    GivePlayerMoney(playerid, strval(inputtext));
                    format(string, sizeof(string), "{FFFFFF}Your Bank Information\n\nBank Balance: %d\nIn-hand Balance: %d", gPlayerData[playerid][P_BANK_MONEY], GetPlayerMoney(playerid));
                    ShowPlayerDialog(playerid, DIALOG_BANK_INFO, DIALOG_STYLE_MSGBOX,"Bank",string, "Ok", "Back");
                }
            }
            else ShowPlayerDialog(playerid, DIALOG_BANK_MENU,DIALOG_STYLE_LIST,"Bank","Withdraw\nDeposit\nAccount Information","Select", "Cancel");
        }
        if(dialogid == DIALOG_BANK_DEPOSIT)
        {
            if(response)
            {
                if(!strlen(inputtext))
                {
                    	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You've entered an invalid amount.");
                    	format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to deposit from your banking account\n\t\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                        ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT,"Bank",string, "Deposit", "Back");
                        }
                        else if(strval(inputtext) > GetPlayerMoney(playerid))
                        {
                        SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You don't have enough money to deposit.");
                        format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to deposit from your banking account\n\t\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                        ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT,"Bank",string, "Deposit", "Back");
                        }
                        else if(!IsNumeric(inputtext))
                        {
                		SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You've entered an invalid amount.");
                        format(string, sizeof(string), "{FFFFFF}Enter the amount you are willing to depositfrom your banking account\n\t\t\nCurrent Balance: $%d", gPlayerData[playerid][P_BANK_MONEY]);
                        ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT,"Bank",string, "Deposit", "Back");
                        }
                        else
                        {
                        gPlayerData[playerid][P_BANK_MONEY] = gPlayerData[playerid][P_BANK_MONEY] + strval(inputtext);
                        GivePlayerMoney(playerid, -strval(inputtext));
                        format(string, sizeof(string), "{FFFFFF}Your Bank Information\n\nBalance: %d\nCurrent Money: %d", gPlayerData[playerid][P_BANK_MONEY], GetPlayerMoney(playerid));
                        ShowPlayerDialog(playerid, DIALOG_BANK_INFO, DIALOG_STYLE_MSGBOX,"Bank",string, "Ok", "Back");
                }
            }
            else ShowPlayerDialog(playerid, DIALOG_BANK_MENU,DIALOG_STYLE_LIST,"Bank","Withdraw\nDeposit\nAccount Information","Select", "Cancel");
        }
        if(dialogid == DIALOG_BANK_INFO)
        {
            if(!response) ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST,"Bank","Withdraw\nDeposit\nAccount Information","Select", "Cancel");
        }
        return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
        new string[128];
        #if defined SHOW_CLICKED_BANK
                format(string, sizeof(string), "{FFFFFF}%s's Bank Information\n\nBalance: %d\nCurrent Money: %d", ReturnPlayerName(playerid), gPlayerData[clickedplayerid][P_BANK_MONEY], GetPlayerMoney(clickedplayerid));
                ShowPlayerDialog(playerid, 69+1000, DIALOG_STYLE_MSGBOX,""#DIALOG_TITLE" - Bank",string, "Ok", "");
        #endif
        return 1;
}

///////////////////////////////////
///         Functions           ///
//////////////////////////////////

stock SendLBankMessage(playerid, const Message[])
{
        new string[128];
        format(string, sizeof(string), ""COL_LGREEN"LorencBank: {FFFFFF}%s", Message);
        SendClientMessage(playerid, -1, string);
        return 1;
}

SavePlayerBankAccount(playerid)
{
        new Query[128];
    	format(Query, sizeof(Query), "UPDATE `USERS` SET BANKMONEY = '%d' WHERE `NAME` = '%s'", gPlayerData[playerid][P_BANK_MONEY], ReturnPlayerName(playerid));
        return db_free_result(db_query(Database, Query));
}

stock ReturnPlayerName(playerid)
{
        new pname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, pname, sizeof(pname));
        return pname;
}

stock strcpy2(dest[], src[], startdest = 0, startsrc = 0)
{
        for(new i=startsrc,j=strlen(src);i<j;i++) {
                dest[startdest++]=src[i];
        }
        dest[startdest]=0;
}

stock IsNumeric(const str[])
{
    new len = strlen(str);

    if(!len) return false;
    for(new i; i < len; i++)
    {
        if(!('0' <= str[i] <= '9')) return false;
    }
    return true;
}




CMD:getbankmoney(playerid, params[])
{
	new id;
	if(sscanf(params, "u", id))
	return SendClientMessage(playerid, -1, "{FFD700}[USAGE] GETBANKMONEY [PLAYERID]");
	new query[128];
	format(query, sizeof(query), "{90EE90}[BANK MONEY]{FFFFFF} %s has {FFD700}$%d{FFFFFF} in bank.", ReturnPlayerName(playerid), gPlayerData[playerid][P_BANK_MONEY]);
	SendClientMessage(playerid, -1, query);
	return 1;
}


