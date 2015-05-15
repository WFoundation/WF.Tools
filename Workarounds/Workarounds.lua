-- Library for Garmins and Emulator to handle some bugs
-- Copyright by Wherigo Foundation, Charlenni
-- Version 0.9.1
if WIGInternal ~= nil then
  if not WIGInternal.Corrected then
    -- Workaround for crash of ZInput when replaced by other screen
    Wherigo.ZInput.GetInput = function (self, input)
      local inputString = input or "<cancelled>"
      Wherigo.LogMessage("ZInput:GetInput - " .. self.Name .. " -> " .. inputString)
      if type(self["OnGetInput"]) == "function" and input ~= nil then
        pcall(self["OnGetInput"], self, input)
      end
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
