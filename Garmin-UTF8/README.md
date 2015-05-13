# Garmin-UTF8
A library for Garmins to handle UTF-8 strings.

## Purpose
This library provides functions on Garmins to convert UTF-8 strings into 
Latin 8859-1 strings, which could displayed on the player. This library works
only on Garmins. All other players could handle UTF-8 strings without any 
conversion.

## Installation
The code of this library should be placed in the author script or imported by 
a 'require "Garmin-UTF8"' (Urwigo). You don't have to call any function so 
that the conversion take place.

## Explanation
Garmins use Latin 8859-1 as characterset for Wherigos. All other players use 
UTF-8. To use special characters like äöüß, strings have to be converted from 
UTF-8 to Latin 8859-1. If strings entered with a input field, than this have 
to be converted back.

The library replaces at startup all getters for Names, Descriptions and 
Command.Texts, so that they return always Latin 8859-1. That's because the 
Garmin use this functions to get the strings. If you want the original string,
you have to use the rawget() function of the object. Use it as 
'item:rawget("Name")' for object 'item' and property 'Name'.

All Choices for multiple choice inputs are converted to Latin 8859-1 when you 
call the input. Original strings are saved and if the user selects one, it is 
replaced by the original UTF-8 string. Text inputs are converted from Latin 
8859-1 to UTF-8.

MessageBox and Dialog are converted on the fly, so that there are all strings 
and buttons in Latin 8859-1. The same for LogMessage. 

## Further improvements  
The library creates also workarounds for the ZTimer, the ZInput and the 
ShowScreen bugs of Garmins. If you use allready the Workarounds library, it 
isn't a problem, If this library detects the Workaround library, nothing is 
done.
