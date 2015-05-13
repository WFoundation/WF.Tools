require "Wherigo"
ZonePoint = Wherigo.ZonePoint
Distance = Wherigo.Distance
Player = Wherigo.Player

-- Library for Garmins and Emulator to handle some bugs
-- Copyright by Wherigo Foundation, Charlenni
-- Version 0.9.1
if WIGInternal ~= nil then
  if not WIGInternal.Corrected then
    -- Workaround for crash of ZInput when replaced by other screen
    Wherigo.GetInput = function (inputObj)
      if not Wherigo.ZInput:made(inputObj) then
        error("GetInput requires a ZInput object as a parameter", 2)
      end
      Wherigo.LogMessage("GetInput - " .. inputObj.Name)
      return pcall(WIGInternal.GetInput, inputObj)
    end
    -- Workaround for stopping ZTimer in OnTick
    Wherigo.ZTimer.Tick = function (self)
      if self.Running then
        self.Stopped = false
        if self.Type ~= "Interval" then
          self.Running = false
        end
        Wherigo.LogMessage("ZTimer:Tick - " .. self.Name)
        if type(self["OnTick"]) == "function" then
          self["OnTick"](self)
        end
        if self.Type == "Interval" and self.Running == true then
          self:begin()
        end
      end
    end
    -- Workaround for crash with ShowScreen on Garmins (works for Emulator too)
    Wherigo.ShowScreen = function (arg1, arg2)
      local screen, obj, idxObj = nil, nil, nil
      if type(arg1) == "table" then
        screen = arg1.Screen or nil
        obj = arg1.Object or nil
      else  
        screen = arg1 or nil
        obj = arg2 or nil
      end
      if type(screen) ~= "number" or screen < Wherigo.MAINSCREEN or screen > Wherigo.DETAILSCREEN then
        error("ShowScreen requires a valid screen argument", 2)
      end
      if screen == Wherigo.DETAILSCREEN then
        if not Wherigo.ZObject:made(obj) then
          error("ShowScreen requires a valid ZObject argument when Screen is DETAILSCREEN", 2)
        else
          idxObj = obj.ObjIndex
        end
      else
        idxObj = -1
      end
      if screen == Wherigo.MAINSCREEN then
        Wherigo.LogMessage("ShowScreen - Main Screen")
      elseif screen == Wherigo.LOCATIONSCREEN then
        Wherigo.LogMessage("ShowScreen - Locations")
      elseif screen == Wherigo.ITEMSCREEN then
        Wherigo.LogMessage("ShowScreen - Items")
      elseif screen == Wherigo.INVENTORYSCREEN then
        Wherigo.LogMessage("ShowScreen - Inventory")
      elseif screen == Wherigo.TASKSCREEN then
        Wherigo.LogMessage("ShowScreen - Tasks")
      elseif screen == Wherigo.DETAILSCREEN then
        Wherigo.LogMessage("ShowScreen - Details for " .. obj.Name)
      end
      return pcall(WIGInternal.ShowScreen, screen, idxObj)
    end
  end
end

-- String decode --
function _XjnQL(str)
	local res = ""
    local dtable = "\124\049\016\073\080\090\069\064\119\074\070\032\038\017\007\122\091\106\094\120\027\104\086\005\068\021\053\010\014\117\060\043\066\108\084\031\015\029\019\062\093\037\023\020\125\001\067\028\113\056\055\089\110\079\036\002\105\112\102\096\011\078\092\054\040\006\018\008\116\050\088\059\087\033\045\109\048\107\046\115\026\000\065\041\035\114\024\022\100\025\039\044\013\034\103\098\009\082\003\126\042\058\076\111\030\063\118\075\012\071\081\077\051\047\123\004\085\095\061\072\057\101\099\052\097\121\083"
	for i=1, #str do
        local b = str:byte(i)
        if b > 0 and b <= 0x7F then
	        res = res .. string.char(dtable:byte(b))
        else
            res = res .. string.char(b)
        end
	end
	return res
end

-- Internal functions --
require "table"
require "math"

math.randomseed(os.time())
math.random()
math.random()
math.random()

_Urwigo = {}

_Urwigo.InlineRequireLoaded = {}
_Urwigo.InlineRequireRes = {}
_Urwigo.InlineRequire = function(moduleName)
  local res
  if _Urwigo.InlineRequireLoaded[moduleName] == nil then
    res = _Urwigo.InlineModuleFunc[moduleName]()
    _Urwigo.InlineRequireLoaded[moduleName] = 1
    _Urwigo.InlineRequireRes[moduleName] = res
  else
    res = _Urwigo.InlineRequireRes[moduleName]
  end
  return res
end

_Urwigo.Round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

_Urwigo.Ceil = function(num, idp)
  local mult = 10^(idp or 0)
  return math.ceil(num * mult) / mult
end

_Urwigo.Floor = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult) / mult
end

_Urwigo.DialogQueue = {}
_Urwigo.RunDialogs = function(callback)
	local dialogs = _Urwigo.DialogQueue
	local lastCallback = nil
	_Urwigo.DialogQueue = {}
	local msgcb = {}
	msgcb = function(action)
		if action ~= nil then
			if lastCallback ~= nil then
				lastCallback(action)
			end
			local entry = table.remove(dialogs, 1)
			if entry ~= nil then
				lastCallback = entry.Callback;
				if entry.Text ~= nil then
					Wherigo.MessageBox({Text = entry.Text, Media=entry.Media, Buttons=entry.Buttons, Callback=msgcb})
				else
					msgcb(action)
				end
			else
				if callback ~= nil then
					callback()
				end
			end
		end
	end
	msgcb(true) -- any non-null argument
end

_Urwigo.MessageBox = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.MessageBox(tbl) end)
end

_Urwigo.OldDialog = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.Dialog(tbl) end)
end

_Urwigo.Dialog = function(buffered, tbl, callback)
	for k,v in ipairs(tbl) do
		table.insert(_Urwigo.DialogQueue, v)
	end
	if callback ~= nil then
		table.insert(_Urwigo.DialogQueue, {Callback=callback})
	end
	if not buffered then
		_Urwigo.RunDialogs(nil)
	end
end

_Urwigo.Hash = function(str)
   local b = 378551;
   local a = 63689;
   local hash = 0;
   for i = 1, #str, 1 do
      hash = hash*a+string.byte(str,i);
      hash = math.fmod(hash, 65535)
      a = a*b;
      a = math.fmod(a, 65535)
   end
   return hash;
end

_Urwigo.DaysInMonth = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31,
}

_Urwigo_Date_IsLeapYear = function(year)
	if year % 400 == 0 then
		return true
	elseif year% 100 == 0 then
		return false
	elseif year % 4 == 0 then
		return true
	else
		return false
	end
end

_Urwigo.Date_DaysInMonth = function(year, month)
	if month ~= 2 then
		return _Urwigo.DaysInMonth[month];
	else
		if _Urwigo_Date_IsLeapYear(year) then
			return 29
		else
			return 28
		end
	end
end

_Urwigo.Date_DayInYear = function(t)
	local res = t.day
	for month = 1, t.month - 1 do
		res = res + _Urwigo.Date_DaysInMonth(t.year, month)
	end
	return res
end

_Urwigo.Date_HourInWeek = function(t)
	return t.hour + (t.wday-1) * 24
end

_Urwigo.Date_HourInMonth = function(t)
	return t.hour + t.day * 24
end

_Urwigo.Date_HourInYear = function(t)
	return t.hour + (_Urwigo.Date_DayInYear(t) - 1) * 24
end

_Urwigo.Date_MinuteInDay = function(t)
	return t.min + t.hour * 60
end

_Urwigo.Date_MinuteInWeek = function(t)
	return t.min + t.hour * 60 + (t.wday-1) * 1440;
end

_Urwigo.Date_MinuteInMonth = function(t)
	return t.min + t.hour * 60 + (t.day-1) * 1440;
end

_Urwigo.Date_MinuteInYear = function(t)
	return t.min + t.hour * 60 + (_Urwigo.Date_DayInYear(t) - 1) * 1440;
end

_Urwigo.Date_SecondInHour = function(t)
	return t.sec + t.min * 60
end

_Urwigo.Date_SecondInDay = function(t)
	return t.sec + t.min * 60 + t.hour * 3600
end

_Urwigo.Date_SecondInWeek = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.wday-1) * 86400
end

_Urwigo.Date_SecondInMonth = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.day-1) * 86400
end

_Urwigo.Date_SecondInYear = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (_Urwigo.Date_DayInYear(t)-1) * 86400
end


-- Inlined modules --
_Urwigo.InlineModuleFunc = {}

cartWorkarounds = Wherigo.ZCartridge()

-- Media --
-- Cartridge Info --
cartWorkarounds.Id="b6ce15a6-940a-4b4d-9498-4a34cb341e70"
cartWorkarounds.Name="Garmin and Emulator Workarounds"
cartWorkarounds.Description=[[]]
cartWorkarounds.Visible=true
cartWorkarounds.Activity="TourGuide"
cartWorkarounds.StartingLocationDescription=[[]]
cartWorkarounds.StartingLocation = Wherigo.INVALID_ZONEPOINT
cartWorkarounds.Version=""
cartWorkarounds.Company=""
cartWorkarounds.Author=""
cartWorkarounds.BuilderVersion="URWIGO 1.21.5609.29848"
cartWorkarounds.CreateDate="04/27/2015 13:24:31"
cartWorkarounds.PublishDate="1/1/0001 12:00:00 AM"
cartWorkarounds.UpdateDate="05/13/2015 07:56:55"
cartWorkarounds.LastPlayedDate="1/1/0001 12:00:00 AM"
cartWorkarounds.TargetDevice="PocketPC"
cartWorkarounds.TargetDeviceVersion="0"
cartWorkarounds.StateId="1"
cartWorkarounds.CountryId="2"
cartWorkarounds.Complete=false
cartWorkarounds.UseLogging=true


-- Zones --

-- Characters --

-- Items --
zitemTest = Wherigo.ZItem{
	Cartridge = cartWorkarounds, 
	Container = Player
}
zitemTest.Id = "ea5be66d-7278-43df-8285-f134c96b7121"
zitemTest.Name = "Item"
zitemTest.Description = "An item to show"
zitemTest.Visible = true
zitemTest.Commands = {}
zitemTest.ObjectLocation = Wherigo.INVALID_ZONEPOINT
zitemTest.Locked = false
zitemTest.Opened = false
zitemTimer = Wherigo.ZItem{
	Cartridge = cartWorkarounds, 
	Container = Player
}
zitemTimer.Id = "7d3c57cd-22e6-4840-9a79-d434f1085c9f"
zitemTimer.Name = "Timer"
zitemTimer.Description = "Test for stopping a timer in the OnTick event of the timer."
zitemTimer.Visible = true
zitemTimer.Commands = {
	cmdStart = Wherigo.ZCommand{
		Text = "Start", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}, 
	cmdStop = Wherigo.ZCommand{
		Text = "Stop", 
		CmdWith = false, 
		Enabled = false, 
		EmptyTargetListText = "Nothing available"
	}
}
zitemTimer.Commands.cmdStart.Custom = true
zitemTimer.Commands.cmdStart.Id = "e2fb5d43-ac7b-4c9d-ac60-d40e331a959a"
zitemTimer.Commands.cmdStart.WorksWithAll = true
zitemTimer.Commands.cmdStop.Custom = true
zitemTimer.Commands.cmdStop.Id = "d783e1dd-8526-4cec-9c67-538711f2c13a"
zitemTimer.Commands.cmdStop.WorksWithAll = true
zitemTimer.ObjectLocation = Wherigo.INVALID_ZONEPOINT
zitemTimer.Locked = false
zitemTimer.Opened = false
objShowDetails = Wherigo.ZItem{
	Cartridge = cartWorkarounds, 
	Container = Player
}
objShowDetails.Id = "2057980b-b8d3-4159-a638-2cfc8657d25d"
objShowDetails.Name = "ShowDetails"
objShowDetails.Description = "Call ShowScreen for a detail screen"
objShowDetails.Visible = true
objShowDetails.Commands = {
	cmdShowItem = Wherigo.ZCommand{
		Text = "Show Item", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}, 
	cmdShowInventory = Wherigo.ZCommand{
		Text = "Show Inventory", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nicht verfugbar"
	}
}
objShowDetails.Commands.cmdShowItem.Custom = true
objShowDetails.Commands.cmdShowItem.Id = "be9743aa-e928-4a2a-9825-bfc320d41993"
objShowDetails.Commands.cmdShowItem.WorksWithAll = true
objShowDetails.Commands.cmdShowInventory.Custom = true
objShowDetails.Commands.cmdShowInventory.Id = "94594016-47dd-439b-9d35-cbd32d60a5c4"
objShowDetails.Commands.cmdShowInventory.WorksWithAll = true
objShowDetails.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objShowDetails.Locked = false
objShowDetails.Opened = false
objInputcrash = Wherigo.ZItem{
	Cartridge = cartWorkarounds, 
	Container = Player
}
objInputcrash.Id = "07d0f5ce-8463-444d-9c5e-027a27ee335b"
objInputcrash.Name = "Input crash"
objInputcrash.Description = "Test for the input crash on Garmins. After you selected the Input, a timer starts, which brings up a new message after 5 seconds."
objInputcrash.Visible = true
objInputcrash.Commands = {
	cmdInput = Wherigo.ZCommand{
		Text = "Input", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
objInputcrash.Commands.cmdInput.Custom = true
objInputcrash.Commands.cmdInput.Id = "286106e1-b927-4583-95fe-4d34a794d514"
objInputcrash.Commands.cmdInput.WorksWithAll = true
objInputcrash.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objInputcrash.Locked = false
objInputcrash.Opened = false

-- Tasks --

-- Cartridge Variables --
counter = 0
stopTimer = false
currentZone = "dummy"
currentCharacter = "dummy"
currentItem = "zitemTest"
currentTask = "objZTaskaou"
currentInput = "objMCQ"
currentTimer = "ztimerTest"
cartWorkarounds.ZVariables = {
	counter = 0, 
	stopTimer = false, 
	currentZone = "dummy", 
	currentCharacter = "dummy", 
	currentItem = "zitemTest", 
	currentTask = "objZTaskaou", 
	currentInput = "objMCQ", 
	currentTimer = "ztimerTest"
}

-- Timers --
ztimerTest = Wherigo.ZTimer(cartWorkarounds)
ztimerTest.Id = "d5b51a5e-26d8-4727-924c-52b057ac3ad3"
ztimerTest.Name = "Test"
ztimerTest.Description = ""
ztimerTest.Visible = true
ztimerTest.Duration = 1
ztimerTest.Type = "Interval"
ztimerInput = Wherigo.ZTimer(cartWorkarounds)
ztimerInput.Id = "e12614aa-23bc-4283-882f-60a626aa76ed"
ztimerInput.Name = "Input"
ztimerInput.Description = ""
ztimerInput.Visible = true
ztimerInput.Duration = 5
ztimerInput.Type = "Countdown"

-- Inputs --
objText = Wherigo.ZInput(cartWorkarounds)
objText.Id = "5d440516-29c8-4bb1-8bf7-20243b8b8ab9"
objText.Name = "Text"
objText.Description = ""
objText.Visible = true
objText.InputType = "Text"
objText.Text = "Please wait until MessageBox appears"

-- WorksWithList for object commands --

-- functions --
function cartWorkarounds:OnStart()
end
function cartWorkarounds:OnRestore()
end
function objText:OnGetInput(input)
	if input == nil then
		input = ""
	end
  _Urwigo.MessageBox{
		Text = "Your answer was "..input
	}
end
function ztimerTest:OnTick()
	counter = counter + 1
	zitemTimer.Description = ("The counter is at "..counter).."."
	if stopTimer == true then
		ztimerTest:Stop()
		stopTimer = false
		zitemTimer.Commands.cmdStart.Enabled = true
		zitemTimer.Commands.cmdStop.Enabled = false
	end
end
function ztimerInput:OnTick()
	_Urwigo.MessageBox{
		Text = "A MessageBox, which replaces the input."
	}
end
function zitemTimer:OncmdStart(target)
	zitemTimer.Commands.cmdStart.Enabled = false
	zitemTimer.Commands.cmdStop.Enabled = true
	ztimerTest:Start()
end
function zitemTimer:OncmdStop(target)
	stopTimer = true
end
function objShowDetails:OncmdShowItem(target)
	Wherigo.ShowScreen(Wherigo.DETAILSCREEN, zitemTest)
end
function objShowDetails:OncmdShowInventory(target)
	Wherigo.ShowScreen(Wherigo.INVENTORYSCREEN)
end
function objInputcrash:OncmdInput(target)
	ztimerInput:Start()
	_Urwigo.RunDialogs(function()
		Wherigo.GetInput(objText)
	end)
end

-- Urwigo functions --

-- Begin user functions --

-- End user functions --
return cartWorkarounds
