#Full API
##Smartfs
* smartfs( name ) - returns the form regisered with the name 'name'
* smartfs.create( name,function ) - creates a new form and adds elements to it by running the function. Use before Minetest loads. (like minetest.register_node)
* smartfs.element( name, data ) - creates a new element type.
* smartfs.dynamic( formname, playername ) - creates a dynamic form. Returns state. See example.lua for example. Remember to call state:show()
* smartfs.add\_to\_inventory(form, icon, title) - Adds a form to an installed advanced inventory. Returns true on success.
* smartfs.inventory_mod() - Returns the name of an installed and supported inventory mod that will be used above, or null.
* smartfs.override\_load\_checks() - Allows you to use smartfs.create after the game loads. Not recommended!

##Form
* form:show( playername [, parameters] ) - shows the form to a player. See state.param.
* form.name - the name of the form.

##State

### Methods
* state:size( width,height ) - sets the forms width and height.
* state:get( name ) - gets an element by name.
* state:show() - reshows the form to the player.
* state:close() - closes the form (does not work yet, due to no MT api support).
* state:load( filepath ) - Loads elements from a file.
* state:save( filepath ) - Saves elements to a file.
* state:button( x,y,w,h,name,text [, exit_on_click] ) - create a new button at x,y with name and caption (text)
 * ^ optional: exit_on_click - set to true to exit the form when the button is clicked. ( Also see button.setClose() )
* state:toggle( x,y,w,h,name,list ) - create a new toggle button at x,y with name and possible list of values
* state:label( x,y,name,text ) - create a new label at x,y with name and caption (text)
* state:field( x,y,w,h,name,label ) - create a new field at x,y with label
  * state:pwdfield( x,y,w,h,name,label ) - create a password field
  * state:textarea( x,y,w,h,name,label ) - create a new textarea
* state:image( x,y,w,h,name,imagepath ) - create an image box.
* state:inventory( x,y,w,h,name ) - create an inventory listing (use 'main' as name for the main player inventory)
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

##List box
* element:onClick( func(self,state,idx) ) - function to run when listbox item idx is clicked
* element:onDoubleClick( func(self,state,idx) ) - function to run when listbox item idx is double clicked
* element:setPosition( x,y ) - set the position
* element:getPosition() - returns {x=x, y=y}
* element:setSize( w,h ) - set the size
* element:getSize() - gets the size {w=w, h=h}
* element:addItem( item ) - appends and item
* element:removeItem( idx ) - remove item
* element:popItem() - removes last item and returns

##Inventory listing
* element:setPosition( x,y ) - set the position
* element:getPosition() - returns {x=x, y=y}
* element:setSize( w,h ) - set the size
* element:getSize() - gets the size {w=w, h=h}
* element:setLocation( location ) - set a custom inventory location or nil for the default (current_player)
  * element:usePosition( position ) - use a node metadata attached inventory of the node at the given positon
  * element:useDetached( name ) - use a detached inventory with the given name
  * element:usePlayer( name ) - use a player inventory other than the current player
* element:getLocation() - returns the inventory location (default: current_player)
* element:setIndex( index ) - set the inventory starting index
* element:getIndex() - returns the inventory starting index

##Custom Code
* element:onSubmit( func(self) ) - on form submit
* element:onBuild( func(self) ) - run every time form is shown. You can set code from here
* element:setCode( code ) - set the formspec code
* element:getCode( code ) - get the formspec code
