// PARAMETERS
////////////////////////////////
// I will organise these at some point. (Maybe)

CUPMED_debugHintBool = false; // Defines whether or not to show the debug hint. 

CUPMED_instantUnconcsCoeff = 1; // Coefficient for chance to be instantly knocked out upon being hit. 
CUPMED_bleedUnconcsCoeff = 1; // Coefficient for chance to bleed out into unconsciousness. 
CUPMED_unconcsAutorecoverCoeff = 1; // Coefficient for chance to autorecover from standard unconsciousness (when bleeding is stopped). 
CUPMED_bleedCoeff = 12; // Coefficient for bleeding added when hit. 
CUPMED_instantBleedCoeff = 600; // Coefficient for instant blood loss upon being hit. 
CUPMED_bloodClotRate = 0.99; // Blood clot rate. Bleed rate is multiplied by this every second. Set to 1 to effectively disable. Setting it to a value greater than 1 (or smaller than 0) may result in interesting/awful consequences. 
CUPMED_baseRegenRate = 2; // The base regen rate. 
CUPMED_maxRegenRate = 16; // The upper limit for regen rate. If the regen rate goes higher than this, you will go into overdose-unconsciousness. 
/* 
Okay, so something that has happened in this script is that you can effectively put people into a recovery coma. 
That is, you can pump them with the injection so much that they go unconscious, but they do still recover blood when unconscious at the elevated rate, allowing a quicker recovery at the obvious expense of requiring them to be unconscious throughout. 
I would just like to use this to say that this was a complete accident but I am keeping it this way because it actually makes for a kinda okay feature. 
*/
CUPMED_regenRateRecover = 0.04; // Rate at which the regen rate returns to normal
CUPMED_regenRateRecoverUnconcs = 0.16; // Additional recovery for regen rate when unconscious due to overdose. 
CUPMED_overdoseUnconcsRecoverChance = 0.5; // The chance each second for an overdose-unconscious player to recover (after returning to below the max regen rate). 
CUPMED_unconcsRecoverFatigue = 1; // setFatigue value for after recovering from unconsciousness. Set to any negative to disable. 
CUPMED_injectFatigue = 0; // setFatigue value for using an injection. Set to any negative to disable. 
CUPMED_checkPatchBleedRate = 1; // Bleed rate must be greater than this before you can use a patch. 
CUPMED_checkBandageBleedRate = 0; // Bleed rate must be greater than this before you can use a bandage. 
CUPMED_patchQuot = 16; // Number that bleed rate is divided by when a patch is used.
CUPMED_bandageRate = 0; // Number that bleed rate is set to when a bandage is used.
CUPMED_minReviveTime = 5; // Minimum possible time spent to revive someone. 
CUPMED_maxReviveTime = 5; // Maximum additional time spent to revive someone (note: this is not the actual maximum. That would be the above plus this.) 
CUPMED_untrainedReviveCoeff = 3; // Multiplier for time spent to revive if the reviving player is not a medic.
CUPMED_recoverControlsDelay = 3; // Delay between the world fading back in and control being handed back to the player. 
CUPMED_involuntaryFireChance = 0.2; // Chance of involuntary weapon discharge upon being hit in the arm. 
CUPMED_armDamageCoeff = 1; // Multiplier for the damage added to arms upon being hit in the arms
CUPMED_painFlashCoeff = 50; // Multiplier for how long the screen effect upon being hit takes to fade out
CUPMED_bleedWarnCoeff = 0.1; // Multiplier for how long the bleeding indicator takes to fade out
CUPMED_vignetteAlphaExp = 1; // Exponent for the damage vignette. Higher values will make it take longer to start fading in, but fade in quicker as blood level decreases. 
CUPMED_vignetteAlphaMin = 1500; // When the blood level falls below this value, the damage vignette will be completely opaque. 
CUPMED_vignetteAlphaMax = 5000; // When the blood level rises above this value, the damage vignette will be completely invisible.
CUPMED_snark = ["Now would be a good time to start planning your will.", "Maybe all that swag you're carrying is weighing you down.", "Your mother must be so proud of you right now.", "", "So. That whole army thing. How's it going?", "Are you just lazy?", "", "Face-down in the dirt with another man beating your ass. Is it Wednesday already?", "Maybe you should stop being shot all the time.", "Still, at least you're on an island with decent medical care, right? Right?", "These messages are only here because unconsciousness is boring. So, uh. Hi, I guess. Thanks for using my script?", "Bored yet?"]; // Array of snarky messages, to be randomly displayed to entertain unconscious people
CUPMED_snarkChance = 0.1; // Decimal probability (per second) of the snark message changing. Set to 0 to effectively disable. 
// Okay, so the following is a bit of a monster. You REALLY don't want to mess with it, as that could break all the things. All of them. 
// Its actual purpose is to provide the attach points for vehicles, the idea being that people loaded into vehicles should appear in their passenger/cargo space. 
CUPMED_offsetArray = [["B_Truck_01_transport_F",[[0.5,0.5,0.5],[0.5,0.5,0.5]]]];

////////////////////////////////

call compile preprocessFileLineNumbers "cms\cupmed_functions.sqf";

waitUntil {player == player};

player addEventHandler ["HandleDamage", CUPMED_damageHandler];
[] spawn CUPMED_playerInit;
[] spawn CUPMED_addActions;
player addEventHandler ["Respawn", CUPMED_playerInit];
addMissionEventHandler ["Draw3D", CUPMED_updateVignette];

hint "CupMed initialised";

// Okay, so maybe I start too many sentences with "Okay, so". 