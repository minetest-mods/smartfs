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

## Creating and showing forms
A form is a rectangular area of the screen upon which all elements are placed. Use the smartfs.create() function to create a new form. This function takes two arguments and returns a form object.

The first argument is a unique string that identifies the form. The second argument is a function that should take a single argument called state which is used to set form properties like size and background color. State also has constructors for all form elements and can be used with state:element_name. Below is a quick example.

    myform = smartfs.create("My Form",function(state)
        --sets the form's size
        -- (width, hieght)
        state:size(5,5)

        --creates a label and places it on the form
        --(x-pos, y-pos, name, text)
        state:label(3,3,"label1", "A label!")
    end)

Forms can be shown to the player by using the show(target) function. The target argument is the name of the player that will see the form.

    myform:show("singleplayer")

Here is a list of steps the library takes.
* You create a new form using smartfs.create().
* The form is registered and stored for later use.
* You show a form to a player using the myform:show()
* The state is created and stored.
* The function in smartfs.create runs and creates the elements.
* The form is displayed to the player.

## Modifying Elements
Elements have functions of the form element:function(args) where you need to have access to the element object.

You can get the element object by assigning a variable to its creation function like so:

    local button1 = state:button(0,0, 1,4, "btn1", "A button")
    --button1 is now a table representing the button

You can also get the element by using state:get(name). The example below will retrieve a button with the name "btn1":

    button1 = state:get("btn1")
    --or
    state:get("btn1"):onClick(your\_onclick\_function

Both of these methods should be used inside the form creation callback function, the function you pass to smartfs.create, or in event callbacks.

Now that you have located your element you can modify it.

    button1:setPos(4,0)

## Inventory Support
Smartfs supports adding a button to Inventory+ or Unified Inventory which will open one of your own custom forms. Use the smartfs.add\_to\_inventory(form, icon, title) function where form is the smartfs form linked to by the button, icon is the button image (only for unified inventory), and title is the button text (only for inventory+).

    smartfs.add_to_inventory(form, icon, title)

## Dynamic forms
Dynamic forms allow you to make a form without having to register it before the game finished loading.

    local state = smartfs.dynamic("smartfs:dyn_form", name)
    state:load(minetest.get_modpath("smartfs").."/example.smartfs")
    state:get("btn"):click(function(self,state)
    	print("Button clicked!")
    end)
    state:show()

Make sure you call state:show()
