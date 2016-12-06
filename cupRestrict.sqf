waitUntil {player == player};

[] spawn 
{
  if (isNull cynthia) then {cynthia = "PLACEHOLDER";};
  if (isNull betty) then {betty = "PLACEHOLDER";};
  if (isNull kathryn) then {kathryn = "PLACEHOLDER";};
  if (isNull angela) then {angela = "PLACEHOLDER";};
  while {true} do
  {
    if ((driver vehicle player == player) && (vehicle player in [cynthia,betty,kathryn,angela]) && !(getPlayerUID player == "76561197995448080")) then
    {
      moveOut player;
      cutText ["Feck off, she's mine.", "PLAIN"];
    };
  };
};