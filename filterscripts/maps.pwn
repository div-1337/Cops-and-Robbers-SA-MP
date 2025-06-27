// This is a comment
// uncomment the line below if you want to write a filterscript
#define FILTERSCRIPT

#include <a_samp>
#include <streamer>
#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" MAP");
	print("--------------------------------------\n");
	//************************************************************
	//T H E    S A N    F I E R R O    B A N K    I N T E R I O R
	//************************************************************


    //**********************************************************
    //**********S U P A    S A V E    I N T E R I O R***********
	//**********************************************************
	new supaint[39];

	supaint[0] = CreateDynamicObject(18981, 1515.365356, 1588.808105, 9.368094, 0.000000, -90.000053, 0.000000, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[0], 0, 11301, "carshow_sfse", "concreteslab_small", 0);
	supaint[1] = CreateDynamicObject(18981, 1502.835571, 1588.808105, 8.381869, 94.499969, -90.000053, -90.000007, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[1], 0, 16150, "ufo_bar", "GEwhite1_64", 0);
	supaint[2] = CreateDynamicObject(18981, 1515.382812, 1601.327026, 9.369312, 94.499969, 179.999984, -90.000007, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[2], 0, 16150, "ufo_bar", "GEwhite1_64", 0);
	supaint[3] = CreateDynamicObject(18981, 1527.977661, 1588.808105, 10.360594, 94.499969, -90.000053, -90.000007, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[3], 0, 16150, "ufo_bar", "GEwhite1_64", 0);
	supaint[4] = CreateDynamicObject(18981, 1515.382812, 1576.297363, 9.369312, 94.799980, 179.999984, -90.000007, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[4], 0, 16150, "ufo_bar", "GEwhite1_64", 0);
	supaint[5] = CreateDynamicObject(1557, 1513.052490, 1576.752807, 9.758090, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[6] = CreateDynamicObject(1557, 1516.043212, 1576.741088, 9.758090, 0.000000, 0.000000, 179.499938, .interiorid = 1);
	supaint[7] = CreateDynamicObject(19326, 1509.029785, 1600.825439, 13.698098, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[8] = CreateDynamicObject(19326, 1521.438842, 1600.825439, 13.938102, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[9] = CreateDynamicObject(18764, 1527.728637, 1600.027221, 8.468102, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[9], 0, 18202, "w_towncs_t", "hatwall256hi", 0);
	supaint[10] = CreateDynamicObject(18764, 1503.229370, 1600.027221, 8.468102, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[10], 0, 18202, "w_towncs_t", "hatwall256hi");
	supaint[11] = CreateDynamicObject(19553, 1526.610961, 1599.316284, 10.996887, 17.100004, -99.500045, -13.399999, .interiorid = 1);
	supaint[12] = CreateDynamicObject(19554, 1526.873291, 1600.418945, 11.058105, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[13] = CreateDynamicObject(19555, 1526.102539, 1599.992187, 11.058098, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[14] = CreateDynamicObject(19556, 1525.873413, 1599.324340, 11.058099, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[15] = CreateDynamicObject(19557, 1525.873413, 1597.884521, 11.048103, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[16] = CreateDynamicObject(19558, 1525.873413, 1598.883911, 11.048103, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[17] = CreateDynamicObject(19559, 1526.463500, 1598.688842, 10.936798, -91.399971, 0.000000, 0.000000, .interiorid = 1);
	supaint[18] = CreateDynamicObject(19559, 1527.144165, 1600.178466, 10.900393, -91.399971, 0.000000, 155.199951, .interiorid = 1);
	supaint[19] = CreateDynamicObject(19592, 1525.543457, 1600.028686, 11.458106, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[20] = CreateDynamicObject(19470, 1526.475585, 1600.563598, 10.868101, 0.000000, 0.000000, -127.700019, .interiorid = 1);
	supaint[21] = CreateDynamicObject(19528, 1503.693847, 1598.464477, 11.087175, 0.000000, -85.999992, 0.000000, .interiorid = 1);
	supaint[22] = CreateDynamicObject(19528, 1504.880737, 1600.384277, 11.004165, 0.000000, -85.999992, 0.000000, .interiorid = 1);
	supaint[23] = CreateDynamicObject(19528, 1504.502563, 1599.254028, 11.150521, 0.000000, 143.899932, 0.000000, .interiorid = 1);
	supaint[24] = CreateDynamicObject(19830, 1503.694824, 1600.378784, 10.948090, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[25] = CreateDynamicObject(19830, 1505.494506, 1598.108520, 10.948090, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[26] = CreateDynamicObject(3206, 1504.845214, 1599.568725, 11.138088, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[27] = CreateDynamicObject(3026, 1504.651733, 1598.365478, 10.932405, -92.800003, 0.000000, 0.000000, .interiorid = 1);
	supaint[28] = CreateDynamicObject(1580, 1504.199584, 1600.061279, 10.868084, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[29] = CreateDynamicObject(1550, 1505.171752, 1599.098876, 11.308087, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[30] = CreateDynamicObject(1550, 1503.402709, 1598.038818, 11.271304, 0.000000, -31.699998, 0.000000, .interiorid = 1);
	supaint[31] = CreateDynamicObject(1848, 1523.770996, 1590.738159, 9.768079, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[32] = CreateDynamicObject(1848, 1506.890380, 1590.738159, 9.768079, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[33] = CreateDynamicObject(1891, 1506.704589, 1585.848754, 9.508102, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[34] = CreateDynamicObject(1891, 1523.825317, 1585.848754, 9.508102, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[35] = CreateDynamicObject(2413, 1514.948730, 1596.728271, 9.648090, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[36] = CreateDynamicObject(2484, 1515.103637, 1600.230957, 10.618086, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[37] = CreateDynamicObject(2369, 1515.791748, 1596.840209, 10.668084, 0.000000, 0.000000, 0.000000, .interiorid = 1);
	supaint[38] = CreateDynamicObject(18981, 1514.907714, 1588.808105, 21.284147, 0.000000, -94.800018, 0.000000, .interiorid = 1);
	SetDynamicObjectMaterial(supaint[38], 0, 16150, "ufo_bar", "offwhitebrix");
	
	
	//***********************************----------------------------------***********************************
	//**********************************---- V I P    L O U N G E --------************************************
	//**********************************-----------------------------------***********************************
	
	
	new viplounge[123];

	viplounge[0] = CreateDynamicObject(18981, -1194.394287, -284.791473, 12.814048, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[0], 0, 10932, "station_sfse", "ws_stationfloor", 0);
	viplounge[1] = CreateDynamicObject(18981, -1194.394287, -309.720642, 12.814048, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[1], 0, 10932, "station_sfse", "ws_stationfloor", 0);
	viplounge[2] = CreateDynamicObject(18981, -1194.384521, -322.678527, 25.619361, -90.200004, -87.600189, 2.400000);
	SetDynamicObjectMaterial(viplounge[2], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[3] = CreateDynamicObject(18981, -1194.384521, -271.829681, 25.441984, -90.200004, -87.600189, 2.400000);
	SetDynamicObjectMaterial(viplounge[3], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[4] = CreateDynamicObject(14407, -1195.533325, -274.230957, 16.321886, 0.000000, 0.000000, -90.199974);
	SetDynamicObjectMaterial(viplounge[4], 0, 10412, "hotel1", "carpet_red_256", 0);
	viplounge[5] = CreateDynamicObject(14407, -1200.974975, -274.180297, 19.981971, 0.000000, 0.000000, -90.199974);
	SetDynamicObjectMaterial(viplounge[5], 0, 10412, "hotel1", "carpet_red_256", 0);
	viplounge[6] = CreateDynamicObject(18981, -1200.493041, -276.261718, 10.676431, -90.200004, -87.600189, 2.400000);
	SetDynamicObjectMaterial(viplounge[6], 0, 10969, "scum_sfse", "Was_scrpyd_floor_hangar", 0);
	viplounge[7] = CreateDynamicObject(14407, -1195.694824, -320.270294, 16.321886, 0.000000, 0.000000, -90.199974);
	SetDynamicObjectMaterial(viplounge[7], 0, 10412, "hotel1", "carpet_red_256", 0);
	viplounge[8] = CreateDynamicObject(14407, -1201.134765, -320.260131, 19.981971, 0.000000, 0.000000, -90.199974);
	SetDynamicObjectMaterial(viplounge[8], 0, 10412, "hotel1", "carpet_red_256", 0);
	viplounge[9] = CreateDynamicObject(18981, -1200.523071, -318.171539, 10.622564, -90.200004, -87.600189, 2.400000);
	SetDynamicObjectMaterial(viplounge[9], 0, 10969, "scum_sfse", "Was_scrpyd_floor_hangar", 0);
	viplounge[10] = CreateDynamicObject(18981, -1215.409912, -284.791473, 22.684047, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[10], 0, 9953, "ottos_sfw", "carshowroomfloor", 0);
	viplounge[11] = CreateDynamicObject(18981, -1215.409912, -309.800811, 22.684047, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[11], 0, 9953, "ottos_sfw", "carshowroomfloor", 0);
	viplounge[12] = CreateDynamicObject(18981, -1215.409912, -309.800811, 37.834144, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[12], 0, 10932, "station_sfse", "ws_stationfloor", 0);
	viplounge[13] = CreateDynamicObject(18981, -1215.409912, -284.811279, 37.834144, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[13], 0, 10932, "station_sfse", "ws_stationfloor", 0);
	viplounge[14] = CreateDynamicObject(18981, -1194.459960, -284.811279, 37.834144, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[14], 0, 10932, "station_sfse", "ws_stationfloor", 0);
	viplounge[15] = CreateDynamicObject(18981, -1194.464965, -309.800811, 37.834144, 0.000000, 89.999916, 0.000000);
	SetDynamicObjectMaterial(viplounge[15], 0, 10932, "station_sfse", "ws_stationfloor", 0);
	viplounge[16] = CreateDynamicObject(18981, -1215.341918, -271.829681, 25.438835, -90.200004, -87.600189, 2.400000);
	SetDynamicObjectMaterial(viplounge[16], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[17] = CreateDynamicObject(18981, -1215.524902, -322.678527, 25.616350, -90.200004, -87.600189, 2.400000);
	SetDynamicObjectMaterial(viplounge[17], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[18] = CreateDynamicObject(18981, -1227.523437, -309.675079, 25.249561, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[18], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[19] = CreateDynamicObject(18981, -1227.436767, -284.685913, 25.162418, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[19], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[20] = CreateDynamicObject(18981, -1182.376098, -309.833648, 25.256633, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[20], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[21] = CreateDynamicObject(18981, -1182.286987, -284.843597, 25.169504, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[21], 0, 5737, "melrose16_lawn", "creamshop1_LAe", 0);
	viplounge[22] = CreateDynamicObject(18981, -1207.326293, -284.806121, 10.565666, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[22], 0, 3947, "rczero_track", "waterclear256", 0);
	viplounge[23] = CreateDynamicObject(18981, -1207.400512, -305.386260, 10.437474, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[23], 0, 3947, "rczero_track", "waterclear256", 0);
	viplounge[24] = CreateDynamicObject(18981, -1206.341796, -284.811523, 10.565812, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[24], 0, 1649, "wglass", "carshowwin2", 0);
	viplounge[25] = CreateDynamicObject(18981, -1206.429077, -308.819946, 10.589492, -90.200004, 2.599760, 2.400000);
	SetDynamicObjectMaterial(viplounge[25], 0, 1649, "wglass", "carshowwin2", 0);
	viplounge[26] = CreateDynamicObject(1609, -1206.308715, -315.162139, 19.951288, 0.000000, 93.899887, 0.000000);
	viplounge[27] = CreateDynamicObject(1609, -1206.544189, -307.281951, 16.499334, 0.000000, 93.899887, 0.000000);
	viplounge[28] = CreateDynamicObject(1609, -1206.544189, -299.102050, 16.499334, 0.000000, -78.400070, 0.000000);
	viplounge[29] = CreateDynamicObject(1609, -1206.544189, -279.932312, 16.499334, 0.000000, -67.900215, 0.000000);
	viplounge[30] = CreateDynamicObject(1609, -1206.958374, -288.352203, 19.172445, 0.000000, 89.299880, -0.699998);
	viplounge[31] = CreateDynamicObject(1602, -1206.378295, -294.480682, 18.884063, 0.000000, 0.000000, 0.000000);
	viplounge[32] = CreateDynamicObject(1602, -1206.378295, -312.220428, 18.884063, 0.000000, 0.000000, 0.000000);
	viplounge[33] = CreateDynamicObject(1602, -1206.378295, -303.110473, 14.344041, 0.000000, 0.000000, 0.000000);
	viplounge[34] = CreateDynamicObject(1602, -1206.378295, -293.990570, 19.134069, 0.000000, 0.000000, 0.000000);
	viplounge[35] = CreateDynamicObject(1602, -1206.378295, -295.000732, 19.074068, 0.000000, 0.000000, 0.000000);
	viplounge[36] = CreateDynamicObject(1602, -1206.378295, -311.830200, 18.414051, 0.000000, 0.000000, 0.000000);
	viplounge[37] = CreateDynamicObject(1603, -1206.607177, -300.188629, 20.954120, 0.000000, 0.000000, 0.000000);
	viplounge[38] = CreateDynamicObject(1603, -1206.607177, -300.918518, 21.004121, 0.000000, 0.000000, 0.000000);
	viplounge[39] = CreateDynamicObject(1603, -1206.607177, -282.438842, 17.114107, 0.000000, 0.000000, 0.000000);
	viplounge[40] = CreateDynamicObject(1603, -1206.607177, -277.079345, 21.094097, 0.000000, 0.000000, 0.000000);
	viplounge[41] = CreateDynamicObject(902, -1206.504394, -309.552825, 19.327104, 0.000000, 100.000083, 0.000000);
	viplounge[42] = CreateDynamicObject(1608, -1207.035278, -288.875549, 16.532783, 2.100003, 36.999954, 0.000000);
	viplounge[43] = CreateDynamicObject(1607, -1206.696655, -313.421997, 14.959921, 0.000000, 53.800025, 0.000000);
	viplounge[44] = CreateDynamicObject(18885, -1226.385986, -321.534454, 24.184055, 0.000000, 0.000000, 132.399978);
	viplounge[45] = CreateDynamicObject(18885, -1226.244750, -273.019958, 24.134054, 0.000000, 0.000000, 46.100028);
	viplounge[46] = CreateDynamicObject(1557, -1182.783081, -293.208587, 13.294028, 0.000000, 0.000000, -90.299919);
	viplounge[47] = CreateDynamicObject(1557, -1182.804443, -296.228729, 13.294028, 0.000000, 0.000000, 89.800155);
	viplounge[48] = CreateDynamicObject(3471, -1183.761474, -292.425964, 14.314043, 0.000000, 0.000000, 178.700027);
	viplounge[49] = CreateDynamicObject(3471, -1183.865478, -296.985107, 14.314043, 0.000000, 0.000000, 178.700027);
	viplounge[50] = CreateDynamicObject(2311, -1198.803100, -294.347442, 13.304053, 0.000000, 0.000000, -91.599983);
	viplounge[51] = CreateDynamicObject(19525, -1198.836547, -295.119628, 13.774043, 0.000000, 0.000000, 0.000000);
	viplounge[52] = CreateDynamicObject(19822, -1198.805908, -295.814056, 13.774043, 0.000000, 0.000000, 0.000000);
	viplounge[53] = CreateDynamicObject(19822, -1198.805908, -294.514312, 13.774043, 0.000000, 0.000000, 0.000000);
	viplounge[54] = CreateDynamicObject(19820, -1198.819458, -294.297882, 13.764054, 0.000000, 0.000000, 0.000000);
	viplounge[55] = CreateDynamicObject(19820, -1198.819458, -296.017852, 13.764054, 0.000000, 0.000000, 0.000000);
	viplounge[56] = CreateDynamicObject(19819, -1198.918457, -295.528778, 13.884039, 0.000000, 0.000000, 0.000000);
	viplounge[57] = CreateDynamicObject(19819, -1198.918457, -294.738830, 13.884039, 0.000000, 0.000000, 0.000000);
	viplounge[58] = CreateDynamicObject(11682, -1197.771728, -293.126831, 13.294031, 0.000000, 0.000000, 0.000000);
	SetDynamicObjectMaterial(viplounge[58], 0, 11631, "mp_ranchcut", "mpkbsofa333c", 0);
	viplounge[59] = CreateDynamicObject(11685, -1198.795166, -293.127136, 13.294036, 0.000000, 0.000000, 0.000000);
	SetDynamicObjectMaterial(viplounge[59], 0, 11631, "mp_ranchcut", "mpkbsofa333c", 0);
	viplounge[60] = CreateDynamicObject(11685, -1197.655395, -294.538879, 13.344038, 0.000000, 0.000000, -92.199989);
	SetDynamicObjectMaterial(viplounge[60], 0, 11631, "mp_ranchcut", "mpkbsofa333c", 0);
	viplounge[61] = CreateDynamicObject(11685, -1197.699707, -295.707946, 13.344038, 0.000000, 0.000000, -92.199989);
	SetDynamicObjectMaterial(viplounge[61], 0, 11631, "mp_ranchcut", "mpkbsofa333c", 0);
	viplounge[62] = CreateDynamicObject(11685, -1198.792724, -297.036773, 13.294036, 0.000000, 0.000000, 179.400344);
	SetDynamicObjectMaterial(viplounge[62], 0, 11631, "mp_ranchcut", "mpkbsofa333c", 0);
	viplounge[63] = CreateDynamicObject(11684, -1197.734863, -296.999267, 13.284040, 0.000000, 0.000000, 177.500167);
	SetDynamicObjectMaterial(viplounge[63], 0, 11631, "mp_ranchcut", "mpkbsofa333c", 0);
	viplounge[64] = CreateDynamicObject(19128, -1193.576660, -304.206146, 13.264037, 0.000000, 0.000000, 0.000000);
	viplounge[65] = CreateDynamicObject(19128, -1197.539184, -304.206146, 13.264037, 0.000000, 0.000000, 0.000000);
	viplounge[66] = CreateDynamicObject(19128, -1193.576660, -300.306488, 13.264037, 0.000000, 0.000000, 0.000000);
	viplounge[67] = CreateDynamicObject(19128, -1197.539184, -300.256561, 13.264037, 0.000000, 0.000000, 0.000000);
	viplounge[68] = CreateDynamicObject(1963, -1195.290771, -314.635620, 13.534337, 0.000000, 0.000000, 179.800109);
	viplounge[69] = CreateDynamicObject(14820, -1195.332885, -314.634185, 14.014039, 0.000000, 0.000000, 0.000000);
	viplounge[70] = CreateDynamicObject(19786, -1198.340332, -276.656890, 17.464046, 0.000000, 0.000000, 0.000000);
	viplounge[71] = CreateDynamicObject(1703, -1199.303833, -283.449035, 13.274036, 0.000000, 0.000000, -179.800231);
	viplounge[72] = CreateDynamicObject(1703, -1196.372070, -283.439239, 13.264036, 0.000000, 0.000000, -179.800231);
	viplounge[73] = CreateDynamicObject(1703, -1193.904418, -281.694610, 13.264036, 0.000000, 0.000000, -139.500137);
	viplounge[74] = CreateDynamicObject(1703, -1202.247314, -283.332580, 13.274036, 0.000000, 0.000000, 150.699310);
	viplounge[75] = CreateDynamicObject(970, -1202.999389, -311.542114, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[76] = CreateDynamicObject(970, -1202.984252, -315.611846, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[77] = CreateDynamicObject(970, -1203.012939, -307.431823, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[78] = CreateDynamicObject(970, -1203.028320, -303.292144, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[79] = CreateDynamicObject(970, -1203.042480, -299.182128, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[80] = CreateDynamicObject(970, -1203.055786, -295.071899, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[81] = CreateDynamicObject(970, -1203.069702, -290.941833, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[82] = CreateDynamicObject(970, -1203.082763, -286.811645, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[83] = CreateDynamicObject(970, -1203.097778, -282.701934, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[84] = CreateDynamicObject(970, -1203.112548, -278.592041, 23.644041, 0.000000, 0.000000, 90.200149);
	viplounge[85] = CreateDynamicObject(16773, -1227.013183, -301.374847, 31.559658, 0.000000, 0.000000, -90.200080);
	SetDynamicObjectMaterial(viplounge[85], 0, 1676, "wshxrefpump", "black64", 0);
	viplounge[86] = CreateDynamicObject(16773, -1226.961669, -287.105621, 31.559658, 0.000000, 0.000000, -90.200080);
	SetDynamicObjectMaterial(viplounge[86], 0, 1676, "wshxrefpump", "black64", 0);
	viplounge[87] = CreateDynamicObject(16773, -1226.961669, -287.105621, 27.349515, 0.000000, 0.000000, -90.200080);
	SetDynamicObjectMaterial(viplounge[87], 0, 1676, "wshxrefpump", "black64", 0);
	viplounge[88] = CreateDynamicObject(16773, -1227.010986, -301.385101, 27.349515, 0.000000, 0.000000, -90.200080);
	SetDynamicObjectMaterial(viplounge[88], 0, 1676, "wshxrefpump", "black64", 0);
	viplounge[89] = CreateDynamicObject(2229, -1227.237915, -279.351043, 26.762460, 0.000000, 0.000000, 89.199935);
	viplounge[90] = CreateDynamicObject(2229, -1227.237915, -279.351043, 25.382448, 0.000000, 0.000000, 89.199935);
	viplounge[91] = CreateDynamicObject(2229, -1227.237915, -279.351043, 33.322456, 0.000000, 0.000000, 89.199935);
	viplounge[92] = CreateDynamicObject(2229, -1227.237915, -279.351043, 31.942562, 0.000000, 0.000000, 89.199935);
	viplounge[93] = CreateDynamicObject(2229, -1227.237915, -279.351043, 30.712568, 0.000000, 0.000000, 89.199935);
	viplounge[94] = CreateDynamicObject(2229, -1227.237915, -279.351043, 29.362546, 0.000000, 0.000000, 89.199935);
	viplounge[95] = CreateDynamicObject(2229, -1227.237915, -279.351043, 28.102491, 0.000000, 0.000000, 89.199935);
	viplounge[96] = CreateDynamicObject(2229, -1227.237915, -279.351043, 24.112400, 0.000000, 0.000000, 89.199935);
	viplounge[97] = CreateDynamicObject(2229, -1227.285888, -308.552551, 24.112400, 0.000000, 0.000000, 89.199935);
	viplounge[98] = CreateDynamicObject(2229, -1227.285888, -308.552551, 25.432420, 0.000000, 0.000000, 89.199935);
	viplounge[99] = CreateDynamicObject(2229, -1227.285888, -308.552551, 26.752458, 0.000000, 0.000000, 89.199935);
	viplounge[100] = CreateDynamicObject(2229, -1227.285888, -308.552551, 28.052408, 0.000000, 0.000000, 89.199935);
	viplounge[101] = CreateDynamicObject(2229, -1227.285888, -308.552551, 29.222389, 0.000000, 0.000000, 89.199935);
	viplounge[102] = CreateDynamicObject(2229, -1227.285888, -308.552551, 30.552452, 0.000000, 0.000000, 89.199935);
	viplounge[103] = CreateDynamicObject(2229, -1227.285888, -308.552551, 31.782419, 0.000000, 0.000000, 89.199935);
	viplounge[104] = CreateDynamicObject(2229, -1227.285888, -308.552551, 33.052440, 0.000000, 0.000000, 89.199935);
	viplounge[105] = CreateDynamicObject(1723, -1213.245117, -305.227569, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[106] = CreateDynamicObject(1723, -1213.185668, -299.548004, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[107] = CreateDynamicObject(1723, -1213.130859, -294.308105, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[108] = CreateDynamicObject(1723, -1213.073852, -288.898468, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[109] = CreateDynamicObject(1723, -1213.017333, -283.578491, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[110] = CreateDynamicObject(1723, -1212.956787, -278.147888, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[111] = CreateDynamicObject(1723, -1207.204956, -302.169006, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[112] = CreateDynamicObject(1723, -1207.149047, -296.879302, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[113] = CreateDynamicObject(1723, -1207.087768, -291.229400, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[114] = CreateDynamicObject(1723, -1207.033691, -286.169799, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[115] = CreateDynamicObject(1723, -1206.980346, -280.930389, 23.130447, 0.000000, 0.000000, -90.599990);
	viplounge[116] = CreateDynamicObject(2002, -1226.535766, -313.379791, 23.249483, 0.000000, 0.000000, 89.899940);
	viplounge[117] = CreateDynamicObject(19831, -1203.322143, -312.778411, 22.972904, 0.000000, 0.000000, -92.199874);
	viplounge[118] = CreateDynamicObject(14651, -1218.452026, -320.414581, 25.282859, 0.000000, 0.000000, 0.000000);
	viplounge[119] = CreateDynamicObject(16151, -1204.852172, -306.501617, 13.596198, 0.000000, 0.000000, -179.000442);
	viplounge[120] = CreateDynamicObject(16151, -1210.754516, -321.087890, 23.533208, 0.000000, 0.000000, -89.799972);
	viplounge[121] = CreateDynamicObject(2332, -1227.060302, -317.311401, 24.815744, 0.000000, 0.000000, 90.600067);
	viplounge[122] = CreateDynamicObject(2332, -1227.071899, -316.191528, 24.815744, 0.000000, 0.000000, 90.600067);

	
	
	
	
	
	
	
	
	
	
	
	
	
	
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
