# Workarounds
A library to correct different bugs and problems of the different players.

### Purpose
This library provides workarounds for known problems where it is possible.
Not for all bug there is a workaround. But if there is one, a solution could
found here.

### Installation
The code of this library should be placed directly after the 'require "Wherigo"'
in the cartridge Lua file, but it must place before any creation of objects.
Normally this is only possible by builder authors or authors, who write 
cartridges "by hand" without a build. You don't need to call any function so 
that the workaround take place. If you use Urwigo, you could place the code 
into the "Lua user directives".

### Removed bugs

#### Garmin
- ZTimer bug: bug that timer could be stopped in the OnTick event
- ZInput bug: bug that lets the player crash if an input screen is removed
by another screen
- ShowScreen bug: bug that lets the player crash if ShowScreen() is called with
a list type screen

#### Emulator
- ZTimer bug: bug that timer could be stopped in the OnTick event
- ZInput bug: bug that lets the player crash if an input screen is removed
by another screen

### Testing
For testing you could find an attached demo cartridge in folder 
"WorkaroundsCartridge". There you could also find a compilible cartridge where 
the author script is placed correcly. This isn't possible in Urwigo up to now.
  
### Author
- Charlenni (Wherigo Foundation)