_action = _this select 3;

if (_action == "patchself") then
{
  [] spawn CUPMED_doPatchSelf;
};

if (_action == "injectself") then
{
  [] spawn CUPMED_doInjectSelf;
};

if (_action == "bandageself") then
{
  [] spawn CUPMED_doBandageSelf;
};

if (_action == "patchtarget") then
{
  cursorTarget spawn CUPMED_doPatchTarget;
};

if (_action == "injecttarget") then
{
  cursorTarget spawn CUPMED_doInjectTarget;
};

if (_action == "bandagetarget") then
{
  cursorTarget spawn CUPMED_doBandageTarget;
};

if (_action == "revive") then
{
  cursorTarget spawn CUPMED_doRevive;
};

if (_action == "drag") then
{
  cursorTarget spawn CUPMED_doDrag;
};

if (_action == "checkownvitals") then
{
  [] spawn CUPMED_doCheckOwnVitals;
};

if (_action == "checktargetvitals") then
{
  cursorTarget spawn CUPMED_doCheckTargetVitals;
};

if (_action == "getdriver") then
{
	driver cursorTarget spawn CUPMED_doGetCrew;
};

if (_action == "getgunner") then
{
	gunner cursorTarget spawn CUPMED_doGetCrew;
};

if (_action == "getcommander") then
{
	commander cursorTarget spawn CUPMED_doGetCrew;
};

if (_action == "getcargo") then
{
	cursorTarget spawn CUPMED_doGetCargo;
};