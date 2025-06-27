/*


						 _____           _     _       
						|  __ \         | |   (_)      
						| |  | |_ __ ___| |__  _ _ __  
						| |  | | '__/ _ \ '_ \| | '_ \ 
						| |__| | | |  __/ |_) | | | | |
						|_____/|_|  \___|_.__/|_|_| |_|

							   ObjectEditor v1.0.0

								  ©Drebin 2012


*/

#define FILTERSCRIPT

#include <a_samp>
#include <dini>
#include <zcmd>
#include <sscanf2>
//==============================================================================
//                            > D E F I N E S <
//
//                 true = enabled/yes | false = disabled/no
//==============================================================================
#define RCON_ADMINS_ONLY					false		//Restrict the usage of the editor to RCON admins
#define TOGGLED_ONLY						false		//If true, an admin has to /toggleeditor the player first before they can use the editor.
#define ALLOW_USE_3D_LABELS					true		//Allow the user to enable 3D text labels attached to objects
#define USE_COMMAND_SHORTCUTS				true		//Allow the usage of command shortcuts (eg. /createnewobject -> /cno)
#define USE_MAX_CREATE_DISTANCE 			true		//Restrict the distance an object is create from the player
#define USE_MAX_MOVE_DISTANCE				true		//Restict the max. distance a player can move the object
#define MAX_CREATE_DISTANCE					200.0		//The max. distance a player can enter when he creates an object (only if USEMAX_CREATE_DISTANCE is enabled)
#define MAX_MOVE_DISTANCE 					400.0		//The max. distance a player can move an object (only if MAX_CREATE_DISTANCE is enabled)
#define ALLOW_EXPORT_MAP_FILE				false		//Allow normal players to export an object file? (if disabled, only RCON admins can)
#define ALLOW_EDIT_OBJECT_ON_DUPLICATE 		true		//Allow a player to enable the auto edition of an object after it has been duplicated
#define ALLOW_USE_MATERIAL_CHANGE_DIALOG	true		//Allow the player to use the material change dialog (recommended)
#define ALLOW_EDIT_OBJECT_ON_CREATE 		true		//Allow a player to enable the auto edition of an object after creating it
#define ALLOW_KEEP_MATERIAL					false		//Allow a player to enable a function which keeps the cusrom texture after changing the model of the object
#define ALLOW_USE_CROSS						true		//Allow a player to enable the fade cross when he's in the flyeditor
#define ALLOW_TRANSFER_MATERIAL				true		//If a player duplicates an object with a custom material(texture) on it, this allows him to
														//-> enable a setting which automatically transfers the material to the duplicated object
//==============================================================================
//                           > D I A L O G   I D S <
//==============================================================================
#define DIALOG_MAINMENU 1693
#define DIALOG_MAP_SAVENAME 1694
#define DIALOG_MAP_EXPORTNAME 1695
#define DIALOG_MAP_LOAD 1696
#define DIALOG_SELECTMENU 1697
#define DIALOG_CHANGEMODEL 1698
#define DIALOG_MATERIALS 1699
#define DIALOG_MATERIALINDEX 1700
#define DIALOG_MODELID 1701
#define DIALOG_TXDNAME 1702
#define DIALOG_TEXTURENAME 1703
#define DIALOG_COLOR 1704
#define DIALOG_SETTINGS 1705
#define DIALOG_EDITORCOMMANDS 1706
#define DIALOG_EDITORCOMMANDS2 1707
#define DIALOG_SETTINGSHELP 1708
//==============================================================================
//                        > C O L O R  D E F I N E S <
//==============================================================================
#define COLOR_USAGE 	0x91FF91FF		//{91FF91} - The color of the command usage
#define COLOR_USAGE2 	0x87FF87FF		//{87FF87} - The color of the command parameter explanation
#define COLOR_WARNING 	0xF58282FF	    //{F58282} - The color of the red error messages
#define COLOR_INFO 		0xF5F582FF		//{F5F582} - The color of the info messages
										//{A9C4E4} - default dialog color
//==============================================================================

//==============================================================================
//------------------------------------------------------------------------------
// !!!  D O  N O T  C H A N G E  V A L U E S  B E L O W  T H I S  L I N E  !!!
//------------------------------------------------------------------------------
//==============================================================================
#define INVALID_OBJECT_NUMBER (-1)
#define MAX_CREATED_OBJECTS 400

#define MOVE_FORWARD    		1
#define MOVE_BACK       		2
#define MOVE_LEFT       		3
#define MOVE_RIGHT      		4
#define MOVE_FORWARD_LEFT       5
#define MOVE_FORWARD_RIGHT      6
#define MOVE_BACK_LEFT          7
#define MOVE_BACK_RIGHT         8

#define MOVE_SPEED              100.0
#define ACCEL_RATE              0.03

enum objectenum
{
	created,
	objectID,
	modelID,
	Float:XLoc,
	Float:YLoc,
	Float:ZLoc,
	Float:XRot,
	Float:YRot,
	Float:ZRot,
	usesmaterial,
	indexused,
	modelused,
	txdused,
	textureused,
	colorused,
	matindex,
	matmodel,
	PlayerText3D:labelID
};

enum playerenum
{
	bool:EditObjectOnCreate,
	bool:EditObjectOnDuplicate,
	bool:UseMaterialDialog,
	bool:TransferMaterial,
	bool:KeepMaterial,
	bool:UseCross,
	bool:UseLabels,
	bool:editing,
	totalobjects,
	editobject,
	flyeditor,
	flyobject,
	mode,
	lrold,
	udold,
	lastmove,
	Float:accelmul,
	Float:poX,
	Float:poY,
	Float:poZ,
	canuse
};

new pInfo[MAX_PLAYERS][playerenum];
new oInfo[MAX_PLAYERS][MAX_CREATED_OBJECTS][objectenum];

new PlayerText:Cross[2];

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("-----------------------------------------------------------------------------\n");
	print("                         > Drebin's Object Editor <                          ");
	print("                                   v1.0.0                                    ");
	print("                                                                             ");
	print("                                ©Drebin 2012                                 ");
	print("                                                                             ");
	print("-----------------------------------------------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	for(new i = 0; i <= MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
			Endflyeditor(i);
	}
	return 1;
}

#endif

public OnPlayerConnect(playerid)
{
	ResetAllValues(playerid);
	pInfo[playerid][canuse]					= false;
	pInfo[playerid][EditObjectOnCreate] 	= false;
	pInfo[playerid][EditObjectOnDuplicate] 	= false;
	pInfo[playerid][UseMaterialDialog] 		= true;
	pInfo[playerid][TransferMaterial] 		= true;
	pInfo[playerid][KeepMaterial]			= true;
	pInfo[playerid][UseCross]				= false;
	pInfo[playerid][lrold]	   	 			= 0;
	pInfo[playerid][udold]   				= 0;
	pInfo[playerid][mode]   				= 0;
	pInfo[playerid][lastmove]   			= 0;
	pInfo[playerid][accelmul]   			= 0.0;
	Cross[0] = CreatePlayerTextDraw(playerid, 320.000000, 221.000000, "_");
	PlayerTextDrawAlignment(playerid, Cross[0], 2);
	PlayerTextDrawBackgroundColor(playerid, Cross[0], 255);
	PlayerTextDrawFont(playerid, Cross[0], 1);
	PlayerTextDrawLetterSize(playerid, Cross[0], 0.500000, 1.400000);
	PlayerTextDrawColor(playerid, Cross[0], -1);
	PlayerTextDrawSetOutline(playerid, Cross[0], 0);
	PlayerTextDrawSetProportional(playerid, Cross[0], 1);
	PlayerTextDrawSetShadow(playerid, Cross[0], 1);
	PlayerTextDrawUseBox(playerid, Cross[0], 1);
	PlayerTextDrawBoxColor(playerid, Cross[0], -1);
	PlayerTextDrawTextSize(playerid, Cross[0], 0.000000, -3.000000);

	Cross[1] = CreatePlayerTextDraw(playerid, 320.000000, 229.000000, "_");
	PlayerTextDrawAlignment(playerid, Cross[1], 2);
	PlayerTextDrawBackgroundColor(playerid, Cross[1], 255);
	PlayerTextDrawFont(playerid, Cross[1], 1);
	PlayerTextDrawLetterSize(playerid, Cross[1], 0.500000, -0.400000);
	PlayerTextDrawColor(playerid, Cross[1], -1);
	PlayerTextDrawSetOutline(playerid, Cross[1], 0);
	PlayerTextDrawSetProportional(playerid, Cross[1], 1);
	PlayerTextDrawSetShadow(playerid, Cross[1], 1);
	PlayerTextDrawUseBox(playerid, Cross[1], 1);
	PlayerTextDrawBoxColor(playerid, Cross[1], -1);
	PlayerTextDrawTextSize(playerid, Cross[1], 0.000000, 13.000000);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Endflyeditor(playerid);
	ResetAllValues(playerid);
	pInfo[playerid][canuse]	= false;
	return 1;
}

CMD:openeditor(playerid, params[])
{
	#if RCON_ADMINS_ONLY == true
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_WARNING,"Sorry, the object editor is for RCON admins only.");
	#endif
	#if TOGGLED_ONLY == true
	if(pInfo[playerid][canuse] != 1) return SendClientMessage(playerid, COLOR_WARNING, "Sorry, you have to ask an admin first before you can use the object editor.");
	#endif
	if(pInfo[playerid][editing] == false)
	{
		SendClientMessage(playerid, -1, "[Editor {91FF91}ON{FFFFFF}]");
		SendClientInfoMessage(playerid, "You have entered the object editor.");
		pInfo[playerid][editing] = true;
	}
	else
	{
		SendClientMessage(playerid, -1, "[Editor {F58282}OFF{FFFFFF}]");
		DeleteAllObjects(playerid);
		ResetAllValues(playerid);
		SendClientInfoMessage(playerid, "You have left the editor. | All your objects have been automatically deleted.");
		pInfo[playerid][editing] = false;
	}
	return 1;
}

CMD:cno(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_createnewobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:createnewobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new model, Float:distance;
  	if(sscanf(params, "iF(10.0)", model, distance))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /createnewobject [modelid] <distance>");
		SendClientMessage(playerid, COLOR_USAGE2, "> Creates a new object using the defined model ID and distance.");
		SendClientMessage(playerid, COLOR_USAGE2, "> If no distance is entered, the default value of 10.0m is used.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /cno.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_CREATE_DISTANCE == true
			if(distance > MAX_CREATE_DISTANCE) return SendClientErrorMessage(playerid, 5);
			#endif
		    for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
		    {
		        if(oInfo[playerid][i][created] == 0)
		        {
		            oInfo[playerid][i][created] = 1;
					if(pInfo[playerid][flyeditor] == 1)
					{
								new
									Float:fPX, Float:fPY, Float:fPZ,
									Float:fVX, Float:fVY, Float:fVZ;
								GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
								GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);
								oInfo[playerid][i][modelID]  = model;
								oInfo[playerid][i][XLoc] = fPX + floatmul(fVX, distance);
								oInfo[playerid][i][YLoc] = fPY + floatmul(fVY, distance);
								oInfo[playerid][i][ZLoc] = fPZ + floatmul(fVZ, distance);
								oInfo[playerid][i][XRot] 	 = 0.0;
								oInfo[playerid][i][YRot] 	 = 0.0;
								oInfo[playerid][i][ZRot] 	 = 0.0;
								oInfo[playerid][i][objectID] = CreateObject(model,oInfo[playerid][i][XLoc], oInfo[playerid][i][YLoc], oInfo[playerid][i][ZLoc],0,0,0);
								pInfo[playerid][totalobjects]		 ++;
								new string[100];
								format(string, sizeof(string), "Created object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) %.1f meter infront of you.", i, oInfo[playerid][i][modelID], distance);
								SendClientMessage(playerid, COLOR_INFO, string);
					}
					else
					{
						new Float:X, Float:Y, Float:Z;
						new Float:rot;
						GetPlayerPos(playerid, X, Y, Z);
						if(IsPlayerInAnyVehicle(playerid))
							GetVehicleZAngle(GetPlayerVehicleID(playerid), rot);
						else
							GetPlayerFacingAngle(playerid, rot);
						oInfo[playerid][i][modelID]  = model;
						oInfo[playerid][i][XLoc] 	 = X + (distance * floatsin(-rot, degrees));
						oInfo[playerid][i][YLoc] 	 = Y + (distance * floatcos(-rot, degrees));
						oInfo[playerid][i][ZLoc] 	 = Z;
						oInfo[playerid][i][XRot] 	 = 0.0;
						oInfo[playerid][i][YRot] 	 = 0.0;
						oInfo[playerid][i][ZRot] 	 = 0.0;
						oInfo[playerid][i][objectID] = CreateObject(model,X + (distance * floatsin(-rot, degrees)), Y + (distance * floatcos(-rot, degrees)), Z,0,0,0);
						pInfo[playerid][totalobjects]		 ++;
						new string[100];
						format(string, sizeof(string), "Created object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) %.1f meter infront of you.", i, oInfo[playerid][i][modelID], distance);
						SendClientMessage(playerid, COLOR_INFO, string);
					}
					#if ALLOW_EDIT_OBJECT_ON_CREATE == true
					if(pInfo[playerid][EditObjectOnCreate] == true)
					{
						pInfo[playerid][editobject] = i;
						EditObject(playerid, oInfo[playerid][i][objectID]);
					}
					#endif
					#if ALLOW_USE_3D_LABELS == true
					if(pInfo[playerid][UseLabels] == true)
					{
						new labeltext[200];
						format(labeltext, 200, "Object Number: %i\nModel ID: %i\nRotation: 0.0, 0.0, 0.0", i, model);
						oInfo[playerid][i][labelID] = CreatePlayer3DTextLabel(playerid, labeltext, -1, oInfo[playerid][i][XLoc], oInfo[playerid][i][YLoc], oInfo[playerid][i][ZLoc], 10.0, 0, 0, 0);
					}
					#endif
	                break;
				}
			}
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:deo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_deleteobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:deleteobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
    new object;
  	if(sscanf(params, "i", object))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /deleteobject [object number]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Deleted the defined object number.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /deo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] !=0)
		{
		    if(oInfo[playerid][object][created] == 1)
		    {
		        DestroyObject(oInfo[playerid][object][objectID]);
		        pInfo[playerid][totalobjects]--;
		        new string[100];
		        format(string, sizeof(string), "You have succesfully deleted object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}).", object, oInfo[playerid][object][modelID]);
		        SendClientMessage(playerid, COLOR_INFO, string);
		        oInfo[playerid][object][created] 		= 0;
		        oInfo[playerid][object][objectID]		= INVALID_OBJECT_ID;
	         	oInfo[playerid][object][modelID] 		= 0;
	         	oInfo[playerid][object][XLoc] 			= 0.0;
	         	oInfo[playerid][object][YLoc] 			= 0.0;
	         	oInfo[playerid][object][ZLoc] 			= 0.0;
	         	oInfo[playerid][object][XRot] 			= 0.0;
	         	oInfo[playerid][object][YRot] 			= 0.0;
	         	oInfo[playerid][object][ZRot] 			= 0.0;
				oInfo[playerid][object][indexused] 		= 0;
				oInfo[playerid][object][modelused] 		= 0;
				oInfo[playerid][object][txdused] 		= 0;
				oInfo[playerid][object][textureused] 	= 0;
				oInfo[playerid][object][colorused] 		= 0;
				oInfo[playerid][object][matindex] 		= -1;
				oInfo[playerid][object][matmodel] 		= -1;
				new str1[15], str2[15], str3[15];
				format(str1, sizeof(str1), "%i_txdname", object);
				format(str2, sizeof(str2), "%i_texturename", object);
				format(str3, sizeof(str3), "%i_color", object);
				DeletePVar(playerid, str1);
				DeletePVar(playerid, str2);
				DeletePVar(playerid, str3);
				oInfo[playerid][object][usesmaterial] = 0;
		    }
		    else
		    {
		        SendClientErrorMessage(playerid, 0);
			}
		}
		else
		{
		    SendClientErrorMessage(playerid, 1);
		}
	}
	return 1;
}

CMD:deao(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_deleteallobjects(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:deleteallobjects(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	if(pInfo[playerid][totalobjects] !=0)
	{
	    DeleteAllObjects(playerid);
	    SendClientInfoMessage(playerid, "You have successfully deleted all objects.");
	}
	else SendClientErrorMessage(playerid, 1);
	return 1;
}

CMD:neo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_nearestobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:nearestobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	if(pInfo[playerid][totalobjects] != 0)
	{
		if(pInfo[playerid][flyeditor] == 1) return SendClientErrorMessage(playerid, 9);
 		new Float: px, Float: py, Float: pz;
 		new Float: oX, Float: oY, Float: oZ;
 		GetPlayerPos(playerid, px, py, pz);
 		new Float:currentdistance, Float:distance = 99999999.9;
 		new object;
 		for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
 		{
 		    GetObjectPos(oInfo[playerid][i][objectID], oX, oY, oZ);
 		    currentdistance = GetPlayerDistanceFromPoint(playerid, oX, oY, oZ);
 		    if(currentdistance < distance)
 		    {
 		        object = i;
 		        distance = currentdistance;
 		    }
 		}
		new string[128];
		format(string,sizeof(string),"The closest object to you is object number {F58282}%i{F5F582} (Distance: %.1fm).", object, distance);
	    SendClientInfoMessage(playerid, string);
	}
 	else
	{
	    SendClientErrorMessage(playerid, 1);
	}
	return 1;
}

CMD:goo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_gotoobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:gotoobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7);
	if(pInfo[playerid][flyeditor] == 1) return SendClientErrorMessage(playerid, 9);	
    new object;
  	if(sscanf(params, "i", object))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /gotoobject [object number]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Teleports you to the defined object number.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /goo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] != 0)
	    {
	        if(oInfo[playerid][object][created] == 1)
	        {
				new Float:X, Float:Y, Float:Z;
				new string[100];
	            GetObjectPos(oInfo[playerid][object][objectID], X, Y, Z);
	            SetPlayerPos(playerid, X + 1.0, Y + 1.0, Z + 5.0);
	            format(string, sizeof(string), "You have teleported yourself to object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}).", object, oInfo[playerid][object][modelID]);
	            SendClientInfoMessage(playerid, string);
	        }
	        else
	        {
	            SendClientErrorMessage(playerid, 0);
	        }
	    }
	    else
	    {
			SendClientErrorMessage(playerid, 1);
	    }
	}
	return 1;
}

CMD:rpom(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_replaceobjectmodel(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:replaceobjectmodel(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
    new object, model, oldmodel;
  	if(sscanf(params, "ii", object, model))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /replaceobjectmodel [object number] [new model]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Replaces the model of the defined object number with the new model.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /rpom.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] != 0)
	    {
	        if(oInfo[playerid][object][created] == 1)
	        {
	            oldmodel = oInfo[playerid][object][modelID];
				DestroyObject(oInfo[playerid][object][objectID]);
				oInfo[playerid][object][objectID] = CreateObject(model, oInfo[playerid][object][XLoc],oInfo[playerid][object][YLoc],oInfo[playerid][object][ZLoc],oInfo[playerid][object][XRot],oInfo[playerid][object][YRot],oInfo[playerid][object][ZRot]);
                oInfo[playerid][object][modelID] = model;
				if(oInfo[playerid][object][usesmaterial] == 1){
					if(pInfo[playerid][KeepMaterial] == true){
							ChangeObjectMaterial(playerid, object);
					}
					else
						ResetObjectMaterial(playerid, object);
				}
                new string[135];
                format(string, sizeof(string), "You succesfully replaced the model of object {F58282}%i{F5F582} (Model: {F58282}%i{F5F582}) with model {F58282}%i{F5F582}.", object, oldmodel, model);
                SendClientInfoMessage(playerid, string);
			}
	        else
	        {
	            SendClientErrorMessage(playerid, 0);
	        }
	    }
	    else
	    {
			SendClientErrorMessage(playerid, 1);
	    }
	}
	return 1;
}

CMD:saveobjects(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	{
		new dg1[60];
		format(dg1, sizeof(dg1), "Enter the name of the file you want to save the objects in:");
		ShowPlayerDialog(playerid, DIALOG_MAP_SAVENAME, DIALOG_STYLE_INPUT,"Save objects",dg1,"Save","Cancel");
	}
	return 1;
}

CMD:exportobjects(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	#if ALLOW_EXPORT_MAP_FILE == false
		if(IsPlayerAdmin(playerid))
		{
			new dg1[65];
			format(dg1, sizeof(dg1), "Enter the name of the file you want to export the objects to:");
			ShowPlayerDialog(playerid, DIALOG_MAP_EXPORTNAME, DIALOG_STYLE_INPUT,"Export name",dg1,"Export","Cancel");
		}
		else return SendClientErrorMessage(playerid, 3);
	#else
		new dg1[65];
		format(dg1, sizeof(dg1), "Enter the name of the file you want to export the objects to:");
		ShowPlayerDialog(playerid, DIALOG_MAP_EXPORTNAME, DIALOG_STYLE_INPUT,"Export name",dg1,"Export","Cancel");
	#endif
	return 1;
}

CMD:loadobjects(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	ShowPlayerDialog(playerid, DIALOG_MAP_LOAD, DIALOG_STYLE_INPUT, "Load map","Enter the name of the file you want to load:","Load","Cancel");
	return 1;
}

CMD:edo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_editobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:editobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
    new object;
  	if(sscanf(params, "i", object))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /editobject [object number]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to modify the position and rotation of the defined object number with your mouse.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /edo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] !=0)
		{
		    if(oInfo[playerid][object][created] == 1)
		    {
		        EditObject(playerid, oInfo[playerid][object][objectID]);
				pInfo[playerid][editobject] = object;
		    }
		    else
		    {
		        SendClientErrorMessage(playerid, 0);
			}
		}
		else
		{
		    SendClientErrorMessage(playerid, 1);
		}
	}
	return 1;
}

CMD:seo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_selectobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:selectobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	if(pInfo[playerid][totalobjects] !=0)
	{
	    SelectObject(playerid);
		SendClientInfoMessage(playerid, "You can now select an object by clicking onto it with your cursor.");
	}
	else SendClientErrorMessage(playerid, 1);
	return 1;
}

CMD:soxo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectxoffset(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectxoffset(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:offset;
  	if(sscanf(params, "if", object, offset))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectxoffset [object number] [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to move the chosen object number on the X axis.");
		SendClientMessage(playerid, COLOR_USAGE2, "> Positive values will move the object eastbound, negative values westbound.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /soxo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_MOVE_DISTANCE == true
			if(offset > MAX_MOVE_DISTANCE) return SendClientErrorMessage(playerid, 6);
			#endif
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][XLoc]+=offset;
				SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]);
				new string[130];
				format(string, sizeof(string), "You have moved object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) {F58282}%.2f{F5F582}m on the X plane.", object, oInfo[playerid][object][modelID], offset);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:soyo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectyoffset(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectyoffset(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:offset;
  	if(sscanf(params, "if", object, offset))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectyoffset [object number] [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to move the chosen object number on the Y axis.");
		SendClientMessage(playerid, COLOR_USAGE2, "> Positive values will move the object northbound, negative values southbound.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /soyo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_MOVE_DISTANCE == true
			if(offset > MAX_MOVE_DISTANCE) return SendClientErrorMessage(playerid, 6);
			#endif
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][YLoc]+=offset;
				SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]);
				new string[128];
				format(string, sizeof(string), "You have moved object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) {F58282}%.2f{F5F582}m on the Y plane.", object, oInfo[playerid][object][modelID], offset);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:sozo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectzoffset(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectzoffset(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:offset;
  	if(sscanf(params, "if", object, offset))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectzoffset [object number] [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to move the chosen object number on the Z axis.");
		SendClientMessage(playerid, COLOR_USAGE2, "> Positive values will move the object up, negative values down.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /soyo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_MOVE_DISTANCE == true
			if(offset > MAX_MOVE_DISTANCE) return SendClientErrorMessage(playerid, 6);
			#endif
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][ZLoc]+=offset;
				SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]);
				new string[128];
				format(string, sizeof(string), "You have moved object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) {F58282}%.2f{F5F582}m on the Z plane.", object, oInfo[playerid][object][modelID], offset);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:soxr(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectxrotation(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectxrotation(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:rotation;
  	if(sscanf(params, "if", object, rotation))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectxrotation [object number] [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to set the X rotation value of the defined object number.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /soxr.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][XRot] = rotation;
				SetObjectRot(oInfo[playerid][object][objectID], oInfo[playerid][object][XRot], oInfo[playerid][object][YRot], oInfo[playerid][object][ZRot]);
				new string[140];
				format(string, sizeof(string), "You have set the X rotation of object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) to {F58282}%.2f{F5F582} degrees.", object, oInfo[playerid][object][modelID], rotation);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:soyr(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectyrotation(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectyrotation(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:rotation;
  	if(sscanf(params, "if", object, rotation))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectyrotation [object number] [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to set the Y rotation value of the defined object number.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /soyr.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][YRot] = rotation;
				SetObjectRot(oInfo[playerid][object][objectID], oInfo[playerid][object][XRot], oInfo[playerid][object][YRot], oInfo[playerid][object][ZRot]);
				new string[140];
				format(string, sizeof(string), "You have set the Y rotation of object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) to {F58282}%.2f{F5F582} degrees.", object, oInfo[playerid][object][modelID], rotation);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:sozr(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectzrotation(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectzrotation(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:rotation;
  	if(sscanf(params, "if", object, rotation))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectzrotation [object number] [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to set the Z rotation value of the defined object number.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /sozr.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][ZRot] = rotation;
				SetObjectRot(oInfo[playerid][object][objectID], oInfo[playerid][object][XRot], oInfo[playerid][object][YRot], oInfo[playerid][object][ZRot]);
				new string[140];
				format(string, sizeof(string), "You have set the Z rotation of object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) to {F58282}%.2f{F5F582} degrees.", object, oInfo[playerid][object][modelID], rotation);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:sop(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectpos(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectpos(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:X, Float:Y, Float:Z;
  	if(sscanf(params, "ifff", object, X, Y, Z))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectpos [object number] [X] [Y] [Z]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to set the position of the defined object number to a certain coordinate.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /sop.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
		    if(oInfo[playerid][object][created] == 1)
		    {
				oInfo[playerid][object][XLoc] = X;
				oInfo[playerid][object][YLoc] = Y;
				oInfo[playerid][object][ZLoc] = Z;
				SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]);
				new string[175];
				format(string, sizeof(string), "You have set the position of object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) to {F58282}%.2f{F5F582}, {F58282}%.2f{F5F582}, {F58282}%.2f{F5F582}.", object, oInfo[playerid][object][modelID], X, Y, Z);
				SendClientInfoMessage(playerid, string);
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:saoxo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setallobjectsxoffset(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setallobjectsxoffset(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new Float:offset;
  	if(sscanf(params, "f", offset))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setallobjectsxoffset [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to move all your created objects on the X axis using the defined value.");
		SendClientMessage(playerid, COLOR_USAGE2, "> Positive values will move the objects eastbound, negative values westbound.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /saoxo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_MOVE_DISTANCE == true
			if(offset > MAX_MOVE_DISTANCE) return SendClientErrorMessage(playerid, 6);
			#endif
			for(new object = 0; object < MAX_CREATED_OBJECTS; object++)
			{
				if(oInfo[playerid][object][created] == 1)
				{
					oInfo[playerid][object][XLoc]+=offset;
					SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]); 
				}
			}
			new string[90];
			format(string, sizeof(string), "You have moved all objects you created {F58282}%.2f{F5F582}m on the X plane.", offset);
			SendClientInfoMessage(playerid, string);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:saoyo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setallobjectsyoffset(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setallobjectsyoffset(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new Float:offset;
  	if(sscanf(params, "f", offset))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setallobjectsyoffset [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to move all your created objects on the Y axis using the defined value.");
		SendClientMessage(playerid, COLOR_USAGE2, "> Positive values will move the objects northbound, negative values southbound.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /saoyo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_MOVE_DISTANCE == true
			if(offset > MAX_MOVE_DISTANCE) return SendClientErrorMessage(playerid, 6);
			#endif
			for(new object = 0; object < MAX_CREATED_OBJECTS; object++)
			{
				if(oInfo[playerid][object][created] == 1)
				{
					oInfo[playerid][object][YLoc]+=offset;
					SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]);
				}
			}
			new string[90];
			format(string, sizeof(string), "You have moved all objects you created {F58282}%.2f{F5F582}m on the Y plane.", offset);
			SendClientInfoMessage(playerid, string);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:saozo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setallobjectszoffset(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setallobjectszoffset(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new Float:offset;
  	if(sscanf(params, "f", offset))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /setallobjectszoffset [value]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to move all your created objects on the Z axis using the defined value.");
		SendClientMessage(playerid, COLOR_USAGE2, "> Positive values will move the objects up, negative values down.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /saozo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			#if USE_MAX_MOVE_DISTANCE == true
			if(offset > MAX_MOVE_DISTANCE) return SendClientErrorMessage(playerid, 6);
			#endif
			for(new object = 0; object < MAX_CREATED_OBJECTS; object++)
			{
				if(oInfo[playerid][object][created] == 1)
				{
					oInfo[playerid][object][ZLoc]+=offset;
					SetObjectPos(oInfo[playerid][object][objectID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc]);
				}
			}
			new string[90];
			format(string, sizeof(string), "You have moved all objects you created {F58282}%.2f{F5F582}m on the Z plane.", offset);
			SendClientInfoMessage(playerid, string);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:duo(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_duplicateobject(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:duplicateobject(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	new object, Float:X, Float:Y, Float:Z;
  	if(sscanf(params, "ifff", object, X, Y, Z))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /duplicateobject [object number] [X Offset] [Y Offset] [Z Offset]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to \"copy\" and object with a defined distance from the original object.");
		#if USE_COMMAND_SHORTCUTS == true
		SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /duo.");
		#endif
	}
	else
	{
	    if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
	    {
			if(oInfo[playerid][object][created] == 1)
			{
				for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
				{
					if(oInfo[playerid][i][created] == 0)
					{
						pInfo[playerid][editobject] = i;
						oInfo[playerid][i][created] = 1;
						oInfo[playerid][i][XLoc] = oInfo[playerid][object][XLoc] + X;
						oInfo[playerid][i][YLoc] = oInfo[playerid][object][YLoc] + Y;
						oInfo[playerid][i][ZLoc] = oInfo[playerid][object][ZLoc] + Z;
						oInfo[playerid][i][XRot] = oInfo[playerid][object][XRot];
						oInfo[playerid][i][YRot] = oInfo[playerid][object][YRot];
						oInfo[playerid][i][ZRot] = oInfo[playerid][object][ZRot];	
						oInfo[playerid][i][modelID] = oInfo[playerid][object][modelID];
						oInfo[playerid][i][objectID] = CreateObject(oInfo[playerid][i][modelID], oInfo[playerid][i][XLoc], oInfo[playerid][i][YLoc], oInfo[playerid][i][ZLoc], oInfo[playerid][i][XRot], oInfo[playerid][i][YRot], oInfo[playerid][i][ZRot]);
						if(pInfo[playerid][TransferMaterial] == true)
						{
							if(oInfo[playerid][object][usesmaterial] == 1)
							{
								oInfo[playerid][i][usesmaterial] 	= 1;
								oInfo[playerid][i][matindex] 		= oInfo[playerid][object][matindex];
								oInfo[playerid][i][matmodel] 		= oInfo[playerid][object][matmodel];
								oInfo[playerid][i][indexused] 		= 1;
								oInfo[playerid][i][modelused] 		= 1;
								oInfo[playerid][i][txdused] 		= 1;
								oInfo[playerid][i][textureused] 	= 1;
								oInfo[playerid][i][colorused] 		= 1;
								new str[12], str2[16], str3[10];
								new newf[20], newf2[20], newf3[20];
								new txdname[25], texturename[25], color[25];
								format(str, sizeof(str), "%i_txdname", object);
								format(str2, sizeof(str2), "%i_texturename", object);
								format(str3, sizeof(str3), "%i_color", object);
								GetPVarString(playerid, str, txdname, sizeof(txdname));
								GetPVarString(playerid, str2, texturename, sizeof(texturename));
								GetPVarString(playerid, str3, color, sizeof(color));
								format(newf, sizeof(newf), "%i_txdname", i);
								format(newf2, sizeof(newf2), "%i_texturename", i);
								format(newf3, sizeof(newf3), "%i_color", i);
								SetPVarString(playerid, newf, txdname);
								SetPVarString(playerid, newf2, texturename);
								SetPVarString(playerid, newf3, color);
								ChangeObjectMaterial(playerid, i);	
							}
						}
						else
							oInfo[playerid][i][usesmaterial] = 0;
						pInfo[playerid][totalobjects]++;
						new dupinfo[180], numinfo[70];
						format(dupinfo, sizeof(dupinfo), "You have duplicated object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) with the offset {F58282}%.2f{F5F582}m, {F58282}%.2f{F5F582}m, {F58282}%.2f{F5F582}m.", object, oInfo[playerid][object][modelID], X, Y, Z);
						format(numinfo, sizeof(numinfo), "The number of the new created object is {F58282}%i{F5F582}.", i);
						SendClientInfoMessage(playerid, dupinfo);
						SendClientInfoMessage(playerid, numinfo);
						#if ALLOW_EDIT_OBJECT_ON_DUPLICATE == true
						if(pInfo[playerid][EditObjectOnDuplicate] == true)
						{
							pInfo[playerid][editobject] = i;
							EditObject(playerid, oInfo[playerid][i][objectID]);
						}
						#endif
						break;
					}
				}
			}
			else SendClientErrorMessage(playerid, 0);
		}
		else
		{
		    SendClientErrorMessage(playerid, 2);
		}
	}
  	return 1;
}

CMD:som(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_setobjectmaterial(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:setobjectmaterial(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	if(pInfo[playerid][UseMaterialDialog] == true)
	{
		new object;
		if(sscanf(params, "i", object))
		{
			SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectmaterial [object number]");
			SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to change the texture of the defined object number.");
			#if USE_COMMAND_SHORTCUTS == true
			SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /som.");
			#endif
		}
		else
		{
			if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
			{
				if(oInfo[playerid][object][created] == 1)
				{
					pInfo[playerid][editobject] = object;
					ShowPlayerMaterialDialog(playerid, object);
				}
				else SendClientErrorMessage(playerid, 0);
			}
			else
			{
				SendClientErrorMessage(playerid, 2);
			}
		}
	}
	else
	{
		new object, materialindex, mamodel, txdname[50], texturename[50], color[50];
		if(sscanf(params, "iiis[50]s[50]s[50]", object, materialindex, mamodel, txdname, texturename, color))
		{
			SendClientMessage(playerid, COLOR_USAGE, "Usage: /setobjectmaterial [object number] [materialindex] [modelid] [txdname] [texturename] [color]");
			SendClientMessage(playerid, COLOR_USAGE2, "> Allows you to change the texture of the defined object number.");
			SendClientMessage(playerid, COLOR_USAGE2, "> Materialindex = The part of the object you want to change.");
			SendClientMessage(playerid, COLOR_USAGE2, "> Modelid = The ID of the model the replacement texture is from (Use \"0\" for transparent).");
			SendClientMessage(playerid, COLOR_USAGE2, "> Txdname = The name of the .txd file which contains the texture (Use \"none\" for transparent).");
			SendClientMessage(playerid, COLOR_USAGE2, "> Texturename = The name of the texture (Use \"none\" for transparent).");
			SendClientMessage(playerid, COLOR_USAGE2, "> Color = The color you want to paint the texture with in AABBGGRR format. (Use \"0\" for default texture color).");
			#if USE_COMMAND_SHORTCUTS == true
			SendClientMessage(playerid, COLOR_USAGE2, "> The shortcut for this command is /som.");
			#endif
		}
		else
		{
			if(pInfo[playerid][totalobjects] < MAX_CREATED_OBJECTS)
			{
				if(oInfo[playerid][object][created] == 1)
				{
					pInfo[playerid][editobject] = object;
					oInfo[playerid][pInfo[playerid][editobject]][matindex] 		= materialindex;
					oInfo[playerid][pInfo[playerid][editobject]][matmodel] 		= mamodel;
					oInfo[playerid][pInfo[playerid][editobject]][txdused] 		= 1;
					oInfo[playerid][pInfo[playerid][editobject]][textureused] 	= 1;
					oInfo[playerid][pInfo[playerid][editobject]][colorused] 	= 1;
					oInfo[playerid][pInfo[playerid][editobject]][modelused] 	= 1;
					oInfo[playerid][pInfo[playerid][editobject]][indexused] 	= 1;
					new str[20];
					format(str, sizeof(str), "%i_txdname", pInfo[playerid][editobject]);
					SetPVarString(playerid, str, txdname);
					new str2[20];
					format(str2, sizeof(str2), "%i_texturename", pInfo[playerid][editobject]);
					SetPVarString(playerid, str2, texturename);
					new str3[20];
					format(str3, sizeof(str3), "%i_color", pInfo[playerid][editobject]);
					if(!strlen(color))
						SetPVarString(playerid, str3, "0");
					else
						SetPVarString(playerid, str3, color);
					ChangeObjectMaterial(playerid, pInfo[playerid][editobject]);
				}
				else SendClientErrorMessage(playerid, 0);
			}
			else
			{
				SendClientErrorMessage(playerid, 2);
			}
		}
	}
  	return 1;
}

CMD:editorsettings(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7); 
	ShowPlayerSettingsMenu(playerid);
	return 1;
}

CMD:editorcommands(playerid, params[])
{
	ShowPlayerCommandHelp(playerid);
	return 1;
}

CMD:esettingshelp(playerid, params[])
{
	ShowPlayerSettingsHelp(playerid);
	return 1;
}

CMD:fm(playerid, params[])
{
	#if USE_COMMAND_SHORTCUTS == true
		return cmd_flyeditor(playerid, params);
	#else
		SendClientErrorMessage(playerid, 8);
	#endif
}

CMD:flyeditor(playerid, params[])
{
	if(pInfo[playerid][editing] != true) return SendClientErrorMessage(playerid, 7);
	if(pInfo[playerid][flyeditor] == 0)
		Startflyeditor(playerid);
	else
		Endflyeditor(playerid);
	return 1;
}

CMD:toggleeditor(playerid, params[])
{
	#if TOGGLED_ONLY == true
	new pID;
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_WARNING, "Sorry, this command can only be used by RCON admins.");
	if(sscanf(params, "r", pID))
	{
		SendClientMessage(playerid, COLOR_USAGE, "Usage: /toggleeditor [playerid]");
		SendClientMessage(playerid, COLOR_USAGE2, "> Allows a player to use the object editor.");
	}
	else
	{
		if(IsPlayerConnected(pID))
		{
			if(pInfo[playerid][canuse] == 0)
			{
				pInfo[playerid][canuse] = 1;
				new togglename[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME];
				GetPlayerName(pID, togglename, MAX_PLAYER_NAME);
				GetPlayerName(playerid, adminname, MAX_PLAYER_NAME);
				new string[100], string2[100];
				format(string, sizeof(string), "You have allowed %s to use the object editor.", togglename);
				format(string2, sizeof(string2), "Admin %s has allowed you to use the object editor.", adminname);
				SendClientInfoMessage(playerid, string);
				SendClientInfoMessage(pID, string2);
			}
			else
			{
				pInfo[playerid][canuse] = 0;
				new togglename[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME];
				GetPlayerName(pID, togglename, MAX_PLAYER_NAME);
				GetPlayerName(playerid, adminname, MAX_PLAYER_NAME);
				new string[100], string2[100];
				format(string, sizeof(string), "You have taken %s the permission to use the object editor.", togglename);
				format(string2, sizeof(string2), "Admin %s has taken you the permission to use the object editor.", adminname);
				SendClientInfoMessage(playerid, string);
				SendClientInfoMessage(pID, string2);
				if(pInfo[pID][editing] == true)
				{
					SendClientMessage(playerid, -1, "[Editor {F58282}OFF{FFFFFF}]");
					DeleteAllObjects(playerid);
					ResetAllValues(playerid);
					SendClientInfoMessage(playerid, "You have left the editor. | All your objects have been automatically deleted.");
					pInfo[playerid][editing] = false;
				}
			}
		}
		else SendClientErrorMessage(playerid, 10);
	}
	#else
	SendClientMessage(playerid, COLOR_WARNING, "The editor is free for everyone, you don't have to give permissions.");
	#endif
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK))
	{
		if((pInfo[playerid][flyeditor] == 1) && (pInfo[playerid][editing] == true))
		{
			if(pInfo[playerid][totalobjects] == 0) return SendClientErrorMessage(playerid, 1);
			SelectObject(playerid);
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if((pInfo[playerid][editing] == true) && (pInfo[playerid][flyeditor] == 1))
	{
		new keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);
		if(pInfo[playerid][mode] && (GetTickCount() - pInfo[playerid][lastmove] > 100))
		{
		    MoveCamera(playerid);
		}

		if(pInfo[playerid][udold] != ud || pInfo[playerid][lrold] != lr)
		{
			if((pInfo[playerid][udold] != 0 || pInfo[playerid][lrold] != 0) && ud == 0 && lr == 0)
			{
				StopPlayerObject(playerid, pInfo[playerid][flyobject]);
				pInfo[playerid][mode]      = 0;
				pInfo[playerid][accelmul]  = 0.0;
			}
			else
			{

				pInfo[playerid][mode] = GetMoveDirectionFromKeys(ud, lr);
				MoveCamera(playerid);
			}
		}
		pInfo[playerid][udold] = ud; pInfo[playerid][lrold] = lr;
		return 0;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_MAP_SAVENAME:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					SaveMap(playerid, inputtext);
				}
				else
				{
					new dg1[101];
					format(dg1, sizeof(dg1), "Enter the name of the file you want to save the objects in:\n\n{F58282}You need to enter a file name.");
					ShowPlayerDialog(playerid, DIALOG_MAP_SAVENAME, DIALOG_STYLE_INPUT,"Save name",dg1,"Save","Cancel");
				}
			}
		}
		case DIALOG_MAP_EXPORTNAME:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					ExportMap(playerid, inputtext);
				}
				else
				{
					new dg1[103];
					format(dg1, sizeof(dg1), "Enter the name of the file you want to export the objects to:\n\n{F58282}You need to enter a file name.");
					ShowPlayerDialog(playerid, DIALOG_MAP_EXPORTNAME, DIALOG_STYLE_INPUT,"Export name",dg1,"Export","Cancel");
				}
			}
		}
		case DIALOG_MAP_LOAD:
		{
		    if(response)
		    {
		        if(strlen(inputtext))
		        {
					LoadMap(playerid, inputtext);
				}
				else
				{
					new dg1[86];
					format(dg1, sizeof(dg1), "Enter the name of the file you want to load:\n\n{F58282}You need to enter a file name.");
					ShowPlayerDialog(playerid, DIALOG_MAP_LOAD, DIALOG_STYLE_INPUT, "Load map",dg1,"Load","Cancel");
				}
		    }
		}
		case DIALOG_SELECTMENU:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						EditObject(playerid, oInfo[playerid][pInfo[playerid][editobject]][objectID]);
					}	
					case 1:
					{
						ShowPlayerDialog(playerid, DIALOG_CHANGEMODEL, DIALOG_STYLE_INPUT,"Replacement model","Enter the model ID you want to replace the object with","Replace","Cancel");
					}
					case 2:
					{
						new object = pInfo[playerid][editobject];
						DestroyObject(oInfo[playerid][object][objectID]);
						pInfo[playerid][totalobjects]--;
						new string[88];
						format(string, sizeof(string), "You have succesfully deleted object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}).", object, oInfo[playerid][object][modelID]);
						SendClientMessage(playerid, COLOR_INFO, string);
						oInfo[playerid][object][created] 		= 0;
						oInfo[playerid][object][objectID]		= INVALID_OBJECT_ID;
						oInfo[playerid][object][modelID] 		= 0;
						oInfo[playerid][object][XLoc] 			= 0.0;
						oInfo[playerid][object][YLoc] 			= 0.0;
						oInfo[playerid][object][ZLoc] 			= 0.0;
						oInfo[playerid][object][XRot] 			= 0.0;
						oInfo[playerid][object][YRot] 			= 0.0;
						oInfo[playerid][object][ZRot] 			= 0.0;
						oInfo[playerid][object][indexused] 		= 0;
						oInfo[playerid][object][modelused] 		= 0;
						oInfo[playerid][object][txdused] 		= 0;
						oInfo[playerid][object][textureused] 	= 0;
						oInfo[playerid][object][colorused] 		= 0;
						oInfo[playerid][object][matindex] 		= -1;
						oInfo[playerid][object][matmodel] 		= -1;
						new str1[20], str2[20], str3[20];
						format(str1, sizeof(str1), "%i_txdname", object);
						format(str2, sizeof(str2), "%i_texturename", object);
						format(str3, sizeof(str3), "%i_color", object);
						DeletePVar(playerid, str1);
						DeletePVar(playerid, str2);
						DeletePVar(playerid, str3);
						oInfo[playerid][object][usesmaterial] = 0;
					}
				}
			}
		}
		case DIALOG_CHANGEMODEL:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					if(IsNumeric(inputtext))
					{
						new model, oldmodel;
						new object = pInfo[playerid][editobject]; 
						oldmodel = oInfo[playerid][object][modelID];
						model = strval(inputtext);
						DestroyObject(oInfo[playerid][object][objectID]);
						oInfo[playerid][object][objectID] = CreateObject(model, oInfo[playerid][object][XLoc],oInfo[playerid][object][YLoc],oInfo[playerid][object][ZLoc],oInfo[playerid][object][XRot],oInfo[playerid][object][YRot],oInfo[playerid][object][ZRot]);
						oInfo[playerid][object][modelID] = model;
						new string[128];
						if(pInfo[playerid][KeepMaterial] == true)
							ChangeObjectMaterial(playerid, object);
						else
							ResetObjectMaterial(playerid, object);
						format(string, sizeof(string), "You succesfully replaced the model of object {F58282}%i{F5F582} (Model: {F58282}%i{F5F582}) with model {F58282}%i{F5F582}.", object, oldmodel, model);
						SendClientInfoMessage(playerid, string);
					}
					else ShowPlayerDialog(playerid, DIALOG_CHANGEMODEL, DIALOG_STYLE_INPUT,"Replacement model","Enter the model ID you want to replace the object with\n\n{91FF91}You may enter numbers only.","Replace","Cancel");
				}
				else ShowPlayerDialog(playerid, DIALOG_CHANGEMODEL, DIALOG_STYLE_INPUT,"Replacement model","Enter the model ID you want to replace the object with\n\n{91FF91}You need to enter a value.","Replace","Cancel");
			}
		}
		case DIALOG_SETTINGS:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						#if ALLOW_EDIT_OBJECT_ON_CREATE == true
							if(pInfo[playerid][EditObjectOnCreate] == true)
								pInfo[playerid][EditObjectOnCreate] = false;
							else
								pInfo[playerid][EditObjectOnCreate] = true;
						#endif
					}
					case 1:
					{
						#if ALLOW_EDIT_OBJECT_ON_DUPLICATE == true
							if(pInfo[playerid][EditObjectOnDuplicate] == true)
								pInfo[playerid][EditObjectOnDuplicate] = false;
							else
								pInfo[playerid][EditObjectOnDuplicate] = true;
						#endif
					}
					case 2:
					{
						#if ALLOW_USE_MATERIAL_CHANGE_DIALOG == true
							if(pInfo[playerid][UseMaterialDialog] == true)
								pInfo[playerid][UseMaterialDialog] = false;
							else
								pInfo[playerid][UseMaterialDialog] = true;
						#endif
					}
					case 3:
					{
						#if ALLOW_TRANSFER_MATERIAL == true
							if(pInfo[playerid][TransferMaterial] == true)
								pInfo[playerid][TransferMaterial] = false;
							else
								pInfo[playerid][TransferMaterial] = true;
						#endif
					}
					case 4:
					{
						#if ALLOW_KEEP_MATERIAL == true
							if(pInfo[playerid][KeepMaterial] == true)
								pInfo[playerid][KeepMaterial] = false;
							else
								pInfo[playerid][KeepMaterial] = true;
						#endif
					}
					case 5:
					{
						#if ALLOW_USE_CROSS == true
							if(pInfo[playerid][UseCross] == true)
							{
								pInfo[playerid][UseCross] = false;
								PlayerTextDrawHide(playerid, Cross[0]);
								PlayerTextDrawHide(playerid, Cross[1]);
							}
							else
							{
								pInfo[playerid][UseCross] = true;
								if(pInfo[playerid][flyeditor] == 1)
								{
									PlayerTextDrawShow(playerid, Cross[0]);
									PlayerTextDrawShow(playerid, Cross[1]);
								}
							}
						#endif
					}
					case 6:
					{
						#if ALLOW_USE_3D_LABELS == true
							if(pInfo[playerid][UseLabels] == true)
							{
								if(pInfo[playerid][totalobjects] == 0) return 1;
								ShowAllLabels(playerid);
								pInfo[playerid][UseLabels] = false;
							}
							else
							{
								if(pInfo[playerid][totalobjects] == 0) return 1;
								HideAllLabels(playerid);
								pInfo[playerid][UseLabels] = true;
							}
						#endif
					}
				}
				ShowPlayerSettingsMenu(playerid);
			}
		}
		case DIALOG_MATERIALS:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: //materialindex
					{
						ShowPlayerDialog(playerid, DIALOG_MATERIALINDEX, DIALOG_STYLE_INPUT, "Materialindex","Enter the index (part) you want to change of the object:","Set","Back");
					}
					case 1: //modelid
					{
						new dg1[135];
						format(dg1, sizeof(dg1), "Enter the model ID of the object on which the replacement texture is located\n\n{F5F582}Note: {A9C4E4}Use \"0\" for alpha (transparent)");
						ShowPlayerDialog(playerid, DIALOG_MODELID, DIALOG_STYLE_INPUT,"Model ID",dg1,"Set","Back");
					}
					case 2: //txdname
					{
						new dg1[131];
						format(dg1, sizeof(dg1), "Enter the name of the .txd file the replacement texture is located at\n\n{F5F582}Note: {A9C4E4}Use \"none\" for alpha (transparent)");
						ShowPlayerDialog(playerid, DIALOG_TXDNAME, DIALOG_STYLE_INPUT,"TXD file name",dg1,"Set","Back");
					}
					case 3: //texturename
					{
						new dg1[121];
						format(dg1, sizeof(dg1), "Enter the name of the texture you want to put on the object\n\n{F5F582}Note: {A9C4E4}Use \"none\" for alpha (transparent)");
						ShowPlayerDialog(playerid, DIALOG_TEXTURENAME, DIALOG_STYLE_INPUT,"Texture name",dg1,"Set","Back");
					}
					case 4: //color
					{
						new dg1[64], dg2[150], dg3[64], dial[300];
						format(dg1, sizeof(dg1), "Enter a color you want to pain the texture with");
						format(dg2, sizeof(dg2), "{F58282}Important: {A9C4E4}The color has to be in {FFFFFF}AA{0069FF}BB{00FF00}GG{FF0000}RR {A9C4E4}format.\nExample: FF00FF00 (green)");
						format(dg3, sizeof(dg3), "\n{F5F582}Note: {A9C4E4}Use \"0\" to use the default color of the texture.");
						format(dial, sizeof(dial), "%s\n%s\n%s", dg1, dg2, dg3);
						ShowPlayerDialog(playerid, DIALOG_COLOR, DIALOG_STYLE_INPUT,"Color",dial,"Set","Back");
					}
					case 5: //continue
					{
						if(IsAllFilledOut(playerid, pInfo[playerid][editobject]))
							ChangeObjectMaterial(playerid, pInfo[playerid][editobject]);
						else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
					}
					case 6: //remove texture
					{
						if(oInfo[playerid][pInfo[playerid][editobject]][usesmaterial] == 1)
							ResetObjectMaterial(playerid, pInfo[playerid][editobject]);
						else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
					}
				}
			}
		}
		case DIALOG_MATERIALINDEX:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					if(IsNumeric(inputtext))
					{
						oInfo[playerid][pInfo[playerid][editobject]][indexused] = 1;
						oInfo[playerid][pInfo[playerid][editobject]][matindex] = strval(inputtext);
						ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
					}
					else ShowPlayerDialog(playerid, DIALOG_MATERIALINDEX, DIALOG_STYLE_INPUT, "Materialindex","Enter the index (part) you want to change of the object:\n{F58282}You may enter numbers only.","Set","Back");
				}
				else ShowPlayerDialog(playerid, DIALOG_MATERIALINDEX, DIALOG_STYLE_INPUT, "Materialindex","Enter the index (part) you want to change of the object:\n{F58282}You need to enter a value.","Set","Back");
			}
			else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
		}
		case DIALOG_MODELID:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					if(IsNumeric(inputtext))
					{
						oInfo[playerid][pInfo[playerid][editobject]][modelused] = 1;
						oInfo[playerid][pInfo[playerid][editobject]][matmodel] = strval(inputtext);
						ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
					}
					else
					{
						new dg1[135], dg2[35], dial[200];
						format(dg1, sizeof(dg1), "Enter the model ID of the object on which the replacement texture is located\n\n{F5F582}Note: {A9C4E4}Use \"0\" for alpha (transparent)");
						format(dg2, sizeof(dg2), "{F58282}You may only enter numbers.");
						format(dial, sizeof(dial), "%s\n\n%s", dg1, dg2);
						ShowPlayerDialog(playerid, DIALOG_MODELID, DIALOG_STYLE_INPUT,"Model ID",dial,"Set","Back");
					}
				}
				else
				{
					new dg1[135], dg2[35], dial[200];
					format(dg1, sizeof(dg1), "Enter the model ID of the object on which the replacement texture is located\n\n{F5F582}Note: {A9C4E4}Use \"0\" for alpha (transparent)");
					format(dg2, sizeof(dg2), "{F58282}You need to enter a value.");
					format(dial, sizeof(dial), "%s\n\n%s", dg1, dg2);
					ShowPlayerDialog(playerid, DIALOG_MODELID, DIALOG_STYLE_INPUT,"Model ID",dial,"Set","Back");
				}
			}
			else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
		}
		case DIALOG_TXDNAME:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					new str[20];
					format(str, sizeof(str), "%i_txdname", pInfo[playerid][editobject]);
					SetPVarString(playerid, str, inputtext);
					oInfo[playerid][pInfo[playerid][editobject]][txdused] = 1;
					ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
				}
				else
				{
					new dg1[131], dg2[35], dial[200];
					format(dg1, sizeof(dg1), "Enter the name of the .txd file the replacement texture is located at\n\n{F5F582}Note: {A9C4E4}Use \"none\" for alpha (transparent)");
					format(dg2, sizeof(dg2), "{F58282}You need to enter a name.");
					format(dial, sizeof(dial), "%s\n\n%s", dg1, dg2);
					ShowPlayerDialog(playerid, DIALOG_TXDNAME, DIALOG_STYLE_INPUT,"TXD file name",dial,"Set","Back");
				}
			}
			else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
		}
		case DIALOG_TEXTURENAME:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					new str[20];
					format(str, sizeof(str), "%i_texturename", pInfo[playerid][editobject]);
					SetPVarString(playerid, str, inputtext);
					oInfo[playerid][pInfo[playerid][editobject]][textureused] = 1;
					ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
				}
				else
				{
					new dg1[121], dg2[35], dial[200];
					format(dg1, sizeof(dg1), "Enter the name of the texture you want to put on the object\n\n{F5F582}Note: {A9C4E4}Use \"none\" for alpha (transparent)");
					format(dg2, sizeof(dg2), "{F58282}You need to enter a text.");
					format(dial, sizeof(dial), "%s\n\n%s", dg1, dg2);
					ShowPlayerDialog(playerid, DIALOG_TEXTURENAME, DIALOG_STYLE_INPUT,"Texture name",dial,"Set","Back");
				}
			}
			else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
		}
		case DIALOG_COLOR:
		{
			if(response)
			{
				if(strlen(inputtext))
				{
					new str[20];
					format(str, sizeof(str), "%i_color", pInfo[playerid][editobject]);
					SetPVarString(playerid, str, inputtext);
					oInfo[playerid][pInfo[playerid][editobject]][colorused] = 1;
					ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
				}
				else
				{
					new dg1[50], dg2[150], dg3[50], dg4[50], dial[512];
					format(dg1, sizeof(dg1), "Enter a color you want to paint the texture with.");
					format(dg2, sizeof(dg2), "{F58282}Important: {A9C4E4}The color has to be in {FFFFFF}AA{0069FF}BB{00FF00}GG{FF0000}RR {A9C4E4}format.\n\tExample: FF00FF00 (green).");
					format(dg3, sizeof(dg3), "\n{F5F582}Note: {A9C4E4}Use \"0\" for alpha (transparent).");
					format(dg4, sizeof(dg4), "{F58282}You need to enter a color.");
					format(dial, sizeof(dial), "%s\n%s\n\n%s\n\n%s", dg1, dg2, dg3, dg4);
					ShowPlayerDialog(playerid, DIALOG_COLOR, DIALOG_STYLE_INPUT,"Color",dial,"Set","Back");
				}
			}
			else ShowPlayerMaterialDialog(playerid, pInfo[playerid][editobject]);
		}
		case DIALOG_EDITORCOMMANDS:
		{
			if(!response)
			{
				ShowPlayerCommandHelp2(playerid);
			}
		}
		case DIALOG_EDITORCOMMANDS2:
		{
			if(response)
			{
				ShowPlayerCommandHelp(playerid);
			}
		}
	}
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(objectid == oInfo[playerid][pInfo[playerid][editobject]][objectID])
	{
		if(response == EDIT_RESPONSE_FINAL)
		{
			new object = pInfo[playerid][editobject];
			oInfo[playerid][object][XLoc] = fX;
			oInfo[playerid][object][YLoc] = fY;
			oInfo[playerid][object][ZLoc] = fZ;
			oInfo[playerid][object][XRot] = fRotX;
			oInfo[playerid][object][YRot] = fRotY;
			oInfo[playerid][object][ZRot] = fRotZ;
			SetObjectPos(oInfo[playerid][object][objectID], fX, fY, fZ);
			SetObjectRot(oInfo[playerid][object][objectID], fRotX, fRotY, fRotZ);
			new string[128];
			format(string, sizeof(string),"You have finished editing object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}).", object, oInfo[playerid][object][modelID]);
			SendClientInfoMessage(playerid, string);
		}
	}	
	return 1;
}

public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{
	CancelEdit(playerid);
    for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
	{
		if(oInfo[playerid][i][objectID] == objectid)
		{
			if(pInfo[playerid][flyeditor] != 1)
			{
				ShowPlayerDialog(playerid, DIALOG_SELECTMENU, DIALOG_STYLE_LIST,"Select Action","Edit\nChange Model\nDelete","Select","Cancel");
				pInfo[playerid][editobject] = i;
			}
			else
			{
				pInfo[playerid][editobject] = 1;
				EditObject(playerid, oInfo[playerid][i][objectID]);
			}
			break;
		}
		else if(i == (MAX_CREATED_OBJECTS-1)) 
		{
			SendClientErrorMessage(playerid, 4);
		}
	}
    return 1;
}

stock SendClientErrorMessage(playerid, type)
{
	switch(type)
	{
	    case 0: SendClientMessage(playerid, COLOR_WARNING, "This is not a valid object number.");
	    case 1: SendClientMessage(playerid, COLOR_WARNING, "You haven't created any objects.");
	    case 2:
		{
			new string[128];
			format(string, sizeof(string), "You can not create more objects, you have reached the maximum amount of {F58282}%i{F5F582} objects.", MAX_CREATED_OBJECTS);
			SendClientMessage(playerid, COLOR_WARNING, string);
		}
		case 3: SendClientMessage(playerid, COLOR_WARNING, "Sorry, you can not export object files as this function is restricted to RCON admins.");
		case 4: SendClientMessage(playerid, COLOR_WARNING, "The object you selected is not one of those you have created.");
		case 5:
		{
			new string[110];
			format(string, sizeof(string), "The value you entered is too big. Please choose a value smaller than or equal to {F58282}%.2f{F5F582}m.", MAX_CREATE_DISTANCE);
			SendClientMessage(playerid, COLOR_WARNING, string);
		}
		case 6:
		{
			new string[110];
			format(string, sizeof(string), "The value you entered is too big. Please choose a value smaller than or equal to {F58282}%.2f{F5F582}m.", MAX_MOVE_DISTANCE);
			SendClientMessage(playerid, COLOR_WARNING, string);
		}
		case 7: SendClientMessage(playerid, COLOR_WARNING, "Sorry, you can not use this command as you are not in the object editor.");
		case 8: SendClientMessage(playerid, COLOR_WARNING, "Sorry, the usage of command shortcuts for the object editor is disabled.");
		case 9: SendClientMessage(playerid, COLOR_WARNING, "Sorry, you can not use this command when you're in the flyeditor.");
		case 10: SendClientMessage(playerid, COLOR_WARNING, "This user is not connected.");
	}
	return 1;
}

stock SendClientInfoMessage(playerid, string[])
{
	SendClientMessage(playerid, COLOR_INFO, string);
	return 1;
}

forward ExportMap(playerid, inputtext[]);
public ExportMap(playerid, inputtext[])
{
	new string[60];
	format(string, sizeof(string), "ObjectEditor/Exports/%s.txt",inputtext);
	if(!dini_Exists(string))
	{
		new File:File = fopen(string, io_write);
		new def[50];
		new counter = 0;
		format(def, sizeof(def), "new %s[%i];\r\n\r\n", inputtext, pInfo[playerid][totalobjects]);
		fwrite(File, def);
		for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
		{
			if(oInfo[playerid][i][created] == 1)
			{
				new code[200];
				format(code, sizeof(code), "%s[%i] = CreateObject(%i, %f, %f, %f, %f, %f, %f);\r\n",inputtext, counter, oInfo[playerid][i][modelID], oInfo[playerid][i][XLoc], oInfo[playerid][i][YLoc], oInfo[playerid][i][ZLoc], oInfo[playerid][i][XRot], oInfo[playerid][i][YRot], oInfo[playerid][i][ZRot]);
				fwrite(File, code);
				if(oInfo[playerid][i][usesmaterial] == 1)
				{
					new materialindex, matmodelid, txdname[50], texturename[50], color[15];
					new str1[50], str2[50], str3[15];
					new matcolor;
					format(str1, sizeof(str1), "%i_txdname", i);
					GetPVarString(playerid, str1, txdname, sizeof(txdname));
					format(str2, sizeof(str2), "%i_texturename", i);
					GetPVarString(playerid, str2, texturename, sizeof(texturename));
					format(str3, sizeof(str3), "%i_color", i);
					GetPVarString(playerid, str3, color, sizeof(color));
					matcolor = HexToInt(color);
					materialindex = oInfo[playerid][i][matindex];
					matmodelid =  oInfo[playerid][i][matmodel];
					new code2[200];
					format(code2, sizeof(code2), "SetObjectMaterial(%s[%i], %i, %i, \"%s\", \"%s\", %i);\r\n", inputtext, counter, materialindex, matmodelid, txdname, texturename, matcolor);
					fwrite(File, code2);
				}
				counter++;
			}
		}
		fclose(File);
		new msg[100];
		format(msg, sizeof(msg), "You have successfully exported all objects to the file {F58282}%s{F5F582}.txt.", inputtext);
		SendClientInfoMessage(playerid, msg);
	}
	else
	{
		new dg1[141];
		format(dg1, sizeof(dg1), "Enter the name of the file you want to export the objects to:\n\n{F58282}Sorry, this file already exists. {A9C4E4}Please choose another name.");
		ShowPlayerDialog(playerid, DIALOG_MAP_EXPORTNAME, DIALOG_STYLE_INPUT,"Save name",dg1,"Export","Cancel");
	}
	return 1;
}

forward SaveMap(playerid, inputtext[]);
public SaveMap(playerid, inputtext[])
{
	new oFile[100];
	format(oFile, sizeof(oFile), "/ObjectEditor/Saves/%s.txt", inputtext);
	if(!dini_Exists(oFile))
	{
		new oCounter = 0;
		new pName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
		dini_Create(oFile);
		dini_Set(oFile, "creator", pName);
		dini_IntSet(oFile, "totalobjects", pInfo[playerid][totalobjects]);
		for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
		{
			if(oInfo[playerid][i][created] == 1)
			{
				new towrite[60];
				format(towrite, sizeof(towrite), "o%i_modelID", oCounter);
				dini_IntSet(oFile, towrite, oInfo[playerid][i][modelID]);
				format(towrite, sizeof(towrite), "o%i_XLoc", oCounter);
				dini_FloatSet(oFile, towrite, oInfo[playerid][i][XLoc]);
				format(towrite, sizeof(towrite), "o%i_YLoc", oCounter);
				dini_FloatSet(oFile, towrite, oInfo[playerid][i][YLoc]);
				format(towrite, sizeof(towrite), "o%i_ZLoc", oCounter);
				dini_FloatSet(oFile, towrite, oInfo[playerid][i][ZLoc]);
				format(towrite, sizeof(towrite), "o%i_XRot", oCounter);
				dini_FloatSet(oFile, towrite, oInfo[playerid][i][XRot]);
				format(towrite, sizeof(towrite), "o%i_YRot", oCounter);
				dini_FloatSet(oFile, towrite, oInfo[playerid][i][YRot]);
				format(towrite, sizeof(towrite), "o%i_ZRot", oCounter);
				dini_FloatSet(oFile, towrite, oInfo[playerid][i][ZRot]);
				if(oInfo[playerid][i][usesmaterial] == 1)
				{
					new txdname[50], texturename[50], color[15];
					new str1[50], str2[50], str3[15];
					format(towrite, sizeof(towrite), "o%i_usesmaterial", oCounter);
					dini_IntSet(oFile, towrite, 1);
					format(str1, sizeof(str1), "%i_txdname", i);
					GetPVarString(playerid, str1, txdname, sizeof(txdname));
					format(str2, sizeof(str2), "%i_texturename", i);
					GetPVarString(playerid, str2, texturename, sizeof(texturename));
					format(str3, sizeof(str3), "%i_color", i);
					GetPVarString(playerid, str3, color, sizeof(color));
					format(towrite, sizeof(towrite), "o%i_matindex", oCounter);
					dini_IntSet(oFile, towrite, oInfo[playerid][i][matindex]);
					format(towrite, sizeof(towrite), "o%i_matmodelid", oCounter);
					dini_IntSet(oFile, towrite, oInfo[playerid][i][matmodel]);
					format(towrite, sizeof(towrite), "o%i_txdname", oCounter);
					dini_Set(oFile, towrite, txdname);
					format(towrite, sizeof(towrite), "o%i_texturename", oCounter);
					dini_Set(oFile, towrite, texturename);
					format(towrite, sizeof(towrite), "o%i_matcolor", oCounter);
					dini_Set(oFile, towrite, color);
				}
				else
				{
					format(towrite, sizeof(towrite), "o%i_usesmaterial", oCounter);
					dini_IntSet(oFile, towrite, 0);
				}
				oCounter++;
			}
		}
		new msg[100];
		format(msg, sizeof(msg), "You have successfully saved all objects to the file {F58282}%s{F5F582}.txt.", inputtext);
		SendClientInfoMessage(playerid, msg);
	}
	else
	{
		new dg1[139];
		format(dg1, sizeof(dg1), "Enter the name of the file you want to save the objects in:\n\n{F58282}Sorry, this file already exists. {A9C4E4}Please choose another name.");
		ShowPlayerDialog(playerid, DIALOG_MAP_SAVENAME, DIALOG_STYLE_INPUT,"Save name",dg1,"Save","Cancel");
	}
	return 1;
}

forward LoadMap(playerid, inputtext[]);
public LoadMap(playerid, inputtext[])
{
	new oFile[100];
	format(oFile, sizeof(oFile), "/ObjectEditor/Saves/%s.txt", inputtext);
	if(dini_Exists(oFile))
	{
		new amount = dini_Int(oFile, "totalobjects");
		if((pInfo[playerid][totalobjects] + amount) <= MAX_CREATED_OBJECTS)
		{
			new oCount = 0;
			new i = 0;
			do
			{
				if(oInfo[playerid][oCount][created] == 0)
				{
				    new dir0[50], dir1[50], dir2[50], dir3[50], dir4[50], dir5[50], dir6[50], dir7[50];
					format(dir0, sizeof(dir0), "o%i_modelID", i);
					format(dir1, sizeof(dir1), "o%i_XLoc", i);
					format(dir2, sizeof(dir2), "o%i_YLoc", i);
					format(dir3, sizeof(dir3), "o%i_ZLoc", i);
					format(dir4, sizeof(dir4), "o%i_XRot", i);
					format(dir5, sizeof(dir5), "o%i_YRot", i);
					format(dir6, sizeof(dir6), "o%i_ZRot", i);
					oInfo[playerid][oCount][created]  = 1;
					oInfo[playerid][oCount][modelID]  = dini_Int(oFile, dir0);
					oInfo[playerid][oCount][XLoc]	  = dini_Float(oFile, dir1);
					oInfo[playerid][oCount][YLoc]	  = dini_Float(oFile, dir2);
					oInfo[playerid][oCount][ZLoc]	  = dini_Float(oFile, dir3);
					oInfo[playerid][oCount][XRot]	  = dini_Float(oFile, dir4);
					oInfo[playerid][oCount][YRot]	  = dini_Float(oFile, dir5);
					oInfo[playerid][oCount][ZRot]	  = dini_Float(oFile, dir6);
					oInfo[playerid][oCount][objectID] = CreateObject(oInfo[playerid][oCount][modelID], oInfo[playerid][oCount][XLoc], oInfo[playerid][oCount][YLoc], oInfo[playerid][oCount][ZLoc], oInfo[playerid][oCount][XRot], oInfo[playerid][oCount][YRot], oInfo[playerid][oCount][ZRot]);
					format(dir7, sizeof(dir7), "o%i_usesmaterial", i);
					if(dini_Int(oFile, dir7) == 1)
					{
						new dir8[50], dir9[50], dir10[50], dir11[50], dir12[50];
						new str[20], str2[20], str3[20];
						new txdname[50], texturename[50], color[50];
						format(dir8, sizeof(dir8), "o%i_matindex", i);
						format(dir9, sizeof(dir9), "o%i_matmodelid", i);
						format(dir10, sizeof(dir10), "o%i_txdname", i);
						format(dir11, sizeof(dir11), "o%i_texturename", i);
						format(dir12, sizeof(dir12), "o%i_matcolor", i);
						format(txdname, sizeof(txdname), "%s", dini_Get(oFile, dir10));
						format(texturename, sizeof(texturename), "%s", dini_Get(oFile, dir11));
						format(color, sizeof(color), "%s", dini_Get(oFile, dir12));
						oInfo[playerid][oCount][indexused] 		= 1;
						oInfo[playerid][oCount][modelused] 		= 1;
						oInfo[playerid][oCount][txdused] 		= 1;
						oInfo[playerid][oCount][textureused] 	= 1;
						oInfo[playerid][oCount][colorused] 		= 1;
						oInfo[playerid][oCount][matindex] 		= dini_Int(oFile, dir8);
						oInfo[playerid][oCount][matmodel] 		= dini_Int(oFile, dir9);
						format(str, sizeof(str), "%i_txdname", oCount);
						format(str2, sizeof(str2), "%i_texturename", oCount);
						format(str3, sizeof(str3), "%i_color", oCount);
						SetPVarString(playerid, str, txdname);
						SetPVarString(playerid, str2, texturename);
						SetPVarString(playerid, str3, color);
						oInfo[playerid][oCount][usesmaterial] = 1;
						SetObjectMaterial(oInfo[playerid][oCount][objectID], oInfo[playerid][oCount][matindex], oInfo[playerid][oCount][matmodel], txdname, texturename, HexToInt(color));
					}
					else
					{
						oInfo[playerid][oCount][usesmaterial] = 0;
					}
					i++;
				}
				oCount++;
			}
			while(i < amount);
			pInfo[playerid][totalobjects]+=amount;
			new string[256];
			format(string, sizeof(string), "You loaded {F58282}%i{F5F582} objects from file {F58282}%s{F5F582}.txt. | Total current objects: {F58282}%i{F5F582}.", amount, inputtext, pInfo[playerid][totalobjects]);
			SendClientInfoMessage(playerid, string);
		}
		else
		{
		    new string[128];
			format(string, sizeof(string), "You can not load this file as you would exceed the maximum amount of {F58282}%i{F5F582} objects.", MAX_CREATED_OBJECTS);
			SendClientMessage(playerid, COLOR_WARNING, string);
		}
	}
	else
	{
		new dg1[256];
		format(dg1, sizeof(dg1), "Enter the name of the file you want to load:\n\n{F58282}Sorry, this file does not exist.");
		ShowPlayerDialog(playerid, DIALOG_MAP_LOAD, DIALOG_STYLE_INPUT, "Load map",dg1,"Load","Cancel");
	}
	return 1;
}

stock DeleteAllObjects(playerid)
{
    for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
    {
	    DestroyObject(oInfo[playerid][i][objectID]);
	    oInfo[playerid][i][objectID] 		= INVALID_OBJECT_ID;
	   	oInfo[playerid][i][modelID]  		= 0;
	   	oInfo[playerid][i][XLoc] 	 		= 0.0;
	   	oInfo[playerid][i][YLoc] 	 		= 0.0;
	   	oInfo[playerid][i][ZLoc] 	 		= 0.0;
	   	oInfo[playerid][i][XRot] 	 		= 0.0;
	   	oInfo[playerid][i][YRot] 	 		= 0.0;
	   	oInfo[playerid][i][ZRot] 	 		= 0.0;
	   	pInfo[playerid][totalobjects] 		= 0;
	    oInfo[playerid][i][created]  		= 0;
		oInfo[playerid][i][indexused] 		= 0;
		oInfo[playerid][i][modelused] 		= 0;
		oInfo[playerid][i][txdused] 		= 0;
		oInfo[playerid][i][textureused] 	= 0;
		oInfo[playerid][i][colorused] 		= 0;
		oInfo[playerid][i][matindex] 		= -1;
		oInfo[playerid][i][matmodel] 		= -1;
		new str1[20], str2[20], str3[20];
		format(str1, sizeof(str1), "%i_txdname", i);
		format(str2, sizeof(str2), "%i_texturename", i);
		format(str3, sizeof(str3), "%i_color", i);
		DeletePVar(playerid, str1);
		DeletePVar(playerid, str2);
		DeletePVar(playerid, str3);
		oInfo[playerid][i][usesmaterial] 	= 0;
    }
	return 1;
}

forward ShowPlayerSettingsMenu(playerid);
public ShowPlayerSettingsMenu(playerid)
{
	new setting1[128], setting2[128], setting3[128], setting4[128], setting5[128], setting6[128], setting7[128], dialog[512];
	#if ALLOW_EDIT_OBJECT_ON_CREATE == true
	if(pInfo[playerid][EditObjectOnCreate] == true)
		format(setting1, sizeof(setting1), "Auto edit object after creation\t\t\t\t{91FF91}Enabled");
	else
		format(setting1, sizeof(setting1), "Auto edit object after creation\t\t\t\t{F58282}Disabled");
	#else
		format(setting1, sizeof(setting1), "{323232}Auto edit object after creation\t\t\t\tNot available");
	#endif
	#if ALLOW_EDIT_OBJECT_ON_DUPLICATE == true
	if(pInfo[playerid][EditObjectOnDuplicate] == true)
		format(setting2, sizeof(setting2), "Auto edit object after duplication\t\t\t{91FF91}Enabled");
	else
		format(setting2, sizeof(setting2), "Auto edit object after duplication\t\t\t{F58282}Disabled");
	#else
		format(setting2, sizeof(setting2), "{323232}Auto edit object after duplication\t\t\tNot available");
	#endif
	#if ALLOW_USE_MATERIAL_CHANGE_DIALOG == true
	if(pInfo[playerid][UseMaterialDialog] == true)
		format(setting3, sizeof(setting3), "Use material change dialog\t\t\t\t{91FF91}Enabled");
	else
		format(setting3, sizeof(setting3), "Use material change dialog\t\t\t\t{F58282}Disabled");
	#else
		format(setting3, sizeof(setting3), "{323232}Use material change dialog\t\t\t\tNot available");
	#endif
	#if ALLOW_TRANSFER_MATERIAL == true
	if(pInfo[playerid][TransferMaterial] == true)
		format(setting4, sizeof(setting4), "Copy texture to duplicated object\t\t\t{91FF91}Enabled");
	else
		format(setting4, sizeof(setting4), "Copy texture to duplicated object\t\t\t{F58282}Disabled");
	#else
		format(setting4, sizeof(setting4), "{323232}Copy texture to duplicated object\t\t\tNot available");
	#endif
	#if ALLOW_KEEP_MATERIAL == true
	if(pInfo[playerid][KeepMaterial] == true)
		format(setting5, sizeof(setting5), "Keep custom texture after changing object model\t{91FF91}Enabled");
	else
		format(setting5, sizeof(setting5), "Keep custom texture after changing object model\t{F58282}Disabled");
	#else
		format(setting5, sizeof(setting5), "{323232}Keep custom texture after changing object model\tNot available");
	#endif
	#if ALLOW_USE_CROSS == true
	if(pInfo[playerid][UseCross] == true)
		format(setting6, sizeof(setting6), "Use fade cross when in flyeditor editor mode\t\t{91FF91}Enabled");
	else
		format(setting6, sizeof(setting6), "Use fade cross when in flyeditor editor mode\t\t{F58282}Disabled");
	#else
		format(setting6, sizeof(setting6), "{323232}Use fade cross when in flyeditor editor mode\t\tNot available");
	#endif
	
	#if ALLOW_USE_3D_LABELS == true
	if(pInfo[playerid][UseLabels] == true)
		format(setting6, sizeof(setting7), "Use 3D text labels for help\t\t{91FF91}Enabled");
	else
		format(setting6, sizeof(setting7), "Use 3D text labels for help\t\t{F58282}Disabled");
	#else
		format(setting6, sizeof(setting7), "{323232}Use 3D text labels for help\t\tNot available");
	#endif
	format(dialog, sizeof(dialog),"%s\n%s\n%s\n%s\n%s\n%s\n%s", setting1, setting2, setting3, setting4, setting5, setting6, setting7);
	ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, "Editor settings",dialog,"Change","Close");
	return 1;
}

forward ShowPlayerMaterialDialog(playerid, object);
public ShowPlayerMaterialDialog(playerid, object)
{
	new l1[128], l2[128], l3[128], l4[128], l5[128], dialog[512];
	if(oInfo[playerid][pInfo[playerid][editobject]][indexused] == 0)
		format(l1, sizeof(l1), "Materialindex\t{F58282}-");
	else
		format(l1, sizeof(l1), "Materialindex\t{91FF91}%i", oInfo[playerid][pInfo[playerid][editobject]][matindex]);
	if(oInfo[playerid][pInfo[playerid][editobject]][modelused] == 0)
		format(l2, sizeof(l2), "Model ID\t{F58282}-");
	else
		format(l2, sizeof(l2), "Model ID\t{91FF91}%i", oInfo[playerid][pInfo[playerid][editobject]][matmodel]);
	if(oInfo[playerid][pInfo[playerid][editobject]][txdused] == 0)
		format(l3, sizeof(l3), "TXD Name\t{F58282}-");
	else
	{
		new str[20], input[50];
		format(str, sizeof(str), "%i_txdname", pInfo[playerid][editobject]);
		GetPVarString(playerid, str, input, sizeof(input));
		format(l3, sizeof(l3), "TXD Name\t{91FF91}%s", input);
	}
	if(oInfo[playerid][pInfo[playerid][editobject]][textureused] == 0)
		format(l4, sizeof(l4), "Texture name\t{F58282}-");
	else
	{
		new str[20], input[50];
		format(str, sizeof(str), "%i_texturename", pInfo[playerid][editobject]);
		GetPVarString(playerid, str, input, sizeof(input));
		format(l4, sizeof(l4), "Texture Name\t{91FF91}%s", input);
	}
	if(oInfo[playerid][pInfo[playerid][editobject]][colorused] == 0)
		format(l5, sizeof(l5), "Color\t\t{F58282}-");
	else
	{
		new str[20], input[50];
		format(str, sizeof(str), "%i_color", pInfo[playerid][editobject]);
		GetPVarString(playerid, str, input, sizeof(input));
		if(strcmp(input, "0", true) == 0)
			format(l5, sizeof(l5), "Color\t\t{91FF91}no color (texture default)");
		else
			format(l5, sizeof(l5), "Color\t\t{91FF91}%s", input);
	}
	if(oInfo[playerid][pInfo[playerid][editobject]][usesmaterial] == 0)
	{
		if(IsAllFilledOut(playerid, pInfo[playerid][editobject]))
		{
			format(dialog, sizeof(dialog),"%s\n%s\n%s\n%s\n%s\n{91FF91}Continue\n{323232}Remove texture", l1, l2, l3, l4, l5);
			ShowPlayerDialog(playerid, DIALOG_MATERIALS, DIALOG_STYLE_LIST, "Change material",dialog,"Change","Cancel");
		}
		else
		{
			format(dialog, sizeof(dialog),"%s\n%s\n%s\n%s\n%s\n{323232}Continue\n{323232}Remove texture", l1, l2, l3, l4, l5);
			ShowPlayerDialog(playerid, DIALOG_MATERIALS, DIALOG_STYLE_LIST, "Change material",dialog,"Change","Cancel");
		}
	}
	else
	{
		if(IsAllFilledOut(playerid, pInfo[playerid][editobject]))
		{
			format(dialog, sizeof(dialog),"%s\n%s\n%s\n%s\n%s\n{91FF91}Continue\n{F58282}Remove texture", l1, l2, l3, l4, l5);
			ShowPlayerDialog(playerid, DIALOG_MATERIALS, DIALOG_STYLE_LIST, "Change material",dialog,"Change","Cancel");
		}
		else
		{
			format(dialog, sizeof(dialog),"%s\n%s\n%s\n%s\n%s\n{323232}Continue\n{F58282}Remove texture", l1, l2, l3, l4, l5);
			ShowPlayerDialog(playerid, DIALOG_MATERIALS, DIALOG_STYLE_LIST, "Change material",dialog,"Change","Cancel");
		}
	}
	return 1;
}

forward IsAllFilledOut(playerid, object);
public IsAllFilledOut(playerid, object)
{
	if(oInfo[playerid][object][indexused] == 1)
	{
		if(oInfo[playerid][object][modelused] == 1)
		{
			if(oInfo[playerid][object][txdused] == 1)
			{
				if(oInfo[playerid][object][textureused] == 1)
				{
					if(oInfo[playerid][object][colorused] == 1)
					{
						return 1;
					}
					else return 0;
				}
				else return 0;
			}
			else return 0;
		}
		else return 0;
	}
	else return 0;
}

forward ChangeObjectMaterial(playerid, object);
public ChangeObjectMaterial(playerid, object)
{
	oInfo[playerid][object][usesmaterial] = 1;
	new txdname[50], texturename[50], color[15];
	new str1[50], str2[50], str3[15];
	format(str1, sizeof(str1), "%i_txdname", object);
	GetPVarString(playerid, str1, txdname, sizeof(txdname));
	format(str2, sizeof(str2), "%i_texturename", object);
	GetPVarString(playerid, str2, texturename, sizeof(texturename));
	format(str3, sizeof(str3), "%i_color", object);
	GetPVarString(playerid, str3, color, sizeof(color));
	new rescolor = HexToInt(color);
	SetObjectMaterial(oInfo[playerid][object][objectID], oInfo[playerid][object][matindex], oInfo[playerid][object][matmodel], txdname, texturename, rescolor);
	return 1;
}

forward ResetObjectMaterial(playerid, object);
public ResetObjectMaterial(playerid, object)
{	
	oInfo[playerid][object][indexused] 		= 0;
	oInfo[playerid][object][modelused] 		= 0;
	oInfo[playerid][object][txdused] 		= 0;
	oInfo[playerid][object][textureused] 	= 0;
	oInfo[playerid][object][colorused] 		= 0;
	oInfo[playerid][object][matindex] 		= -1;
	oInfo[playerid][object][matmodel] 		= -1;
	new str1[20], str2[20], str3[20];
	format(str1, sizeof(str1), "%i_txdname", object);
	format(str2, sizeof(str2), "%i_texturename", object);
	format(str3, sizeof(str3), "%i_color", object);
	DeletePVar(playerid, str1);
	DeletePVar(playerid, str2);
	DeletePVar(playerid, str3);
	oInfo[playerid][object][usesmaterial] 	= 0;
	DestroyObject(oInfo[playerid][object][objectID]);
	oInfo[playerid][object][objectID] = CreateObject(oInfo[playerid][object][modelID], oInfo[playerid][object][XLoc], oInfo[playerid][object][YLoc], oInfo[playerid][object][ZLoc], oInfo[playerid][object][XRot], oInfo[playerid][object][YRot], oInfo[playerid][object][ZRot]);
	new msg[128];
	format(msg, sizeof(msg), "You have reset the texture of object number {F58282}%i{F5F582} (Model {F58282}%i{F5F582}) to default.", object, oInfo[playerid][object][modelID]);
	SendClientInfoMessage(playerid, msg);
	return 1;
}

forward ResetAllValues(playerid);
public ResetAllValues(playerid)
{
	for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
	{
		oInfo[playerid][i][created] 			= 0;
		oInfo[playerid][i][objectID] 			= 0;
		oInfo[playerid][i][modelID] 			= 0;
		oInfo[playerid][i][XLoc] 				= 0.0;
		oInfo[playerid][i][YLoc] 				= 0.0;
		oInfo[playerid][i][ZLoc] 				= 0.0;
		oInfo[playerid][i][XRot] 				= 0.0;
		oInfo[playerid][i][YRot] 				= 0.0;
		oInfo[playerid][i][ZRot] 				= 0.0;
		oInfo[playerid][i][usesmaterial] 		= 0;
		oInfo[playerid][i][indexused] 			= 0;
		oInfo[playerid][i][modelused] 			= 0;
		oInfo[playerid][i][txdused] 			= 0;
		oInfo[playerid][i][textureused] 		= 0;
		oInfo[playerid][i][colorused] 			= 0;
		oInfo[playerid][i][matindex] 			= 0;
		oInfo[playerid][i][matmodel] 			= 0;
		new str1[20], str2[20], str3[20];
		format(str1, sizeof(str1), "%i_txdname", i);
		format(str2, sizeof(str2), "%i_texturename", i);
		format(str3, sizeof(str3), "%i_color", i);
		DeletePVar(playerid, str1);
		DeletePVar(playerid, str2);
		DeletePVar(playerid, str3);
	}
	pInfo[playerid][EditObjectOnCreate] 		= false;
	pInfo[playerid][EditObjectOnDuplicate] 		= false;
	pInfo[playerid][UseMaterialDialog] 			= false;
	pInfo[playerid][TransferMaterial] 			= false;
	pInfo[playerid][totalobjects] 				= 0;
	pInfo[playerid][editobject] 				= INVALID_OBJECT_NUMBER;
	pInfo[playerid][editing] 					= false;
	return 1;
}

forward ShowPlayerCommandHelp(playerid);
public ShowPlayerCommandHelp(playerid)
{	
	new l1[65], l2[27], l3[210], l4[247], l5[262], l6[262], l7[195];
	new dialog[1200];
	l1  = "Below is a list of all available commands for the object editor:";
	l2  = "Command\t\tShortcut\tEffect";
	l3  =  "{87FF87}/createnewobject\t{F5F582}/cno\t\t{A9C4E4}Creates a new object\n"\
		   "{87FF87}/deleteobject\t\t{F5F582}/deo\t\t{A9C4E4}Deletes an object\n"\
		   "{87FF87}/deleteallobjects\t{F5F582}/deao\t\t{A9C4E4}Deletes all object";
	l4  =  "{87FF87}/setobjectxoffset\t{F5F582}/soxo\t\t{A9C4E4}Moves an object on the X axis\n"\
		   "{87FF87}/setobjectyoffset\t{F5F582}/soyo\t\t{A9C4E4}Moves an object on the Y axis\n"\
		   "{87FF87}/setobjectzoffset\t{F5F582}/sozo\t\t{A9C4E4}Moves an object on the Z axis";
	l5  =  "{87FF87}/setallobjectsxoffset\t{F5F582}/saoxo\t\t{A9C4E4}Move all object on the X axis\n"\
		   "{87FF87}/setallobjectsyoffset\t{F5F582}/saoyo\t\t{A9C4E4}Move all object on the Y axis\n"\
		   "{87FF87}/setallobjectszoffset\t{F5F582}/saozo\t\t{A9C4E4}Move all object on the Z axis";
	l6  =  "{87FF87}/setobjectxrotation\t{F5F582}/soxr\t\t{A9C4E4}Sets the X rotation of an object\n"\
		   "{87FF87}/setobjectyrotation\t{F5F582}/soyr\t\t{A9C4E4}Sets the Y rotation of an object\n"\
		   "{87FF87}/setobjectzrotation\t{F5F582}/sozr\t\t{A9C4E4}Sets the Z rotation of an object";
	l7 =  "{F5F582}Note: {A9C4E4}You can also type the command to get extra information about each command and the parameters.";
	format(dialog, sizeof(dialog), "%s\n\n%s\n%s\n\n%s\n%s\n\n%s\n\n%s",l1, l2, l3, l4, l5, l6, l7);
	ShowPlayerDialog(playerid, DIALOG_EDITORCOMMANDS, DIALOG_STYLE_MSGBOX, "Object Editor Commands #1", dialog, "Close","Page 2 >");
	return 1;
}

forward ShowPlayerCommandHelp2(playerid);
public ShowPlayerCommandHelp2(playerid)
{	
	new l1[65], l2[27], l3[250], l4[247], l5[262], l6[262], l7[470];
	new dialog[1630];
	l1  = "Below is a list of all available commands for the object editor:";
	l2  = "Command\t\tShortcut\tEffect";
	l3  =  "{87FF87}/nearestobject\t{F5F582}/neo\t\t{A9C4E4}Gets the closes object to your position\n"\
		   "{87FF87}/gotoobject\t\t{F5F582}/goo\t\t{A9C4E4}Teleports you to an object\n"\
		   "{87FF87}/replaceobjectmodel\t{F5F582}/rpom\t\t{A9C4E4}Replaces an object with a new object";
	l4  =  "{87FF87}/duplicateobject\t{F5F582}/duo\t\t{A9C4E4}Duplicates an object\n"\
	       "{87FF87}/setobjectmaterial\t{F5F582}/som\t\t{A9C4E4}Changes the texture of an object\n"\
		   "{87FF87}/setobjectpos\t\t{F5F582}/sop\t\t{A9C4E4}Sets an object to an exact position";
	l5  =  "{87FF87}/editobject\t\t{F5F582}/edo\t\t{A9C4E4}Modifies an object using the object editing tool\n"\
		   "{87FF87}/selectobject\t\t{F5F582}/seo\t\t{A9C4E4}Selects an object by clicking on it\n"\
		   "{87FF87}/flyeditor\t\t{F5F582}-\t\t{A9C4E4}Enters the flyeditor editor mode";
	#if ALLOW_EXPORT_MAP_FILE == true
	l6 =  "{87FF87}/saveobjects\t\t{F5F582}-\t\t{A9C4E4}Saves an object file\n"\
		   "{87FF87}/loadobjects\t\t{F5F582}-\t\t{A9C4E4}Loads an object file\n"\
		   "{87FF87}/exportobjects\t{F5F582}-\t\t{A9C4E4}Exports an object file in the CreateObject() format";
	#else
	l6 =  "{87FF87}/saveobjects\t\t{F5F582}-\t\t{A9C4E4}Saves an object file\n"\
		   "{87FF87}/loadobjects\t\t{F5F582}-\t\t{A9C4E4}Loads an object file\n"\
		   "{87FF87}/exportobjects\t{F5F582}-\t\t{A9C4E4}Exports an object file in the CreateObject() format\t{F58282}(RCON Admins only)";
	#endif
	l7 =  "{87FF87}/editorcommands\t{F5F582}-\t\t{A9C4E4}Shows the editor commands help\n"\
		  "{87FF87}/esettingshelp\t{F5F582}-\t\t{A9C4E4}Shows editor settings help\n"\
		  "{87FF87}/editorsettings\t{F5F582}-\t\t{A9C4E4}Shows the editor settings dialog to a player\n"\
		  "{87FF87}/toggleeditor\t\t{F5F582}-\t\t{A9C4E4}Can be used by an RCON admin to allow a player to use the editor\n\n"\
		  "{F5F582}Note: {A9C4E4}You can also type the command to get extra information about each command and the parameters.";
	format(dialog, sizeof(dialog), "%s\n\n%s\n%s\n%s\n%s\n%s\n\n%s",l1, l2, l3, l4, l5, l6, l7);
	//                               1     2   3     4   5     6     7   8     9    10  11
	ShowPlayerDialog(playerid, DIALOG_EDITORCOMMANDS2, DIALOG_STYLE_MSGBOX, "Object Editor Commands #2", dialog, "< Page 1","Close");
	return 1;
}

forward ShowPlayerSettingsHelp(playerid);
public ShowPlayerSettingsHelp(playerid)
{	
	new s1[220], s2[225], s3[233], s4[238], s5[216], s6[236], s7[74], dialog[1450];
	s1 = "{91FF91}Auto edit object after creation:\n"\
		 "{A9C4E4}If this option is enabled you will be automatically be put into the editor mode after creating an object.\nBy this you can immediately modify it's position and rotation.";
	s2 = "{91FF91}Auto edit object after duplication:\n"\
		 "{A9C4E4}If this option is enabled you will be automatically be put into the editor mode after duplicating an object.\nBy this you can immediately modify it's position and rotation.";
	s3 = "{91FF91}Use material change dialog:\n"\
		 "{A9C4E4}This option allows you to use the dialog menu to change an object's texture.\nIf it is disabled, you must use /setobjectmaterial and enter all it's parameters together with the command.";
	s4 = "{91FF91}Copy texture to duplicated object:\n"\
		 "{A9C4E4}If this is enabled, a duplicated object with automatically have the custom texture of it's \"mother object\".\nIf disabled, the duplicated object will have the object default texture.";
	s5 = "{91FF91}Keep custom texture after changing object model:\n"\
		 "{A9C4E4}This option allows you to keep the custom texture after you changed the model of an object.\nIf it's disabled, the custom texture will be deleted.";
	s6 = "{91FF91}Use fade cross when in flyeditor editor mode:\n"\
	     "{A9C4E4}If enabled, you will have a fade cross in the middle of your screen when you're in the flyeditor editor mode.\nYou can remove the fade cross by disabling this option.";
	s7 = "If an object is grayed out, this feature has been disabled by the server.";
	format(dialog, sizeof(dialog), "Below is a list of all options found in {F5F582}/editorsettings{A9C4E4}.\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s", s1, s2, s3, s4, s5, s6, s7);
	ShowPlayerDialog(playerid, DIALOG_SETTINGSHELP, DIALOG_STYLE_MSGBOX, "Editor settings help",dialog,"Close","");
	return 1;
}

forward Startflyeditor(playerid);
public Startflyeditor(playerid)
{
	pInfo[playerid][flyeditor] = 1;
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	pInfo[playerid][flyobject] = CreatePlayerObject(playerid, 19300, X, Y, Z, 0.0, 0.0, 0.0);
	TogglePlayerSpectating(playerid, true);
	AttachCameraToPlayerObject(playerid, pInfo[playerid][flyobject]);
	SendClientInfoMessage(playerid, "You have entered the fly mode.");
	SendClientInfoMessage(playerid, "Use {F58282}~k~~GO_FORWARD~ ~k~~GO_BACK~ ~k~~GO_LEFT~ ~k~~GO_RIGHT~{F5F582} to move the camera.");
	SendClientInfoMessage(playerid, "Press {F58282}~k~~VEHICLE_ENTER_EXIT~{F5F582} to select an object you want to edit.");
	SendClientInfoMessage(playerid, "While you are editing an object, you can move the camera around while holding down {F58282}~k~~PED_SPRINT~{F5F582}.");
	SendClientInfoMessage(playerid, "To exit the fly mode, type /flyeditor again.");
	if(pInfo[playerid][UseCross] == true)
	{
		PlayerTextDrawShow(playerid, Cross[0]);
		PlayerTextDrawShow(playerid, Cross[1]);
	}
	return 1;
}

forward Endflyeditor(playerid);
public Endflyeditor(playerid)
{
	pInfo[playerid][flyeditor] = 0;
	GetPlayerCameraPos(playerid, pInfo[playerid][poX], pInfo[playerid][poY], pInfo[playerid][poZ]);
	CancelEdit(playerid);
	TogglePlayerSpectating(playerid, false);
	DestroyPlayerObject(playerid, pInfo[playerid][flyobject]);
	PlayerTextDrawHide(playerid, Cross[0]);
	PlayerTextDrawHide(playerid, Cross[1]);
	SetTimer("SpawnDelay", 100, 0);
	return 1;
}

forward SpawnDelay(playerid);
public SpawnDelay(playerid)
{
	SetPlayerPos(playerid, pInfo[playerid][poX], pInfo[playerid][poY], pInfo[playerid][poZ]);
}

forward ShowAllLabels(playerid);
public ShowAllLabels(playerid)
{
	for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
	{
		if(oInfo[playerid][i][created])
		{
			//new labeltext[200];
			//format(labeltext, 200, "Object Number: %i\nModel ID: %i\nRotation: %.2f, %.2f, %.2f", i, oInfo[playerid][i][modelID], oInfo[playerid][i][XRot], oInfo[playerid][i][YRot], oInfo[playerid][i][ZRot]);
			oInfo[playerid][i][labelID] = CreatePlayer3DTextLabel(playerid, "*labeltext*""lol", -1, oInfo[playerid][i][XLoc], oInfo[playerid][i][YLoc], oInfo[playerid][i][ZLoc], 10.0, 0, 0, 0);
		}
	}
	return 1;
}

forward HideAllLabels(playerid);
public HideAllLabels(playerid)
{
	for(new i = 0; i < MAX_CREATED_OBJECTS; i++)
	{
		DeletePlayer3DTextLabel(playerid, oInfo[playerid][i][labelID]);
	}
	return 1;
}

IsNumeric(szInput[])
{
	new iChar, i = 0;
	while ((iChar = szInput[i++])) if (!('0' <= iChar <= '9')) return 0;
	return 1;
}

HexToInt(string[]){
   if (string[0]==0) return 0;
   new i;
   new cur=1;
   new res=0;
   for (i=strlen(string);i>0;i--) {
     if (string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
     cur=cur*16;
   }
   return res;
 }

stock GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;
	
    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT;
		else if(ud > 0) direction = MOVE_BACK_LEFT;
		else            direction = MOVE_LEFT;
	}
	else if(lr > 0)
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;
		else if(ud > 0) direction = MOVE_BACK_RIGHT;
		else			direction = MOVE_RIGHT;
	}
	else if(ud < 0) 	direction = MOVE_FORWARD;
	else if(ud > 0) 	direction = MOVE_BACK;
	return direction;
}

stock MoveCamera(playerid)
{
	new Float:FV[3], Float:CP[3];
	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);
	if(pInfo[playerid][accelmul] <= 1) pInfo[playerid][accelmul] += ACCEL_RATE;
	new Float:speed = MOVE_SPEED * pInfo[playerid][accelmul];
	new Float:X, Float:Y, Float:Z;
	GetNextCameraPosition(pInfo[playerid][mode], CP, FV, X, Y, Z);
	MovePlayerObject(playerid, pInfo[playerid][flyobject], X, Y, Z, speed);
	pInfo[playerid][lastmove] = GetTickCount();
	return 1;
}

stock GetNextCameraPosition(move_mode, Float:CP[3], Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    #define OFFSET_X (FV[0]*6000.0)
	#define OFFSET_Y (FV[1]*6000.0)
	#define OFFSET_Z (FV[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = CP[0]+OFFSET_X;
			Y = CP[1]+OFFSET_Y;
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = CP[0]-OFFSET_X;
			Y = CP[1]-OFFSET_Y;
			Z = CP[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = CP[0]-OFFSET_Y;
			Y = CP[1]+OFFSET_X;
			Z = CP[2];
		}
		case MOVE_RIGHT:
		{
			X = CP[0]+OFFSET_Y;
			Y = CP[1]-OFFSET_X;
			Z = CP[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = CP[0]+(-OFFSET_X - OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = CP[0]+(-OFFSET_X + OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = CP[0]+(OFFSET_X  - OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  + OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = CP[0]+(OFFSET_X  + OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  - OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
	}
}