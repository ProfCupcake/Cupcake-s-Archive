CUPMED_addActions = 
{
	// title, filename, arguments, priority, showWindow, hideOnUse, shortcut, condition
	player addAction ["Apply patch on self", "cms\cupmed_actions.sqf", "patchself", 20, true, true, "", "call CUPMED_checkPatchSelf"];
	player addAction ["Give injection to self", "cms\cupmed_actions.sqf", "injectself", 0, false, true, "", "call CUPMED_checkInjectSelf"];
	player addAction ["Bandage self", "cms\cupmed_actions.sqf", "bandageself", 25, true, true, "", "call CUPMED_checkBandageSelf"];
	player addAction ["Apply patch on target", "cms\cupmed_actions.sqf", "patchtarget", 21, true, true, "", "call CUPMED_checkPatchTarget"];
	player addAction ["Give injection to target", "cms\cupmed_actions.sqf", "injecttarget", 1, false, true, "", "call CUPMED_checkInjectTarget"];
	player addAction ["Bandage target", "cms\cupmed_actions.sqf", "bandagetarget", 26, true, true, "", "call CUPMED_checkBandageTarget"];
	player addAction ["Revive", "cms\cupmed_actions.sqf", "revive", 30, true, true, "", "call CUPMED_checkRevive"];
	player addAction ["Drag", "cms\cupmed_actions.sqf", "drag", 29, true, true, "", "call CUPMED_checkDrag"];
	player addAction ["Check own vitals", "cms\cupmed_actions.sqf", "checkownvitals", 10, false, false, "", "call CUPMED_checkCheckOwnVitals"];
	player addAction ["Check target vitals", "cms\cupmed_actions.sqf", "checktargetvitals", 11, false, false, "", "call CUPMED_checkCheckTargetVitals"];
	player addAction ["Drag casualty out of vehicle", "cms\cupmed_actions.sqf", "getloaded", 21, true, true, "", "call CUPMED_checkGetLoaded"];
	// DEBUG FUNCTIONS FOLLOW - REMEMBER TO COMMENT THESE OUT BEFORE RELEASE
	/*
	player addAction ["[DEBUG] Instant unconsciousness", {"instant" spawn CUPMED_knockout;}, "", -1, false, false, "", "true"];
	player addAction ["[DEBUG] Bleedout unconsciousness", {"bleed" spawn CUPMED_knockout;}, "", -1, false, false, "", "true"];
	player addAction ["[DEBUG] Increase bleed rate", {player setVariable ["CUPMED_bleedRate", (player getVariable "CUPMED_bleedRate") + 1, true];}, "", -1, false, false, "", "true"];
	//*/
};

CUPMED_playerInit = 
{
	// Set variables to starting values
	player setVariable ["CUPMED_bloodLevel", 5500, true];
	player setVariable ["CUPMED_bleedRate", 0, true];
	player setVariable ["CUPMED_regenRate", CUPMED_baseRegenRate, true];
	player setVariable ["CUPMED_canAct", 1, true];
	player setVariable ["CUPMED_lifeState", 0, true];
	player setVariable ["CUPMED_armDamage", 0, true];
	player setVariable ["CUPMED_isLoaded", nil, true];
	// Add actions
	//[] spawn CUPMED_addActions; // Commented out to prevent respawn bug
	// Initiate control loop
	[] spawn CUPMED_controlLoop;
};

CUPMED_controlLoop = 
{
	while {alive player} do 
	{
		// Fetching variables
		_bleedRate = player getVariable "CUPMED_bleedRate";
		_bloodLevel = player getVariable "CUPMED_bloodLevel";
		_regenRate = player getVariable "CUPMED_regenRate";
		_lifeState = player getVariable "CUPMED_lifeState";
		_armDamage = player getVariable "CUPMED_armDamage";
		// Applying bleed & regen
		_newBloodLevel = _bloodLevel - _bleedRate;
		// Bleeding indicator
		if (_bleedRate > 1) then
		{
			41 cutRsc ["BleedWarn", "PLAIN", (_bleedRate-1)*CUPMED_bleedWarnCoeff, true];
		};
		_newBloodLevel = _newBloodLevel + _regenRate;
		// Simulated blood clot
		_newBleedRate = _bleedRate*CUPMED_bloodClotRate;
		player setVariable ["CUPMED_bleedRate", _newBleedRate, true];
		// Upper buffer (maximum blood)
		if (_newBloodLevel > 5500) then
		{
			_newBloodLevel = 5500;
		};
		// Lower buffer (death)
		if (_newBloodLevel <= 0) then
		{
			player setDamage 1;
		};
		// Regen rate handling
		if (_regenRate > CUPMED_baseRegenRate) then
		{
			_newRegenRate = _regenRate - CUPMED_regenRateRecover;
			// Lower buffer (minimum)
			if (_newRegenRate < CUPMED_baseRegenRate) then
			{
				_newRegenRate = CUPMED_baseRegenRate;
			};
			// Overdose unconsciousness
			if ((_newRegenRate > CUPMED_maxRegenRate) && (_lifeState != 2)) then
			{
				"overdose" spawn CUPMED_knockout;
			};
			player setVariable ["CUPMED_regenRate", _newRegenRate, true];
		};
		// Bleedout unconsciousness
		if (!((_bloodLevel > 2000) && (_regenRate > _bleedRate)) && (_lifeState == 0)) then
		{
			_unconcsChance = ((1 - (_newBloodLevel-1000)/1000)*((_bleedRate - _regenRate)/10))*CUPMED_bleedUnconcsCoeff;
			_unconcsRoll = random 1;
			if (_unconcsRoll > (1 - _unconcsChance)) then
			{
				"bleed" spawn CUPMED_knockout;
			};
		};			
		// Arm damage effects
		if (_armDamage > 0) then
		{
			// [Actual effects to go here - WIP]
			// Regen
			_newArmDamage = _armDamage - _regenRate;
			player setVariable ["CUPMED_armDamage", _newArmDamage, true]; 
		};
			
		player setVariable ["CUPMED_bloodLevel", _newBloodLevel, true];
		if (CUPMED_debugHintBool) then {hintSilent format ["Blood level: %1 \n\nBleed rate: %2 \n\nRegen rate: %3 \n\nArm damage: %4", _newBloodLevel, _bleedRate, _regenRate, _armDamage];};
		sleep 1;
	};
};

CUPMED_updateVignette = 
{
	_bloodLevel = player getVariable "CUPMED_bloodLevel";
	if (_bloodLevel < CUPMED_vignetteAlphaMax) then // This check is required to defeat even powers. Damn even powers. 
	{
		CUPMED_vignetteAlpha = ((CUPMED_vignetteAlphaMax - _bloodLevel)/(CUPMED_vignetteAlphaMax - CUPMED_vignetteAlphaMin))^CUPMED_vignetteAlphaExp;
		if (CUPMED_vignetteAlpha > 1) then {CUPMED_vignetteAlpha = 1;};
		if (CUPMED_vignetteAlpha < 0) then {CUPMED_vignetteAlpha = 0;};
	} else {CUPMED_vignetteAlpha = 0;};
	9001 cutRsc ["damageVignette", "PLAIN"];
};

CUPMED_damageHandler = 
{
	_hitPoint = _this select 1;
	_amountOfDamage = _this select 2;

	if (_hitPoint == "") then // General damage
	{
		// Flash screen to indicate injury
		(floor (1000 + random 1000)) cutRsc ["PainFlash", "PLAIN", _amountOfDamage*CUPMED_painFlashCoeff, true];
		// Bleeding
		_addBleed = _amountOfDamage*CUPMED_bleedCoeff;
		_bleedRate = player getVariable "CUPMED_bleedRate";
		_newBleedRate = _bleedRate + _addBleed;
		player setVariable ["CUPMED_bleedRate", _newBleedRate, true];
		// Instantaneous blood loss
		_instantBleed = _amountOfDamage*CUPMED_instantBleedCoeff;
		_bloodLevel = player getVariable "CUPMED_bloodLevel";
		_newBloodLevel = _bloodLevel - _instantBleed;
		if (_newBloodLevel < 0) then {player setDamage 1;};
		player setVariable ["CUPMED_bloodLevel", _newBloodLevel, true];
		// Knockout chance
		_lifeState = player getVariable "CUPMED_lifeState";
		_unconcsChance = ((1 - _newBloodLevel/5500)*((_amountOfDamage + _newBleedRate)/100))*CUPMED_instantUnconcsCoeff;
		_unconcsRoll = random 1;
		if ((_unconcsRoll > (1 - _unconcsChance)) && (_lifeState == 0)) then
		{
			"instant" spawn CUPMED_knockout;
		};
	};
	if (_hitPoint == "hands") then // Arm damage
	{
		_armDamage = player getVariable "CUPMED_armDamage";
		// Involuntary weapon discharge
		_involFireRoll = random 1;
		if (_involFireRoll < CUPMED_involuntaryFireChance) then
		{
			player forceWeaponFire [currentWeapon player, currentWeaponMode player];
		};
		// Add damage to arm damage
		_newArmDamage = _armDamage + (_amountOfDamage*CUPMED_armDamageCoeff);
		player setVariable ["CUPMED_armDamage", _newArmDamage, true];
	};
	0
};

CUPMED_knockout = 
{
	if (vehicle player != player) exitWith {};
	/* WIP STUFF YAY. This probably doesn't work, so I wouldn't use it if I were you. 
	if (vehicle player != player) then
	{
		_pVeh = vehicle player;
		moveOut player;
		_offset = [0, 0, 0];
		_offsetArray = _pVeh call CUPMED_getOffsetArray;
		if !(isNil {_offsetArray}) then
		{
			_offset = _offsetArray select floor random count _offsetArray;
		};
		player attachTo [_pVeh, _offset];
		_loCas = _pVeh getVariable "CUPMED_loadedCasualties";
		if !(isNil {_loCas}) then
		{
			_loCas set [_loCas select count _loCas, player];
		} else
		{
			_loCas = [player];
		};
		_pVeh setVariable ["CUPMED_loadedCasualties", _loCas, true];
		player setVariable ["CUPMED_isLoaded", _pVeh, true];
	};
	*/
	player playActionNow "agonyStart";
	disableuserinput true;
	player setCaptive true;

	if (_this != "overdose") then
	{
		if (_this == "instant") then
		{
		 1 cutText ["", "BLACK OUT", 0];
		};
		if (_this == "bleed") then
		{
		 1 cutText ["", "BLACK OUT", 3];
		};
		player setVariable ["CUPMED_lifeState", 1, true];
		sleep 6;
		disableuserinput false;
		player enableSimulation false;
		while {(alive player) && (player getVariable "CUPMED_lifeState" == 1)} do
		{
			_bleedRate = player getVariable "CUPMED_bleedRate";
			_regenRate = player getVariable "CUPMED_regenRate";
			_bloodLevel = player getVariable "CUPMED_bloodLevel";
			_recoverChance = (((_bloodLevel - 1000)/1000)*((_regenRate - _bleedRate)/8))*CUPMED_unconcsAutorecoverCoeff;
			_recoverRoll = random 1;
			if (((_recoverRoll > (1 - _recoverChance)) || (_recoverRoll > 0.99)) && (_bloodLevel > 1000)) then
			{
				player setVariable ["CUPMED_lifeState", 0, true];
			};
			sleep 1;
			_snarkRoll = random 1;
			if (_snarkRoll < CUPMED_snarkChance) then
			{
				2 cutText [CUPMED_snark select floor random count CUPMED_snark, "PLAIN"];
			};
		};
		if (player getVariable "CUPMED_lifeState" == 2) exitWith {};
	};

	if (_this == "overdose") then
	{
		1 cutText ["", "BLACK OUT", 1];
		player setVariable ["CUPMED_lifeState", 2, true];
		sleep 6;
		disableuserinput false;
		player enableSimulation false;
		while {(alive player) && (player getVariable "CUPMED_lifeState" == 2)} do
		{
			_regenRate = player getVariable "CUPMED_regenRate";
			if (_regenRate < CUPMED_maxRegenRate) then
			{
				_recoverRoll = random 1;
				if (_recoverRoll > CUPMED_overdoseUnconcsRecoverChance) then
				{
					player setVariable ["CUPMED_lifeState", 0, true];
				};
			};
			_newRegenRate = _regenRate - CUPMED_regenRateRecoverUnconcs;
			player setVariable ["CUPMED_regenRate", _newRegenRate, true];
			2 cutText [format ["You've overdosed. Whoops. You will stabilise in approximately %1 seconds.", ceil ((_newRegenRate - CUPMED_maxRegenRate)/(CUPMED_regenRateRecover + CUPMED_regenRateRecoverUnconcs))], "PLAIN", 0];
			if (_newRegenRate < CUPMED_maxRegenRate) then {2 cutText ["You've overdosed. Whoops. You will recover soon.", "PLAIN", 0];};
			sleep 1;
		};
	};
	1 cutText ["", "BLACK IN", 10];
	_isLoaded = player getVariable "CUPMED_isLoaded";
	if !(isNil {_isLoaded}) then
	{
		sleep 10;
		1 cutText ["You are currently in a vehicle. You will need to be unloaded before you can get up.", "PLAIN"];
		//player addAction ["Eject instead", {player setVariable ["CUP_isLoaded", nil, true]; player allowDamage false; detach player; sleep 1; player allowDamage true;}];
		waitUntil {isNil {player getVariable "CUPMED_isLoaded"}};
	};
	if (CUPMED_unconcsRecoverFatigue >= 0) then {player setFatigue CUPMED_unconcsRecoverFatigue;};
	sleep CUPMED_recoverControlsDelay;
	player enableSimulation true;
	player playAction "agonyStop";
	player setCaptive false;
};

CUPMED_checkRevive = 
{
	_return = false;
	_tLifeState = cursorTarget getVariable "CUPMED_lifeState";
	_lifeState = player getVariable "CUPMED_lifeState";
	_canAct = player getVariable "CUPMED_canAct";
	_canTAct = cursorTarget getVariable "CUPMED_canAct";
	if ((_lifeState == 0) && (_tLifeState == 1) && (alive player) && (alive cursorTarget) && ("Medikit" in items player) && (player distance cursorTarget < 2) && (_canAct == 1) && (_canTAct == 1)) then
	{
		_return = true;
	};
	_return
};

CUPMED_checkDrag = 
{
	_return = false;
	_tLifeState = cursorTarget getVariable "CUPMED_lifeState";
	_lifeState = player getVariable "CUPMED_lifeState";
	_canAct = player getVariable "CUPMED_canAct";
	_canTAct = cursorTarget getVariable "CUPMED_canAct";
	if ((_lifeState == 0) && (_tLifeState != 0) && (alive player) && (alive cursorTarget) && (player distance cursorTarget < 2) && (_canAct == 1) && (_canTAct == 1)) then
	{
		_return = true;
	};
	_return
};

CUPMED_checkGetLoaded = 
{
	_return = false;
	_loadedCasualties = cursorTarget getVariable "CUPMED_loadedCasualties";
	if (isNil {_loadedCasualties}) exitWith {false};
	_canAct = player getVariable "CUPMED_canAct";
	_lifeState = player getVariable "CUPMED_lifeState";
	if ((_lifeState == 0) && (_canAct == 1) && (count _loadedCasualties > 0)) then
	{
		_return = true;
	};
	_return
};

CUPMED_checkPatchSelf = 
{
	_bleedRate = player getVariable "CUPMED_bleedRate";
	_canAct = player getVariable "CUPMED_canAct";
	_lifeState = player getVariable "CUPMED_lifeState";
	_return = false;
	if ((_lifeState == 0) && (_bleedRate > CUPMED_checkPatchBleedRate) && ("FirstAidKit" in items player) && (_canAct == 1)) then {_return = true;};
	_return
};

CUPMED_checkInjectSelf = 
{
	_canAct = player getVariable "CUPMED_canAct";
	_isMedic = getNumber(configFile >> "CfgVehicles" >> (typeOf player) >> "attendant");
	_lifeState = player getVariable "CUPMED_lifeState";
	_return = false;
	if ((_lifeState == 0) && ("Medikit" in items player) && (_canAct == 1) && (_isMedic == 1)) then {_return = true;};
	_return
};

CUPMED_checkBandageSelf = 
{
	_bleedRate = player getVariable "CUPMED_bleedRate";
	_canAct = player getVariable "CUPMED_canAct";
	_lifeState = player getVariable "CUPMED_lifeState";
	_return = false;
	if ((_lifeState == 0) && (_bleedRate > CUPMED_checkBandageBleedRate) && ("Medikit" in items player) && (_canAct == 1)) then {_return = true;};
	_return
};

CUPMED_checkBandageTarget = 
{
	_bleedRate = cursorTarget getVariable "CUPMED_bleedRate";
	_canAct = player getVariable "CUPMED_canAct";
	_canTAct = cursorTarget getVariable "CUPMED_canAct";
	_lifeState = player getVariable "CUPMED_lifeState";
	_return = false;
	if ((_lifeState == 0) && (_bleedRate > CUPMED_checkBandageBleedRate) && ("Medikit" in items player) && (_canAct == 1) && (_canTAct == 1) && (isPlayer cursorTarget) && ((player distance cursorTarget) < 2)) then {_return = true;};
	_return
};

CUPMED_checkInjectTarget = 
{
	_canAct = player getVariable "CUPMED_canAct";
	_canTAct = cursorTarget getVariable "CUPMED_canAct";
	_isMedic = getNumber(configFile >> "CfgVehicles" >> (typeOf player) >> "attendant");
	_lifeState = player getVariable "CUPMED_lifeState";
	_return = false;
	if ((_lifeState == 0) && ("Medikit" in items player) && (_canAct == 1) && (_isMedic == 1) && (_canTAct == 1) && (isPlayer cursorTarget) && ((player distance cursorTarget) < 2)) then {_return = true;};
	_return
};

CUPMED_checkPatchTarget = 
{
	_bleedRate = cursorTarget getVariable "CUPMED_bleedRate";
	_canAct = player getVariable "CUPMED_canAct";
	_canTAct = cursorTarget getVariable "CUPMED_canAct";
	_lifeState = player getVariable "CUPMED_lifeState";
	_return = false;
	if ((_lifeState == 0) && (_bleedRate > CUPMED_checkPatchBleedRate) && ("FirstAidKit" in items player) && (_canAct == 1) && (_canTAct == 1) && (isPlayer cursorTarget) && ((player distance cursorTarget) < 2)) then {_return = true;};
	_return
};

CUPMED_checkCheckOwnVitals = 
{
	_return = false;
	_isMedic = getNumber(configFile >> "CfgVehicles" >> (typeOf player) >> "attendant");
	_lifeState = player getVariable "CUPMED_lifeState";
	if ((_lifestate == 0) && (_isMedic == 1)) then {_return = true;};
	_return
};

CUPMED_checkCheckTargetVitals = 
{
	_return = false;
	_isMedic = getNumber(configFile >> "CfgVehicles" >> (typeOf player) >> "attendant");
	_lifeState = player getVariable "CUPMED_lifeState";
	if ((_lifestate == 0) && (_isMedic == 1) && (cursorTarget isKindOf "Man")) then {_return = true;};
	_return
};

CUPMED_doRevive = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_this setVariable ["CUPMED_canAct", 0, true];
	_isMedic = getNumber(configFile >> CfgVehicles >> (typeOf player) >> "attendant");
	player playAction "medicStart";
	_reviveTime = ((random CUPMED_maxReviveTime) + CUPMED_minReviveTime);
	if (_isMedic != 1) then {_reviveTime = _reviveTime*CUPMED_untrainedReviveCoeff;};
	sleep _reviveTime;
	_this setVariable ["CUPMED_lifeState", 0, true];
	_this setVariable ["CUPMED_bleedRate", 0, true];
	sleep 3;
	player setVariable ["CUPMED_canAct", 1, true];
	_this setVariable ["CUPMED_canAct", 1, true];
	player playAction "medicStop";
};

CUPMED_doGetLoaded = 
{
	_loadedCasualties = _this getVariable "CUPMED_loadedCasualties";
	_dragTarget = _loadedCasualties select ((count _loadedCasualties) - 1);
	_dragTarget spawn CUPMED_doDrag;
	_dragTarget setVariable ["CUPMED_isLoaded", nil];
	_loadedCasualties = _loadedCasualties - [_dragTarget];
	_this setVariable ["CUPMED_loadedCasualties", _loadedCasualties];
};

CUPMED_doDrag = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_this setVariable ["CUPMED_canAct", 0, true];
	player playAction "grabDrag";
	//_this playAction "grabDragged";
	_this attachTo [player, [0, 1, 0]];
	//_this setDir 180;
	sleep 2;
	_id = player addAction ["Drop", {player setVariable ["CUPMED_canAct", 1, true];}, nil, 39, true, true, "", "true"];
	while {player getVariable "CUPMED_canAct" == 0} do
	{
		_lifeState = player getVariable "CUPMED_lifeState";
		_tLifeState = _this getVariable "CUPMED_lifeState";
		if ((!alive player) || (!alive _target) || (_lifeState != 0) || (_tLifeState == 0)) then
		{
			player setVariable ["CUPMED_canAct", 1, true];
		};
		sleep 1;
	};
	player playAction "released";
	//_this playAction "released";
	sleep 2;
	detach _this;
	player removeAction _id;
	_this setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doPatchSelf = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_bleedRate = player getVariable "CUPMED_bleedRate";
	player playAction "medic";
	_newBleedRate = _bleedRate/CUPMED_patchQuot;
	player setVariable ["CUPMED_bleedRate", _newBleedRate, true];
	sleep 7;
	player removeItem "FirstAidKit";
	player setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doInjectSelf = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_bleedRate = player getVariable "CUPMED_bleedRate";
	_regenRate = player getVariable "CUPMED_regenRate";
	player playAction "medic";
	sleep 4;
	_newBleedRate = _bleedRate*4;
	_newRegenRate = _regenRate*2;
	player setVariable ["CUPMED_bleedRate", _newBleedRate, true];
	player setVariable ["CUPMED_regenRate", _newRegenRate, true];
	if (CUPMED_injectFatigue >= 0) then {player setFatigue CUPMED_injectFatigue;};
	sleep 2;
	player setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doBandageSelf = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	player playAction "medic";
	player setVariable ["CUPMED_bleedRate", CUPMED_bandageRate, true];
	sleep 7;
	player setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doBandageTarget = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_this setVariable ["CUPMED_canAct", 0, true];
	player playAction "medic";
	_this setVariable ["CUPMED_bleedRate", CUPMED_bandageRate, true];
	sleep 7;
	player setVariable ["CUPMED_canAct", 1, true];
	_this setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doPatchTarget = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_this setVariable ["CUPMED_canAct", 0, true];
	_bleedRate = _this getVariable "CUPMED_bleedRate";
	player playAction "medic";
	_newBleedRate = _bleedRate/CUPMED_patchQuot;
	_this setVariable ["CUPMED_bleedRate", _newBleedRate, true];
	sleep 7;
	player removeItem "FirstAidKit";
	player setVariable ["CUPMED_canAct", 1, true];
	_this setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doInjectTarget = 
{
	player setVariable ["CUPMED_canAct", 0, true];
	_this setVariable ["CUPMED_canAct", 0, true];
	_bleedRate = _this getVariable "CUPMED_bleedRate";
	_regenRate = _this getVariable "CUPMED_regenRate";
	player playAction "medic";
	sleep 4;
	_newBleedRate = _bleedRate*4;
	_newRegenRate = _regenRate*2;
	_this setVariable ["CUPMED_bleedRate", _newBleedRate, true];
	_this setVariable ["CUPMED_regenRate", _newRegenRate, true];
	if (CUPMED_injectFatigue >= 0) then {_this setFatigue CUPMED_injectFatigue;};
	sleep 2;
	player setVariable ["CUPMED_canAct", 1, true];
	_this setVariable ["CUPMED_canAct", 1, true];
};

CUPMED_doCheckOwnVitals = 
{
	_bloodLevel = player getVariable "CUPMED_bloodLevel";
	_bleedRate = player getVariable "CUPMED_bleedRate";
	_regenRate = player getVariable "CUPMED_regenRate"; 
	_armDamage = player getVariable "CUPMED_armDamage";
	if ("Medikit" in items player) then
	{
		hint format ["Blood level: %1 \n\nBleed rate: %2 \n\nRegen rate: %3 \n\nArm damage: %4", _bloodLevel, _bleedRate, _regenRate, _armDamage];
	}
	else
	{
		_bloodLevelDesc = "Blood level critical.";
		if (_bloodLevel > 1000) then {_bloodLevelDesc = "Blood level is dangerously low."};
		if (_bloodLevel > 2000) then {_bloodLevelDesc = "Blood level is low."};
		if (_bloodLevel > 3000) then {_bloodLevelDesc = "Blood level is moderate."};
		if (_bloodLevel > 4000) then {_bloodLevelDesc = "Blood level is OK."};
		if (_bloodLevel > 5000) then {_bloodLevelDesc = "Blood level is nominal."};
		_bleedRateDesc = "Not bleeding";
		if (_bleedRate > 1) then {_bleedRateDesc = "Minor bleeding"};
		if (_bleedRate > 10) then {_bleedRateDesc = "Bleeding"};
		if (_bleedRate > 20) then {_bleedRateDesc = "Bleeding badly"};
		if (_bleedRate > 40) then {_bleedRateDesc = "Bleeding heavily"};
		if (_bleedRate > 60) then {_bleedRateDesc = "Major bleeding"};
		if (_bleedRate > 80) then {_bleedRateDesc = "Bleed rate critical"};
		_regenRateDesc = "Blood regen normal";
		if (_regenRate > 1) then {_regenRateDesc = "Blood regen mildly accelerated"};
		if (_regenRate > 2.5) then {_regenRateDesc = "Accelerated blood regen"};
		if (_regenRate > 5) then {_regenRateDesc = "Highly accelerated blood regen"};
		if (_regenRate > 7) then {_regenRateDesc = "Dangerously high blood regen rate"};
		if (_regenRate > 10) then {_regenRateDesc = "Extremely high blood regen rate"};
		 _armDamageDesc = "Arms uninjured";
		if (_armDamage > 1) then {_armDamageDesc = "Arms slightly injured"};
		if (_armDamage > 20) then {_armDamageDesc = "Arms injured"};
		if (_armDamage > 50) then {_armDamageDesc = "Arms heavily injured"};
		if (_armDamage > 100) then {_armDamageDesc = "Arms critically injured"};
		hint format ["%1\n\n%2\n\n%3\n\n%4", _bloodLevelDesc, _bleedRateDesc, _regenRateDesc, _armDamageDesc];
	};
};

CUPMED_doCheckTargetVitals = 
{
	if !(isPlayer _this) exitWith {hint format ["Target '%1' is an AI.\nCupMed does not have AI support yet.\n:(", name _this];};
	_bloodLevel = _this getVariable "CUPMED_bloodLevel";
	_bleedRate = _this getVariable "CUPMED_bleedRate";
	_regenRate = _this getVariable "CUPMED_regenRate"; 
	_armDamage = _this getVariable "CUPMED_armDamage";
	if ("Medikit" in items player) then
	{
		hint format ["Target: %1\n\nBlood level: %2 \n\nBleed rate: %3 \n\nRegen rate: %4 \n\nArm damage: %5", name _this, _bloodLevel, _bleedRate, _regenRate, _armDamage];
	}
	else
	{
		_bloodLevelDesc = "Blood level critical.";
		if (_bloodLevel > 1000) then {_bloodLevelDesc = "Blood level is dangerously low."};
		if (_bloodLevel > 2000) then {_bloodLevelDesc = "Blood level is low."};
		if (_bloodLevel > 3000) then {_bloodLevelDesc = "Blood level is moderate."};
		if (_bloodLevel > 4000) then {_bloodLevelDesc = "Blood level is OK."};
		if (_bloodLevel > 5000) then {_bloodLevelDesc = "Blood level is nominal."};
		_bleedRateDesc = "Not bleeding";
		if (_bleedRate > 1) then {_bleedRateDesc = "Minor bleeding"};
		if (_bleedRate > 10) then {_bleedRateDesc = "Bleeding"};
		if (_bleedRate > 20) then {_bleedRateDesc = "Bleeding badly"};
		if (_bleedRate > 40) then {_bleedRateDesc = "Bleeding heavily"};
		if (_bleedRate > 60) then {_bleedRateDesc = "Major bleeding"};
		if (_bleedRate > 80) then {_bleedRateDesc = "Bleed rate critical"};
		_regenRateDesc = "Blood regen normal";
		if (_regenRate > 1) then {_regenRateDesc = "Blood regen mildly accelerated"};
		if (_regenRate > 2.5) then {_regenRateDesc = "Accelerated blood regen"};
		if (_regenRate > 5) then {_regenRateDesc = "Highly accelerated blood regen"};
		if (_regenRate > 7) then {_regenRateDesc = "Dangerously high blood regen rate"};
		if (_regenRate > 10) then {_regenRateDesc = "Extremely high blood regen rate"};
		 _armDamageDesc = "Arms uninjured";
		if (_armDamage > 1) then {_armDamageDesc = "Arms slightly injured"};
		if (_armDamage > 20) then {_armDamageDesc = "Arms injured"};
		if (_armDamage > 50) then {_armDamageDesc = "Arms heavily injured"};
		if (_armDamage > 100) then {_armDamageDesc = "Arms critically injured"};
		hint format ["Target:%1\n\n%2\n\n%3\n\n%4\n\n%5", name _this, _bloodLevelDesc, _bleedRateDesc, _regenRateDesc, _armDamageDesc];
	};
};

CUPMED_getOffsetArray = 
{
	_veh = typeOf _this;
	_array = nil;
	{
		if ((_x select 0) == _veh) exitWith {_array = _x select 1};
	} forEach CUPMED_offsetArray;
	_array
};
