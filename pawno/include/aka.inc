#if !defined _samp_included 
    #error samp is not included 
#endif 
#if defined _AKA 
    #endinput 
#endif 
#define _AKA 
static DB:database; 

LoadAKADatabase() 
{ 
    database = db_open("aka.db"); 
    db_query(database,"CREATE TABLE IF NOT EXISTS `akas` (`Username`,`Ip`)"); 
} 

InitAKAOnConnect(playerid) 
{ 
    if(IsPlayerNPC(playerid)) return 1; 
    new ip[16],name[MAX_PLAYER_NAME],DBResult:result,string[128]; 
    GetPlayerIp(playerid,ip,16); 
    GetPlayerName(playerid,name,MAX_PLAYER_NAME); 
    format(string,sizeof(string),"SELECT `Ip` FROM `akas` WHERE `Username`='%s'",name); 
    result = db_query(database,string); 
    switch(db_num_rows(result))  
    { 
        case 0: format(string,sizeof(string),"INSERT INTO `akas` (`Username`,`Ip`) VALUES ('%s','%s')",name,ip); 
        default: format(string,sizeof(string),"UPDATE `akas` SET `Ip`='%s' WHERE `Username`='%s'",ip,name); 
    } 
    db_free_result(result); 
    db_query(database,string); 
    return 1; 
} 
stock AKA(playerid,accs[][],const size=sizeof(accs)) 
{ 
    new ip[16],name[MAX_PLAYER_NAME],DBResult:result,string[128],rows; 
    GetPlayerIp(playerid,ip,16); 
    GetPlayerName(playerid,name,MAX_PLAYER_NAME); 
    format(string,sizeof(string),"SELECT `Username` FROM `akas` WHERE `Ip`='%s'",ip); 
    result = db_query(database,string); 
    rows = db_num_rows(result); 
    if(rows>1) 
    { 
        for(new i,j; i<rows; i++) 
        { 
            if(j==size) break; 
            db_get_field(result,0,accs[j++],MAX_PLAYER_NAME); 
            db_next_row(result); 
        } 
    } 
    return db_free_result(result); 
}  