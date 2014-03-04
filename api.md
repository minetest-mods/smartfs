#Full API
##Smartfs

* create( name,function ) - creates a new form and adds elements to it by running the function. Use before Minetest loads. (like minetest.register_node)
* element( name, data ) - creates a new element type.
* dynamic( formname, playername ) - creates a dynamic form. Returns state. See example.lua for example. Remember to call state:show()
* add\_to\_inventory( name,icon,title ) - Adds a form to an installed advanced inventory.
* inventory_mod() - Returns the name of an installed advanced inventory, or null.
* smartfs.override\_load\_checks() - Allows you to use smartfs.create after the game loads. Not recommended!

##Form

* form:show( playername [, parameters] ) - shows the form to a player.
* form.name - the name of the form.

##State

### Methods
* state:size( width,height ) - sets the forms width and height.
* state:get( name ) - gets an element by name.
* state:show() - reshows the form to the player.
* state:close() - closes the form (does not work yet, due to no MT api support).
* state:load( filepath ) - Loads elements from a file.
* state:save( filepath ) - Saves elements to a file.
* state:button( x,y,w,h,name,text ) - create a new button at x,y with name and caption (text)
* state:toggle( x,y,w,h,name,list ) - create a new toggle button at x,y with name and possible list of values
* state:label( x,y,name,text ) - create a new label at x,y with name and caption (text)
* state:field( x,y,w,h,name,label ) - create a new field at x,y with label
  * state:pwdfield( x,y,w,h,name,label ) - create a password field
  * state:textarea( x,y,w,h,name,label ) - create a new textarea
* state:image( x,y,w,h,name,imagepath ) - create an image box.
* state:checkbox( x,y,name,label,selected ) - create a check box.
* state:element( element_type, data ) - Semi-private, create an element with type and data.

### Variables
* state.player - The name of the player.
* state.param - The parameters supplied by form:show.
* state.def - The form definition.
* state.is_inv - Boolean which is true if this form is being shown as an inventory.

##Button

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the button
* element:setImage( filename ) - sets the background of the button
* element:getImage() - get the background filename of the button
* element:click( func(self,state) ) - specify a function to run when the button is clicked

##Toggle Button

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:getText() - get the text of the toggle option
* element:setId( filename ) - sets the selected id
* element:getId() - get the selected id
* element:onToggle( func(self,state) ) - specify a function to run when the value if toggled

##Label

* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setText( text ) - set the caption of the label
* element:getText() - get the caption of the label

##Field and Text Area
* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the field
* element:setImage( filename ) - sets the background of the field
* element:getImage() - get the background filename of the field
