#include <anticheat\rAgc>//Anti gun cheats -Rogue
#include <anticheat\FLaggers>//Lag spike\desnyc detector- Rogue
#include <anticheat\Opba>//Anti airbreak\teleport - Rogue
#define ManualUse//Needed to use the callback!
#include <anticheat\rAct>//Anti car trolls - Rogue
#include <anticheat\AntiJC>//Anti jetpack cheats- Rogue
#include <anticheat\rEac>//Anti carswing\particlespam - Lorenc_
#include <anticheat\rAmc>//Anti money cheats- Rogue.
#include <anticheat\rAntiBuggers>//Depresses 5 abusing bugs triggered by cheats. -Rogue
#include <anticheat\AFkill> //Anti fake kill -Rogue
#include <anticheat\AntiFC>//Anti fake clients - Rogue
#include <anticheat\rAsc>//Anti speed cheats- Rogue
#include <anticheat\rVM>//Anti illegal car mods -Emmet_
#include <anticheat\rAcs>//Anti car spam - Rogue
#include <anticheat\rED> //Anti dialog spoof/crash- Emmet_ (easyDialog)
#include <anticheat\AntiSpam>//Anti chat spam- Rogue
#include <anticheat\AntiSba>//Anti slide bug abuse- Rogue

#if !defined FILTERSCRIPT 

#if defined RogueAC_OnGameModeInit
    forward RogueAC_OnGameModeInit();
#endif

public OnGameModeInit()
{
    print("     [[--|| Rogue-AC V7.0 ||--]]     ");
    print("     [[--|| Rogue Anti cheat version 7.0 ||--]]      ");
    print("     [[--|| Successfully Loaded! ||--]]      ");
    #if defined RogueAC_OnGameModeInit
        return RogueAC_OnGameModeInit();
    #else
        return 1;
    #endif
}

#if defined _ALS_OnGameModeInit
  #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif

#define OnGameModeInit RogueAC_OnGameModeInit

#endif