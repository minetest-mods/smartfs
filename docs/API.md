# Full API
## Smartfs
* smartfs( name ) - returns the form regisered with the name 'name'
* smartfs.create( name,function ) - creates a new form and adds elements to it by running the function. Use before Minetest loads. (like minetest.register_node)
* smartfs.element( name, data ) - creates a new element type.
* smartfs.dynamic( formname, playername ) - creates a dynamic form. Returns state. See example.lua for example. Remember to call state:show()
* smartfs.add_to_inventory(form, icon, title, show_inv) - Adds a form to an installed advanced inventory. Returns true on success.
* smartfs.set_player_inventory(form) - Set the form as players main inventory for all player
* smartfs.inventory_mod() - Returns the name of an installed and supported inventory mod that will be used above, or nil.
* smartfs.override_load_checks() - Allows you to use smartfs.create after the game loads. Not recommended!
* smartfs.nodemeta_on_receive_fields(nodepos, formname, fields, sender) - on_receive_fields callback can be used in minetest.register_node for nodemeta forms

## Form
* form:show( playername [, parameters] ) - shows the form to a player. See state.param.
* form.name - the name of the form.
* form:attach_to_node(nodepos, params) - Attach a form to a node meta (usable in register_node's constructor, on_placenode, or dynamically)

## Supported locations
* unified_inventory, inventory_plus, or sfinv plugins - assigned by smartfs.add_to_inventory() - auto-detection which inventory should be used
* player / show_formspec() - used for form:show(player)
* (main) inventory - assigned by smartfs.set_player_inventory()
* nodemeta - assigned by form:attach_to_node(nodepos, params)
* container - used internally for state:container()

## State

### Methods
* state:size( width,height ) - sets the forms width and height.
* state:get( name ) - gets an element by name.
* state:show() - reshows the form to the player.
* state:close() - closes the form (does not work yet, due to no MT api support).
* state:load( filepath ) - Loads elements from a file.
* state:save( filepath ) - Saves elements to a file.
* state:onInput( function(self,fields,playername)) - specify a function to run after data and/or events received
* state:button( x,y,w,h,name,text [, exit_on_click] ) - create a new button at x,y with name and caption (text)
  * ^ optional: exit_on_click - set to true to exit the form when the button is clicked. ( Also see button.setClose() )
  * state:image_button( x,y,w,h,name,text, image [, exit_on_click] ) create a new button with image.
  * state:item_image_button( x,y,w,h,name,text, item [, exit_on_click] ) create a new button with item as image.
* state:toggle( x,y,w,h,name,list ) - create a new toggle button at x,y with name and possible list of values
* state:label( x,y,name,text ) - create a new label at x,y with name and caption (text)
  * state:vertlabel( x,y,name,text ) - create a new vertical label at x,y with name and caption (text)
* state:field( x,y,w,h,name,label ) - create a new field at x,y with label
  * state:pwdfield( x,y,w,h,name,label ) - create a password field
  * state:textarea( x,y,w,h,name,label ) - create a new textarea
* state:image( x,y,w,h,name,image ) - create an image box
  * state:background( x,y,w,h,name,image ) - create an image box in background
  * state:item_image( x,y,w,h,name,itemname ) - create an item image box
* state:inventory( x,y,w,h,name ) - create an inventory listing (use 'main' as name for the main player inventory)
* state:checkbox( x,y,name,label,selected ) - create a check box.
* state:listbox( x,y,w,h,name,selected, transparent ) - create a list box
* state:dropdown( x,y,w,h,name,selected ) - create a drop down list
* state:container(x,y,name) - Add a container with elements shift relative to x,y
  * state:view(x,y,name) - Add a virtual container (view). element coordinates are ablsolute to the parent view
* state:element( element_type, data ) - Semi-private, create an element with type and data.

### Variables
* state.players - Object to handle players connected to the formspec
  * state.players:connect(playername) - register player is viewing the formspec (should be used only by framework)
  * state.players:disconnect(playername) - remove player from active viewers (should be used only by framework)
  * state.players:get_first() - get the first player, or nil if no players connected
* state.param - The parameters supplied by form:show.
* state.def - The form definition.
* state.location - defines the location the form is assigned - please use it read only
  * state.location.type - defines the assignment type. Values: "player", "inventory", "nodemeta"
  * state.location.player - the assigned player ("player" and "inventory" only)
  * state.location.pos - the assigned node position ("nodemeta" only)

## State Elements

### All elements / abstract
* element:setPosition( x,y ) - change the position
* element:getPosition() - get the current position
* element:setSize( w,h ) - set the size
* element:getSize() - get the size
* element:setBackground(image) - Set the background of element. Please note a size needs to be defined on element
* element:getBackground() - get the current background
* element:setVisible(bool) - set the visibility status (set hidden=>false, unhide=>true or nil)
* element:getVisible() - get the visibility status
* element:setValue(string) - set value for the element, called internally from on_receive_fields
* element:setTooltip(text) - set the tooltip for the button
* element:getTooltip() - get the current tooltip

### Button
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the button
* element:setImage( filename ) - sets the background of the button
* element:getImage() - get the background filename of the button
* element:setItem(item) - Set a registred itemname and convert the button to item_image_button
* element:getItem() - get the current itemname
* element:setClose(bool) - set option (bool) if the button should close the form
* element:getClose() - get the current close setting
* element:click( func(self,state,playername) ) - specify a function to run when the button is clicked (equal to onClick)

### Toggle Button
* element:getText() - get the text of the toggle option
* element:setId( filename ) - sets the selected id
* element:getId() - get the selected id
* element:onToggle( func(self,state,playername) ) - specify a function to run when the value if toggled

### Label
* element:setText( text ) - set the caption of the label
* element:getText() - get the caption of the label

### Image and Background
* element:setImage( image ) - set image
* element:getImage() - get the image

### Checkbox
* element:setValue( bool ) - set the value
* element:getValue() - get the value
* element:onToggle( func(self,state,playername) ) - specify a function to run when the value if toggled

### Field and Text Area
* element:setText( text ) - set the caption of the button
* element:getText() - get the caption of the field
* element:isPassword() - returns true if the field is a password field
* element:isMultiline() - returns true if the field is a miltiline textarea
* element:setCloseOnEnter(bool) - Set the field_close_on_enter string, usually set to false to disable the formspec close on enter
* element:getCloseOnEnter() - Get the field_close_on_enter value
* element:onKeyEnter(func(self, state, playername) - process the Enter key action for this fiels

### List box
* element:onClick( func(self,state,idx,playername) ) - function to run when listbox item idx is clicked
* element:onDoubleClick( func(self,state,idx,playername) ) - function to run when listbox item idx is double clicked
* element:addItem( item ) - appends and item - returns the index for the item
* element:removeItem( idx ) - remove item
* element:getItem( idx ) - get Item idx
* element:popItem() - removes last item and returns
* element:clearItems() - empty the list
* element:setSelected( idx ) - set item selection to idx
* element:getSelected() - get selected item (index)
* element:getSelectedItem() - get selected item (value)

### Drop Down list
* element:onSelect( func(self,state,field,playername) ) - function to run when dropdown entry selected
* element:addItem( item ) - appends and item
* element:removeItem( idx ) - remove item
* element:getItem( idx ) - get Item idx
* element:popItem() - removes last item and returns
* element:clearItems() - empty the dropdown list
* element:setSelected( idx ) - set item selection to idx
* element:getSelected() - get selected item (index)
* element:getSelectedItem() - get selected item (value)

### Inventory listing
* element:setLocation( location ) - set a custom inventory location or nil for the default (current_player)
  * element:usePosition( position ) - use a node metadata attached inventory of the node at the given positon
  * element:useDetached( name ) - use a detached inventory with the given name
  * element:usePlayer( name ) - use a player inventory other than the current player
* element:getLocation() - returns the inventory location (default: current_player)
* element:setList( list ) - set a custom inventory list name or nil for the default (the element's name)
* element:getList() - returns the list name (defaults to the element's name)
* element:setIndex( index ) - set the inventory starting index
* element:getIndex() - returns the inventory starting index

### Custom Code
* element:onSubmit( func(self) ) - on form submit
* element:onBuild( func(self) ) - run every time form is shown. You can set code from here
* element:setCode( code ) - set the formspec code
* element:getCode( code ) - get the formspec code

### Container/View
* element:getContainerState() - returns the container's sub-state to work with or add container elements
