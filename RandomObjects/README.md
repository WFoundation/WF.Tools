# RandomObjects
A library for handling tables and random access to the entries.

### Purpose
This library provides functions to access entries of a table in random style.

### Installation
The code of this library (Lua script file) should be placed in the author 
script or imported by a 'require "RandomObjects"' (Urwigo).

### Initialization
To create such a table, you use the following function
```lua
tabRandom = RandomObjects({101, 102, 103, 104, 105, 106})
```
Here I created the table with the numbers from 101 to 106, but I could have 
created it with items like this
```lua
tabRandom = RandomObjects({itemHammer, itemNail, itemRope, itemKnife})
```
where itemHammer and so on are the variable names of the items. You could now 
access each entry with a "tabRandom[1]", "tabRandom[2]" and so on. Which is 
the normal way to access table entries.

### Usage

#### GetNext() and GetNextWithRemove()
If you want a random entry, than you get this by
```lua
entry = tabRandom:GetNext()
entry = tabRandom:GetNextWithRemove()
```
The difference between both functions is, that the later one removes the 
entry from the table, so that is one entry smaller. 

#### Last
I stored the returned in the above example the returned entry in the variable 
"entry". If you don't do this, you could use
```lua
tabRandom:Last
```
to access the last returned entry from the table.

#### IsNext()
To test, if there is one or more entries left in the table, you could use
```lua
tabRandom:IsNext()
```
It returns "true", if there is one or more entries left or "false" if the tabel
is empty.

#### Add()
To add an new entry to the table, you could use  
```lua
tabRandom:Add(entry)
```
which adds an entry to the table, but not to the original values.

#### Remove()
To remove an entry by hand from the table use
```lua
tabRandom:Remove(entry)
```

#### Reset()
To restore the original entries of the table, which you have set by the call 
of RandomObjects(), you could use
```lua
tabRandom:Reset()
```

### Authors
- Charlenni (Wherigo Foundation))
