-- Library for Garmins to handle special characters and some bugs
-- Copyright by Wherigo Foundation, Charlenni
-- Version 0.9.5

-- HowTo
--
-- Installation
-- Copy this code into your Author script or add it as a Lua file 
-- with require statement
--
-- Initialisation
-- You must not do anything. It works out of the box
--
-- Usage
-- Insert everywhere in your cartridge special characters.
-- To access Name, Description or Command.Text you should
-- use obj:rawget("Name") to get the UTF-8 representation 
-- of the Name. If you do not this, you get the Latin 8859-1 
-- representation of the string. 
-- All other things work like expected.

-- Create table holding all the Garmin stuff
Garmin = {}

-- Initialisation for garmin utf-8 to latin conversation
Garmin.Init = function ()
   -- Call init only once
  if Garmin.IsGarmin ~= nil then
    return
  end
  -- Save for later use
  Garmin.IsGarmin = string.sub(Env.Platform,1,6) == "Vendor"
  -- Check for Garmins
  if not Garmin.IsGarmin then
    return
  end
  -- Init
  Garmin.InitFramework()
  -- Get cartridge
  cart = Garmin.GetCartridgeObject()
  if cart == nil then
    -- We did not find a ZCartridge instance
    return
  end
  -- Ensure that table Garmin is saved
  cart.ZVariables.Garmin = true
  -- Replace cartridge OnResume with a new function
  -- so that it is possible to setup things after a 
  -- resume of cartridge
  Garmin.OrgOnRestore = cart.OnRestore
  cart.OnRestore = Garmin.OnRestore
  -- Replace original function for adding new ZObjects
  Garmin.GetCartridgeObject().AddZObject = function (self, obj)
      if Wherigo.ZObject:made(obj) then
        if table.Contains(self.AllZObjects, obj) then
          error("Object already added to the cartridge: " .. obj.Name, 2)
        end
        table.insert(self.AllZObjects, obj)
        obj.Cartridge = self
        obj.ObjIndex = #self.AllZObjects
      end
      Garmin.InitObject(obj)
    end
  -- Check all ZObjects
  for k,v in ipairs(cart.AllZObjects) do
    Garmin.InitObject(v)
  end
end

-- Init default settings for Wherigo methods and bugs
Garmin.InitFramework = function ()
  -- Correct Garmin bugs
  if not WIGInternal.Corrected then
    -- Workaround for ShowScreen bug
    Garmin.WorkaroundShowScreen()
    -- Workaround for ZTimer bug
    Garmin.WorkaroundZTimer(Wherigo.ZTimer)
    -- Workaround for ZInput bug
    Garmin.WorkaroundZInput()
  end
  -- Save original functions
  Garmin.OrgMessageBox = Wherigo.MessageBox
  Garmin.OrgDialog = Wherigo.Dialog
  Garmin.OrgGetInput = Wherigo.GetInput
  Garmin.OrgLogMessage = Wherigo.LogMessage
  -- Replace MessageBox and Dialog
  Wherigo.MessageBox = Garmin.MessageBox
  Wherigo.Dialog = Garmin.Dialog
  Wherigo.GetInput = Garmin.GetInput
  Wherigo.LogMessage = Garmin.LogMessage
  -- Replace bugy rawget function
  rawget = function (obj, prop)
    return obj.rawget(obj, prop)
  end
end

-- Init all settings for existing and new ZObjects
Garmin.InitObject = function (obj)
    if Wherigo.Zone:made(obj) or Wherigo.ZCharacter:made(obj) or Wherigo.ZItem:made(obj) or Wherigo.ZTask:made(obj) then
      -- Init all names and descriptions for Zone, ZItem, ZCharacter, ZTask
      Garmin.InitProperty(obj, "Name")
      Garmin.InitProperty(obj, "Description")
      -- Init all commands of this ZObject
      if obj.Commands ~= nil then
        for j,w in pairs(obj.Commands) do
          Garmin.InitProperty(w, "Text")
        end
      end
    end
    if Wherigo.ZInput:made(obj) then
      obj.OrgGetInput = obj.GetInput
    end
    if Wherigo.ZTimer:made(obj) then
      -- Workaround for timer bug (stop in OnTick)
      Garmin.WorkaroundZTimer(obj)
    end
end

-- Init of properties, so that the getter returns Latin and rawget returns UTF8
Garmin.InitProperty = function (obj, property)
  -- Replace get method
  obj["Get"..property] = function (self, value)
      return Garmin.UTF8ToLatin(value)
    end
end

Garmin.OnRestore = function (self)
  Garmin.InitFramework()
  -- Call original OnResume
  if Garmin.OrgOnRestore ~= nil and type(Garmin.OrgOnRestore) == "function" then
    Garmin.OrgOnRestore(self)
  end
end

-- MessageBox function with UTF-8 to Latin translation
Garmin.MessageBox = function (arg1, arg2, arg3, arg4)
  if arg1 ~= nil and type(arg1) == "table" then
    -- MessageBox call with table
    arg1.Text = Garmin.UTF8ToLatin(arg1.Text)
    -- Cave! Garmins have only around 800 characters for MessageBoxes
    if string.len(arg1.Text) > 800 then
      arg1.Text = string.sub(arg1.Text, 1, 796) .. " ..."
    end
    if arg1.Buttons ~= nil and arg1.Buttons[1] ~= nil then
      arg1.Buttons[1] = Garmin.UTF8ToLatin(arg1.Buttons[1])
    end
    if arg1.Buttons ~= nil and arg1.Buttons[2] ~= nil then
      arg1.Buttons[2] = Garmin.UTF8ToLatin(arg1.Buttons[2])
    end
    Garmin.OrgMessageBox(arg1)
  else
    -- MessageBox with discrete arguments
    arg1 = Garmin.UTF8ToLatin(arg1)
    -- Cave! Garmins have only around 800 characters for MessageBoxes
    if string.len(arg1) > 800 then
      arg1 = string.sub(arg1, 1, 796) .. " ..."
    end
    if type(arg3) == "table" then
      arg3[1] = Garmin.UTF8ToLatin(arg3[1])
      arg3[2] = Garmin.UTF8ToLatin(arg3[2])
    end
    Garmin.OrgMessageBox(arg1, arg2, arg3, arg4)
  end
end

-- Dialog function with UTF-8 to Latin translation
Garmin.Dialog = function (tbl)
  for k, v in ipairs(tbl) do
    if v.Text ~= nil then
      v.Text = Garmin.UTF8ToLatin(v.Text)
      -- Cave! Garmins have only around 800 characters for Dialogs
      if string.len(v.Text) > 800 then
        v.Text = string.sub(v.Text, 1, 796) .. " ..."
      end
    end
  end
  Garmin.OrgDialog(tbl)
end

-- GetInput function with UTF-8 to Latin and vice versa translation
-- With this function, all input results are converted to UTF-8
Garmin.GetInput = function(input)
  if Wherigo.ZInput:made(input) then
    -- Check this, because of a aborted input operation
    if not input.TextTranslated then
      input.OrgText = input.Text
      input.Text = Garmin.UTF8ToLatin(input.Text)
      input.TextTranslated = true
    end
    -- If MultipleChoice input, than translate all choices and save original for later use
    if input.InputType ~= nil and input.InputType == "MultipleChoice" then
      -- Table for original choices
      input.OrgChoices = {}
      -- Translate choices
      for j,w in ipairs(input.Choices) do
        input.OrgChoices[j] = input.Choices[j]
        input.Choices[j] = Garmin.UTF8ToLatin(input.Choices[j])
      end
      -- Save original OnGetInput for later use
      if input.OrgOnGetInput == nil then
        input.OrgOnGetInput = input.OnGetInput
        -- Create a new OnGetInput, which translate input to original value
        input.OnGetInput = function (self, value)
            local utf8value = value
            -- Emulator returns string in UTF-8, so convert it
            for i,x in ipairs(self.Choices) do
              if x == value then
                utf8value = self.OrgChoices[i]
              end
              self.Choices[i] = self.OrgChoices[i]
            end
            self.Text = self.OrgText
            self.TextTranslated = false
            self.OrgOnGetInput(self, utf8value)
          end
      end
    end
    -- If Text input, than translate answer back
    if input.InputType ~= nil and input.InputType == "Text" then
      -- Save original OnGetInput for later use
      if input.OrgOnGetInput == nil then
        input.OrgOnGetInput = input.OnGetInput
        -- Create a new OnGetInput, which translate input back
        input.OnGetInput = function (self, value)
            self.Text = self.OrgText
            self.TextTranslated = false
            self.OrgOnGetInput(self, Garmin.LatinToUTF8(value))
          end
      end
    end
  end
  Garmin.OrgGetInput(input)
end

-- LogMessage function with UTF-8 to Latin translation
Garmin.LogMessage = function (level, message)
  Garmin.OrgLogMessage(level, Garmin.UTF8ToLatin(message))
end

-- Normal Latin to UTF8 function
Garmin.LatinToUTF8 = function (s)
  local result = ""
  if s == nil then
    return ""
  end
  for i = 1, #s, 1 do
    local b = string.byte(s, i)
    if b >= 0xa0 and b <= 0xbf then
      result = result .. string.char(0xc2, b)
    elseif b >= 0xc0 and b <= 0xff then
      result = result .. string.char(0xc3, b - 0x40)
    else
      result = result .. string.char(b)
    end
  end
  return result
end

-- Normal UTF8 to Latin function, found in an Earwigo cartridge
Garmin.UTF8ToLatin = function (s)
  if s == nil or s == "" then
    return s
  end
  if (Garmin.UTF8Table == nil) then
    Garmin.UTF8Table = {
      [0xC487] = 'c';
      [0xC48D] = 'c';
      [0xC48F] = 'd';
      [0xC49B] = 'e';
      [0xC4BA] = 'l';
      [0xC4BE] = 'l';
      [0xC584] = 'n';
      [0xC588] = 'n';
      [0xC595] = 'r';
      [0xC599] = 'r';
      [0xC59B] = 's';
      [0xC5A1] = 's';
      [0xC5A5] = 't';
      [0xC5AF] = 'u';
      [0xC5BA] = 'z';
      [0xC5BE] = 'z';
      [0xC486] = 'C';
      [0xC48C] = 'C';
      [0xC48E] = 'D';
      [0xC49A] = 'E';
      [0xC4B9] = 'L';
      [0xC4BD] = 'L';
      [0xC583] = 'N';
      [0xC587] = 'N';
      [0xC594] = 'R';
      [0xC598] = 'R';
      [0xC59A] = 'S';
      [0xC5A0] = 'S';
      [0xC5A4] = 'T';
      [0xC5AE] = 'U';
      [0xC5B9] = 'Z';
      [0xC5BD] = 'Z';
    }
  end
  local result = ""
  local i = 1
  local l = string.len(s)
  while (i <= l) do
    local c = string.byte(s, i)
    local x = '?'
    if ((c == 194) or (c == 195)) then
      i = i + 1
      if (i <= l) then
        local n = string.byte(s, i)
        if (c == 195) then
          n = n + 64
        end
        x = string.char(n)
      end
    elseif ((c == 196) or (c == 197)) then
      i = i + 1
      if (i <= l) then
        local index = c * 256 + string.byte(s, i)
        local e = Garmin.UTF8Table[index]
        if (e ~= nil) then
          x = e
        end
      end
    elseif ((c >= 198) and (c <= 223)) then
      i = i + 1
    elseif ((c >= 224) and (c <= 255)) then
      i = i + 2
    else
      x = string.char(c)
    end
    result = result .. x
    i = i + 1
  end
  return result
end

-- Get ZCartridge object
Garmin.GetCartridgeObject = function ()
  for k,v in pairs(_G) do
    if Wherigo.ZCartridge:made(v) then
      return v
    end
  end
  return nil
end

-- Workaround for crash with ShowScreen on Garmins (works for Emulator too)
Garmin.WorkaroundShowScreen = function ()
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

-- Workaround for crash of ZInput when replaced by other screen
Garmin.WorkaroundZInput = function ()
  Wherigo.GetInput = function (inputObj)
      if not Wherigo.ZInput:made(inputObj) then
        error("GetInput requires a ZInput object as a parameter", 2)
      end
      Wherigo.LogMessage("GetInput - " .. inputObj.Name)
      return pcall(WIGInternal.GetInput, inputObj)
    end
end

-- Workaround for not stopping ZTimer from OnTick (works for Emulator too)
Garmin.WorkaroundZTimer = function (obj)
  obj.Tick = function (self)
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
end

-- Save original OnStart function of cartridge for later use
Garmin.OrgOnStart = Garmin.GetCartridgeObject().OnStart

-- Replace cartridge OnStart with one, that is calling Garmin.Init
-- to initialize the Garmin replacements
Garmin.GetCartridgeObject().OnStart = function (self)
  Garmin.Init()
  Garmin.OrgOnStart(self)  
end

-- Add a missing rawget
Wherigo.Get = function (obj, prop)
  if string.sub(Env.Platform, 1, 6) == "Vendor" then
    return obj.rawget(obj, prop)
  else
    return obj[prop]
  end
end