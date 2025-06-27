#include <a_samp>
#include <a_mysql>
#include <izcmd>
#include <YSI\y_ini>
#include <streamer>
#include <sscanf2>
#include "a_toys.pwn"
#include <a_zones>
#include <directory>
#include <foreach>
#include <aka>


#define WEBSITE_NAME "www.inexorablegaming.com"




#undef MAX_PLAYERS
#define MAX_PLAYERS 100
#define PLAYERS 50 //This is for sending a client message to admins.. Max players wasnt working, so used this.
#define MAX_STORES 50
#define MAX_ATMS 25
#define MAX_ATMCP 25


#define MAX_PING 1024
//#define MAX_CP 1

//#include "classTD.pwn"
native WP_Hash(buffer[], len, const str[]);

//new cptest[MAX_CP];

//new PlayerText:XPBar;
new PlayerText:CurrentXP;
new PlayerText:XPBarTD[MAX_PLAYERS];
new PlayerText:WLvlTD[MAX_PLAYERS];
new PlayerText:LocationTD;


//new PlayerText:wStars[MAX_PLAYERS];
new PlayerText:wLvlStars[MAX_PLAYERS];
new PlayerText:Robbery[MAX_PLAYERS][12];
new SafeRecentlyRobbed[MAX_PLAYERS];
new SafeBeingRobbed[MAX_PLAYERS];

new String[128], Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS], Name[MAX_PLAYER_NAME], IsBeingSpeced[MAX_PLAYERS],spectatorid[MAX_PLAYERS];

new bool:DoubleXP;
new dndid[MAX_PLAYERS];








#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_REGISTERSUCCESS 3
#define DIALOG_LOGINSUCCESS 4
#define DIALOG_STATS 5
#define DIALOG_CMDS 6
#define DIALOG_TAX 7
#define DIALOG_CHANGEPW 8
#define DIALOG_JOB 9
#define DIALOG_SHOP 10 //SUPA SAVE DIALOG SHOP
#define DIALOG_SHOP_ROPE 11
#define DIALOG_SHOP_SCISSOR 12
#define DIALOG_SHOP_BOBBYPINS 13
#define DIALOG_SHOP_METALMELTERS 14
#define DIALOG_SHOP_MONEYBAG 15


#define MAX_STORE_CP_SIZE 1.5
#define MAX_ATM_CP_SIZE 0.75

#define TEAM_FBI 0
#define TEAM_CIA 1
#define TEAM_ARMY 2
#define TEAM_FIREMAN 3
#define TEAM_MEDIC 4
#define TEAM_POLICE 5
#define TEAM_CIVILIAN 6


//job defines
#define JOB_RAPIST 0
#define JOB_KIDNAPPER 1
#define JOB_TERRORIST 2
#define JOB_HITMAN 3
#define JOB_PROSTITUTE 4
#define JOB_WEAPONDEALER 5
#define JOB_DRUGDEALER 6
#define JOB_DIRTYMECHANIC 7






new skinSelectionTDBoxColor[] =
{
	385941503,           // FBI
	1127180543,         //CIA
	639443043,             //ARMY
	2116297983,           //FIREMAN
	1124008191,             //MEDIC
	795526399,               //POLICE/SIMPLE COP
	255          //CIVILIAN
};
// fix these warnings and then let me know
enum storeExteriorCoordinateData
{
	storeName[32], //KYA THA WO? ENUMS THE? KYA? WAGERAH WAGERAH..CreateActor
	Float:ExteriorX,
	Float:ExteriorY,
	Float:ExteriorZ
};
new Float:storeExteriorCoordinates[][storeExteriorCoordinateData] =
{
	//SAN FIERRO ONLY
//	{"BURGER SH0T",-2336.8684, -166.7399, 35.5547}, //GARCIA SF
	{"GYM", -2270.6482,-155.9236,35.3203},
	{"MISTY'S BAR", -2242.1431,-88.2210,35.3203},
 	{"ZERO'S RC SHOP", -2241.8164,128.6043,35.3203},
 	{"AMMUNATION", -2625.9143,208.2347,4.8125},
 	{"GAYDAR DISCO", -2551.2227,194.2516,6.2266},
 	{"SUPA SAVE", -2442.6589,755.0315,35.1719},
 //	{"GAS STATION", -2420.1563,969.7122,45.2969}, //XOOMER, near SUPA
 //	{"BURGER_SHOT", -2420.1563,969.7122,45.2969}, //NEAR SUPA SAVE SF    WON'T BE ADDED NOW..
 	{"DONUT SHOP", -2767.8713,788.7899,52.7813},// erm.. where did u CREATE them not the variables
 	//{"HOSPITAL", -2655.0449,640.1652,14.4545},
 	{"CLUCKIN' BELL", -2671.5457,257.9267,4.6328},
 	{"THE BARBER'S SHOP", -2571.4475,246.6283,10.4330},
 	{"TATTOO SHOP", -2490.9946,-38.8578,25.6172},
 	{"SUB URBAN", -2490.7200,-29.0269,25.6172},
// 	{"TOY SHOP", -2490.5410,-16.9049,25.6172},
 	{"DRIVING SCHOOL", -2026.5026,-102.0663,35.1641},
 	//{"CHURCH", -1989.8986,1117.9479,54.4688},
 	{"THE JIZZY", -2625.2505,1412.6266,7.0938},
 	{"THE WELL STACKED PIZZA", -1720.9393,1360.5741,7.1853}, //NEAR JIZZY OR IN FRONT OF OTTO'S GROTTI
 	//{"SF BANK", -1492.1321,920.1070,7.1875},
 	{"VICTIM", -1694.5853,951.9246,24.8906},
// 	{"WELL STACKED PIZZA", -1808.7285,945.8605,24.8906}, //NEAR VICTIM SF
 	{"ZIP", -1882.2384,866.4849,35.1719},
 	{"BURGER SHOT", -1912.3386,827.8304,35.2211}, //FINANCIAL or IN FRONT OF VIP LOUNGE
 	{"GAS STATION", -1676.2047,432.1628,7.1797} //NEAR SF BANK
};

enum storeInteriorCoordinateData
{
	StoreName[32],
	Float:InteriorX,
	Float:InteriorY,
	Float:InteriorZ,
	InteriorID,
	worldid

};

new Float:storeInteriorCoordinates[][storeInteriorCoordinateData] =
{
	//SAN FIERRO ONLY
//	{"BURGER SHOT", 363.1972,-75.4457,1001.5078, 10, 1}, //  UNWORKING, WILL BE ADDED LATER
	{"GYM", 774.2014,-50.4772,1000.5859, 6, 2},//
	{"MISTY'S BAR", 501.9337,-67.5643,998.7578, 11, 3},//
	{"ZERO'S RC SHOP", -2240.7827,137.1085,1035.4141, 6, 4},//
	{"AMMUNATION", 286.1404,-41.8046,1001.5156, 1, 5},//
	{"GAYDAR DISCO", 493.9912,-24.9607,1000.6719, 17, 6},// //
	{"SUPA SAVE", 1514.5879,1577.1765,10.8681, 1, 2},
	{"GAS STATION", -26.5975,-58.2672,1003.5469, 6, 7},//
//	{"BURGER SHOT", 363.1972,-75.4457,1001.5078, 10, 8},// UNWORKING WILL BE ADDED LATER
	{"DONUT SHOP", 377.1571,-193.3035,1000.6328, 17, 9},//
	//{"HOSPITAL", 375.962463,-65.816848,1001.507812, 10},
	{"CLUCKIN' BELL", 365.7634,-11.8433,1001.8516, 9, 10},//
	{"THE BARBER SHOP", 412.0977,-54.4467,1001.8984, 12, 11},//
	{"TATTOO SHOP", -204.3791,-27.3476,1002.2734, 16, 12},//
	{"SUB URBAN", 203.7211,-50.6643,1001.8047, 1, 13},//
//	{"TOY SHOP", -2240.7827,137.1085,1035.4141, 6, 14},// // UNWORKING, WILL BE ADDED LATER
	{"DRIVING SCHOOL", -2026.8256,-103.6017,1035.1835, 3, 15},//
	//{"CHURCH", 375.962463,-65.816848,1001.507812, 10},
	{"THE JIZZY", -2636.1851,1402.4630,906.4609, 3, 16},//
	{"WELL STACKED PIZZA", 372.4151,-133.5241,1001.4922, 5, 17},//
	//{"SF BANK", 375.962463,-65.816848,1001.507812, 10},
	{"VICTIM", 227.5630,-7.5413,1002.2109, 5, 18},//
//	{"WELL STACKED PIZZA", 372.4154,-133.5244,1001.4922, 5, 19},// UNWORKING, WILL BE ADDED LATER
	{"ZIP", 161.4383,-97.1108,1001.8047, 18, 20},//
	{"BURGER SHOT", 363.1972,-75.4457,1001.5078, 10, 21},//
	{"GAS STATION", -26.5971,-58.2672,1003.5469, 6, 22}//
};
#define MAX_SAFES 95
enum BodyOfSafe //the only body of the safe, doors and
{
	Float:SafeX,
	Float:SafeY,
	Float:SafeZ,
	Float:SafeRX,
	Float:SafeRY,
	Float:SafeRZ,
	StoreLocation[69] // From %s,  "Burger Shot Near Garcia In San Fierro"
};
new SafeBody[][BodyOfSafe] =
{
 //   {382.546600, -56.539268, 1000.957580, 0.000000, 0.000000, 0.000000, "Burger Shot near Garcia in San Fierro"}, //BURGERSHOT
    {768.734619, -16.605970, 1000.065368, 0.000000, 0.000000, 0.000000, "Gym near Garcia in San Fierro"}, //GYM
	{511.984741, -74.733131, 998.147277, 0.000000, 0.000000, -89.899986, "Misty's bar near Garcia in San Fierro"},
	{-2222.248535, 133.333160, 1035.162719, 0.000000, 0.000000, 180.000000,  "Zero's RC Shop near Garcia in San Fierro"},
	{296.044952, -30.195020, 1000.885070, 0.000000, 0.000000, 0.000000, "Misty's bar near Garcia in San Fierro"},
	{503.455413, -24.457609, 1000.089294, 0.000000, 0.000000, -89.900001,"Misty's bar near Garcia in San Fierro"},
	{1524.330810, 1600.408691, 10.268095, 0.000000, 0.000000, 0.000000, "Misty's bar near Garcia in San Fierro"},
	{-32.849315, -57.956821, 1002.976867, 0.000000, 0.000000, -179.400009, "Misty's bar near Garcia in San Fierro"},
	//{382.546600, -56.539268, 1000.957580, 0.000000, 0.000000, 0.000000, "Misty's bar near Garcia in San Fierro"},  //BURGER SHOT
	{382.495880, -188.462814, 1000.042724, 0.000000, 0.000000, -90.000030, "Misty's bar near Garcia in San Fierro"},
	{363.503723, -7.443450, 1001.241271, 0.000000, 0.000000, 90.599998, "Misty's bar near Garcia in San Fierro"},
	{408.466094, -55.786533, 1001.288513, 0.000000, 0.000000, -177.500015, "Misty's bar near Garcia in San Fierro"},
	{-200.292083, -26.956869, 1001.693176, 0.000000, 0.000000, -90.299980, "Misty's bar near Garcia in San Fierro"},
	{204.779647, -33.611824, 1001.254394, 0.000000, 0.000000, 0.000000, "Misty's bar near Garcia in San Fierro"},
	//{-2222.248535, 133.333160, 1035.162719, 0.000000, 0.000000, 180.000000,  "Misty's bar near Garcia in San Fierro"},  TOY SHOP
	{-2031.228149, -119.319564, 1034.611328, 0.000000, 0.000000, 179.899978,  "Misty's bar near Garcia in San Fierro"},
	{-2657.571777, 1423.707519, 905.933349, 0.000000, 0.000000, 0.000000, "Misty's bar near Garcia in San Fierro"},
	{371.879150, -113.893875, 1000.911804, 0.000000, 0.000000, 90.299995,  "Misty's bar near Garcia in San Fierro"},
	{199.784332, -5.738388, 1000.650756, 0.000000, 0.000000, 179.999969,  "Misty's bar near Garcia in San Fierro"},
//	{371.879150, -113.893875, 1000.911804, 0.000000, 0.000000, 90.299995,  "Misty's bar near Garcia in San Fierro"},
	{158.655502, -70.026893, 1001.234130, 0.000000, 0.000000, 0.000000,  "Misty's bar near Garcia in San Fierro"},
	{382.546600, -56.539268, 1000.957580, 0.000000, 0.000000, 0.000000,  "Misty's bar near Garcia in San Fierro"},
	{-32.849315, -57.956821, 1002.976867, 0.000000, 0.000000, -179.400009,  "Misty's bar near Garcia in San Fierro"}
};

enum MoneyOfSafe //the only body of the safe, doors and
{
	Float:SafeX,
	Float:SafeY,
	Float:SafeZ,
	Float:SafeRX,
	Float:SafeRY,
	Float:SafeRZ,
	vworld
};

new SafeMoney[][MoneyOfSafe] =
{
//    {382.519470, -56.520069, 1000.847290, 0.000000, 0.000000, -3.399998, 1},
	{768.728759, -16.660827, 999.965576, 0.000000, 0.000000, 0.000000, 2},
	{512.044982, -74.707756, 998.077331, 0.000000, 0.000000, -93.500000, 3},
	{-2222.229003, 133.286727, 1035.092285, 0.000000, 0.000000, 179.300003, 4},
	{296.016693, -30.148305, 1000.825561, 0.000000, 0.000000, 0.000000, 5},
	{503.492492, -24.451353, 1000.009643, 0.000000, 0.000000, -91.099975, 6},
	{1524.332641, 1600.454345, 10.148094, 0.000000, 0.000000, -1.899999, 7},
	{-32.853031, -57.980606, 1002.886840, 0.000000, 0.000000, 177.800033, 8},
	//{382.519470, -56.520069, 1000.847290, 0.000000, 0.000000, -3.399998, 9},
	{382.530975, -188.467071, 1000.002075, 0.000000, 0.000000, -91.900016, 10},
	{363.498748, -7.436305, 1001.161132, 0.000000, 0.000000, 90.099990, 11},
	{408.488586, -55.793586, 1001.228088, 0.000000, 0.000000, 179.300018, 12},
	{-200.265274, -26.942903, 1001.613281, 0.000000, 0.000000, -92.900009, 13},
	{204.763305, -33.567375, 1001.164123, 0.000000, 0.000000, 0.000000, 14},
	//{-2222.229003, 133.286727, 1035.092285, 0.000000, 0.000000, 179.300003, 15},
	{-2031.239501, -119.352462, 1034.521240, 0.000000, 0.000000, 176.799987, 16},
	{-2657.579833, 1423.650634, 905.886718, 0.000000, 0.000000, 0.000000, 17},
	{371.937286, -113.952919, 1000.871948, 0.000000, 0.000000, 92.500015, 18},
	{199.760833, -5.768735, 1000.540405, 0.000000, 0.000000, -178.699981,19},
//	{371.937286, -113.952919, 1000.871948, 0.000000, 0.000000, 92.500015, 20},
	{158.667755, -70.009178, 1001.134033, 0.000000, 0.000000, 0.000000, 21},
	{382.519470, -56.520069, 1000.847290, 0.000000, 0.000000, -3.399998, 22},
	{-32.853031, -57.980606, 1002.886840, 0.000000, 0.000000, 177.800033, 23}
};
new StoreSafeMoney[MAX_SAFES];

enum DoorOfSafe
{

	Float:SafeX,
	Float:SafeY,
	Float:SafeZ,
	Float:SafeRX,
	Float:SafeRY,
	Float:SafeRZ
};

new SafeDoor[][DoorOfSafe] =
{

	//{382.211303, -56.731536, 1000.967346, 0.000000, 0.000000, -133.500045},
	{768.397888, -16.823215, 1000.065612, 0.000000, 0.000000, -129.499984},
	{511.912078, -74.438972, 998.157348, 0.000000, 0.000000, 149.100006},
	{-2221.938720, 133.421676, 1035.153198, 0.000000, 0.000000, 62.100013},
	{295.714904, -30.344364, 1000.925354, 0.000000, 0.000000, -126.299995},
	{503.278045, -24.136524, 1000.099853, 0.000000, 0.000000, 146.600006},
	{1524.027709, 1600.274536, 10.298103, 0.000000, 0.000000, -133.000000},
	{-32.517383, -57.793003, 1002.986999, 0.000000, 0.000000, 59.899986},
	//{382.211303, -56.731536, 1000.967346, 0.000000, 0.000000, -133.500045},
	{382.387420, -188.157226, 1000.022827, 0.000000, 0.000000, 139.100036},
	{363.593414, -7.783213, 1001.241333, 0.000000, 0.000000, -23.399997},
	{408.782318, -55.590072, 1001.308227, 0.000000, 0.000000, 63.999992},
	{-200.475051, -26.597469, 1001.713195, 0.000000, 0.000000, 149.100021},
	{204.448745, -33.772617, 1001.264343, 0.000000, 0.000000, -127.100021},
	//{-2221.938720, 133.421676, 1035.153198, 0.000000, 0.000000, 62.100013},
	{-2030.849121, -119.105697, 1034.631835, 0.000000, 0.000000, 44.199993},
	{-2657.929443, 1423.561523, 905.923400, 0.000000, 0.000000, -122.200050},
	{372.023590, -114.244590, 1000.931823, 0.000000, 0.000000, -29.399997},
	{200.165679, -5.517936, 1000.640747, 0.000000, 0.000000, 41.800018},
//	{372.023590, -114.244590, 1000.931823, 0.000000, 0.000000, -29.399997},
	{158.273590, -70.221260, 1001.224487, 0.000000, 0.000000, -124.999923},
	{382.211303, -56.731536, 1000.967346, 0.000000, 0.000000, -133.500045},
	{-32.517383, -57.793003, 1002.986999, 0.000000, 0.000000, 59.899986}

};
new StoreSafeDoor[MAX_SAFES];





enum atm
{
	objID,
	Float:AtmX,
	Float:AtmY,
	Float:AtmZ,
	Float:AtmrX,
	Float:AtmrY,
	Float:AtmrZ
};

new Float:ATMobjectPos[][atm] =
{
{19324, -1938.216674, 883.306701, 38.088527, 0.000000, 0.000000, 91.599998},
{19324, -2438.586914, 752.608825, 34.785640, 0.000000, 0.000000, 0.000000},
{19324, -2630.759765, 631.255493, 14.034218, 0.000000, 0.000000, 0.000000},
{19324, -2635.805175, 208.588455, 3.962610, 0.000000, 0.000000, -178.800003},
{19324, -2640.340087, -37.669147, 3.983896, 0.000000, 0.000000, 0.000000},
{19324, -2726.326660, -319.814483, 6.803497, 0.000000, 0.000000, -134.100128},
{19324, -2516.953857, -624.958557, 132.390075, 0.000000, 0.000000, 179.999923},
{19324, -1980.598144, 144.074172, 27.270055, 0.000000, 0.000000, -90.399932},
{19324, -1973.953247, 309.380187, 34.797080, 0.000000, 0.000000, 0.000000},
{19324, -1990.538208, 745.110900, 45.068481, 0.000000, 0.000000, -43.399955}
};


//ISKO chor... ROBBERY FS ka kya krein?? Usme sbko message jaye

//EXAMPLE: [ROBBERY] Sherlock_(69) has robbed 6969 from AMMUNATION near OCEAN FLATS in San Fierro
// where is robbery fs?


new Float:teamFBIspawns[][]=
{
{-2454.5720,503.9985,30.0784}
};

new Float:teamCIAspawns[][]=
{
{-2454.5720,503.9985,30.0784}
};

new Float:teamArmyspawns[][]=
{
{-1390.9393,498.7409,18.2344}
};

new Float:teamFiremanspawns[][]=
{
{-2025.7831,67.2317,28.4671}
};

new Float:teamMedicspawns[][]=
{
{-2653.6592,632.7040,14.4531}
};

new Float:teamCopspawns[][]=
{
{-1606.1080,679.3832,-5.2422}
};

new Float:teamCivilspawns[][] =
{
{-2319.3103,-140.6699,35.5547},
{-2239.1213,113.1026,35.3203},
{-1984.4160,148.2307,27.6875},
{-2034.0242,-95.2204,35.1641},
{-1953.3257,295.7997,41.0471},
{-1505.3716,914.2769,7.1875},
{-2625.0098,1394.1588,7.1016},
{-2470.9756,1254.0615,31.6283},
{-1981.0078,1116.2543,53.1255},
{-1932.7061,883.2413,38.5078},
{-2093.7019,715.4874,69.5625},
{-2588.2007,216.4961,9.4301},
{-2759.8081,375.0569,4.5682},
{-2514.0493,-20.6762,25.6172}

};







new skinSelectionTDText[][][] = {
	{"FBI", "-Law Enforcement Officer",  "-Maintains the LAW", "-Can use /bruteforce", "-10,000 XP REQUIRED"},
	{"CIA", "-Law Enforcement Officer",  "-Maintains the LAW", "-Invisible from RADAR", "-15,000 XP REQUIRED"},
	{"ARMY", "-Law Enforcement Officer",  "-Maintains the LAW", "-Can use HUNTER", "-20,000 XP REQUIRED"},
	{"FIREMAN", "-Can abuse canon",  "-Can abuse firetruck water", "-Rob stores for money", "-2,000 XP REQUIRED"},
	{"MEDIC", "-Can HEAL players",  "-Can CURE STDs", "-Rob stores for money", "-3,000 XP REQUIRED"},
	{"POLICE", "-Law Enforcement Officer",  "-Maintains the LAW", "-Can kill/arrest wanteds", "-0 XP REQUIRED"},
	{"CIVILIAN", "-Rob/Rape players ingame",  "-Kill anyone on STREETS", "-Rob stores for money", "-Can join any CLAN/GANG"}
};
// go through all the textdraws and see wherethe color changes and make a list of all
//homework :-P the colors for all the teams.. and then let me know
//wtbout tha box colors and the text colors? the FBI/CIVILIAN COLOR CHANGES.. OR ONLY THE BOX COLOR I DONT REMEMBER..
new IsPlayerSpawned[MAX_PLAYERS];
new AntiSpam[MAX_PLAYERS];





#define MYSQL_HOST "localhost"
#define MYSQL_USER "root"
#define MYSQL_DB "sfcnr"
#define MYSQL_PASSWORD ""



enum pData
{
	pName,
	pPassword,
	pAdmin,
	pVIP,
	pKills,
	pDeaths,
	pLoginAttempts,
	pLoggedIn,
	pDBID,
	pJobSelected,
	pJob,
	pXP,
	pWanted,
	pWarns
}

//*** S U P A    I T E M S***

enum SupaItems
{
	pRopes,
	pScissors,
	pBobbyPins,
	pMetalMelter,
	bool:pMoneyBag
};
new pItems[MAX_PLAYERS][SupaItems];



//new	bool:pMoneyBag[MAX_PLAYERS];




 //SUPA ITEMS
new pInfo[MAX_PLAYER_NAME][pData];
new gTeam[MAX_PLAYERS];

new StoreInteriorCP[MAX_STORES];
new StoreExteriorCP[MAX_STORES];
new ATMobj[MAX_ATMS];
new StoreSafeBody[MAX_SAFES];








new Text:selectionTD[MAX_PLAYERS][5];
new dbHandle;
//explain :/
// basically u use a variable "dbhandle" to store the current connection
// this will later be used to tell the script which connection to
// for example u make 10 connections to 10 different databses.. then u use dbHandle to tell the script to do mysql stuff on the sfcnr table


//___________________//
//____CHECKPOINTS____//
//___________________//

//******* S E R V E R     L O G S **************

//********* A D M I N    C O M M A N D S ***************
forward AdminLogs(string[]);
public AdminLogs(string[])
{
    new entry[128],
		fyear, fmonth, fday,
		fhour, fminute, fsecond;
		
		
	getdate(fyear, fmonth, fday);
	gettime(fhour, fminute, fsecond);
		
	format(entry, sizeof(entry), "[%02d/%02d/%04d %02d:%02d:%02d]  %s  \n", fday, fmonth, fyear, fhour, fminute, fsecond, string);
	new File:hFile;
	hFile = fopen("/LOGS/AdminLogs.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

//********* A D M I N    C H A T L O G**********

forward AdminChatLog(string[]);
public AdminChatLog(string[])
{
	new entry[128],
		fyear, fmonth, fday,
		fhour, fminute, fsecond;
		
	format(entry, sizeof(entry), "[%02d/%02d/%04d %02d:%02d:%02d]  %s  \n", fday, fmonth, fyear, fhour, fminute, fsecond, string);
	
	
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("/LOGS/AdminChat.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

forward ChatLog(string[]);
public ChatLog(string[])
{
	new entry[128],
		fyear, fmonth, fday,
		fhour, fminute, fsecond;

	format(entry, sizeof(entry), "[%02d/%02d/%04d %02d:%02d:%02d]  %s  \n", fday, fmonth, fyear, fhour, fminute, fsecond, string);


	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("/LOGS/Chat.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

forward PMLog(string[]);
public PMLog(string[])
{
	new entry[128],
		fyear, fmonth, fday,
		fhour, fminute, fsecond;

	format(entry, sizeof(entry), "[%02d/%02d/%04d %02d:%02d:%02d]  %s  \n", fday, fmonth, fyear, fhour, fminute, fsecond, string);


	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("/LOGS/PM.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}
forward SMLog(string[]);
public SMLog(string[])
{
	new entry[128],
		fyear, fmonth, fday,
		fhour, fminute, fsecond;

	format(entry, sizeof(entry), "[%02d/%02d/%04d %02d:%02d:%02d]  %s  \n", fday, fmonth, fyear, fhour, fminute, fsecond, string);


	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("/LOGS/SM.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}



//^^^^^^^^^^^^^^^^^^ S T O C K S ^^^^^^^^^^^^^^^^^^^^^^^^
//####################### S T A R T S########################

stock Error(playerid, const Message[])
{
	new string[128];
	format(string, 128, "{FF0000}[ERROR]{FFFFFF} %s", Message);
	SendClientMessage(playerid, -1, string);
	return 1;
}

stock AdminUsage(playerid, const Message[])
{
	new string2[128];
	format(string2, 128, "{1E90FF}[ADMIN]{FFFFFF} %s", Message);
	SendClientMessage(playerid, -1, string2);
	return 1;
}

stock Usage(playerid, const Message[])
{
	new string3[128];
	format(string3, 128, "{FFFF00}[USAGE]{FFFFFF} %s", Message);
	SendClientMessage(playerid, string3);
	return 1;
}

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");

	print("----------------------------------\n");
}
//deleted them.. cuz making it as a GM..


public OnGameModeInit()
{
    // Don't use these lines if it's a filterscript
	SetGameModeText("Cops and Robbers");
	DisableInteriorEnterExits();
	
 	mysql_tquery(1, "CREATE TABLE IF NOT EXISTS `Objects` (`ID` int(5) NOT NULL,`Index` int(2) NOT NULL,`Model` int(7) NOT NULL,`Bone` int(2) NOT NULL,`OffsetX` float NOT NULL,`OffsetY` float NOT NULL,`OffsetZ` float NOT NULL,`RotX` float NOT NULL,`RotY` float NOT NULL,`RotZ` float NOT NULL,`ScaleX` float NOT NULL,`ScaleY` float NOT NULL,`ScaleZ` float NOT NULL)");
	objectlist = LoadModelSelectionMenu("objects.txt");
	
	

    EnableStuntBonusForAll(0);
	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);


	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		selectionTD[i][0] = TextDrawCreate(186.000000, 191.000000, "CIVILIAN");
		TextDrawBackgroundColor(selectionTD[i][0], 255);
		TextDrawFont(selectionTD[i][0], 3);
		TextDrawLetterSize(selectionTD[i][0], 0.689999, 1.900000);
		TextDrawColor(selectionTD[i][0], -1);
		TextDrawSetOutline(selectionTD[i][0], 0);
		TextDrawSetProportional(selectionTD[i][0], 1);
		TextDrawSetShadow(selectionTD[i][0], 1);
		TextDrawUseBox(selectionTD[i][0], 1);
		TextDrawBoxColor(selectionTD[i][0], 255); // here is it freeeend
		TextDrawTextSize(selectionTD[i][0], 278.000000, -203.000000);
  		TextDrawSetSelectable(selectionTD[i][0], 0);

		selectionTD[i][1] = TextDrawCreate(186.000000, 212.000000, "-Rob/Rape players ingame");
		TextDrawBackgroundColor(selectionTD[i][1], 255);
		TextDrawFont(selectionTD[i][1], 1);
		TextDrawLetterSize(selectionTD[i][1], 0.200000, 1.000000);
		TextDrawColor(selectionTD[i][1], -1);
		TextDrawSetOutline(selectionTD[i][1], 0);
		TextDrawSetProportional(selectionTD[i][1], 1);
		TextDrawSetShadow(selectionTD[i][1], 1);
		TextDrawUseBox(selectionTD[i][1], 1);
		TextDrawBoxColor(selectionTD[i][1], 639443043);
		TextDrawTextSize(selectionTD[i][1], 278.000000, 0.000000);
		TextDrawSetSelectable(selectionTD[i][1], 0);

		selectionTD[i][2] = TextDrawCreate(186.000000, 224.000000, "-Kill anyone on STREETS");
		TextDrawBackgroundColor(selectionTD[i][2], 255);
		TextDrawFont(selectionTD[i][2], 1);
		TextDrawLetterSize(selectionTD[i][2], 0.200000, 1.000000);
		TextDrawColor(selectionTD[i][2], -1);
		TextDrawSetOutline(selectionTD[i][2], 0);
		TextDrawSetProportional(selectionTD[i][2], 1);
		TextDrawSetShadow(selectionTD[i][2], 1);
		TextDrawUseBox(selectionTD[i][2], 1);
		TextDrawBoxColor(selectionTD[i][2], 639443043);
		TextDrawTextSize(selectionTD[i][2], 278.000000, 0.000000);
		TextDrawSetSelectable(selectionTD[i][2], 0);

		selectionTD[i][3] = TextDrawCreate(186.000000, 237.000000, "-Rob stores for money");
		TextDrawBackgroundColor(selectionTD[i][3], 255);
		TextDrawFont(selectionTD[i][3], 1);
		TextDrawLetterSize(selectionTD[i][3], 0.200000, 1.000000);
		TextDrawColor(selectionTD[i][3], -1);
		TextDrawSetOutline(selectionTD[i][3], 0);
		TextDrawSetProportional(selectionTD[i][3], 1);
		TextDrawSetShadow(selectionTD[i][3], 1);
		TextDrawUseBox(selectionTD[i][3], 1);
		TextDrawBoxColor(selectionTD[i][3], 639443043);
		TextDrawTextSize(selectionTD[i][3], 278.000000, 0.000000);
		TextDrawSetSelectable(selectionTD[i][3], 0);

		selectionTD[i][4] = TextDrawCreate(186.000000, 250.000000, "-Can join any CLAN/GANG");
		TextDrawBackgroundColor(selectionTD[i][4], 255);
		TextDrawFont(selectionTD[i][4], 1);
		TextDrawLetterSize(selectionTD[i][4], 0.200000, 1.000000);
		TextDrawColor(selectionTD[i][4], -1);
		TextDrawSetOutline(selectionTD[i][4], 0);
		TextDrawSetProportional(selectionTD[i][4], 1);
		TextDrawSetShadow(selectionTD[i][4], 1);
		TextDrawUseBox(selectionTD[i][4], 1);
		TextDrawBoxColor(selectionTD[i][4], 639443043);
		TextDrawTextSize(selectionTD[i][4], 278.000000, 0.000000);
		TextDrawSetSelectable(selectionTD[i][4], 0);

		for(new x = 0; x < 5; x++)
		    TextDrawHideForAll(selectionTD[i][x]);
	}



	AddPlayerClass(119,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(289,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(273,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(271,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(208,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(268,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(292,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(293,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(3,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(4,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(2,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(7,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(12,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(13,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(14,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(15,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(17,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(19,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(20,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(21,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(22,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(23,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(24,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(26,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(28,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(29,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(30,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(31,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(32,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(33,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(34,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(35,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(36,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(37,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(38,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(46,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(47,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(48,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(59,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(60,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(63,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(64,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(152,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(237,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(78,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(79,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(134,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(100,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(101,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(137,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(286,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(71,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(285,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(287,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(303,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(304,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(305,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(277,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(278,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(279,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(274,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(275,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(276,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(308,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(265,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(266,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(267,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(306,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(280,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(281,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(284,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //
	AddPlayerClass(307,-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0); //-2255.5356,-34.8754,35.1719,359.4352,0,0,0,0,0,0



	UsePlayerPedAnims();
	// Konsa store bnadia tune ,-, thoda part of text?? wo jo code lekha tha wo kaha hai ARE KONSA CODE?? THODA EXAMPLE?
	for(new i = 0; i < sizeof(storeExteriorCoordinates); i++)

	{
	    StoreExteriorCP[i] =  CreateDynamicCP(storeExteriorCoordinates[i][ExteriorX], storeExteriorCoordinates[i][ExteriorY], storeExteriorCoordinates[i][ExteriorZ], MAX_STORE_CP_SIZE, .worldid = 0);
		CreateDynamic3DTextLabel(storeExteriorCoordinates[i][storeName], 0xFF0000FF, storeExteriorCoordinates[i][ExteriorX], storeExteriorCoordinates[i][ExteriorY], storeExteriorCoordinates[i][ExteriorZ], 10.00, .worldid = 0);
	}

	for (new x = 0; x < sizeof(storeInteriorCoordinates); x++)
	{
	    StoreInteriorCP[x] = CreateDynamicCP(storeInteriorCoordinates[x][InteriorX], storeInteriorCoordinates[x][InteriorY], storeInteriorCoordinates[x][InteriorZ], MAX_STORE_CP_SIZE, .interiorid = storeInteriorCoordinates[x][InteriorID]);
	    CreateDynamic3DTextLabel("EXIT", 0xFF0000FF, storeInteriorCoordinates[x][InteriorX], storeInteriorCoordinates[x][InteriorY], storeInteriorCoordinates[x][InteriorZ], 10.00, .interiorid = storeInteriorCoordinates[x][InteriorID], .worldid = storeInteriorCoordinates[x][worldid]);
	}

	for(new i = 0; i < sizeof(ATMobjectPos); i++)
	{
	ATMobj[i] = CreateDynamicObject(ATMobjectPos[i][objID], ATMobjectPos[i][AtmX], ATMobjectPos[i][AtmY], ATMobjectPos[i][AtmZ], ATMobjectPos[i][AtmrX], ATMobjectPos[i][AtmrY],ATMobjectPos[i][AtmrZ]);
	}

	for(new x = 0; x < sizeof(SafeBody); x++)
	{
	StoreSafeBody[x] = CreateDynamicObject(19618, SafeBody[x][SafeX], SafeBody[x][SafeY], SafeBody[x][SafeZ], SafeBody[x][SafeRX], SafeBody[x][SafeRY], SafeBody[x][SafeRZ]);
	}

	for(new i = 0; i < sizeof(SafeMoney); i++)
	{
	StoreSafeMoney[i] = CreateDynamicObject(2005, SafeMoney[i][SafeX], SafeMoney[i][SafeY], SafeMoney[i][SafeZ], SafeMoney[i][SafeRX], SafeMoney[i][SafeRY], SafeMoney[i][SafeRZ]);
	}
	for(new x = 0; x < sizeof(SafeDoor); x++)
	{
	StoreSafeDoor[x] = CreateDynamicObject(2004, SafeDoor[x][SafeX], SafeDoor[x][SafeY], SafeDoor[x][SafeZ], SafeDoor[x][SafeRX], SafeDoor[x][SafeRY], SafeDoor[x][SafeRZ]);
	}



	AddStaticVehicle(411,-1226.9730,-453.3592,14.8802,180.2217,3,1); //
	AddStaticVehicle(402,-1226.8340,-461.4283,14.9897,180.7013,3,1); //
	AddStaticVehicle(451,-1227.1622,-468.6017,14.8651,179.5992,3,1); //
	AddStaticVehicle(510,-1227.1292,-472.5562,14.7466,81.6371,3,1); //
	AddStaticVehicle(405,-1496.0353,911.5580,7.0625,89.0338,1,1); //
	AddStaticVehicle(439,-1495.8514,928.5759,7.0835,89.2314,4,9); //
	AddStaticVehicle(409,-1747.8363,945.1866,24.6833,269.3011,1,1); //
	AddStaticVehicle(409,-1762.6063,945.3637,24.6827,269.3012,1,1); //
	AddStaticVehicle(411,-1880.3451,832.5536,34.8104,269.8452,9,1); //
	AddStaticVehicle(402,-1990.1161,1046.9304,55.4736,269.2300,99,1); //
	AddStaticVehicle(426,-1972.4215,1109.8221,54.5104,0.5972,95,1); //
	AddStaticVehicle(448,-1802.0519,945.3403,24.4929,182.1477,3,6); //
	AddStaticVehicle(448,-1802.1663,948.1583,24.4878,182.1477,3,6); //
	AddStaticVehicle(413,-1995.9659,710.6469,45.4342,0.7432,69,1); //
	AddStaticVehicle(429,-2082.2856,714.3859,69.2422,0.1692,3,1); //
	//AddPlayerClass(155,-1921.0189,277.4795,41.0469,182.1432,0,0,0,0,0,0); //
	AddStaticVehicle(415,-1687.4786,982.9156,17.3570,268.1132,58,1); //
	AddStaticVehicle(562,-1687.9535,991.4496,17.2441,269.1697,29,1); //
	AddStaticVehicle(521,-1685.6855,999.5315,17.1275,270.5246,35,1); //
	AddStaticVehicle(459,-1736.2054,1020.4814,17.6336,268.8438,1,1); //
	AddStaticVehicle(560,-2620.5757,1377.8651,6.8435,178.6640,1,1); //
	AddStaticVehicle(401,-2626.2974,1378.1036,6.9201,178.8259,169,1); //
	AddStaticVehicle(412,-2633.5630,1377.2435,6.9698,178.9155,13,1); //
	AddStaticVehicle(463,-2642.3547,1378.9393,6.6936,174.4645,184,1); //
	AddStaticVehicle(586,-2647.2327,1379.1149,6.6912,180.0147,67,1); //
	AddStaticVehicle(562,-2539.2876,1229.5916,37.0815,206.1948,43,1); //
	AddStaticVehicle(400,-2530.3718,1229.4623,37.5206,211.7298,1,1); //
	AddStaticVehicle(560,-2521.5630,1229.0825,37.1768,211.8030,69,1); //
	AddStaticVehicle(418,-2501.6421,1222.2690,37.5196,142.4570,42,1); //
	AddStaticVehicle(421,-2494.8052,1216.7548,37.3043,144.6430,92,1); //
	AddStaticVehicle(580,-2442.1890,954.2448,45.0941,89.3576,96,1); //
	AddStaticVehicle(466,-2429.8201,954.3259,45.0391,88.8982,196,1); //
	AddStaticVehicle(579,-2379.1660,893.8798,45.2967,177.5213,64,1); //
	AddStaticVehicle(580,-2412.1831,741.3799,34.8116,358.9373,1,1); //
	AddStaticVehicle(411,-2421.0859,741.5087,34.7427,359.9658,32,1); //
	AddStaticVehicle(560,-2429.5415,741.2466,34.7652,358.9462,14,1); //
	AddStaticVehicle(567,-2438.4336,741.4517,34.8766,359.4591,57,1); //
	AddStaticVehicle(566,-2447.1909,741.3666,34.7938,357.2256,39,1); //
	AddStaticVehicle(451,-2455.8904,741.5881,34.6793,359.4606,92,1); //
	AddStaticVehicle(555,-2464.4688,741.4323,34.6990,0.1899,29,1); //
	AddStaticVehicle(541,-2473.3762,741.7214,34.6406,359.9133,13,1); //
	AddStaticVehicle(542,-2482.0435,741.5656,34.7590,359.8932,13,13); //
	AddStaticVehicle(536,-2491.0125,741.5215,34.7463,0.2235,29,28); //
	AddStaticVehicle(533,-2499.6970,741.2320,34.7314,359.7375,72,79); //
	AddStaticVehicle(534,-2508.1755,740.8548,34.7447,358.5726,22,1); //
	AddStaticVehicle(490,-2413.7263,539.7753,30.0704,90.0459,0,0); //
	AddStaticVehicle(427,-2413.6670,535.4655,30.0848,72.4970,0,1); //
	AddStaticVehicle(490,-2429.7476,515.5412,30.0633,36.2255,0,0); //
	AddStaticVehicle(490,-2425.7913,518.2285,30.0565,40.3755,0,0); //
	AddStaticVehicle(427,-2422.3618,521.5455,30.1562,41.9009,0,1); //
	AddStaticVehicle(427,-2419.1648,524.8397,30.1346,50.6432,0,1); //
	AddStaticVehicle(463,-2605.9302,203.1424,4.8533,12.5917,7,1); //
	AddStaticVehicle(463,-2596.1208,202.3708,5.2254,4.1160,13,1); //
	AddStaticVehicle(411,-2571.3464,139.6097,4.0630,324.4135,33,1); //
	AddStaticVehicle(500,-2621.7307,152.1193,4.3597,267.4549,13,13); //
	AddStaticVehicle(500,-2712.0159,118.9982,4.4336,180.0871,13,13); //
	AddStaticVehicle(420,-1445.0492,-282.1029,13.7800,64.7050,6,6); //
	AddStaticVehicle(420,-1436.9414,-286.7730,13.7802,58.4989,6,6); //
	AddStaticVehicle(420,-1426.9340,-293.7505,13.7777,52.4997,6,6); //
	AddStaticVehicle(519,-1332.9222,-625.3234,15.0642,356.2940,1,1); //
	AddStaticVehicle(519,-1274.0292,-619.7797,15.0700,357.1492,1,1); //
	AddStaticVehicle(519,-1362.4810,-487.2667,15.0911,202.7188,1,1); //
	AddStaticVehicle(519,-1435.8306,-530.7328,15.0911,206.2953,0,0); //
	AddStaticVehicle(487,-1140.5078,-373.0283,14.2000,46.5290,47,1); //
//	AddPlayerClass(299,-1136.2191,-360.8173,14.1484,91.6872,0,0,0,0,0,0); //
	AddStaticVehicle(487,-1136.1040,-360.8150,14.2052,116.4411,47,1); //
	AddStaticVehicle(487,-1155.0719,-363.3197,14.2242,248.7289,47,1); //
	AddStaticVehicle(411,-1257.5568,32.5222,13.8738,313.6928,63,25); //
	AddStaticVehicle(451,-1236.1018,34.5554,13.8514,43.5355,34,1); //
	AddStaticVehicle(405,-2265.6584,113.2660,35.0468,270.0313,1,1); //
	AddStaticVehicle(506,-2266.1289,105.5460,34.8762,269.4045,24,1); //
	AddStaticVehicle(518,-2267.3384,97.3070,34.8445,269.1849,24,1); //
	AddStaticVehicle(562,-2267.4155,89.4244,34.8309,267.6559,1,1); //
	AddStaticVehicle(571,-2212.2471,116.0259,34.6044,268.8634,1,1); //
	AddStaticVehicle(571,-2213.4736,112.9396,34.6263,266.1265,1,1); //
	AddStaticVehicle(571,-2214.1665,110.2699,34.6043,269.2664,1,1); //
	AddStaticVehicle(420,-1989.7202,160.7312,27.3185,359.6871,6,6); //
	AddStaticVehicle(420,-1989.7756,148.8507,27.3192,359.6871,6,6); //
	AddStaticVehicle(420,-1989.8301,137.7927,27.3187,359.6869,6,6); //
	AddStaticVehicle(567,-2457.5278,146.3102,34.8324,179.3989,33,1); //
	AddStaticVehicle(550,-2457.3074,162.2590,34.8045,177.5137,39,1); //
	AddStaticVehicle(545,-2456.9077,171.2646,34.8451,177.4569,29,1); //
	AddStaticVehicle(468,-2513.9446,-2.2114,25.2811,184.1331,3,1); //
	AddStaticVehicle(468,-2517.3044,-1.6293,25.2839,180.8486,3,1); //
	AddStaticVehicle(521,-2484.1741,59.8597,25.6609,356.6788,1,1); //
	AddStaticVehicle(524,-2106.0752,223.3873,35.6603,267.2165,1,1); //
	AddStaticVehicle(486,-2094.0034,232.8587,35.1752,304.1086,2,1); //
	AddStaticVehicle(522,-1986.8765,301.4904,34.7553,90.8942,6,15); //
	AddStaticVehicle(429,-1987.3444,306.9752,34.7813,87.6409,8,1); //
	AddStaticVehicle(522,-1989.0021,276.2999,34.7872,88.6688,3,1); //
	AddStaticVehicle(451,-1989.0377,269.8493,34.8807,86.8837,23,1); //
	AddStaticVehicle(603,-1989.3252,263.5957,35.0196,82.4872,3,1); //
	AddStaticVehicle(559,-1989.8574,256.4928,34.8282,78.5276,23,1); //
	AddStaticVehicle(560,-1991.0659,247.5739,34.8775,83.3218,24,1); //
	AddStaticVehicle(541,-1955.4753,258.3481,35.0942,88.6910,23,1); //
	AddStaticVehicle(411,-1953.0505,270.0688,35.1958,88.8450,217,1); //
	AddStaticVehicle(411,-2201.2300,293.5249,34.8443,179.0501,217,1); //
	AddStaticVehicle(562,-2192.6450,293.7127,34.7770,179.1274,222,1); //
	AddStaticVehicle(451,-2184.3970,293.6789,34.8247,178.7280,7,1); //
	AddStaticVehicle(451,-2657.7236,373.2253,3.9487,177.9161,7,1); //
	AddStaticVehicle(481,-2707.0886,388.6252,3.9068,38.5378,1,1); //
	AddStaticVehicle(481,-2704.7280,391.7165,3.9117,289.5824,1,1); //
	AddStaticVehicle(481,-2702.4954,395.2152,3.8814,24.8026,1,1); //
	AddStaticVehicle(481,-2700.7705,391.1472,3.8821,116.6792,1,1); //
	AddStaticVehicle(481,-2704.0889,385.4465,3.8812,149.4682,1,1); //
	AddStaticVehicle(567,-2754.7559,378.0894,4.0970,0.2413,1,1); //
	AddStaticVehicle(443,-1668.5822,435.4228,7.8121,227.1118,49,1); //
	AddStaticVehicle(443,-1654.8972,449.2369,7.8159,223.5661,49,1); //
	AddStaticVehicle(523,-1581.4382,650.8943,6.7579,178.2053,1,1); //
	AddStaticVehicle(523,-1587.7991,651.9760,6.7520,176.3254,1,1); //
	AddStaticVehicle(523,-1593.3512,652.0746,6.7555,176.2000,1,1); //
	AddStaticVehicle(599,-1616.7136,651.7018,7.3753,178.6272,0,1); //
	AddStaticVehicle(599,-1622.3540,651.8090,7.2475,181.5725,0,1); //
	AddStaticVehicle(597,-1588.0590,673.6343,6.9555,178.9639,0,1); //
	AddStaticVehicle(597,-1594.1161,673.4930,6.9570,179.4605,0,1); //
	AddStaticVehicle(597,-1600.4742,673.4494,6.9563,179.5964,0,1); //
	AddStaticVehicle(597,-1620.6718,692.1493,-5.4733,178.4779,0,1); //
	AddStaticVehicle(597,-1616.4326,691.4327,-5.4760,179.7413,0,1); //
	AddStaticVehicle(597,-1612.6556,693.4094,-5.4817,178.1348,0,1); //
	AddStaticVehicle(490,-1574.0886,718.2511,-5.1148,269.6714,0,0); //
	AddStaticVehicle(490,-1573.8309,722.3046,-5.1210,268.8421,0,0); //
	AddStaticVehicle(490,-1573.0400,726.7151,-5.1165,269.4498,0,0); //
	AddStaticVehicle(523,-1587.9742,749.0366,-5.6934,0.1852,1,1); //
	AddStaticVehicle(523,-1592.4961,749.0361,-5.6902,359.5022,1,1); //
	AddStaticVehicle(523,-1596.3771,748.9084,-5.6692,1.6228,1,1); //
	AddStaticVehicle(541,-1929.2896,585.2320,34.7510,0.1682,23,1); //
	AddStaticVehicle(560,-1935.3577,585.1490,34.8302,359.4544,24,1); //
	AddStaticVehicle(527,-1941.3403,585.1596,34.8357,0.2957,7,1); //
	AddStaticVehicle(536,-1947.4164,585.8734,34.8492,0.7580,27,1); //
	AddStaticVehicle(540,-1953.4052,585.3298,34.9800,359.0664,49,1); //
	AddStaticVehicle(546,-1959.3298,585.0941,34.8405,359.2857,69,1); //
	AddStaticVehicle(416,-2639.3669,623.7687,14.6025,267.3420,1,3); //
	AddStaticVehicle(416,-2652.7656,624.2888,14.6021,270.9123,1,3); //
	AddStaticVehicle(416,-2661.9385,624.1489,14.6010,270.9301,1,3); //
	AddStaticVehicle(446,-2050.0913,1348.8267,-0.5275,359.3021,1,1); //
	AddStaticVehicle(446,-2035.1456,1345.4303,-0.5923,356.8064,1,1); //
	AddStaticVehicle(560,-2689.9390,-54.6144,4.0414,178.4471,24,1); //
	AddStaticVehicle(468,-2683.1387,-54.6369,4.0158,177.8666,3,1); //
	AddStaticVehicle(562,-2676.7314,-54.8530,3.9954,179.4517,29,1); //
	AddStaticVehicle(411,-2669.8386,-54.7255,4.0632,179.2752,23,1); //
	AddStaticVehicle(400,-2660.0386,-54.9379,4.4311,179.5060,1,1); //
	AddStaticVehicle(506,-2340.8674,-125.6161,35.0188,359.6489,26,1); //
	AddStaticVehicle(429,-2333.6223,-125.8792,34.9921,0.8123,69,1); //


	return 1;
	}




public OnPlayerEnterDynamicCP(playerid, checkpointid)
{

    {
    if(AntiSpam[playerid]-gettime() > 0)
    {
        return 0;
    }
    AntiSpam[playerid] = gettime() + 3; // cooldown (anti command spam)
  //  return 1;
}



	for(new i = 0; i < sizeof(StoreInteriorCP); i++)
	{
	    if(checkpointid == StoreInteriorCP[i])
	    {
	        SetPlayerPos(playerid, storeExteriorCoordinates[i][ExteriorX], storeExteriorCoordinates[i][ExteriorY], storeExteriorCoordinates[i][ExteriorZ]);
	        SetPlayerInterior(playerid, 0);
	        SetPlayerVirtualWorld(playerid, 0);
	    }
	}

	for(new x = 0; x < sizeof(StoreExteriorCP); x++)
	{
	    if(checkpointid == StoreExteriorCP[x])
	    {
	        SetPlayerPos(playerid, storeInteriorCoordinates[x][InteriorX], storeInteriorCoordinates[x][InteriorY], storeInteriorCoordinates[x][InteriorZ]);
	        SetPlayerInterior(playerid, storeInteriorCoordinates[x][InteriorID]);
	        SetPlayerVirtualWorld(playerid, storeInteriorCoordinates[x][worldid]);
	    }
	}



	//MUTE TIMER
	SetTimer("Update", 1000, true);
//	SetTimer("UpdateXP", 1000, true);
//	SetTimer("UpdateWanteds", 1000, true);
	return 1; //ye RUNTIME ERROR 20 kyu ata hai?
}


public OnGameModeExit()
{
  	mysql_close();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, -1951.571289, 719.238464, 46.562500);
	SetPlayerCameraPos(playerid, -1951.235961, 732.070190, 48.020900);
	SetPlayerFacingAngle(playerid, 0);
	SetPlayerCameraLookAt(playerid, -1951.571289, 719.238464, 46.562500);
	ApplyAnimation(playerid, "CAMERA", "camcrch_cmon", 4.1, 1, 1, 1, 1, 1, 1);
	ApplyAnimation(playerid, "CAMERA", "camcrch_cmon", 4.1, 1, 1, 1, 1, 1, 1);




	switch(classid)
	{

 		case 0..49: gTeam[playerid] = TEAM_CIVILIAN; // do the rest and then tell me ok
		case 50..52: gTeam[playerid] = TEAM_FBI;
		case 53: gTeam[playerid] = TEAM_ARMY;
		case 54..56: gTeam[playerid] = TEAM_CIA;
		case 57..59: gTeam[playerid] = TEAM_FIREMAN;
		case 60..63: gTeam[playerid] = TEAM_MEDIC;
		case 64..71: gTeam[playerid] = TEAM_POLICE;


	}

	showSelectionTDForTeam(playerid, gTeam[playerid]);



	return 1;
	//dafuq
}


public OnPlayerConnect(playerid) // So player just connected ,you want to check if he is regis
{
	new name[24];
	GetPlayerName(playerid, name, 24);
	SendDeathMessage(playerid, INVALID_PLAYER_ID, 200);
	SendClientMessage(playerid, -1, "{FF0000}[WARNING] {FFFFFF}This server contains explicit content, play at your own risk.");
	new query[128];
	format(query, 128, "SELECT *  FROM `playerdata` WHERE `Username` = '%s'", name); //thx for the clarification buddy
	mysql_tquery(dbHandle, query, "OnPlayerRegisterCheck", "d", playerid);
	
	
	
//	new qname[24]; GetPlayerName(playerid, name, 24);
    for(new i, j=MAX_OBJECTS; i<j; i++) { oInfo[playerid][i][used1] = false; }
    new qquery[100]; mysql_format(1, qquery, sizeof(qquery), "SELECT `%e` FROM `%e` WHERE `%e` = '%e' LIMIT 1", MYSQL_ID_FIELDNAME, MYSQL_USERS_TABLE, MYSQL_NAME_FIELDNAME, name);
	mysql_tquery(1, query, "LoadPlayerID", "i", playerid);
	
	
	

	XPBarTD[playerid] = CreatePlayerTextDraw(playerid, 582.399719, 433.413482, "000000");
    PlayerTextDrawLetterSize(playerid, XPBarTD[playerid], 0.217200, 1.343066);
    PlayerTextDrawTextSize(playerid, XPBarTD[playerid], 295.000000, 0.250000);
    PlayerTextDrawAlignment(playerid, XPBarTD[playerid], 1);
    PlayerTextDrawColor(playerid, XPBarTD[playerid], -1378294017);
    PlayerTextDrawSetShadow(playerid, XPBarTD[playerid], 0);
    PlayerTextDrawBackgroundColor(playerid, XPBarTD[playerid], 255);
    PlayerTextDrawFont(playerid, XPBarTD[playerid], 3);
    PlayerTextDrawSetProportional(playerid, XPBarTD[playerid], 0);


    new lvl[9];
	format(lvl, sizeof(lvl), "%d", pInfo[playerid][pWanted]);
	WLvlTD[playerid] = CreatePlayerTextDraw(playerid, 548.800109, 123.297790, lvl); //for wanted level displaying
	PlayerTextDrawLetterSize(playerid, WLvlTD[playerid], 0.396799, 1.838933);
	PlayerTextDrawTextSize(playerid, WLvlTD[playerid], -7.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, WLvlTD[playerid], 1);
	PlayerTextDrawColor(playerid, WLvlTD[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, WLvlTD[playerid], -1);
	PlayerTextDrawSetOutline(playerid, WLvlTD[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, WLvlTD[playerid], 255);
	PlayerTextDrawFont(playerid, WLvlTD[playerid], 2);
	PlayerTextDrawSetProportional(playerid, WLvlTD[playerid], 1);

/*	wStars[playerid] = CreatePlayerTextDraw(playerid, 578.401123, 123.297912, "[]    []");
	PlayerTextDrawLetterSize(playerid, wStars[playerid], 0.355600, 2.048001);
	PlayerTextDrawTextSize(playerid, wStars[playerid], -225.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, wStars[playerid], 3);
	PlayerTextDrawColor(playerid, wStars[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, wStars[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, wStars[playerid], 255);
	PlayerTextDrawFont(playerid, wStars[playerid], 0);
	PlayerTextDrawSetProportional(playerid, wStars[playerid], 1);*/

	wLvlStars[playerid] = CreatePlayerTextDraw(playerid, 492.801116, 99.302291, "[][][][][][]");
	PlayerTextDrawLetterSize(playerid, wLvlStars[playerid], 0.309600, 2.192178);
	PlayerTextDrawTextSize(playerid, wLvlStars[playerid], -111.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, wLvlStars[playerid], 1);
	PlayerTextDrawColor(playerid, wLvlStars[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, wLvlStars[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, wLvlStars[playerid], 255);
	PlayerTextDrawFont(playerid, wLvlStars[playerid], 0);
	PlayerTextDrawSetProportional(playerid, wLvlStars[playerid], 1);


	PlayerTextDrawShow(playerid, wLvlStars[playerid]);
	PlayerTextDrawShow(playerid, WLvlTD[playerid]);

	//************************L O C A T I O N    T E X T D R A W S*****************************

	new zone[MAX_ZONE_NAME], str[16];
	GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
	format(str, sizeof(str), "%s", zone);
	LocationTD = CreatePlayerTextDraw(playerid, 67.200004, 323.802215, str);
	PlayerTextDrawLetterSize(playerid, LocationTD, 0.243999, 0.898134);
	PlayerTextDrawAlignment(playerid, LocationTD, 1);
	PlayerTextDrawColor(playerid, LocationTD, -1378294017);
	PlayerTextDrawSetShadow(playerid, LocationTD, 288);
	PlayerTextDrawSetOutline(playerid, LocationTD, 1);
	PlayerTextDrawBackgroundColor(playerid, LocationTD, 255);
	PlayerTextDrawFont(playerid, LocationTD, 2);
	PlayerTextDrawSetProportional(playerid, LocationTD, 1);




	//*****************************ROBBERY TEXTDRAWS*******************************************


    Robbery[playerid][0] = CreatePlayerTextDraw(playerid, 283.199920, 182.533325, "ROBBERY_IN_PROGRESS");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][0], 0.170799, 1.206755);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][0], 361.000000, 9.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][0], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][0], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][0], 255);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][0], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][0], 1);

	Robbery[playerid][1] = CreatePlayerTextDraw(playerid, 284.399963, 184.524505, "`");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][1], 0.369199, 0.758754);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][1], 360.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][1], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][1], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][1], -2139094785);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][1], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][1], 1);

	Robbery[playerid][2] = CreatePlayerTextDraw(playerid, 284.400238, 184.026626, "`");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][2], 0.404399, 0.843376);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][2], 293.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][2], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][2], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][2], -65281);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][2], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][2], 3);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][2], 1);

	Robbery[playerid][3] = CreatePlayerTextDraw(playerid, 296.000305, 184.026580, "`");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][3], 0.404399, 0.843376);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][3], 306.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][3], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][3], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][3], -65281);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][3], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][3], 3);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][3], 1);

	Robbery[playerid][4] = CreatePlayerTextDraw(playerid, 308.400299, 184.026641, "`");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][4], 0.404399, 0.843376);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][4], 322.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][4], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][4], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][4], -65281);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][4], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][4], 3);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][4], 1);

	Robbery[playerid][5] = CreatePlayerTextDraw(playerid, 325.200317, 184.026641, "`");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][5], 0.404399, 0.843376);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][5], 343.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][5], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][5], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][5], -65281);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][5], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][5], 3);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][5], 1);

	Robbery[playerid][6] = CreatePlayerTextDraw(playerid, 345.600158, 184.026641, "`");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][6], 0.404399, 0.843376);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][6], 360.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][6], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][6], -65281);
	PlayerTextDrawUseBox(playerid, Robbery[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, Robbery[playerid][6], -65281);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][6], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][6], 3);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][6], 1);

	Robbery[playerid][7] = CreatePlayerTextDraw(playerid, 290.000427, 183.528945, "ROBBED");
	PlayerTextDrawLetterSize(playerid, Robbery[playerid][7], 0.404399, 0.843376);
	PlayerTextDrawTextSize(playerid, Robbery[playerid][7], 354.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Robbery[playerid][7], 1);
	PlayerTextDrawColor(playerid, Robbery[playerid][7], -2139094785);
	PlayerTextDrawSetShadow(playerid, Robbery[playerid][7], 1);
	PlayerTextDrawSetOutline(playerid, Robbery[playerid][7], 1);
	PlayerTextDrawBackgroundColor(playerid, Robbery[playerid][7], 255);
	PlayerTextDrawFont(playerid, Robbery[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, Robbery[playerid][7], 1);











	return 1;
}

forward OnPlayerRegisterCheck(playerid);
public OnPlayerRegisterCheck(playerid)
{
	new rows = 0;
	rows = cache_get_row_count();

	if(!rows) // player is not register
	{
	    // Put show player dialog code for registration
	    new lName[24], lquery[456];
	    GetPlayerName(playerid, lName, 24);
	    format(lquery, 456, "{FFFFFF}Welcome to San Fierro Cops and Robbers. The account{FF0000} (%s){FFFFFF} is NOT registered.\t\n\n\nPlease register by entering your password.\t\n\n\n{696969}Please make sure you read all the server rules(/rules) before playing.", lName);
	    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "REGISTER TO SAN FIERRO COPS AND ROBBERS", lquery, "REGISTER", "QUIT");  //is it fine?
	    return 1;
	}

	else
	{
		new lName[24], lquery[456];
		GetPlayerName(playerid, lName, 24);
		format(lquery, 456, "{FFFFFF}Welcome to San Fierro Cops and Robbers. The account {00FF00}(%s){FFFFFF} is registered.\t\n\n\nPlease log-in by entering your password.\t\n\n\n{696969}If this account does not belong to you, please leave and join with a new nickname.", lName);
		//format(lquery, 1024, "", lName);
		//format(lquery, 1024, "");
		//format(lquery, 1024, "");
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Account - Authentication", lquery, "LOG-IN", "QUIT");
	//onplayerdialogresponse now?? vbase??? dayum
	}

	return 1;
}




public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	print("test");
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			print("test2");
			if(!response)
				return Kick(playerid);
			print("test2");
			if(response)
				{
				 print("test3");
				 if(!strlen(inputtext))
				 {
				 new lquery[456], lName[24];
				 GetPlayerName(playerid, lName, 24);
                 format(lquery, 456, "{FFFFFF}Welcome to San Fierro Cops and Robbers. The account{FF0000} (%s){FFFFFF} is NOT registered.\t\n\n\nPlease register by entering your password.\t\n\n\n{696969}Please make sure you read all the server rules(/rules) before playing.", lName);
				 return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Account-Registration", lquery, "REGISTER", "QUIT");
				 }
				 else
				 {
				    new query[320];
				    new lName[24];
				    new hash[129]; //i saw that from serverlog.txt and editted it to 1024..
				    GetPlayerName(playerid, lName, 24);
				    GetPlayerName(playerid, lName, 24);
				    WP_Hash(hash, 129, inputtext); // hash isn't a requirement, althouhgh, it is good practie to  hide player passwords what hash is this? to decode it..CreateActor this hash cannot be decoded lol.. to change pw?m thats for later
				    format(query, 320, "INSERT INTO `playerdata` (`username`, `password`, `pjobselected`, `wated`) VALUES ('%s', '%s', '0', '0')", lName, hash);

				    print(query);
				    // see here we are inserting ito databse and we are telling it the user name and password
				    // if we dont tell it here then the database will just put no_name and no_password, get it? yeah
					mysql_tquery(dbHandle, query);
					SendClientMessage(playerid, -1, "{FFFF00}[INFO] {FFFFFF}You've successfully registered at San Fierro Cops and Robbers");


		    	 }
		    	 }
				//print("test4");

		}

		case DIALOG_LOGIN:
		 {
			if(!response)
				return Kick(playerid);

			if(response)
			{

			new  lName[24];
			GetPlayerName(playerid, lName, 24);

			//else

		 	if(!strlen(inputtext))
			{
			    new lquery[456];

				format(lquery, 456, "{FFFFFF}Welcome to San Fierro Cops and Robbers. The account {00FF00}(%s){FFFFFF} is registered.\t\n\n\nPlease log-in by entering your password.\t\n\n\n{696969}If this account does not belong to you, please leave and join with a new nickname.", lName);
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Account-Authentication", lquery, "LOG-IN", "QUIT");

			//	return 1;
			}

			new hash[129];
			WP_Hash(hash, 129, inputtext);

			new query[256];
			format(query, 256, "SELECT * FROM `playerdata` WHERE `username` = '%s' AND `password` = '%s'", lName, hash); //isnt it lName
		    mysql_tquery(dbHandle, query, "OnPlayerTryLogin", "d", playerid);
		}
		} // this is why taab is so important, ur code has missing brackets and they are hard to find



			case DIALOG_CHANGEPW:
		{
		if(!response)
		return SendClientMessage(playerid, -1, "{FFFF00}[INFO]{FFFFFF} You cancelled the step of changing your password.");


		if(response)
		{
		new lName[24];
		GetPlayerName(playerid, lName, 24);

		if(!strlen(inputtext))
		{
		new lquery[128];
		SendClientMessage(playerid, -1, "{FFFF00}Please enter a valid password, or your password will not be changed.\n\n");
		ShowPlayerDialog(playerid, DIALOG_CHANGEPW, DIALOG_STYLE_PASSWORD, "Change-Password", lquery, "CHANGE", "EXIT");
		}
		else
		{
		new hash[129], query[320];
        WP_Hash(hash, 129, inputtext); // hash isn't a requirement, althouhgh, it is good practie to  hide player passwords what hash is this? to decode it..CreateActor this hash cannot be decoded lol.. to change pw?m thats for later
		//format(query, 320, "UPDATE INTO `playerdata` WHERE `password` = '%s'", hash);
		format(query, 320, "UPDATE `playerdata` SET `password` = '%s' WHERE `username` = '%s';", hash, lName);
		mysql_tquery(dbHandle, query);
		}
		}
		}
		
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
	if(dialogid == DIALOG_JOB)
		{
		if(!response)
	 	return ShowPlayerDialog(playerid, DIALOG_JOB, DIALOG_STYLE_LIST, "JOB", "RAPIST\nKIDNAPPER\nTERRORIST\nHITMAN\nPROSTITUTE\nWEAPON DEALER\nDRUG DEALER\nDIRTY MECHANIC", "OK", "OK");

		if(listitem == 0)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_RAPIST;

		}
		if(listitem == 1)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_KIDNAPPER;
		}
		if(listitem == 2)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_TERRORIST;
		}
		if(listitem == 3)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_HITMAN;
		}
		if(listitem == 4)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_PROSTITUTE;
		}
		if(listitem == 5)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_WEAPONDEALER;
		}
		if(listitem == 6)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_DRUGDEALER;
		}
		if(listitem == 7)
		{
		pInfo[playerid][pJobSelected] = 1;
		pInfo[playerid][pJob] = JOB_DIRTYMECHANIC;
		}
		new query[128], jName[24];
		GetPlayerName(playerid, jName, 24);
		format(query, sizeof(query), "UPDATE `playerdata` SET `pjobselected` = '1' WHERE `username` = '%s'", jName);
		mysql_tquery(dbHandle, query);

		}

	if(dialogid == DIALOG_SHOP)

		{
//Ropes, Scissors, Bobby Pins, Metal Melters, MoneyBag
		if(response)
		{
		if(listitem == 0)
		{
		ShowPlayerDialog(playerid, DIALOG_SHOP_ROPE, DIALOG_STYLE_LIST, "ROPES", "{FFFFFF}1 Rope\t\t{00FA9A}$1299{FFFFFF}\n5 Ropes\t{00FA9A}$5999{FFFFFF}\nMax Ropes(25 Ropes)\t {00FA9A}$27999", "BUY", "CANCEL");
		}
		if(listitem == 1)
		{
        ShowPlayerDialog(playerid, DIALOG_SHOP_SCISSOR, DIALOG_STYLE_LIST, "Scissors", "{FFFFFF}1 Scissor\t\t{00FA9A}$1499{FFFFFF}\n5 Scissors\t{00FA9A}$7299{FFFFFF}\nMax Scissors(25 Scissors)\t {00FA9A}$29999", "BUY", "CANCEL");
		}
		if(listitem == 2)
		{
        ShowPlayerDialog(playerid, DIALOG_SHOP_BOBBYPINS, DIALOG_STYLE_LIST, "Bobby Pins", "{FFFFFF}1 Bobby Pin\t\t{00FA9A}$1699{FFFFFF}\n5 Bobby Pins\t{00FA9A}$8669{FFFFFF}\nMax Bobby Pins(25 Bobby Pins)\t {00FA9A}$32999", "BUY", "CANCEL");
		}
		if(listitem == 3)
		{
        ShowPlayerDialog(playerid, DIALOG_SHOP_BOBBYPINS, DIALOG_STYLE_LIST, "Metal Melters", "{FFFFFF}1 Metal Melter\t\t{00FA9A}$7499{FFFFFF}\n3 Metal Melters\t{00FA9A}$20999{FFFFFF}\nMax Metal Melters(7 Metal Melters)\t {00FA9A}$42999", "BUY", "CANCEL");
		}
		if(listitem == 4)
		{
		pItems[playerid][pMoneyBag] = true;
		}
		}
		}




	return 1;
}

forward OnPlayerTryLogin(playerid);
public OnPlayerTryLogin(playerid)
{

	new rows = 0;
	rows = cache_get_row_count();

	if(!rows) // player entered wrong password
	{
	    new lquery[456]; // Can you not fuck around when i am doing stuff? hard for me :#

		pInfo[playerid][pLoginAttempts] ++;

		if(pInfo[playerid][pLoginAttempts] >= 3)
		{
		    Kick(playerid);
		    return 1;
		}
		new lName[24];
		GetPlayerName(playerid, lName, 24);
		format(lquery, 456, "{FFFFFF}Welcome to San Fierro Cops and Robbers. The account {00FF00}(%s){FFFFFF} is registered.\t\n\n\nPlease log-in by entering your password.\t\n\n\n{696969}If this account does not belong to you, please leave and join with a new nickname.", lName);
  		//format(lquery, 128, "Welcome back to San Fierro Cops and Robbers %s\n If this account does not belong to you, please quit and register with a new name.\n{FF0000}The password you entered was incorrect.", lName);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "LOGIN TO SAN FIERRO COPS AND ROBBERS", lquery, "LOG-IN", "QUIT");
		return 1;
	}

	else // account is there and right password entered
	{
	    pInfo[playerid][pLoggedIn] = 1;
	    SendClientMessage(playerid, -1, "{FFFF00}[INFO] {FFFFFF}You've successfully logged into your account.");
	    new score  = cache_get_field_content_int(0, "score");
	    SetPlayerScore(playerid, score);
		pInfo[playerid][pJobSelected] = cache_get_field_content_int(0, "pjobselected");
		pInfo[playerid][pJob] = cache_get_field_content_int(0, "pjob");
	    pInfo[playerid][pDBID] = cache_get_field_content_int(0, "id");
	    pInfo[playerid][pKills] = cache_get_field_content_int(0, "kills");
	    pInfo[playerid][pDeaths] = cache_get_field_content_int(0, "deaths");
	    pInfo[playerid][pAdmin] = cache_get_field_content_int(0, "admin");
	    pInfo[playerid][pVIP] = cache_get_field_content_int(0, "VIP");
	    pInfo[playerid][pWanted] = cache_get_field_content_int(0, "wanted");
	    new money = cache_get_field_content_int(0, "money");
	    GivePlayerMoney(playerid, money);
		//Now, cache_get_field_int is used to fetch integer data? yea oke.. if u want to fetch other data.. there is float
	  //ok.. also if u want to fetch string u just use cache_get_field_content
/*		new string[128];//but username is max of 24 chars.. why 128? this is just an example, we dont even need to fetch username as the playername is already username,ikr
	    cache_get_field_content(0, "username", string); keep this just for example
	    also, if i ever forget anything, it will help me remember, dont delete this*/
 	}
	return 1;
}

// this is iur basic login register system..CreateActor althouhgh it wont save data yet.. so that is just one more step
public OnPlayerDisconnect(playerid, reason)
{

    SendDeathMessage(playerid, INVALID_PLAYER_ID, 201);
 	if(pInfo[playerid][pLoggedIn] == 1)
	{
		new score = GetPlayerScore(playerid);
		new money = GetPlayerMoney(playerid);
	    new query[256];
	    format(query, 256, "UPDATE `playerdata` SET `score` = '%d', `kills` = '%d', `deaths` = '%d', `admin` = '%d', `pXP` = '%s' `VIP` = '%d', `money` = '%d', `pjobselected` = '1', `pjob` ='%d', `wanted` = '%d' WHERE `id` = '%d'", score, pInfo[playerid][pKills], pInfo[playerid][pDeaths], pInfo[playerid][pAdmin], pInfo[playerid][pXP], pInfo[playerid][pVIP], money, pInfo[playerid][pJob], pInfo[playerid][pWanted], pInfo[playerid][pDBID]);
		mysql_tquery(dbHandle, query); // thats it
	}
	pInfo[playerid][pLoginAttempts] = 0;
	pInfo[playerid][pLoggedIn] = 0;
	pInfo[playerid][pWarns] = 0;

	//*********@@@@@@@@@@ S P E C T A T I O N     R E L A T E D    C O D E @@@@@@@@@@@@*************

	if(IsBeingSpeced[playerid] == 1)//If the player being spectated, disconnects, then turn off the spec mode for the spectator.
	{
	    foreach(Player,i)
	    {
	    	if(spectatorid[i] == playerid)
			{
				TogglePlayerSpectating(i,false);// This justifies what's above, if it's not off then you'll be either spectating your connect screen, or somewhere in blueberry (I don't know why)
			}
		}
	}




	return 1;



}

public OnPlayerSpawn(playerid)
{

	hideSelectionTDs(playerid);
	SetPlayerVirtualWorld(playerid, 0);

	if(gTeam[playerid] == TEAM_FBI)
	{
	new Random = random(sizeof(teamFBIspawns));
	SetPlayerPos(playerid, teamFBIspawns[Random][0], teamFBIspawns[Random][1], teamFBIspawns[Random][2]);
	SetPlayerColor(playerid, 385941503);
	}

	if(gTeam[playerid] == TEAM_CIA)
	{
	new Random = random(sizeof(teamCIAspawns));
	SetPlayerPos(playerid, teamCIAspawns[Random][0], teamCIAspawns[Random][1], teamCIAspawns[Random][2]);
	SetPlayerColor(playerid, 0x4F325D00);

	}
	if(gTeam[playerid] == TEAM_ARMY)
	{
	new Random = random(sizeof(teamArmyspawns));
	SetPlayerPos(playerid, teamArmyspawns[Random][0], teamArmyspawns[Random][1], teamArmyspawns[Random][2]);
	SetPlayerColor(playerid, 639443043);
	}
	if(gTeam[playerid] == TEAM_FIREMAN)
	{
	new Random = random(sizeof(teamFiremanspawns));
	SetPlayerPos(playerid, teamFiremanspawns[Random][0], teamFiremanspawns[Random][1], teamFiremanspawns[Random][2]);
	SetPlayerColor(playerid, 2116297983);
	}
	if(gTeam[playerid] == TEAM_MEDIC)
	{
	new Random = random(sizeof(teamMedicspawns));
	SetPlayerPos(playerid, teamMedicspawns[Random][0], teamMedicspawns[Random][1], teamMedicspawns[Random][2]);
	SetPlayerColor(playerid, 1124008191);
	}
	if(gTeam[playerid] == TEAM_POLICE)
	{
	new Random = random(sizeof(teamCopspawns));
	SetPlayerPos(playerid, teamCopspawns[Random][0], teamCopspawns[Random][1], teamCopspawns[Random][2]);
	SetPlayerColor(playerid, 795526399);
	}
	if(gTeam[playerid] == TEAM_CIVILIAN)
	{
	new Random = random(sizeof(teamCivilspawns));
	SetPlayerPos(playerid, teamCivilspawns[Random][0], teamCivilspawns[Random][1], teamCivilspawns[Random][2]);
	SetPlayerColor(playerid, 255);

 	cache_get_field_content_int(0, "pjobselected", pInfo[playerid][pJobSelected]);

	if(pInfo[playerid][pJobSelected] == 0)
	{
	ShowPlayerDialog(playerid, DIALOG_JOB, DIALOG_STYLE_LIST, "JOB", "Rapist\nKidnapper\nTerrorist\nHitman\nProstitute\nWeapon Dealer\nDrug Dealer\nDirty Mechanic", "OK","");
	}
	}
	IsPlayerSpawned[playerid] = 1;


//	for(new i = 0; i < sizeof(TDEditor_PTD[playerid]); i++)
 //	PlayerTextDrawShow(playerid, TDEditor_PTD[playerid][i]);
 //	{
	//WANTED TDS AND XP TDS///
	//=============OBJECTS==============//
	
	for(new i,j=MAX_OBJECTS; i<j; i++)
	{ if(oInfo[playerid][i][used1] == true)
	SetPlayerAttachedObject(playerid, oInfo[playerid][i][index1], oInfo[playerid][i][modelid1], oInfo[playerid][i][bone1], oInfo[playerid][i][fOffsetX1], oInfo[playerid][i][fOffsetY1], oInfo[playerid][i][fOffsetZ1], oInfo[playerid][i][fRotX1], oInfo[playerid][i][fRotY1], oInfo[playerid][i][fRotZ1], oInfo[playerid][i][fScaleX1], oInfo[playerid][i][fScaleY1], oInfo[playerid][i][fScaleZ1]);
	}



	CurrentXP = CreatePlayerTextDraw(playerid, 581.999938, 427.440002, "CURRENT_XP");
	PlayerTextDrawLetterSize(playerid, CurrentXP, 0.190799, 0.878222);
	PlayerTextDrawTextSize(playerid, CurrentXP, -117.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, CurrentXP, 1);
	PlayerTextDrawColor(playerid, CurrentXP, -1378294017);
	PlayerTextDrawSetShadow(playerid, CurrentXP, 0);
	PlayerTextDrawBackgroundColor(playerid, CurrentXP, 255);
	PlayerTextDrawFont(playerid, CurrentXP, 3);
	PlayerTextDrawSetProportional(playerid, CurrentXP, 1);

/*	TDEditor_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 578.401123, 123.297912, "[]    []");
	PlayerTextDrawLetterSize(playerid, TDEditor_PTD[playerid][2], 0.355600, 2.048001);
	PlayerTextDrawTextSize(playerid, TDEditor_PTD[playerid][2], -225.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TDEditor_PTD[playerid][2], 3);
	PlayerTextDrawColor(playerid, TDEditor_PTD[playerid][2], -5963521);
	PlayerTextDrawSetShadow(playerid, TDEditor_PTD[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, TDEditor_PTD[playerid][2], 255);
	PlayerTextDrawFont(playerid, TDEditor_PTD[playerid][2], 0);
	PlayerTextDrawSetProportional(playerid, TDEditor_PTD[playerid][2], 1);

	TDEditor_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 492.801116, 99.302291, "[][][][][][]");
	PlayerTextDrawLetterSize(playerid, TDEditor_PTD[playerid][3], 0.309600, 2.192178);
	PlayerTextDrawTextSize(playerid, TDEditor_PTD[playerid][3], -111.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, TDEditor_PTD[playerid][3], 1);
	PlayerTextDrawColor(playerid, TDEditor_PTD[playerid][3], -5963521);
	PlayerTextDrawSetShadow(playerid, TDEditor_PTD[playerid][3], 1);
	PlayerTextDrawBackgroundColor(playerid, TDEditor_PTD[playerid][3], 255);
	PlayerTextDrawFont(playerid, TDEditor_PTD[playerid][3], 0);
	PlayerTextDrawSetProportional(playerid, TDEditor_PTD[playerid][3], 1);
*/





	//TextDrawShowForPlayer(playerid, TDEditor_PTD[playerid][0]);*/

 	PlayerTextDrawShow(playerid, XPBarTD[playerid]);
 	PlayerTextDrawShow(playerid, CurrentXP);

	if(pInfo[playerid][pWanted] <= 0)
	{
	PlayerTextDrawHide(playerid, WLvlTD[playerid]);
//	PlayerTextDrawShow(playerid, wStars[playerid]);
	PlayerTextDrawHide(playerid, wLvlStars[playerid]);
	}

	if(pInfo[playerid][pWanted] >= 6)
	{
	PlayerTextDrawShow(playerid, WLvlTD[playerid]);
//	PlayerTextDrawShow(playerid, wStars[playerid]);
	PlayerTextDrawShow(playerid, wLvlStars[playerid]);

	//***L O C A T I O N    T E X T D R A W***

	PlayerTextDrawShow(playerid, LocationTD);
	SetTimer("Update", 2000, true);  // For updating location textdraw, wanted level, xp every 2 second..

	//************** S P E C T A T I O N    R E L A T E D**************************
	if(IsSpecing[playerid] == 1)
	{
		SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// Remember earlier we stored the positions in these variables, now we're gonna get them from the variables.
		SetPlayerInterior(playerid,Inter[playerid]);//Setting the player's interior to when they typed '/spec'
		SetPlayerVirtualWorld(playerid,vWorld[playerid]);//Setting the player's virtual world to when they typed '/spec'
		IsSpecing[playerid] = 0;//Just saying you're free to use '/spec' again YAY :D
		IsBeingSpeced[spectatorid[playerid]] = 0;//Just saying that the player who was being spectated, is not free from your stalking >:D
	}



	}
	return 1;


}
forward Update(playerid);
public Update(playerid)
{   new str[24], zone[MAX_ZONE_NAME];
	GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
	format(str, sizeof(str), "%s", zone);
	PlayerTextDrawSetString(playerid, LocationTD, str);

	new XPs[15];
	format(XPs, 15, "%d", pInfo[playerid][pXP]);
	PlayerTextDrawSetString(playerid, XPBarTD[playerid], XPs);


	new wanteds[10];
	format(wanteds, sizeof(wanteds), "%d", pInfo[playerid][pWanted]);
	PlayerTextDrawSetString(playerid, WLvlTD[playerid], wanteds);

	if(pInfo[playerid][pWanted] > 6)
	return PlayerTextDrawShow(playerid, wLvlStars[playerid]);
	else
	PlayerTextDrawHide(playerid, wLvlStars[playerid]);

	return 1;
}


/*forward UpdateXP(playerid);
public UpdateXP(playerid)
{
	new xps[24], axp;
	format(xps, sizeof(xps), "%d", pInfo[playerid][pXP]);
	PlayerTextDrawSetString(playerid, XPBarTD, xps);
//	return 1;
{*/

public OnPlayerDeath(playerid, killerid, reason)
{
	IsPlayerSpawned[playerid] = 0;
	pInfo[playerid][pDeaths]++;
	PlayerTextDrawShow(playerid, LocationTD);
	pInfo[playerid][pWanted] = 0;
	{
	if(killerid != INVALID_PLAYER_ID)
	{
	pInfo[killerid][pKills]++;
 	pInfo[killerid][pXP] = pInfo[killerid][pXP] + 10;
 	pInfo[killerid][pWanted] = pInfo[killerid][pWanted] + 12;
 	PlayerTextDrawShow(playerid, LocationTD);
	}  //Invalid player id predefined h kya scripting me? ya defi
 	else
	SendDeathMessage(playerid, INVALID_PLAYER_ID, 255);
	}
	//*************** S P E C T A T I O N    R E L A T E D*******************


	if(IsBeingSpeced[playerid] == 1)//If the player being spectated, dies, then turn off the spec mode for the spectator.
	{
	    foreach(Player,i)
	    {
	    	if(spectatorid[i] == playerid)
			{
				TogglePlayerSpectating(i,false);// This justifies what's above, if it's not off then you'll be either spectating your connect screen, or somewhere in blueberry (I don't know why)
			}
		}
	}











	return 1;
}
//store cps mennz kaise banane hn? i made one.. that could be the reason // erm update streamer include and plugin.. it may not load then.. i can try
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{ //streamer failed :/cant continue without this...
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{

if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)// If the player's state changes to a vehicle state we'll have to spec the vehicle.
	{
		SetPlayerArmedWeapon(playerid, 0);
		if(IsBeingSpeced[playerid] == 1)//If the player being spectated, enters a vehicle, then let the spectator spectate the vehicle.
		{
	    	foreach(Player,i)
	    	{
	    		if(spectatorid[i] == playerid)
				{
					PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));// Letting the spectator, spectate the vehicle of the player being spectated (I hope you understand this xD)
				}
			}
		}
	}
if(newstate == PLAYER_STATE_ONFOOT)
	{
		if(IsBeingSpeced[playerid] == 1)//If the player being spectated, exists a vehicle, then let the spectator spectate the player.
		{
		    foreach(Player,i)
		    {
		    	if(spectatorid[i] == playerid)
				{
					PlayerSpectatePlayer(i, playerid);// Letting the spectator, spectate the player who exited the vehicle.
				}
			}
		}
	}

if(newstate==PLAYER_STATE_PASSENGER)
{
    if(GetPlayerWeapon(playerid) == 24 || 25 || 26 || 27 || 33 || 34 ||  35 || 36 || 37 )
    {
		SetPlayerArmedWeapon(playerid, 0);
	}
}


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



		if(gTeam[playerid] == TEAM_FBI && pInfo[playerid][pXP] <= 9999)
		{
	    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient XP to join this class.");
	    return 0;
		}



		if(gTeam[playerid] == TEAM_CIA && pInfo[playerid][pXP] <= 14999)
		{
	    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient XP to join this class.");
	    return 0;
		}




		if(gTeam[playerid] == TEAM_ARMY && pInfo[playerid][pXP] <= 19999)
		{
	    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient XP to join this class.");
	    return 0;
		}



		if(gTeam[playerid] == TEAM_FIREMAN && pInfo[playerid][pXP] <= 1999)
		{
	    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient XP to join this class.");
	    return 0;
		}



		if(gTeam[playerid] == TEAM_MEDIC && pInfo[playerid][pXP] <= 2999)
		{
	    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient XP to join this class.");
	    return 0;
		}


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
	if(IsBeingSpeced[playerid] == 1)//If the player being spectated, changes an interior, then update the interior and virtualword for the spectator.
	{
	    foreach(Player,i)
	    {
	    	if(spectatorid[i] == playerid)
			{
				SetPlayerInterior(i,GetPlayerInterior(playerid));
				SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(playerid));
			}
		}
	}
	return 1;
}

stock SetPlayerLookAt(playerid, Float:X, Float:Y) // Forum.sa-mp 'Write'dan aýntýdýr.
{
	new Float:Px, Float:Py, Float: Pa;
	GetPlayerPos(playerid, Px, Py, Pa);
	Pa = floatabs(atan((Y-Py)/(X-Px)));
	if (X <= Px && Y >= Py) Pa = floatsub(180, Pa);
	else if (X < Px && Y < Py) Pa = floatadd(Pa, 180);
	else if (X >= Px && Y <= Py) Pa = floatsub(360.0, Pa);
	Pa = floatsub(Pa, 90.0);
	if (Pa >= 360.0) Pa = floatsub(Pa, 360.0);
	SetPlayerFacingAngle(playerid, Pa);
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{

    new str[128];
	if(newkeys == KEY_WALK)
	{
	if(gTeam[playerid] == TEAM_CIVILIAN ||  TEAM_FIREMAN ||  TEAM_MEDIC)
 	{
 	new safeid = GetPlayerVirtualWorld(playerid);
 	if(SafeRecentlyRobbed[safeid] == 1)
	{
	format(str, 128, "{FF0000}[ERROR] {FFFFFF}This store has recently been robbed, please wait before robbing it again.");
	return SendClientMessage(playerid, -1, str);
	}
	if(SafeBeingRobbed[playerid] == 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You're already robbing a safe.");

	for(new i = 0; i < sizeof(StoreSafeMoney); i++)
	{



	if (IsPlayerInRangeOfPoint(playerid, 2.0, SafeMoney[i][SafeX], SafeMoney[i][SafeY], SafeMoney[i][SafeZ]))
    {
    SetPlayerLookAt(playerid, SafeMoney[i][SafeX], SafeMoney[i][SafeY]);
	ClearAnimations(playerid);
	SetTimer("RobberyStart", 0, false);
	}
	}
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You cannot rob stores or perform any crime as a Law Enforcement Officer.");
	}

	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(GetPVarInt(playerid,"XP") != pInfo[playerid][pXP])
    {
        new ster[15]; format(ster,sizeof(ster),"%5d",pInfo[playerid][pXP]);
        PlayerTextDrawSetString(playerid,XPBarTD[playerid],ster);
        SetPVarInt(playerid,"XP",pInfo[playerid][pXP]);
		new query[128], name[24];
		GetPlayerName(playerid, name, 24);
		format(query, sizeof(query), "UPDATE `playerdata` SET `pXP` = '%d' WHERE `username` = '%s'", pInfo[playerid][pXP], name);
		mysql_tquery(dbHandle, query);
    }
/*
    if(GetPVarInt(playerid,"Wanted") != pInfo[playerid][pWanted])
    {
        new wlvl[9];
		format(wlvl, 9, "%d", pInfo[playerid][pWanted]);
        PlayerTextDrawSetString(playerid, WLvlTD[playerid], wlvl);
        SetPVarInt(playerid,"Wanted", pInfo[playerid][pWanted]);
		new query[128], name[24];
		GetPlayerName(playerid, name, 24);
		format(query, sizeof(query), "UPDATE `playerdata` SET `wanted` = '%d' WHERE `username` = '%s'", pInfo[playerid][pWanted], name);
		mysql_tquery(dbHandle, query);
    }
    */
    if(GetPVarInt(playerid,"Wanted") != pInfo[playerid][pWanted])
{
    new wlvl[9];
    format(wlvl, 9, "%d", pInfo[playerid][pWanted]);
    PlayerTextDrawSetString(playerid, WLvlTD[playerid], wlvl);
    SetPVarInt(playerid,"Wanted", pInfo[playerid][pWanted]);
    new query[128], name[24];
    GetPlayerName(playerid, name, 24);
    format(query, sizeof(query), "UPDATE `playerdata` SET `wanted` = '%d' WHERE `username` = '%s'", pInfo[playerid][pWanted], name);
    mysql_tquery(dbHandle, query);

    new starCount = 0, genTextStr[30];
    if(pInfo[playerid][pWanted] > 0)
	{
        format(genTextStr, sizeof genTextStr, "");
        for(new i = 0; i < pInfo[playerid][pWanted]; i++)
		{
            starCount++;
            if(starCount == 7)
			{
                break;
            }
            else {
                strcat(genTextStr, "[]", sizeof genTextStr);
            }
        }
        PlayerTextDrawSetString(playerid, wLvlStars[playerid], genTextStr);
    }

    if(pInfo[playerid][pWanted] == 0) {
        PlayerTextDrawSetString(playerid, wLvlStars[playerid], "");
    }
}



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

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}



public OnPlayerCommandReceived(playerid, cmdtext[])
{
    if(AntiSpam[playerid]-gettime() > 0)
    {
        SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You need to wait atleast one second before using any command again.");
        return 0;
    }
    AntiSpam[playerid] = gettime() + 1; // cooldown (anti command spam)
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success) SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You've entered an invalid command, please check /cmds for a list of commands.");
    return 1;
}



/*forward Wanteds();
public Wanteds()
{
     	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
     {
     //	new string[30];
     //	format(string, sizeof(string), "%00005d", pInfo[playerid][pXP]);
        new wlvl[9];
		format(wlvl, 9, "%d", pInfo[playerid][pWanted]);
        PlayerTextDrawSetString(playerid, WLvlTD[playerid], wlvl);
      // 	PlayerTextDrawShow(playerid, XPBar);
     }
     	return 1;
}*/












///_____________OTHER STUFF____________________






//lets start with class selection textdraw first? ok? or something else? do u have textdraws? yep

hideSelectionTDs(playerid)
{
	for(new x = 0; x < 5; x++)
	    TextDrawHideForPlayer(playerid, selectionTD[playerid][x]);

	// Basically the above code and the above code are the same.
	// Got it? abit.. but there arent only 4 tds.. these 4 are just for civilian class(case 1 to 47) and
  //didnt get the loop thingy
  // wait for it.. the civilian etc will be fixed.. also loops are advnaced you will get them with time ok
	/*TextDrawHideForPlayer(playerid, selectionTD[playerid][0]);
	TextDrawHideForPlayer(playerid, selectionTD[playerid][1]);
	TextDrawHideForPlayer(playerid, selectionTD[playerid][2]);
	TextDrawHideForPlayer(playerid, selectionTD[playerid][3]);
	TextDrawHideForPlayer(playerid, selectionTD[playerid][4]);*/
}

//bro, the box color is different for each.. for civilian, the box is white, for fbi is blue, etc
// thats easy
showSelectionTDForTeam(playerid, teamid)
{
 	TextDrawBoxColor(selectionTD[playerid][0], skinSelectionTDBoxColor[teamid]);
	for(new x = 0; x < 5; x++)
	{ //when u coming back btw?
		TextDrawSetString(selectionTD[playerid][x], skinSelectionTDText[teamid][x]);
		TextDrawHideForPlayer(playerid, selectionTD[playerid][x]);
		TextDrawShowForPlayer(playerid, selectionTD[playerid][x]);
 	}
}
// END_OF



// i will use this, its cool :D.. but there's a problem :/.. it doesnt


  //_____________________//________________//_____________________//
 //_____________________//PLAYER COMMANDS//_____________________//
//_____________________//______________//_____________________//

CMD:cmds(playerid, params[])
{


	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");
	ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_LIST, "SERVER COMMANDS", "Basic Commands\nMain Commands\nCivilian Commands\nCop Commands\nShop commands\n{FFD700}V.I.P Commands\nMedic commands\nFiremanCommands\nHouse Commands\nVehicle Commands", "SELECT", "EXIT");
	return 1;
}







CMD:stats(playerid, params[])
{

	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");

	new stats[256];
 	new PlayerName[24];
	new PlayerScore;
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	PlayerScore = GetPlayerScore(playerid);
	format(stats, 256, "Username: %s \nScore: %d\nVIP: %d\nAdmin: %d\nKills: %d\nDeaths: %d", PlayerName, PlayerScore, pInfo[playerid][pVIP], pInfo[playerid][pAdmin], pInfo[playerid][pKills], pInfo[playerid][pDeaths]);
	ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "STATS", stats, "OK", "");

	return 1;
}


CMD:kill(playerid, params[])
{

    if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");

	if(GetPlayerWantedLevel(playerid) > 0)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You cannot use this command while you have a wanted level on you!");

	else
	{
	SetPlayerHealth(playerid, 0);
	SendClientMessage(playerid, -1, "{DCDCDC}[STATS] {FFFFFF}Your stats have been saved!");
	}
	return 1;
}

CMD:savestats(playerid, params[])
{

		if(pInfo[playerid][pLoggedIn] == 1)
		{
		if(IsPlayerSpawned[playerid] != 1)
		return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");

		new score = GetPlayerScore(playerid);
		new money = GetPlayerMoney(playerid);
	    new query[256];
	    format(query, 256, "UPDATE `playerdata` SET `score` = '%d', `kills` = '%d', `deaths` = '%d', `admin` = '%d', `VIP` = '%d', `money` = '%d', `pjobselected = '1', `pjob` = '%s' WHERE `id` = '%d'", score, pInfo[playerid][pKills], pInfo[playerid][pDeaths], pInfo[playerid][pAdmin], pInfo[playerid][pVIP], money, pInfo[playerid][pJob], pInfo[playerid][pDBID]);
		mysql_tquery(dbHandle, query); // thats i
		SendClientMessage(playerid, -1, "{DCDCDC}[STATS] {FFFFFF}You've successfully saved your statistics!");
		}

		else
		{
		SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}Your statistics could not be saved.");
		}
		return 1;
}

CMD:dnd(playerid, params[])
{

	new dname[24], msg[96], did;
	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");
	
	if(sscanf(params, "u", did))
	return SendClientMessage(playerid, -1, "{FFFF00}[USAGE]{FFFFFF} /dnd [PLAYERID]");
	if(dndid[did] == 1)
	return dndid[did] = 0;
	
	GetPlayerName(did, dname, 24);
	format(msg, sizeof(msg), "{FFD700}[DO NOT DISTURB]{FFFFFF} You've blocked %s from sending you further private messages.", dname);
	SendClientMessage(playerid, -1, msg);
	dndid[did] = 1;
	return 1;
}



CMD:pm(playerid, params[])
{

	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");

	new id, string[128], string2[128], sender[MAX_PLAYER_NAME], reciever[MAX_PLAYER_NAME], logs[128], undnd[128];
	if(sscanf(params, "us[75]", id, params[2]))
	return SendClientMessage(playerid, -1, "{FFFF00}[USAGE] {FFFFFF}PM [PLAYERID] [MESSAGE]");

	if(dndid[playerid] == 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player has toggled DO NOT DISTURB mode.");
	
	GetPlayerName(playerid, sender, sizeof(sender));
	GetPlayerName(id, reciever, sizeof(reciever));

	if(playerid == id)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You cannot send a private message to yourself.");

	if(!IsPlayerConnected(playerid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You cannot send message to an offline player.");


	format(string, sizeof(string), "{FFD700}[MESSAGE] {C0C0C0} From %s(%d): %s", sender, playerid, params[2]);
	format(string2, sizeof(string2), "{FFD700}[MESSAGE] {A9A9A9} To %s(%d): %s", reciever, id, params[2]);
	format(logs, sizeof(logs), "[PM] FROM %s   to   %s  : %s", sender, reciever, params[2]);
	format(undnd, 128, "{FFD700}[DO NOT DISTURB]{FFFFFF} You have sent a message to a player you've blocked, as a result, they've been unblocked.");
	SendClientMessage(playerid, -1, undnd);
	dndid[id] = 0;
	PMLog(logs);
	SendClientMessage(id, -1, string);
	SendClientMessage(playerid, -1, string2);

	GameTextForPlayer(id, "~B~PM RECIEVED...", 1250, 5);
	PlayerPlaySound(id, 1054, 0.0, 0.0, 0.0);

	return 1;

}

CMD:sendmoney(playerid, params[])
{

    if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");


	new id, amount, sender[MAX_PLAYER_NAME], reciever[MAX_PLAYER_NAME], string[128], string2[128], logs[128];
	if (sscanf(params,"ud", id, params[2]))
	return	SendClientMessage(playerid, -1, "{FFFF00}[USAGE]{FFFFFF} SENDMONEY [PLAYERID] [AMOUNT]");

	if(!IsPlayerConnected(playerid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You cannot send money to an offline player.");

	GetPlayerName(playerid, sender, sizeof(sender));
	GetPlayerName(id, reciever, sizeof(sender));

	if(playerid == id)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You cannot send money to yourself.");

	if(GetPlayerMoney(playerid) < amount)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You do not have enough amount of money.");

	format(string, 128, "{FF0000}[TRANSACTION] To %s(%d): {CCFF00}%d${FFFFFF}.", reciever, id, amount);
	format(string2, 128, "{66FF33}[TRANSACTION] From %s(%d): {CCFF00}%d${FFFFFF}.", sender, playerid, amount);
	format(logs, sizeof(logs), "[TRANSACTION] FROM  %s  TO  %s: %d", sender, reciever, amount);
	SMLog(logs);

	SendClientMessage(playerid, -1, string);
	SendClientMessage(id, -1, string2);

	GivePlayerMoney(playerid, -amount);
	GivePlayerMoney(id, amount);

	return 1;
}
CMD:sm(playerid, params[])
{

	return cmd_sendmoney(playerid, params);
}


CMD:taxes(playerid, params[])
{
    if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");
	ShowPlayerDialog(playerid, DIALOG_TAX, DIALOG_STYLE_MSGBOX, "Death-Taxes", "{FFFFFF}MONEY\t\t\tTAX\nLESS THAN $100,000\t\t$100\nMore than $100,000\t\t$1,500\nMore than $1,000,000\t\t$15,000\nMore than $10,000,000\t\t$50,000", "OK", "");
	return 1;
}

CMD:changepw(playerid, params[])
{

    if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");
	new query[136], lName[24];
	GetPlayerName(playerid, lName, 24);
	format(query, sizeof(query), "{FFFF00}Please enter your new password to change your current password to the new one./n/n");
	ShowPlayerDialog(playerid, DIALOG_CHANGEPW, DIALOG_STYLE_PASSWORD, "Change-Password", query, "CHANGE", "EXIT");

	return 1;
}

CMD:idof(playerid, params[])
{

    if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");
	new iName[24], id;
	if(sscanf(params, "u", id, params))
	return SendClientMessage(playerid, -1, "{FFFF00}[USAGE] {FFFFFF}IDOF [PLAYERID/PART OF NAME OF PLAYER]");
	GetPlayerName(id, iName, 24);
	new string[128];
	format(string, sizeof(string), "{696969}[IDOF]{FFFFFF} %s(%d)", iName, id);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:mydbid(playerid, params[])
{

    if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");
	new dbid = pInfo[playerid][pDBID];
	new string[128];
	format(string, sizeof(string), "{696969}[SERVER]{FFFFFF} Your database ID is %i.", dbid);
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:r(playerid, params[])
{

	return cmd_pm(playerid, params);
}

CMD:me(playerid, params[])
{   new action[65];
	if(sscanf(params, "s", action))
	return SendClientMessage(playerid, -1, "{FFFF00}[USAGE] ME [MESSAGE/ACTION]");

	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");

	new string[128];
	new mName[24];

	format(string, 128, "{%06x}*** %s(%d) %s.", GetPlayerColor(playerid), mName, playerid, action);
	SendClientMessageToAll(-1, string);
	return 1;
}
/*CMD:rob(playerid, params[])
{
   	new targetid, time;
 	if(sscanf(params, "u", targetid))
	return SendClientMessage(playerid, -1, "{FFFF00}[USAGE] ROB [PLAYERID]");
	if(!IsPlayerConnected(targetid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}The player is not connected.");
	if(!IsPlayerInAnyVehicle(playerid))
	return Error(playerid, "You cannot rob anyone inside a vehicle.");
	
	if(time > gettime())
	return Error(playerid, "You are too tired from the last time you robbed someone");
	new randrob = 1;
	switch(randrob)
	{
	
	case 0:
	{


	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You must be spawned to use any command");


	new rAmount = random(3669);
	new string1[128], string2[128];
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(targetid, X, Y, Z);
	new tName[24], rName[24];
 	GetPlayerName(playerid, rName, 24);
	GetPlayerName(targetid, tName, 24);
	if(IsPlayerInRangeOfPoint(playerid, X, Y, Z, 15))
	{
	format(string1, sizeof(string1), "{90EE90}[ROB]{FFFFFF} You've robbed {FFFF00}$%d{FFFFFF} from %s(%d).", rAmount, tName, targetid);
	format(string2, sizeof(string2), "{FF0000}[ROB]{FFFFFF} You've been robbed {FFFF00}$%d{FFFFFF} by %s(%d).", rAmount, rName, playerid);
	SendClientMessage(playerid, -1, string1);
	SendClientMessage(targetid, -1, string2);
	time = gettime() + 45;
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} There are no players around to rob");
	}

	case 1:
	{
	new string1[128], string2[128], rName[24], tName[24];
	GetPlayerName(playerid, rName, 24);
	GetPlayerName(targetid, tName, 24);
	format(string1, sizeof(string1), "{FF0000}[ROB FAIL]{FFFFFF} You've failed to rob %s(%d).", tName, targetid);
	format(string2, sizeof(string2), "{90EE90}[ROB FAIL]{FFFFFF} %s(%d) tried to rob you but failed.", rName, playerid);
	SendClientMessage(playerid, -1, string1);
	SendClientMessage(targetid, -1, string2);
	time = gettime() + 45;
	}
	}
	return 1;
}
*/





CMD:rob(playerid, params[])
{
	new rname[24], tname[24], rmoney, Float:PX, Float:PY, Float:PZ, Float:TX, Float:TY, Float:TZ, time, string1[128], string2[128];
	new randrob = 1;
	
	if(!IsPlayerInAnyVehicle(playerid))
	return Error(playerid, "You cannot rob anyone inside a vehicle.");
	
   // if(!IsPlayerConnected(targetid))
	//return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}The player is not connected.");

	
	if(time > gettime())
	return Error(playerid, "You are too tired from the last time you had robbed someone");
	
	for(new i = 0; i < MAX_PLAYERS; i++)
		{
			GetPlayerPos(playerid, PX, PY, PZ);
			GetPlayerPos(i, TX, TY, TZ);
	
			if(!IsPlayerInRangeOfPoint(playerid, 10, TX, TY, TZ))
			return Error(playerid, "There are no players arounnd you to rob.");
			
			
	
			else
				{
					GetPlayerName(playerid, rname, 24);
					GetPlayerName(i, tname, 24);
	
	
					switch(randrob)
						{
							case 0:
								{
									if(GetPlayerMoney(i) < 500)
									return Error(playerid, "This player has a very low economic level and cannot afford to be robbed.");
									else if(GetPlayerMoney(i) >= 500)
										{
	
											rmoney = random(369);
											format(string1, sizeof(string1), "{90EE90}[ROB]{FFFFFF} You've robbed {FFFF00}$%d{FFFFFF} from %s(%d).", rmoney, tname, i);
											format(string2, sizeof(string2), "{FF0000}[ROB]{FFFFFF} You've been robbed {FFFF00}$%d{FFFFFF} by %s(%d).", rmoney, rname, playerid);
											SendClientMessage(playerid, -1, string1);
											SendClientMessage(i, -1, string2);
											GivePlayerMoney(playerid, rmoney);
											GivePlayerMoney(i, rmoney);
											time = gettime() + 45;
 										}
	
 									else if(GetPlayerMoney(i) >= 5000)
										{

											rmoney = random(1000) + 1500;
											format(string1, sizeof(string1), "{90EE90}[ROB]{FFFFFF} You've robbed {FFFF00}$%d{FFFFFF} from %s(%d).", rmoney, tname, i);
											format(string2, sizeof(string2), "{FF0000}[ROB]{FFFFFF} You've been robbed {FFFF00}$%d{FFFFFF} by %s(%d).", rmoney, rname, playerid);
											SendClientMessage(playerid, -1, string1);
											SendClientMessage(i, -1, string2);
											GivePlayerMoney(playerid, rmoney);
											GivePlayerMoney(i, rmoney);
											time = gettime() + 45;


										}
							
								}
	
							case 1:
								{
	                               	format(string1, sizeof(string1), "{FF0000}[ROB FAIL]{FFFFFF} You've failed to rob %s(%d).", tname, i);
									format(string2, sizeof(string2), "{90EE90}[ROB FAIL]{FFFFFF} %s(%d) tried to rob you but failed.", rname, playerid);
									SendClientMessage(playerid, -1, string1);
									SendClientMessage(i, -1, string2);
									time = gettime() + 45;
								}
								
						}
				}
		}
	return 1;
 }
								
								
								
CMD:setvip(playerid, params[])
{
	pInfo[playerid][pVIP] = 3;
	return 1;
}
CMD:xpls(playerid, params[])
{
	pInfo[playerid][pXP] = 25000;
	new query[128];
	new xName[24];
	GetPlayerName(playerid, xName, 24);
	format(query, sizeof(query), "UPDATE `playerdata` SET `pXP` = '%d' WHERE `username` = '%s'", pInfo[playerid][pXP], xName);
	mysql_tquery(dbHandle, query);
	SetTimer("UpdateXP", 1000, true);
	return 1;
}

CMD:shop(playerid, params[])
{
	if(IsPlayerSpawned[playerid] != 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You must be spawned to use any command.");

	if(!IsPlayerInRangeOfPoint(playerid, 200, 1514.6748,1579.7668,10.8681))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] {FFFFFF}You must be inside supa save to use this command.");

	ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, "SHOP", "{FFFFFF}Ropes\t\tTo tie other players (/tie)\t\nScissors\tTo cut the tie (/cuttie)\nBobby Pins\tTo break cuffs(/bc)\nMetal Melters\tTo escape from jail (/breakout)\nMoney Bag\t Increases loot from robbery.", "SELECT", "EXIT");
	return 1;
}
CMD:robsafe(playerid, params[])
{

	SendClientMessage(playerid, -1, "{FFFF00}[INFO] Press {C9C9C9}LEFT ALT{FFFFFF} near a safe to rob it.");
	return 1;
}
forward RobberyStart(playerid);
public RobberyStart(playerid)
{
	//************************************ R O B B E R Y    T E X T D R A W S*****************************
	//****************************************************************************************************
	//****************************************************************************************************

	SetCameraBehindPlayer(playerid);
	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_LOOP", 4.1, true, false, false, false, 10000, true);
	SetTimer("Robbery1", 1666, false);
	PlayerTextDrawShow(playerid, Robbery[playerid][0]);
	PlayerTextDrawShow(playerid, Robbery[playerid][1]);
	PlayerTextDrawShow(playerid, Robbery[playerid][2]);
	SafeBeingRobbed[playerid] = 1;
	return 1;
}


forward Robbery1(playerid);
public Robbery1(playerid)
{
	PlayerTextDrawShow(playerid, Robbery[playerid][3]);
	SetTimer("Robbery2", 1666, false);
	return 1;
}
forward Robbery2(playerid);
public Robbery2(playerid)
{
	PlayerTextDrawShow(playerid, Robbery[playerid][4]);
	SetTimer("Robbery3", 1666, false);
	return 1;
}
forward Robbery3(playerid);
public Robbery3(playerid)
{

	PlayerTextDrawShow(playerid, Robbery[playerid][5]);
	SetTimer("Robbery4", 1666, false);
	return 1;
}

forward Robbery4(playerid);
public Robbery4(playerid)
{

	PlayerTextDrawShow(playerid, Robbery[playerid][6]);
	SetTimer("Robbery5", 1666, false);
	return 1;

}
forward Robbery5(playerid);
public Robbery5(playerid)
{

	PlayerTextDrawShow(playerid, Robbery[playerid][7]);
	SetTimer("FinishRobbery", 0, false);
	return 1;

}




forward FinishRobbery(playerid);
public FinishRobbery(playerid)
{
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, 1);
 	//GameTextForPlayer(playerid, "ROBBED SUCCESSFULLY", 2000, 2);

  	for(new i=0; i < 8; i++)
   	{
	PlayerTextDrawHide(playerid, Robbery[playerid][i]);
	}
	SetTimer("RobMoney", 0, false);
	SafeBeingRobbed[playerid] = 0;
	return 1;

}


forward RobMoney(playerid);
public RobMoney(playerid)
{
	{
	new RandMoney = random(4969);
	GivePlayerMoney(playerid, RandMoney);
	new msg[128], sName[24];
	GetPlayerName(playerid, sName, 24);

	format(msg, 128, "%s(%d) has robbed $%d.", sName, playerid, RandMoney);
	SendClientMessageToAll(-1, msg);
	pInfo[playerid][pWanted] = pInfo[playerid][pWanted] + 6;
	if(DoubleXP == true)
	{
	pInfo[playerid][pXP] = pInfo[playerid][pXP] + 20;
	}
	else if(DoubleXP == false)
	{
	pInfo[playerid][pXP] = pInfo[playerid][pXP] + 10;
	}


	new safeid = GetPlayerVirtualWorld(playerid);
	for(new i = 0; i < sizeof(StoreSafeMoney); i++)
	{
	SafeRecentlyRobbed[safeid] = 1;
	}
	SetTimer("SafeRobberyReset", 260000, false);
	}
	return 1;
}
forward SafeRobberyReset(playerid);
public SafeRobberyReset(playerid)
{
	SafeRecentlyRobbed[playerid] = 0;
	return 1;
}









//************* V I P      C O M M A N D S****************************


CMD:vipobjects(playerid)
{

	if(pInfo[playerid][pVIP] <= 0)
	return Error(playerid, "You need to be a V.I.P to use this command. Donate at "WEBSITE_NAME" to become one.");
	
	else if(pInfo[playerid][pVIP] >= 1)
	{
    new string[300], s[40];
	format(string, sizeof(string), "{84B4C4}Slot 1\t%s\n", oInfo[playerid][0][used1] == true ? ("{E62E2E}Used") : ("{0DFF00}Empty"));
	for(new i=1,j=MAX_OBJECTS; i<j; i++) {
		format(s, sizeof(s), "{84B4C4}Slot %d\t%s\n", i+1, oInfo[playerid][i][used1] == true ? ("{E62E2E}Used") : ("{0DFF00}Empty"));
		strcat(string, s); }
	ShowPlayerDialog(playerid, 70, DIALOG_STYLE_TABLIST, "{33FF00}Objects", string, "Select", "Cancel");
	}
	return 1;
}












//****************** A D M I N I S T R A T I O N **********************









//******************** A D M I N    S T O C K S**************

stock SCMToAdmins(COLOR,message[])//here we set params for this stock, [] means string/message
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	if(IsPlayerConnected(i))
	{
	if(pInfo[i][pAdmin] >= 1)
	{
	SendClientMessage(i, COLOR, message);
	return 1;
	}
	}
	}
	return 1;
}




//********** A D M I N    V A R I A B L E S****************************


new Mute[MAX_PLAYERS];




//******** A D M I N    T I M E R S*********************************

forward UpdateMute(playerid);
public UpdateMute(playerid)
{

    for(new i = 0; i < MAX_PLAYERS; i ++) // loops all the players
	{
		if(IsPlayerConnected(i)) // will check if the player is connected
		{
			if(Mute[i] >= 1) // will check if their mute time is equal or above to 1
			{
				Mute[i] --; // if it is, then it will minus the mute time by 1 second
			}
		}
	}
	return 1;
}
//***************** A D M I N   R E Q U I R E D    C A L L B A C K S********


public OnPlayerText(playerid, text[])
{
	if(Mute[playerid] >= 1) // check if the player is muted
	{
		new string[50]; // creates a new variable
		format(string, sizeof(string), "{FF0000}[ERROR]{FFFFFF} You cannot text in the mainchat as you are muted for %d seconds.", Mute[playerid]); // sets the string
		SendClientMessage(playerid, 0xFFFFFFFF, string); // sends the message
		return 0; // this is crucial, by returning 0 here it will stop the player from being able to talk
	}

	if(text[0] == '@')
	
    {
    new aname[24], msg[128];
    GetPlayerName(playerid, aname, 24); //Checks for the symbol
    format(msg, sizeof(msg), "{1E90FF}<ADMIN CHAT>{C0C0C0} %s(%d): %s", aname, playerid, text);
    AdminChatLog(msg);
	if(pInfo[playerid][pAdmin] >= 1)
	{
	SCMToAdmins(-1, msg);
 	return 1; //Returning 0 will stop the server from sending the message to everyone
	}
	
	{
	new pname[24], cmsg[156];
	GetPlayerName(playerid, pname, 24);
	format(cmsg, 156, "%s(%d): %s", pname, playerid, text);
	ChatLog(cmsg);
	}
	
	}



	return 1; // don't put this here if you've already got it at the bottom of your OnPlayerText.
}



//******************** A D M I N     C O M M A N D S********************







//****************    L  E  V  E  L      O  N  E     C  O  M  M  A  N  D  S   ***********************




CMD:spawn(playerid, params[])
{

	new tid, tname[24], aname[24], pmsg[64], tmsg[64], logs[96];
	if(pInfo[playerid][pAdmin] >= 1)
	{

 	if(sscanf(params, "u", tid))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /spawn [PLAYERID]");

	SpawnPlayer(tid);
	format(tmsg, 64, "{1E90FF}[ADMIN]{FFFFFF} You've been spawned by %s(%d).", aname, playerid);
	format(pmsg, 64, "{1E90FF}[ADMIN]{FFFFFF} You've spawned %s(%d)", tname, tid);
	format(logs, 96, "%s spawned %s", aname, tname);
	SendClientMessage(tid, -1, tmsg);
	SendClientMessage(playerid, -1, pmsg);
	AdminLogs(logs);
	}
    
	else
    SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} You do not have sufficient administration level to use this command.");

	return 1;
}

CMD:slap(playerid, params[])
{
	new tid, tname[24], aname[24], height, pmsg[64], tmsg[64], Float:PosX, Float:PosY, Float:PosZ, logs[96];
	if(pInfo[playerid][pAdmin] >= 1)
	{
	if(sscanf(params, "ui", tid, height))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /slap [PLAYERID] [HEIGHT]");

	GetPlayerPos(playerid, PosX, PosY, PosZ);

	SetPlayerPos(playerid, PosX, PosY, PosZ + height);
	GetPlayerName(tid, tname, 24);
	GetPlayerName(playerid, aname, 24);
	format(pmsg, 64, "{1E90FF}[ADMIN]{FFFFFF} You have slapped %s(%d).", tname, tid);
	format(tmsg, 64, "{1E90FF}[ADMIN]{FFFFFF} You've been slapped by %s(%d)", aname, playerid);
	format(logs, sizeof(logs), "%s slapped %s", aname, tname);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(playerid, -1, tmsg);
	AdminLogs(logs);
	}
	else
    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}
new bool:aod[MAX_PLAYERS];

CMD:aod(playerid, params[])
{
	new Float:PosX, Float:PosY, Float:PosZ;

	if(pInfo[playerid][pAdmin] <= 1)
	{
	if(aod[playerid] == true)
	{
	aod[playerid] = false;
	}

	if(aod[playerid] == false)
	{

	aod[playerid] = true;
	SetPlayerColor(playerid, 0x1E90FFFF);
	GetPlayerPos(playerid, PosX, PosY, PosZ);

	CreateDynamic3DTextLabel("Admin on Duty", 0x1E90FFFF, PosX, PosY, PosZ, 20.0, .streamdistance = 20.0);
	SetPlayerHealth(playerid, 9999999);
	}
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}

CMD:a(playerid, params[])
{
    new aname[24], msg[128], text[128];
    {
    
    GetPlayerName(playerid, aname, 24); //Checks for the symbol
    format(msg, sizeof(msg), "{1E90FF}<ADMIN CHAT>{C0C0C0} %s(%d): %s", aname, playerid, text);
    AdminChatLog(msg);
	if(pInfo[playerid][pAdmin] >= 1)
	{
	if(sscanf(params, "s", text))
    return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /a [MESSAGE]");

	SCMToAdmins(-1, msg);
 	return 1; //Returning 0 will stop the server from sending the message to everyone
	}
	}

	return 1;
}

CMD:goto(playerid,params[])
{
    new ID;
    new Float:X;
    new Float:Y;
    new Float:Z;
    new Float:A;
    new str[96];
    new tname[24];
    new aname[24];
    new vw;
    new intid;
	new logs[96];

    if(pInfo[playerid][pAdmin] >= 1)
    {

    if(sscanf(params,"u", ID))
	return SendClientMessage(playerid,-1,"{1E90FF}[ADMIN]{FFFFFF} /goto [PLAYERID]");

    if(!IsPlayerConnected(playerid))
    return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");

    GetPlayerPos(ID, X,Y,Z);
    GetPlayerFacingAngle(ID, A);
    SetPlayerPos(playerid, X,Y,Z);
    SetPlayerFacingAngle(playerid, A);
    GetPlayerName(ID, tname, 24);
    GetPlayerVirtualWorld(ID);
    GetPlayerInterior(intid);
    SetPlayerInterior(playerid, intid);
    SetPlayerVirtualWorld(playerid, vw);
    format(str, 96, "{1E90FF}[ADMIN]{FFFFFF} You've teleported yourself to %s(%d).", tname, ID);
    SendClientMessage(playerid, -1, str);
    GetPlayerName(playerid, aname, 24);
    format(logs, sizeof(logs), "%s teleported himself to %s", aname, tname);
    AdminLogs(logs);
    }
    else
    SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");


    return 1;
}

CMD:bring(playerid, params[])
{

	new tid, tname[24], aname[24], Float:PosX, Float:PosY, Float:PosZ, pmsg[96], tmsg[96];
	if(pInfo[playerid][pAdmin] >= 1)
	{
	if(sscanf(params, "u", tid))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /bring [PLAYERID]");

	if(!IsPlayerConnected(playerid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");

	if(pInfo[playerid][pAdmin] < pInfo[playerid][pAdmin])
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You cannot bring this player.");

	GetPlayerPos(playerid, PosX, PosY, PosZ);

	SetPlayerPos(tid, PosX, PosY, PosZ);
	GetPlayerName(tid, tname, 24);
	GetPlayerName(playerid, aname, 24);
	format(pmsg, 96, "{1E90FF}[ADMIN]{FFFFFF} You've brought %s(%d) to yourself.", tname, tid);
	format(tmsg, 96, "{1E90FF}[ADMIN]{FFFFFF} You've been brought by %s(%d).", aname, playerid);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(tid, -1, tmsg);
	}

	else
 	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}
//***********************__
// CMD: JAIL IS PENDING...__
// GETSTATS COMMAND MISSING__
//***************************


CMD:spec(playerid, params[])
{
	new tid;// This will hold the ID of the player you are going to be spectating.
	if(pInfo[playerid][pAdmin] >= 1)
	{
	if(sscanf(params,"u", tid))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /spec [PLAYERID]");// Now this is where we use sscanf to check if the params were filled, if not we'll ask you to fill them
	if(tid == playerid)return SendClientMessage(playerid, -1,"{FF0000}[ERROR]{FFFFFF}You cannot spectate yourself.");// Just making sure.
	if(tid == INVALID_PLAYER_ID)return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");// This is to ensure that you don't fill the param with an invalid player id.
	if(IsSpecing[playerid] == 1)return SendClientMessage(playerid,-1,"{FF0000}[ERROR]{FFFFFF} You're already in spectation mode.");// This will make you not automatically spec someone else by mistake.
	GetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// This is getting and saving the player's position in a variable so they'll respawn at the same place they typed '/spec'
	Inter[playerid] = GetPlayerInterior(playerid);// Getting and saving the interior.
	vWorld[playerid] = GetPlayerVirtualWorld(playerid);//Getting and saving the virtual world.
	TogglePlayerSpectating(playerid, true);// Now before we use any of the 3 functions listed above, we need to use this one. It turns the spectating mode on.
	if(IsPlayerInAnyVehicle(tid))//Checking if the player is in a vehicle.
	{
	    if(GetPlayerInterior(tid) > 0)//If the player's interior is more than 0 (the default) then.....
	    {
			SetPlayerInterior(playerid,GetPlayerInterior(tid));//.....set the spectator's interior to that of the player being spectated.
		}
		if(GetPlayerVirtualWorld(tid) > 0)//If the player's virtual world is more than 0 (the default) then.....
		{
		    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(tid));//.....set the spectator's virtual world to that of the player being spectated.
		}
	    PlayerSpectateVehicle(playerid,GetPlayerVehicleID(tid));// Now remember we checked if the player is in a vehicle, well if they're in a vehicle then we'll spec the vehicle.
	}
	else// If they're not in a vehicle, then we'll spec the player.
	{
	    if(GetPlayerInterior(tid) > 0)
	    {
			SetPlayerInterior(playerid,GetPlayerInterior(tid));
		}
		if(GetPlayerVirtualWorld(tid) > 0)
		{
		    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(tid));
		}
	    PlayerSpectatePlayer(playerid,tid);// Letting the spectator spec the person and not a vehicle.
	}
	GetPlayerName(tid, Name, sizeof(Name));//Getting the name of the player being spectated.
	format(String, sizeof(String),"{1E90FF}[ADMIN]{FFFFFF} You've toggled the spectation mode and now spectating %s.",Name);// Formatting a string to send to the spectator.
	SendClientMessage(playerid,0x0080C0FF,String);//Sending the formatted message to the spectator.
	IsSpecing[playerid] = 1;// Just saying that the spectator has begun to spectate someone.
	IsBeingSpeced[tid] = 1;// Just saying that a player is being spectated (You'll see where this comes in)
	spectatorid[playerid] = tid;// Saving the spectator's id into this variable.
	return 1;
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}
COMMAND:specoff(playerid, params[])
{
	if(pInfo[playerid][pAdmin] >= 1)
	{
	if(IsSpecing[playerid] == 0)return SendClientMessage(playerid, -1,"{FF0000}[ERROR]{FFFFFF} You're not spectating anyone.");

	TogglePlayerSpectating(playerid, 0);
	SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} You've exitted the spectation mode.");
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}





CMD:warn(playerid, params[])
{
	new tid, tname[24], aname[24], reason[48], string[128], string2[128], logs[96];

	if(pInfo[playerid][pAdmin] >= 1)
	{
	if(sscanf(params, "us", tid, reason))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /warn [PLAYERID] [REASON]");

	if(!IsPlayerConnected(playerid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");

	GetPlayerName(tid, tname, 24);
	GetPlayerName(playerid, aname, 24);

	pInfo[tid][pWarns]++;
	GameTextForPlayer(playerid, "~r~WARNED!", 1000, 5);
	format(string2, sizeof(string2), "{1E90FF}[ADMIN]{FFFFFF} %s(%d) has been warned by %s(%d). {00FF00}[REASON: %s]", tname, tid, aname, playerid, reason);
	SendClientMessageToAll(-1, string2);
	format(logs, 96, "%s warned %s. [REASON: %s]", aname, tname, reason);
	AdminLogs(logs);

    if(pInfo[playerid][pWarns] >= 3)
	{
	Kick(tid);

	format(string, sizeof(string), "{1E90FF}[ADMIN]{FFFFFF} %s(%d) has been kicked from the server. {00FF00}[REASON: Excessive Warns]", tname, tid);
	SendClientMessageToAll(-1, string);
	}

	}

	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");

	return 1;
}

//**********************  L  E  V  E  L    T  W  O    C  O  M  M  A  N  D  S*****************************************


CMD:ann(playerid, params[])
{
	new ann[46];

	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "s", ann))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /ann [MESSAGE]");

	GameTextForAll(ann, 1250, 5);
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command");
	return 1;
}


CMD:asay(playerid, params[])
{
	new text, string[128];
	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "s", text))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /asay [MESSAGE]");

	format(string, sizeof(string), "{1E90FF}[ADMIN]{FFFFFF} %s", text);
	SendClientMessageToAll(-1, string);
	}

	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}


CMD:mute(playerid, params[])
{


    new mName[24], str[128], logs[96];
	GetPlayerName(playerid, mName, 24);

	new targetid, targetname[24], time, reason[25];

	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "uds", targetid, time, reason))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /mute [PLAYERID] [TIME IN SECONDS] [REASON]");

	if(!IsPlayerConnected(targetid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");

	if(pInfo[playerid][pAdmin] < pInfo[targetid][pAdmin])
	{
 	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You cannot any admin command on your senior admins.");
	format(str, sizeof(str), "{1E90FF}[ADMIN]{FFFFFF} %s(%d) tried to mute you.", mName, playerid);
	SendClientMessage(targetid, -1, str);
	}

	if(Mute[targetid] == 1)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is already muted.");

	GetPlayerName(targetid, targetname, 24);
	new MuteSent[128];

	new calc = time*1;
	Mute[targetid] = calc;
	format(MuteSent, 128, "{1E90FF}[ADMIN] {FFFFFF}%s(%d) has been muted by %s(%d) for %d seconds. {00FF00}[REASON: %s]", targetname, targetid, playerid, mName, time, reason);
	SendClientMessageToAll(-1, MuteSent);
	format(logs, sizeof(logs), "%s muted %s for %d seconds. REASON: %s", mName, targetname, time, reason);
	AdminLogs(logs);
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}


CMD:unmute(playerid, params[])
{
	new tid, tname[24], mName[24], logs[96];

	if(pInfo[playerid][pAdmin] >= 2)
	{


	if(Mute[tid] == 0)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not muted.");

 	if(sscanf(params, "u", tid))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /unmute [PLAYERID].");
	if(!IsPlayerConnected(tid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");
	format(logs, 96, "%s unmuted %s", mName, tname);
	AdminLogs(logs);

	GetPlayerName(playerid, mName, 24);
	GetPlayerName(tid, tname, 24);
	Mute[tid] = 0;

	new tmsg[64];
	format(tmsg, sizeof(tmsg), "{1E90FF}[ADMIN]{FFFFFF} %s(%d) has been unmuted by %s(%d).", tname, tid, mName, playerid);
	SendClientMessageToAll(-1, tmsg);
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");

	return 1;
}


CMD:kick(playerid, params[])
{


	if(pInfo[playerid][pAdmin] >= 2)
	{
	new tid, tname[24], aname[24], reason[44], msg[128], logs[96];
	if(sscanf(params, "us", tid, reason))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /kick [PLAYERID] [REASON]");

	if(!IsPlayerConnected(tid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} This player is not connected.");

	GetPlayerName(tid, tname, 24);
	GetPlayerName(playerid, aname, 24);

	format(msg, sizeof(msg), "{1E90FF}[ADMIN]{FFFFFF} %s(%d) has been kicked by %s(%d). {00FF00}[REASON: %s].", tname, tid, aname, playerid, reason);
	SendClientMessageToAll(-1, msg);
	Kick(tid);
	format(logs, 96, "%s kicked %s. REASON: %s", aname, tname, reason);
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");

	return 1;
}

CMD:getweapons(playerid,params[])
{
    if(pInfo[playerid][pAdmin] >=2)
        {
        new player1, Count, tname[24], x, string[128], string2[64], WeapName[24], slot, weap, ammo;

        if(sscanf(params, "u", player1))
		return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /getweapons [PLAYERID]");

    	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
     	{
   		GetPlayerName(playerid, tname, 24);
     	format(string2,sizeof(string2),"_______|- %s(%d) Weapons -|_______", tname, player1);
        SendClientMessage(playerid, -1, string2);
        for(slot = 0; slot < 14; slot++)
        {
        GetPlayerWeaponData(player1, slot, weap, ammo);
        if( ammo != 0 && weap != 0)
        Count++;
        }
        if(Count < 1)
        return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} This player doesn't have any weapons.");
        //------------------------------------------------------------------
        if(Count >= 1)
        {
        for (slot = 0; slot < 14; slot++)
        {
        GetPlayerWeaponData(player1, slot, weap, ammo);
        if( ammo != 0 && weap != 0)
        {
        GetWeaponName(weap, WeapName, sizeof(WeapName));
        if(ammo == 65535 || ammo == 1)
        format(string,sizeof(string),"{1E90FF}[ADMIN]{FFFFFF} %s %s (1)",string, WeapName);
        else format(string,sizeof(string),"{1E90FF}[ADMIN]{FFFFFF} %s %s (%d)",string, WeapName, ammo);
        x++;
        if(x >= 5)
        {
        SendClientMessage(playerid, -1, string);
        x = 0;
        format(string, sizeof(string), "");
        }
        else format(string, sizeof(string), "%s,  ", string);
        }
        }
  		if(x <= 4 && x > 0)
    	{
		string[strlen(string)-3] = '.';
  		SendClientMessage(playerid, -1, string);
    	}
     	}
		return 1;
  		}

        }
        else
        {
		if(pInfo[playerid][pAdmin] <= 1)
		return SendClientMessage(playerid, 1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
		}
	return 1;

}


CMD:getip(playerid, params[])

{
	new tid, tname[24], msg[69], tIP[16];
	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "u", tid))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /getip [PLLAYERID]");
	if(!IsPlayerConnected(tid))
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR] This player is not connected");
	GetPlayerName(tid, tname, 16);
	GetPlayerIp(tid, tIP, 16);
	format(msg, 38, "{1E90FF}[ADMIN]{FFFFFF} IP of %s(%d): %s", tname, tid, tIP);

	SendClientMessage(playerid, -1, msg);
	}
	return 1;
}
new bool:countdownEnabled;
new cdtime;


CMD:countdown(playerid, params[])
{

	new time[9], aname[24], msg[96];
	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(countdownEnabled == true)
	return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} Countdown is already in progress.");

	if(sscanf(params, "d", cdtime))
	return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /countdown [TIME]");

	GetPlayerName(playerid, aname, 24);
	format(msg, sizeof(msg), "{1E90FF}[ADMIN]{FFFFFF} %s(%d) has started a timeout from %d", aname, playerid, cdtime);
	AdminLogs(msg);
	SendClientMessageToAll(playerid, msg);
	cdtime--;

	if(cdtime > 0)
	{
	format(time, sizeof(time), "%d", cdtime);
	GameTextForAll(time, 1000, 4);
	}

	else if(cdtime == 0)
	{
	GameTextForAll(time, 1000, 4);
	}
	}
	else
	{
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration to use this command.");
	}

	return 1;
}

CMD:clearchat(playerid, params[])
{
	new tname[24], msgall[69];
	if(pInfo[playerid][pAdmin] >= 2)
	{

	for(new i = 0; i < 250; i++)
	{
	SendClientMessageToAll(0x00000000, "   ");
	}
	GetPlayerName(playerid, tname, 24);
	format(msgall, 69, "{1E90FF}[ADMIN]{FFFFFF} The chat has been cleared by %s(%d).", tname, playerid);
	AdminLogs(msgall);
	SendClientMessageToAll(-1, msgall);
	}
	
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration to use this command.");
	return 1;
}

CMD:vc(playerid, params[])
{
	new
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:rot
	;
	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "i", model)) return SendClientMessage(playerid, -1, "{1E90FF}[ADMIN]{FFFFFF} /vc [VEHICLE ID]" );
	if(model < 400 || model > 611) return SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You've entered an invalid vehicle id.");
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, rot);
 	CreateVehicle(model, x, y, z, rot, 0, 0, 200);
	PutPlayerInVehicle(playerid, model, 0);
	new string[45];
	format(string, sizeof(string), "{1E90FF}[ADMIN]{FFFFFF} You've successfully spawned vehicle MODELID: {00FF00}%i", model);
	SendClientMessage(playerid, -1, string);
	}
	else
	SendClientMessage(playerid, -1, "{FF0000}[ERROR]{FFFFFF} You do not have sufficient administration level to use this command.");
	return 1;
}

CMD:freeze(playerid, params[])
{

	new tname[24], tid, aname[24], tmsg[128], pmsg[128], logs[128];
	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "u", tid))
	AdminUsage(playerid, "/freeze [PLAYERID]");

	GetPlayerName(playerid, aname, 24);
	GetPlayerName(tid, tname, 24);
	format(tmsg, 128, "{1E90FF}[ADMIN]{FFFFFF} You have been frozen by %s(%d).", aname, playerid);
	format(pmsg, 128, "{1E90FF}[ADMIN]{FFFFFF} You've frozen %s(%d)", tname, tid);
	TogglePlayerControllable(tid, 0);
	format(logs, sizeof(logs), "%s has frozen %s.", aname, tname);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(playerid, -1, tmsg);
	AdminLogs(logs);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}

CMD:unfreeze(playerid, params[])
{
	new tid, tname[24], aname[24], tmsg[128], pmsg[128], logs[54];
	if(pInfo[playerid][pAdmin] >= 2)
	{
	if(sscanf(params, "u", tid))
	return AdminUsage(playerid, "/unfreeze [PLAYERID]");
	
	GetPlayerName(playerid, aname, 24);
	GetPlayerName(tid, tname, 24);
	TogglePlayerControllable(tid, 1);
	format(pmsg, sizeof(pmsg), "{1E90FF}[ADMIN]{FFFFFF} You've unfrozen %s(%d)", tname, tid);
	format(tmsg, sizeof(tmsg), "{1E90FF}[ADMIN]{FFFFFF} You have been unfrozen by %s(%d)", aname, playerid);
	format(logs, sizeof(logs), "%s unfrozen %d", aname, tname);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(tid, -1, tmsg);
	AdminLogs(logs);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}

//****************** L E V E L   T H R E E   C O M M A N D S**********************
CMD:aheal(playerid, params[])
{
	new tid, tname[24], aname[24], pmsg[64], tmsg[64], logs[44];
	if(pInfo[playerid][pAdmin] >= 3)
	{
	if(sscanf(params, "u", tid))
	return AdminUsage(playerid, "/aheal [PLAYERID]");

	GetPlayerName(tid, tname, 24);
	GetPlayerName(playerid, aname, 24);
	SetPlayerHealth(tid, 100);
	format(tmsg, 64, "{1E90FF}[ADMIN]{FFFFFF} You have been admin healed by %s(%d).", aname, playerid);
	format(pmsg, 64, "{1E90FF}[ADMIN]{FFFFFF} You have admin healed %s(%d).", tname, tid);
	format(logs, sizeof(logs), "%s healed %s.", aname, tname);
	SendClientMessage(tid, -1, tmsg);
	SendClientMessage(playerid, -1, pmsg);
	AdminLogs(logs);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}

CMD:slay(playerid, params[])
{

	new tid, tname[24], aname[24], pmsg[46], tmsg[46], logs[46];
	if(pInfo[playerid][pAdmin] >= 3)
	{
	if(sscanf(params, "u", tid))
	return AdminUsage(playerid, "/slay [PLAYERID]");
	
	GetPlayerName(playerid, aname, 24);
	GetPlayerName(tid, tname, 24);
	SetPlayerHealth(tid, 0);
	
	format(pmsg, sizeof(pmsg), "{1E90FF}[ADMIN]{FFFFFF} You have slain %s(%d).", tname, tid);
	format(tmsg, sizeof(tmsg), "{1E90FF}[ADMIN]{FFFFFF} You have been slain by %s(%d).", aname, playerid);
	format(logs, sizeof(logs), "%s slain %s", aname, tname);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(tid, -1, tmsg);
	AdminLogs(logs);
	}
	else
	Error(playerid, "You do not have sufficient adminnistration level to use this command.");
	
	return 1;
}

CMD:giveweapon(playerid, params[])
{
	new tid, tname[24], aname[24], wpid, ammo, logs[69], tmsg[128], pmsg[128];
	if(pInfo[playerid][pAdmin] >= 3)
	{
	if(sscanf(params, "udd", tid, wpid, ammo))
	return AdminUsage(playerid, "/giveweapon [PLAYERID] [WEAPON ID] [AMMO]");
	GetPlayerName(playerid, aname, 24);
	GetPlayerName(tid, tname, 24);
	GivePlayerWeapon(tid, wpid, ammo);
	format(tmsg, sizeof(tmsg), "{1E90FF}[ADMIN]{FFFFFF} You have been given a %s with %d AMMO by %s(%d).", GetPlayerWeapon(tid), ammo, aname, playerid);
	format(pmsg, sizeof(pmsg), "{1E90FF}[ADMIN]{FFFFFF} You have given a %s with %d AMMO to %s(%d).", GetPlayerWeapon(tid), ammo, tname, tid);
	format(logs, sizeof(logs), "%s gave WEAPON %s with %d ammo to %s", aname, GetPlayerWeapon(tid), ammo, tname);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(tid, -1, tmsg);
	AdminLogs(logs);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}

CMD:respawnalluv(playerid, params[])// To be made in such a way that private vehicles aren't respawned.. can be made after making vehicle ownership system
{
	return 1;
}
CMD:setvw(playerid, params[])
{
	new aname[24], tname[24], tid, vworldid, pmsg[66], tmsg[66], logs[39];
	if(pInfo[playerid][pAdmin] >= 3)
	{
	if(sscanf(params, "ui", tid, worldid))
	return AdminUsage(playerid, "/setvw [PLAYERID] [WORLDID]");
	
	GetPlayerName(playerid, aname, 24);
	GetPlayerName(tid, tname, 24);
	format(tmsg, sizeof(tmsg), "{1E90FF}[ADMIN]{FFFFFF} Your virtual world has been set to %i by %s(%d).", vworldid, aname, playerid);
	format(pmsg, sizeof(pmsg), "{1E90FF}[ADMIN]{FFFFFF} You've set %s(%d)'s virtual world to %i.", tname, tid, vworldid);
	format(logs, sizeof(logs), "%s set %s 's virtual world to %i.", aname, tname, vworldid);
	SendClientMessage(playerid, -1, pmsg);
	SendClientMessage(tid, -1, tmsg);
	AdminLogs(logs);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}

CMD:setint(playerid, params[])
{
	new intid, tid, aname[24], tname[24], tmsg[128], pmsg[128], logs[66];
	
	if(pInfo[playerid][pAdmin] >= 3)
	{
	if(sscanf(params, "ui", tid, intid))
	return AdminUsage(playerid, "/setint [PLAYERID] [INTERIOR ID]");
	
	GetPlayerName(tid, tname, 24);
	GetPlayerName(playerid, aname, 24);

	SetPlayerInterior(tid, intid);
	format(tmsg, sizeof(tmsg), "{1E90FF}[ADMIN]{FFFFFF} Your interior id has been set to %i by %s(%d).", intid, aname, playerid);
	format(pmsg, 128, "{1E90FF}[ADMIN]{FFFFFF} You have set %s(%d)'s interior to %i.", tname, tid, intid);
	format(logs, sizeof(logs), "%s has set %s's virtual world to %i", aname, tname, intid);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}


CMD:vbring(playerid, params[])
{

	new vid, aname, logs[48], pmsg[64], Float:X, Float:Y, Float:Z;
	if(pInfo[playerid][pAdmin] >= 3)
	{
	if(sscanf(params, "d", vid))
	return AdminUsage(playerid, "/vbring [VEHICLE ID] || /dl to check the VEHICLE ID");
	
	GetPlayerPos(playerid, X, Y, Z);
	
	SetVehiclePos(vid, X, Y, Z+5);
	format(pmsg, sizeof(pmsg), "{1E90FF}[ADMIN]{FFFFFF} You've brought VEHICLE ID: %d to yourself.", vid);
	format(logs, sizeof(logs), "%s brought vehicle id %d", aname, vid);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command");
	return 1;
}


CMD:ban(playerid, params[])
{

	return 1;
}

//************* L E V E L    F O U R    C O M M A N D S*****************


CMD:gotopos(playerid, params[])
{
	new Float:PosX, Float:PosY, Float:PosZ;
	
	if(pInfo[playerid][pAdmin] >= 4)
	{
	if(sscanf(params, "fff", PosX, PosY, PosZ))
	return AdminUsage(playerid, "/gotopos [X] [Y] [Z]");
	}
	else
	return Error(playerid, "You do not have sufficient administration level to use this command.");


	SetPlayerPos(playerid, PosX, PosY, PosZ);
	return 1;
}


//EVENT COMMANDS MAINLY AND AN EVENTBANK


//************* L E V E L   F I V E   C O M M A N D S***************

CMD:c(playerid, params[])
{
	new msg[296], aname[24];
	if(pInfo[playerid][pAdmin] >= 5)
	if(sscanf(params, "s", msg))
	return AdminUsage(playerid, "/c [MESSAGE]");
	GetPlayerName(playerid, aname, 24);
	
	format(msg, sizeof(msg), "{00FFFF}<COUNCIL CHAT>{696969} %s(%d): %s", aname, playerid, msg);

	for(new i = 0; i < MAX_PLAYERS; i++)
	if(pInfo[i][pAdmin] >= 5)
	{
	SendClientMessage(i, -1, msg);
	}
	else
	Error(playerid, "You do not have sufficient administration level to use this command");

	return 1;
}


CMD:unban(playerid, params[])
{

	return 1;
}

CMD:aka(playerid,params[])
{
    new ppID, accounts[6][MAX_PLAYER_NAME], string[256];
    if(pInfo[playerid][pAdmin] >= 5)
    {
    if(!sscanf(params,"u",ppID)) return AdminUsage(playerid, "/aka [PLAYERID]");
    if(!IsPlayerConnected(ppID)) return Error(playerid, "The player is not connected.");
    AKA(playerid,accounts);
    if(accounts[0][0] == '\0') return AdminUsage(playerid,"This player doesn't have any more account.");
    for(new i; i<sizeof(accounts); i++)
    {
        if(accounts[i][0] == '\0') break;
        format(string,sizeof(string),"%sPlayerName: %s\n",string,accounts[i]);
    }
    return ShowPlayerDialog(playerid,999,DIALOG_STYLE_MSGBOX,"All Player Accounts",string,!"Okay",!"");
    }
    else
	Error(playerid, "You do not have sufficient administration level to use this command.");
	return 1;
}







// TO DO LIST

//SAVABLE COPWARN, ARMYWARN, COPBAN, ARMYBAN system, /unbanme command to get cop and army unbanned.
//BAN SYSTEM AFTER REACHING HOME FOR LVL 3
//SUSPEND FOR LVL 2
//EVENTBANK SYSTEM AND EVENT COMMANDS FOR LEVEL 4
