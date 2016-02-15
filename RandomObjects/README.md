# RandomObjects
A library for handling tables and random access to the entries.

### Purpose
This library provides functions to access entries of a table in random style.

### Installation
The code of this library (Lua script file) should be placed in the author 
script or imported by a 'require "RandomObjects"' (Urwigo).

### Initialization
To create such a table, you use the following function
  tabRandom = RandomObjects({101, 102, 103, 104, 105, 106})
Here I created the table with the numbers from 101 to 106, but I could have 
created it with items like this
  tabRandom = RandomObjects({itemHammer, itemNail, itemRope, itemKnife})
where itemHammer and so on are the variable names of the items. You could now 
access each entry with a "tabRandom[1]", "tabRandom[2]" and so on. Which is 
the normal way to access table entries.

If you want a random entry, than you get this by
  entry = tabRandom:GetNext()
  entry = tabRandom:GetNextWithRemove()
The difference between both functions is, that the later one removes the 
entry from the table, so that is one entry smaller. I stored the returned 
entry in the variable "entry". If you don't do this, you could use
  tabRandom:Last
to access the last returned entry from the table.

Additional functions are:
  tabRandom:IsNext()
It returns "true", if there is an entry left or "false" if there is no entry.

  tabRandom:Add(entry)
Adds an entry to the list.

  tabRandom:Remove(entry)
Removes an entry from the list if it exists.

  tabRandom:Reset()
Restores all entries of the original table (entries you set with the RandomObjects function).

### Authors
- Charlenni (Wherigo Foundation))
