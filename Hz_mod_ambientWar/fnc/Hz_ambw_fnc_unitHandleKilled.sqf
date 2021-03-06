/*******************************************************************************
* Copyright (C) 2018 K.Hunter
*
* This file is licensed under a Creative Commons
* Attribution-NonCommercial-ShareAlike 4.0 International License.
* 
* For more information about this license view the LICENSE.md distributed
* together with this file or visit:
* https://creativecommons.org/licenses/by-nc-sa/4.0/
*******************************************************************************/

private _unit = _this select 0;
private _killer = _this select 1;

if (isPlayer _unit) exitWith {};

if (_unit getVariable ["Hz_ambw_disableSideRelations",false]) exitWith {};

//witnessed EH firing twice one time, make sure it doesn't happen...
if (_unit getVariable ["Hz_ambw_killHandled",false]) exitWith {};
_unit setVariable ["Hz_ambw_killHandled",true];

// for now this isn't handled -- maybe in future handling death from bleeding from ACE medical after being hit can be implemented...
if (isnull _killer) exitWith {};

private _killedByPlayer = false;
private _hitAndRun = false;
      
if (isplayer _killer) then {

	_killedByPlayer = true;

} else {

	if ((vehicle _unit) != _unit) exitWith {};
	
	//hit and run detection
	if (_unit == _killer) then {
		
		//unit might be sent away so keep radius large
		private _nearCars = nearestobjects [_unit,["LandVehicle"],20];
		
		{
			
			if (((speed _x) > 10) && {isplayer (driver _x)}) exitWith {
			
				_killedByPlayer = true;
				_hitAndRun = true;
				
			};
			
		} foreach _nearCars;
		
	};
	
};

if (!_killedByPlayer) exitWith {};

// determine factions

private _playerSideFaction = _killer call Hz_ambw_srel_fnc_getUnitSideFaction;
private _playerSide = _playerSideFaction select 0;
private _playerFaction = _playerSideFaction select 1;

if (_playerFaction == "") exitWith {};

private _unitSideFaction = _unit call Hz_ambw_srel_fnc_getUnitSideFaction;
private _unitSide = _unitSideFaction select 0;
private _unitFaction = _unitSideFaction select 1;
private _unitImportance = _unitSideFaction select 2;

if (_unitFaction == "") exitWith {};

if (!([_unitSide,_playerSide] call Hz_ambw_fnc_areEnemies)) then {

	// global event
	[_unit,_unitImportance,_unitSide,_unitFaction,_playerSide,_playerFaction] remoteExecCall ["Hz_ambw_srel_fnc_broadcastUnitKilled",0,false];
	
	if (_hitAndRun) then {
	
		diag_log format ["Unit %1 was killed by %2 (%3 / %4) with speed %5", typeof _unit, name _killer, typeof vehicle _killer, assignedVehicleRole _killer, speed vehicle _killer];
	
	} else {
	
		diag_log format ["Unit %1 was killed by %2 (%3 / %4) with weapon %5", typeof _unit, name _killer, typeof vehicle _killer, assignedVehicleRole _killer, currentWeapon vehicle _killer];
	
	};

};