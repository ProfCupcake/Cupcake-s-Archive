----------------------------------------
DEAD SIMPLE VEHICLE RESUPPLY SCRIPT
-- By Professor Cupcake ----------------

Trust me, it's dead simple. 

--WHAT IT DOES-------------------------

Upon activation, it will black out the screen, disable user input and then begin running through and resupplying each element of a vehicle's status (damage, fuel, ammo, and the three cargo versions of them), if it requires it. The resupply will take longer if there is more to resupply (and vice-versa). 

--USAGE---------------------------------

First of all, copy the 'scripts' folder into your mission folder. 

If you want to use the ACTION version:

	1. Pick an object to place the action on. I would suggest something like a box in a FOB, or an important supply truck, but hey, it's your mission so you decide. 

	2. Add the following code into its init field: 
		this addAction ["Resupply", "scripts\resupplyAction.sqf", [x,y], 50, true, true, "", "vehicle _this != _this"];

	3. Where it says 'x' and 'y' in the array there, replace them with two numbers. The first, x, is the maximum time in seconds each part of the resupply will take. The second, y, is the amount to resupply to, as a value between 0 and 1. For example, if this was set to 0.5, the vehicle would only be resupplied to half its maximum ammo, fuel, etc. 

If you, alternatively, want to use the TRIGGER version: 

	1. Place a trigger wherever you want it, and set up the conditions etc. however you like. 

	2. Enter the following code into the 'On Act' field: 
		nul = [z, x, y] execVM "scripts\resupplyTrigger.sqf";

	3. Replace the above 'z' with the name of the unit you want to resupply, and 'x' and 'y' with the same values as mentioned for the action version. 

	NOTE: The trigger version has (still) not been tested in multiplayer yet. 

----------------------------------------

If you have any problems due to how terrible I am at explaining things, feel free to ask me about whatever specific issues you have and I'll see what I can do. 