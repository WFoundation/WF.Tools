--------------------------------------------------------------------------------
-- Table with random access
-- Version 1.0.1
-- Copyright Wherigo Foundation, Dirk Weltz
--
-- Create table by
--   RandomObjects({Your objects})
--
-- You could use every object you like. It could be numbers, 
-- strings or Wherigo objects
--
-- Check if there are more objects remaining in the table
--   IsNext(self)
-- Parameter self is the table itself
-- Returns true if there are more objects in the table, otherwise false
--
-- Get next objects
--   GetNext(self, remove)
-- Parameter self is the table itself
-- Parameter remove says, if the return object should be removed from the 
-- entries
-- Returns the randomly selected object from the entries
--
-- Get next object with remove
--   GetNextWithRemove(self)
-- Parameter self is the table itself
-- Returns the randomly selected object from the entries
--
-- Add an object
--   Add(self, object)
-- Parameter self is the table itself
-- Parameter object is the object, which should be added to the entries
--
-- Remove an object
--   Remove(self, object)
-- Parameter self is the table itself
-- Parameter object is the object, which should be removed from the entries
--
-- Reset the entries
--   Reset(self)
-- Parameter self is the table itself
-- Restores the table to the values, when it was created
--
-- Get last entry from GetNext or GetNextWithRemove
--  Last
-- This property saves the last return entry
--------------------------------------------------------------------------------
RandomObjects = function (objs)

  -- Create table
  local tab = {}
  
  -- Create table for objects
  tab.OriginalObjects = {}
  
  -- Create entry for last object that is returned by GetNext
  tab.Last = nil
  
  -- Copy objects
  for i = 1, #objs, 1 do
    table.insert(tab, objs[i])
    table.insert(tab.OriginalObjects, objs[i])
  end
  
  -- Init random generator
  math.randomseed(os.time())
  
  -- Function for check, if there are more objects
  tab.IsNext = function (self)
    return #self > 0
  end

  -- Function to get next object. Default is without removing returned object.
  tab.GetNext = function (self, remove)
    remove = remove or false
    -- If no next object, then return nil
    if not self:IsNext() then
      return nil
    end
    -- Calc next object
    rand = math.random(#self)
    -- Save for later use
    self.Last = self[rand]
    -- Delete selectet object from objects
    if remove then
      table.remove(self, rand)
    end
    -- Return selected object
    return self.Last
  end

  -- Function to get next object and than remove this object from table
  tab.GetNextWithRemove = function (self)
    return self:GetNext(true)
  end

  -- Function to reset the table Objects to their initial value
  tab.Reset = function (self)
    -- Delete old entries
    for i = #self, 1, -1 do
      table.remove(self, i)
    end
    -- Transfer original entries to table
    for i = 1, #self.OriginalObjects, 1 do
      table.insert(self, self.OriginalObjects[i])
    end
  end
  
  -- Function to add an entry to the table
  tab.Add = function(self, object)
    table.insert(self, object)
  end

  -- Function to remove an entry from the table
  tab.Remove = function(self, object)
    local remove = 0
    -- Get position of object
    for i = 1, #self, 1 do
      if self[i] == object then
        remove = i
      end
    end
    -- If object was not in the table than return false
    if remove == 0 then
      return false
    end
    -- Remove object from table
    table.remove(self, remove)
    -- Return true, because object was in table
    return true
  end

  -- Return RandomObjects table
  return tab
  
end