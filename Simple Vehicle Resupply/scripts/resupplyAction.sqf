cutText ["Resupply beginning...", "BLACK OUT", 1];
disableUserInput true;

_user = (_this select 1);
_veh = vehicle (_this select 1);
_delay = ((_this select 3) select 0);
_amount = ((_this select 3) select 1);
_veh engineOn false;

_totalAmmo = 0;
_maxAmmo = 0;
{
  _totalAmmo = _totalAmmo + (_x select 1);
  _maxAmmo = _maxAmmo + (getNumber(configFile >> "CfgMagazines" >> (_x select 0) >> "count"));
} forEach magazinesAmmo _veh;
_getVehicleAmmo = _totalAmmo/_maxAmmo;
if (_maxAmmo == 0) then {_getVehicleAmmo = 1;};

sleep 1;
cutText ["Repairing...", "BLACK FADED", 0];
if ((damage _veh) > (1 - _amount)) then {sleep (_delay*(damage _veh)); _veh setDamage (1 - _amount);};
cutText ["Refueling...", "BLACK FADED", 0];
if ((fuel _veh) < _amount) then {sleep (_delay*(1 - (fuel _veh))); _veh setFuel _amount;};
cutText ["Rearming...", "BLACK FADED", 0];
if (_getVehicleAmmo < _amount) then {sleep (_delay*(1 - _getVehicleAmmo)); _veh setVehicleAmmo _amount;};
cutText ["Refilling repair cargo...", "BLACK FADED", 0];
if ((getRepairCargo _veh) < _amount) then {sleep (_delay*(1 - (getRepairCargo _veh))); _veh setRepairCargo _amount;};
cutText ["Refilling fuel cargo...", "BLACK FADED", 0];
if ((getFuelCargo _veh) < _amount) then {sleep (_delay*(1 - (getFuelCargo _veh))); _veh setFuelCargo _amount;};
cutText ["Refilling ammo cargo...", "BLACK FADED", 0];
if (getAmmoCargo _veh < _amount) then {sleep (_delay*(1 - (getAmmoCargo _veh))); _veh setAmmoCargo _amount;};

disableUserInput false;
cutText ["Resupplied.", "BLACK IN", 1];