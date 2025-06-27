// TextDraw developed using Zamaroht's Textdraw Editor 1.0

//TEXTDRAW 0-4 = CIVILIAN
//TEXTDRAW 5-9 = FBI
//TEXTDRAW 9-14 = ARMY
//TEXTDRAW 15-19 = CIA
//TEXTDRAW 20-24 = FIREFIGHTER
//TEXTDRAW 25-29 = MEDIC
//TEXTDRAW 30-34 = COP(simple POLICE)

//MAKE SURE TO EDIT THE XP MINIMUM REQUIREMENTS FOR DIFFERENT CLASSES FROM THE GAMEMODE, @UltraZ or @Dual
//XP REQUIREMENT :-
//CIVILIAN = 0 XP REQUIRED
//FBI = 10,000 XP REQUIRED
//ARMY = 20,000 XP REQUIRED
//CIA = 15,000 XP REQUIRED
//FIREFIGHTER = 5,000 XP REQUIRED
//MEDIC = 3,000 XP REQUIRED
//COP = 0 XP REQUIRED




// On top of script:


//CIVILIAN
// In OnGameModeInit prefferably, we procced to create our textdraws:
Textdraw0 = TextDrawCreate(186.000000, 191.000000, "CIVILIAN");
TextDrawBackgroundColor(Textdraw0, 255);
TextDrawFont(Textdraw0, 3);
TextDrawLetterSize(Textdraw0, 0.689999, 1.900000);
TextDrawColor(Textdraw0, -1);
TextDrawSetOutline(Textdraw0, 0);
TextDrawSetProportional(Textdraw0, 1);
TextDrawSetShadow(Textdraw0, 1);
TextDrawUseBox(Textdraw0, 1);
TextDrawBoxColor(Textdraw0, 255);
TextDrawTextSize(Textdraw0, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw0, 0);

Textdraw1 = TextDrawCreate(186.000000, 212.000000, "-Rob/Rape players ingame");
TextDrawBackgroundColor(Textdraw1, 255);
TextDrawFont(Textdraw1, 1);
TextDrawLetterSize(Textdraw1, 0.200000, 1.000000);
TextDrawColor(Textdraw1, -1);
TextDrawSetOutline(Textdraw1, 0);
TextDrawSetProportional(Textdraw1, 1);
TextDrawSetShadow(Textdraw1, 1);
TextDrawUseBox(Textdraw1, 1);
TextDrawBoxColor(Textdraw1, 639443043);
TextDrawTextSize(Textdraw1, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw1, 0);

Textdraw2 = TextDrawCreate(186.000000, 224.000000, "-Kill anyone on STREETS");
TextDrawBackgroundColor(Textdraw2, 255);
TextDrawFont(Textdraw2, 1);
TextDrawLetterSize(Textdraw2, 0.200000, 1.000000);
TextDrawColor(Textdraw2, -1);
TextDrawSetOutline(Textdraw2, 0);
TextDrawSetProportional(Textdraw2, 1);
TextDrawSetShadow(Textdraw2, 1);
TextDrawUseBox(Textdraw2, 1);
TextDrawBoxColor(Textdraw2, 639443043);
TextDrawTextSize(Textdraw2, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw2, 0);

Textdraw3 = TextDrawCreate(186.000000, 237.000000, "-Rob stores for money");
TextDrawBackgroundColor(Textdraw3, 255);
TextDrawFont(Textdraw3, 1);
TextDrawLetterSize(Textdraw3, 0.200000, 1.000000);
TextDrawColor(Textdraw3, -1);
TextDrawSetOutline(Textdraw3, 0);
TextDrawSetProportional(Textdraw3, 1);
TextDrawSetShadow(Textdraw3, 1);
TextDrawUseBox(Textdraw3, 1);
TextDrawBoxColor(Textdraw3, 639443043);
TextDrawTextSize(Textdraw3, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw3, 0);

Textdraw4 = TextDrawCreate(186.000000, 250.000000, "-Can join any CLAN/GANG");
TextDrawBackgroundColor(Textdraw4, 255);
TextDrawFont(Textdraw4, 1);
TextDrawLetterSize(Textdraw4, 0.200000, 1.000000);
TextDrawColor(Textdraw4, -1);
TextDrawSetOutline(Textdraw4, 0);
TextDrawSetProportional(Textdraw4, 1);
TextDrawSetShadow(Textdraw4, 1);
TextDrawUseBox(Textdraw4, 1);
TextDrawBoxColor(Textdraw4, 639443043);
TextDrawTextSize(Textdraw4, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw4, 0);




//FBI
Textdraw5 = TextDrawCreate(186.000000, 191.000000, "FBI");
TextDrawBackgroundColor(Textdraw5, 255);
TextDrawFont(Textdraw5, 3);
TextDrawLetterSize(Textdraw5, 0.689999, 1.900000);
TextDrawColor(Textdraw5, -1);
TextDrawSetOutline(Textdraw5, 0);
TextDrawSetProportional(Textdraw5, 1);
TextDrawSetShadow(Textdraw5, 1);
TextDrawUseBox(Textdraw5, 1);
TextDrawBoxColor(Textdraw5, 385941503);
TextDrawTextSize(Textdraw5, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw5, 0);

Textdraw6 = TextDrawCreate(186.000000, 212.000000, "-Law Enforcement Officer");
TextDrawBackgroundColor(Textdraw6, 255);
TextDrawFont(Textdraw6, 1);
TextDrawLetterSize(Textdraw6, 0.200000, 1.000000);
TextDrawColor(Textdraw6, -1);
TextDrawSetOutline(Textdraw6, 0);
TextDrawSetProportional(Textdraw6, 1);
TextDrawSetShadow(Textdraw6, 1);
TextDrawUseBox(Textdraw6, 1);
TextDrawBoxColor(Textdraw6, 639443043);
TextDrawTextSize(Textdraw6, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw6, 0);

Textdraw7 = TextDrawCreate(186.000000, 224.000000, "-Maintains the LAW");
TextDrawBackgroundColor(Textdraw7, 255);
TextDrawFont(Textdraw7, 1);
TextDrawLetterSize(Textdraw7, 0.200000, 1.000000);
TextDrawColor(Textdraw7, -1);
TextDrawSetOutline(Textdraw7, 0);
TextDrawSetProportional(Textdraw7, 1);
TextDrawSetShadow(Textdraw7, 1);
TextDrawUseBox(Textdraw7, 1);
TextDrawBoxColor(Textdraw7, 639443043);
TextDrawTextSize(Textdraw7, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw7, 0);

Textdraw8 = TextDrawCreate(186.000000, 237.000000, "-Can use /bruteforce");
TextDrawBackgroundColor(Textdraw8, 255);
TextDrawFont(Textdraw8, 1);
TextDrawLetterSize(Textdraw8, 0.200000, 1.000000);
TextDrawColor(Textdraw8, -1);
TextDrawSetOutline(Textdraw8, 0);
TextDrawSetProportional(Textdraw8, 1);
TextDrawSetShadow(Textdraw8, 1);
TextDrawUseBox(Textdraw8, 1);
TextDrawBoxColor(Textdraw8, 639443043);
TextDrawTextSize(Textdraw8, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw8, 0);

Textdraw9 = TextDrawCreate(186.000000, 250.000000, "-10,000 XP REQUIRED");
TextDrawBackgroundColor(Textdraw9, 255);
TextDrawFont(Textdraw9, 1);
TextDrawLetterSize(Textdraw9, 0.200000, 1.000000);
TextDrawColor(Textdraw9, -1);
TextDrawSetOutline(Textdraw9, 0);
TextDrawSetProportional(Textdraw9, 1);
TextDrawSetShadow(Textdraw9, 1);
TextDrawUseBox(Textdraw9, 1);
TextDrawBoxColor(Textdraw9, 639443043);
TextDrawTextSize(Textdraw9, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw9, 0);



//ARMY
Textdraw10 = TextDrawCreate(186.000000, 191.000000, "ARMY");
TextDrawBackgroundColor(Textdraw10, 255);
TextDrawFont(Textdraw10, 3);
TextDrawLetterSize(Textdraw10, 0.689999, 1.900000);
TextDrawColor(Textdraw10, -1);
TextDrawSetOutline(Textdraw10, 0);
TextDrawSetProportional(Textdraw10, 1);
TextDrawSetShadow(Textdraw10, 1);
TextDrawUseBox(Textdraw10, 1);
TextDrawBoxColor(Textdraw10, 1493237759);
TextDrawTextSize(Textdraw10, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw10, 0);

Textdraw11 = TextDrawCreate(186.000000, 212.000000, "-Law Enforcement Officer");
TextDrawBackgroundColor(Textdraw11, 255);
TextDrawFont(Textdraw11, 1);
TextDrawLetterSize(Textdraw11, 0.200000, 1.000000);
TextDrawColor(Textdraw11, -1);
TextDrawSetOutline(Textdraw11, 0);
TextDrawSetProportional(Textdraw11, 1);
TextDrawSetShadow(Textdraw11, 1);
TextDrawUseBox(Textdraw11, 1);
TextDrawBoxColor(Textdraw11, 639443043);
TextDrawTextSize(Textdraw11, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw11, 0);

Textdraw12 = TextDrawCreate(186.000000, 224.000000, "-Maintains the LAW");
TextDrawBackgroundColor(Textdraw12, 255);
TextDrawFont(Textdraw12, 1);
TextDrawLetterSize(Textdraw12, 0.200000, 1.000000);
TextDrawColor(Textdraw12, -1);
TextDrawSetOutline(Textdraw12, 0);
TextDrawSetProportional(Textdraw12, 1);
TextDrawSetShadow(Textdraw12, 1);
TextDrawUseBox(Textdraw12, 1);
TextDrawBoxColor(Textdraw12, 639443043);
TextDrawTextSize(Textdraw12, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw12, 0);

Textdraw13 = TextDrawCreate(186.000000, 237.000000, "-Can use HUNTER/RHINO");
TextDrawBackgroundColor(Textdraw13, 255);
TextDrawFont(Textdraw13, 1);
TextDrawLetterSize(Textdraw13, 0.200000, 1.000000);
TextDrawColor(Textdraw13, -1);
TextDrawSetOutline(Textdraw13, 0);
TextDrawSetProportional(Textdraw13, 1);
TextDrawSetShadow(Textdraw13, 1);
TextDrawUseBox(Textdraw13, 1);
TextDrawBoxColor(Textdraw13, 639443043);
TextDrawTextSize(Textdraw13, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw13, 0);

Textdraw14 = TextDrawCreate(186.000000, 250.000000, "-20,000 XP REQUIRED");
TextDrawBackgroundColor(Textdraw14, 255);
TextDrawFont(Textdraw14, 1);
TextDrawLetterSize(Textdraw14, 0.200000, 1.000000);
TextDrawColor(Textdraw14, -1);
TextDrawSetOutline(Textdraw14, 0);
TextDrawSetProportional(Textdraw14, 1);
TextDrawSetShadow(Textdraw14, 1);
TextDrawUseBox(Textdraw14, 1);
TextDrawBoxColor(Textdraw14, 639443043);
TextDrawTextSize(Textdraw14, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw14, 0);




//CIA
Textdraw15 = TextDrawCreate(186.000000, 191.000000, "CIA");
TextDrawBackgroundColor(Textdraw15, 255);
TextDrawFont(Textdraw15, 3);
TextDrawLetterSize(Textdraw15, 0.689999, 1.900000);
TextDrawColor(Textdraw15, -1);
TextDrawSetOutline(Textdraw15, 0);
TextDrawSetProportional(Textdraw15, 1);
TextDrawSetShadow(Textdraw15, 1);
TextDrawUseBox(Textdraw15, 1);
TextDrawBoxColor(Textdraw15, 1127180543);
TextDrawTextSize(Textdraw15, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw15, 0);

Textdraw16 = TextDrawCreate(186.000000, 212.000000, "-Law Enforcement Officer");
TextDrawBackgroundColor(Textdraw16, 255);
TextDrawFont(Textdraw16, 1);
TextDrawLetterSize(Textdraw16, 0.200000, 1.000000);
TextDrawColor(Textdraw16, -1);
TextDrawSetOutline(Textdraw16, 0);
TextDrawSetProportional(Textdraw16, 1);
TextDrawSetShadow(Textdraw16, 1);
TextDrawUseBox(Textdraw16, 1);
TextDrawBoxColor(Textdraw16, 639443043);
TextDrawTextSize(Textdraw16, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw16, 0);

Textdraw17 = TextDrawCreate(186.000000, 224.000000, "-Maintains the LAW");
TextDrawBackgroundColor(Textdraw17, 255);
TextDrawFont(Textdraw17, 1);
TextDrawLetterSize(Textdraw17, 0.200000, 1.000000);
TextDrawColor(Textdraw17, -1);
TextDrawSetOutline(Textdraw17, 0);
TextDrawSetProportional(Textdraw17, 1);
TextDrawSetShadow(Textdraw17, 1);
TextDrawUseBox(Textdraw17, 1);
TextDrawBoxColor(Textdraw17, 639443043);
TextDrawTextSize(Textdraw17, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw17, 0);

Textdraw18 = TextDrawCreate(186.000000, 237.000000, "-Invisible from RADAR");
TextDrawBackgroundColor(Textdraw18, 255);
TextDrawFont(Textdraw18, 1);
TextDrawLetterSize(Textdraw18, 0.200000, 1.000000);
TextDrawColor(Textdraw18, -1);
TextDrawSetOutline(Textdraw18, 0);
TextDrawSetProportional(Textdraw18, 1);
TextDrawSetShadow(Textdraw18, 1);
TextDrawUseBox(Textdraw18, 1);
TextDrawBoxColor(Textdraw18, 639443043);
TextDrawTextSize(Textdraw18, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw18, 0);

Textdraw19 = TextDrawCreate(186.000000, 250.000000, "-15,000 XP REQUIRED");
TextDrawBackgroundColor(Textdraw19, 255);
TextDrawFont(Textdraw19, 1);
TextDrawLetterSize(Textdraw19, 0.200000, 1.000000);
TextDrawColor(Textdraw19, -1);
TextDrawSetOutline(Textdraw19, 0);
TextDrawSetProportional(Textdraw19, 1);
TextDrawSetShadow(Textdraw19, 1);
TextDrawUseBox(Textdraw19, 1);
TextDrawBoxColor(Textdraw19, 639443043);
TextDrawTextSize(Textdraw19, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw19, 0);




/FIREMAN
Textdraw20 = TextDrawCreate(186.000000, 191.000000, "FIREMAN");
TextDrawBackgroundColor(Textdraw20, 255);
TextDrawFont(Textdraw20, 3);
TextDrawLetterSize(Textdraw20, 0.689999, 1.900000);
TextDrawColor(Textdraw20, -1);
TextDrawSetOutline(Textdraw20, 0);
TextDrawSetProportional(Textdraw20, 1);
TextDrawSetShadow(Textdraw20, 1);
TextDrawUseBox(Textdraw20, 1);
TextDrawBoxColor(Textdraw20, 2116297983);
TextDrawTextSize(Textdraw20, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw20, 0);

Textdraw21 = TextDrawCreate(186.000000, 212.000000, "-Can abuse canon");
TextDrawBackgroundColor(Textdraw21, 255);
TextDrawFont(Textdraw21, 1);
TextDrawLetterSize(Textdraw21, 0.200000, 1.000000);
TextDrawColor(Textdraw21, -1);
TextDrawSetOutline(Textdraw21, 0);
TextDrawSetProportional(Textdraw21, 1);
TextDrawSetShadow(Textdraw21, 1);
TextDrawUseBox(Textdraw21, 1);
TextDrawBoxColor(Textdraw21, 639443043);
TextDrawTextSize(Textdraw21, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw21, 0);

Textdraw22 = TextDrawCreate(186.000000, 224.000000, "-Can abuse firetruck water");
TextDrawBackgroundColor(Textdraw22, 255);
TextDrawFont(Textdraw22, 1);
TextDrawLetterSize(Textdraw22, 0.200000, 1.000000);
TextDrawColor(Textdraw22, -1);
TextDrawSetOutline(Textdraw22, 0);
TextDrawSetProportional(Textdraw22, 1);
TextDrawSetShadow(Textdraw22, 1);
TextDrawUseBox(Textdraw22, 1);
TextDrawBoxColor(Textdraw22, 639443043);
TextDrawTextSize(Textdraw22, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw22, 0);

Textdraw23 = TextDrawCreate(186.000000, 237.000000, "-Rob stores for money");
TextDrawBackgroundColor(Textdraw23, 255);
TextDrawFont(Textdraw23, 1);
TextDrawLetterSize(Textdraw23, 0.200000, 1.000000);
TextDrawColor(Textdraw23, -1);
TextDrawSetOutline(Textdraw23, 0);
TextDrawSetProportional(Textdraw23, 1);
TextDrawSetShadow(Textdraw23, 1);
TextDrawUseBox(Textdraw23, 1);
TextDrawBoxColor(Textdraw23, 639443043);
TextDrawTextSize(Textdraw23, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw23, 0);

Textdraw24 = TextDrawCreate(186.000000, 250.000000, "-5,000 XP REQUIRED");
TextDrawBackgroundColor(Textdraw24, 255);
TextDrawFont(Textdraw24, 1);
TextDrawLetterSize(Textdraw24, 0.200000, 1.000000);
TextDrawColor(Textdraw24, -1);
TextDrawSetOutline(Textdraw24, 0);
TextDrawSetProportional(Textdraw24, 1);
TextDrawSetShadow(Textdraw24, 1);
TextDrawUseBox(Textdraw24, 1);
TextDrawBoxColor(Textdraw24, 639443043);
TextDrawTextSize(Textdraw24, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw24, 0);



//MEDIC
Textdraw25 = TextDrawCreate(186.000000, 191.000000, "MEDIC");
TextDrawBackgroundColor(Textdraw25, 255);
TextDrawFont(Textdraw25, 3);
TextDrawLetterSize(Textdraw25, 0.689999, 1.900000);
TextDrawColor(Textdraw25, -1);
TextDrawSetOutline(Textdraw25, 0);
TextDrawSetProportional(Textdraw25, 1);
TextDrawSetShadow(Textdraw25, 1);
TextDrawUseBox(Textdraw25, 1);
TextDrawBoxColor(Textdraw25, 1124008191);
TextDrawTextSize(Textdraw25, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw25, 0);

Textdraw26 = TextDrawCreate(186.000000, 212.000000, "-Can HEAL players");
TextDrawBackgroundColor(Textdraw26, 255);
TextDrawFont(Textdraw26, 1);
TextDrawLetterSize(Textdraw26, 0.200000, 1.000000);
TextDrawColor(Textdraw26, -1);
TextDrawSetOutline(Textdraw26, 0);
TextDrawSetProportional(Textdraw26, 1);
TextDrawSetShadow(Textdraw26, 1);
TextDrawUseBox(Textdraw26, 1);
TextDrawBoxColor(Textdraw26, 639443043);
TextDrawTextSize(Textdraw26, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw26, 0);

Textdraw27 = TextDrawCreate(186.000000, 224.000000, "-Can CURE STDs");
TextDrawBackgroundColor(Textdraw27, 255);
TextDrawFont(Textdraw27, 1);
TextDrawLetterSize(Textdraw27, 0.200000, 1.000000);
TextDrawColor(Textdraw27, -1);
TextDrawSetOutline(Textdraw27, 0);
TextDrawSetProportional(Textdraw27, 1);
TextDrawSetShadow(Textdraw27, 1);
TextDrawUseBox(Textdraw27, 1);
TextDrawBoxColor(Textdraw27, 639443043);
TextDrawTextSize(Textdraw27, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw27, 0);

Textdraw28 = TextDrawCreate(186.000000, 237.000000, "-Rob stores for money");
TextDrawBackgroundColor(Textdraw28, 255);
TextDrawFont(Textdraw28, 1);
TextDrawLetterSize(Textdraw28, 0.200000, 1.000000);
TextDrawColor(Textdraw28, -1);
TextDrawSetOutline(Textdraw28, 0);
TextDrawSetProportional(Textdraw28, 1);
TextDrawSetShadow(Textdraw28, 1);
TextDrawUseBox(Textdraw28, 1);
TextDrawBoxColor(Textdraw28, 639443043);
TextDrawTextSize(Textdraw28, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw28, 0);

Textdraw29 = TextDrawCreate(186.000000, 250.000000, "-3,000 XP REQUIRED");
TextDrawBackgroundColor(Textdraw29, 255);
TextDrawFont(Textdraw29, 1);
TextDrawLetterSize(Textdraw29, 0.200000, 1.000000);
TextDrawColor(Textdraw29, -1);
TextDrawSetOutline(Textdraw29, 0);
TextDrawSetProportional(Textdraw29, 1);
TextDrawSetShadow(Textdraw29, 1);
TextDrawUseBox(Textdraw29, 1);
TextDrawBoxColor(Textdraw29, 639443043);
TextDrawTextSize(Textdraw29, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw29, 0);

Textdraw30 = TextDrawCreate(186.000000, 191.000000, "POLICE");
TextDrawBackgroundColor(Textdraw30, 255);
TextDrawFont(Textdraw30, 3);
TextDrawLetterSize(Textdraw30, 0.689999, 1.900000);
TextDrawColor(Textdraw30, -1);
TextDrawSetOutline(Textdraw30, 0);
TextDrawSetProportional(Textdraw30, 1);
TextDrawSetShadow(Textdraw30, 1);
TextDrawUseBox(Textdraw30, 1);
TextDrawBoxColor(Textdraw30, 795526399);
TextDrawTextSize(Textdraw30, 278.000000, -203.000000);
TextDrawSetSelectable(Textdraw30, 0);

Textdraw31 = TextDrawCreate(186.000000, 212.000000, "-Law Enforcement Officer");
TextDrawBackgroundColor(Textdraw31, 255);
TextDrawFont(Textdraw31, 1);
TextDrawLetterSize(Textdraw31, 0.200000, 1.000000);
TextDrawColor(Textdraw31, -1);
TextDrawSetOutline(Textdraw31, 0);
TextDrawSetProportional(Textdraw31, 1);
TextDrawSetShadow(Textdraw31, 1);
TextDrawUseBox(Textdraw31, 1);
TextDrawBoxColor(Textdraw31, 639443043);
TextDrawTextSize(Textdraw31, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw31, 0);

Textdraw32 = TextDrawCreate(186.000000, 224.000000, "-Maintains the LAW");
TextDrawBackgroundColor(Textdraw32, 255);
TextDrawFont(Textdraw32, 1);
TextDrawLetterSize(Textdraw32, 0.200000, 1.000000);
TextDrawColor(Textdraw32, -1);
TextDrawSetOutline(Textdraw32, 0);
TextDrawSetProportional(Textdraw32, 1);
TextDrawSetShadow(Textdraw32, 1);
TextDrawUseBox(Textdraw32, 1);
TextDrawBoxColor(Textdraw32, 639443043);
TextDrawTextSize(Textdraw32, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw32, 0);

Textdraw33 = TextDrawCreate(186.000000, 237.000000, "-Can kill/arrest wanteds");
TextDrawBackgroundColor(Textdraw33, 255);
TextDrawFont(Textdraw33, 1);
TextDrawLetterSize(Textdraw33, 0.200000, 1.000000);
TextDrawColor(Textdraw33, -1);
TextDrawSetOutline(Textdraw33, 0);
TextDrawSetProportional(Textdraw33, 1);
TextDrawSetShadow(Textdraw33, 1);
TextDrawUseBox(Textdraw33, 1);
TextDrawBoxColor(Textdraw33, 639443043);
TextDrawTextSize(Textdraw33, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw33, 0);

Textdraw34 = TextDrawCreate(186.000000, 250.000000, "-0 XP REQUIRED");
TextDrawBackgroundColor(Textdraw34, 255);
TextDrawFont(Textdraw34, 1);
TextDrawLetterSize(Textdraw34, 0.200000, 1.000000);
TextDrawColor(Textdraw34, -1);
TextDrawSetOutline(Textdraw34, 0);
TextDrawSetProportional(Textdraw34, 1);
TextDrawSetShadow(Textdraw34, 1);
TextDrawUseBox(Textdraw34, 1);
TextDrawBoxColor(Textdraw34, 639443043);
TextDrawTextSize(Textdraw34, 278.000000, 0.000000);
TextDrawSetSelectable(Textdraw34, 0);

// You can now use TextDrawShowForPlayer(-ForAll), TextDrawHideForPlayer(-ForAll) and
// TextDrawDestroy functions to show, hide, and destroy the textdraw.