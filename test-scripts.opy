#!mainFile "genji.opy"

##### general #####
    # 100 is non
    #!define slowmotion 100
    #!define 3thpersoncam true

##### average load show #####
    #!define avrgon false

##### orb visialize #####
    #!define orb_visialon false

    #!define show_playerradius false
    #!define show_orbradius true

#### test bots #####
    #!define testaion false

    ##### should do 19 max #####
    #!define testbotnumber 8
    ##### wait for all bots to be created #####
    #!define waitforcreate true
    ##### delay after all bots are created - toggle #####
    #!define aistartdelay true
    ##### delay after all bots are created - seconds #####
    #!define creationdelay 8 

    ##### delay between each action #####
    #!define aiactiondelay 3 + (testAI.index(eventPlayer) * 2)
    ##!define aiactiondelay 3
    ##!define aiactiondelay (testAI.index(eventPlayer) * 2)

    ##### AI #####
        #!define leaderboardai true 

globalvar AvrgSecStore
globalvar AvrgSecDisplay
globalvar LastTimePeak
globalvar AvrgMinStore
globalvar AvrgMinDisplay
globalvar AvrgMinStoreTemp
globalvar AvrgMinStoreLen
globalvar testAI
globalvar AIcreated


# temps ######################################################################################################################################################

# general ######################################################################################################################################################

rule "slowmo":
    setSlowMotion(slowmotion)


rule "3th person cam":
    @Condition 3thpersoncam
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    eventPlayer.startCamera( eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() * -2.5) + vect(0,0.5,0), eventPlayer.getEyePosition(), 15)

rule "multi purpose hud":
    hudSubheader(getAllPlayers(), 
        "hud count {}\n"
        "fx count: {}\n"
        "bouncetouched: {}\n"
        "bouncelast: {} \n"
        "".format(
        getNumberOfTextIds(),
        getNumberOfEntityIds(),
        localPlayer.bouncetouched,
        localPlayer.bouncetouchedlast
        ),
        HudPosition.LEFT, HO.leftend + 10, Color.LIME_GREEN, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT
    )


  
# Load Calc ######################################################################################################################################################

rule "server load hud":
    @Condition avrgon
    hudSubheader(
        getAllPlayers(), 
        "Load: {0} / Avrg: {1} \n"
        "Mavrg: {3} / Last: {4} \n"
        "Minu: {5} / Peak: {2} \n".format(
            getServerLoad(), 
            getAverageServerLoad(),
            getPeakServerLoad(),
            AvrgSecDisplay,
            LastTimePeak,
            AvrgMinDisplay
        ), 
    
        HudPosition.LEFT, HO.leftend, 
        Color.RED if getAverageServerLoad() > 220 else 
        Color.ORANGE if getAverageServerLoad() > 190 else 
        Color.YELLOW if getAverageServerLoad() > 160  else 
        Color.BLUE if getAverageServerLoad() > 130 else
        Color.LIME_GREEN, 
        HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT
    )

#!define avrg 125
rule "Avrg Seconds":
    @Condition avrgon
    while len(AvrgSecStore) < avrg:  
        AvrgSecStore.append(getAverageServerLoad())
        wait()

    AvrgSecDisplay = 0
    LastTimePeak = 0
    while len(AvrgSecStore) > 0:
        LastTimePeak = max(LastTimePeak,AvrgSecStore[0] )
        AvrgSecDisplay += AvrgSecStore[0]
        del AvrgSecStore[0]

    AvrgSecDisplay = AvrgSecDisplay / avrg
    AvrgMinStore.append(AvrgSecDisplay)
    goto RULE_START

#!define mintime 10
rule "Avrg Seconds":   
    @Condition avrgon
    #@Condition len(AvrgMinStore) == mintime/avrg
    AvrgMinDisplay = 0
    AvrgMinStoreTemp = AvrgMinStore
    AvrgMinStore = []
    AvrgMinStoreLen = len(AvrgMinStoreTemp)
    while len(AvrgMinStoreTemp) > 0:
        AvrgMinDisplay += AvrgMinStoreTemp[0]
        del AvrgMinStoreTemp[0]

    AvrgMinDisplay = AvrgMinDisplay / (AvrgMinStoreLen)
    wait(mintime)
    goto RULE_START

# orb radius ######################################################################################################################################################

rule "orbradiustest": # show radius on all bounce orbs
    @Condition orb_visialon
    @Condition show_orbradius
    wait(8)   
    for TempIterator1 in range(0,len(BouncePadCheckpoints)):
        
        createEffect(
            [i for i in getAllPlayers() if i.CurrentCheckpoint == BouncePadCheckpoints[evalOnce(TempIterator1)]], 
            Effect.SPHERE, 
            Color.WHITE, 
            BouncePositions[evalOnce(TempIterator1)], #bounceoffset,
            bounceorbdistance,
            EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
        )
        
        createEffect(
            [i for i in getAllPlayers() if i.CurrentCheckpoint == BouncePadCheckpoints[evalOnce(TempIterator1)]], 
            Effect.SPHERE, 
            Color.RED, 
            BouncePositions[evalOnce(TempIterator1)], #bounceoffset,
            0.1,
            EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
        )


rule "orbradiustest": # show player orb hit detection
    @Condition orb_visialon
    @Event eachPlayer
    if show_orbradius:
        createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, updateEveryTick( eventPlayer.getPosition() bounceoffset), 0.1, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR) 
        createEffect(getAllPlayers(), Effect.SPHERE, Color.ORANGE, updateEveryTick( eventPlayer.getPosition() bounceoffset), 0.03, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR) 

    if show_playerradius:
        # own orb radius
        createEffect(getAllPlayers(), Effect.SPHERE, Color.YELLOW, updateEveryTick( eventPlayer.getPosition() bounceoffset), bounceorbdistance, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR) 


# AI - leaderboard ######################################################################################################################################################

rule "leaderboard test bots":
    @Condition testaion
    wait(creationdelay) # wait for other entities to be created
    while len(testAI) < testbotnumber:
        createDummy(Hero.GENJI, Team.1, -1, null, null)
        testAI.append(getLastCreatedEntity())
        wait(0.1)
        testAI[len(testAI)-1].startForcingName("bot {0}".format(len(testAI)-1))
        
    AIcreated = true

rule "leaderboard test ai":
    @Event eachPlayer
    @Condition testaion
    @Condition leaderboardai
    @Condition eventPlayer in testAI

    @Condition eventPlayer.CurrentCheckpoint < len(CheckpointPositions) #- 1
    @Condition (waitforcreate and AIcreated) or not waitforcreate
    

    if aistartdelay:
        wait(aiactiondelay )

    if CompMode:
        wait(0.16)
        eventPlayer.forceButtonPress(Button.INTERACT)
        wait(0.16)
        
    else:
        wait(1)

    eventPlayer.CurrentCheckpoint = len(CheckpointPositions) - 2
    checkpointFailReset()
    wait(1)
    eventPlayer.LockCollected = eventPlayer.BouncePosition_Cache
    eventPlayer.teleport(CheckpointPositions[eventPlayer.CurrentCheckpoint+1]+ Vector.UP) # teleport not needed