smartfs
=======

This mod provides a 2nd generation way of creating forms - this means that the modder does not need to worry about complex formspec strings

* Expandable: you can register your own elements to use on the form.
* Easy event handling: use binding to handle events.
* New elements: Includes a toggle button

License: WTFPL
To install this library, place the smartfs.lua file in your mod and then include it (dofile).
There is an init.lua file in the download that shows you how to do this.

Elements
========

Button
------

* state:button( x,y,w,h,name,text ) - create a new button at x,y with name and caption (text)
* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the button
* element:setImage( filename ) - sets the background of the button
* element:getImage() - get the background filename of the button
* element:onClick( func(self,state) ) - specify a function to run when the button is clicked

Toggle Button
-------------

* state:toggle( x,y,w,h,name,list ) - create a new toggle button at x,y with name and possible list of values
* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:getText() - get the text of the toggle option
* element:setId( filename ) - sets the selected id
* element:getId() - get the selected id
* element:onToggle( func(self,state) ) - specify a function to run when the value if toggled

Label
-----

* state:label( x,y,name,text ) - create a new label at x,y with name and caption (text)
* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the button

Field
-----

* state:field( x,y,w,h,name,label ) - create a new field at x,y with label
* state:pwdfield( x,y,w,h,name,label ) - create a password field
* state:textarea( x,y,w,h,name,label ) - create a new textarea
* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the button
* element:setImage( filename ) - sets the background of the button
* element:getImage() - get the background filename of the button
* element:onClick( func(self,state) ) - specify a function to run when the button is clicked

And more documentation coming soon...
