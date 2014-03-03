smartfs
=======

This mod provides a 2nd generation way of creating forms - this means that the modder does not need to worry about complex formspec strings

* Expandable: you can register your own elements to use on the form.
* Easy event handling: use binding to handle events.
* New elements: Includes a toggle button

License: WTFPL
To install this library, place the smartfs.lua file in your mod and then include it (dofile).
There is an init.lua file in the download that shows you how to do this.

#Using Smart Formspec
Smartfs provides 2nd generation Minetest forms to replace clunky formspec strings. Each smartfs form is a container filled with GUI elements. A number of default elements are included with smartfs, but modders can also define their own custom elements. This document describes the basic usage of the smartfs API.

##Installation
Smartfs can be used as a library or a mod.

To use smartfs as a library, copy the smartfs.lua file to your mod folder and add
    dofile(minetest.get\_modpath(minetest.get\_current\_modname()).."/smartfs.lua")
to the top of any files that use it.

To use smartfs as a mod, add it to your game's mods folder or to the user mods folder and enable it.

## Creating Forms
A form is a rectangular area of the screen upon which all elements are placed. Use the smartfs.create() function to create a new form. This function takes two arguments and returns a form object.

The first argument is a unique string that identifies the form. The second argument is a function that should take a single argument called state which is used to set form properties like size and background color. State also has constructors for all form elements and can be used with state:element_name. Below is a quick example.

    form_name = smartfs.create("My Form",
                               function(state)
                                   --sets the form's size
                                   -- (width, hieght)
                                   state:size(5,5)

                                   --creates a label and places it on the form
                                   --(x-pos, y-pos, name, text)
                                   state:label(3,3,"ly label", "A label!")
                               end)
## Showing Forms
Forms can be shown to the player by using the show(target) function. The target argument is the name of the player that will see the form.

    form_name:show("singleplayer")

## Inventory Support
Smartfs supports adding a button to Inventory+ or Unified Inventory which will open one of your own custom forms. Use the smartfs.add\_to\_inventory(form, icon, title) function where form is the smartfs form linked to by the button, icon is the button image(only for unified inventory), and title is the button text(only for inventory+.

    smartfs.add_to_inventory(form_name, "my form icon.png", "Open My Form")

##Creating New Elements

#Full API
##Smartfs

* create( name,function ) - creates a new form with name and adds elements to it by running function.
* add\_to\_inventory( name,icon,title ) - adds a button with image icon if unified inventory or text title if inventory+ that links to the form belonging to the given name.

##Form

* state:size( width,height ) - sets the forms width and height.

##Button

###Creation

* state:button( x,y,w,h,name,text ) - create a new button at x,y with name and caption (text)

###Manipulation

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the button
* element:setImage( filename ) - sets the background of the button
* element:getImage() - get the background filename of the button

###Event Handling

* element:onClick( func(self,state) ) - specify a function to run when the button is clicked

##Toggle Button

###Creation

* state:toggle( x,y,w,h,name,list ) - create a new toggle button at x,y with name and possible list of values

###Manipulation

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:getText() - get the text of the toggle option
* element:setId( filename ) - sets the selected id
* element:getId() - get the selected id

###Event Handling

* element:onToggle( func(self,state) ) - specify a function to run when the value if toggled

##Label

###Creation

* state:label( x,y,name,text ) - create a new label at x,y with name and caption (text)

###Manipulation

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setText( text ) - set the caption of the label
* element:getText() - get the caption of the label

##Field and Text Area
###Creation

* state:field( x,y,w,h,name,label ) - create a new field at x,y with label
* state:pwdfield( x,y,w,h,name,label ) - create a password field
* state:textarea( x,y,w,h,name,label ) - create a new textarea

###Manipulation

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the field
* element:setImage( filename ) - sets the background of the field
* element:getImage() - get the background filename of the field

###Event Handling

* element:onClick( func(self,state) ) - specify a function to run when the field is clicked
