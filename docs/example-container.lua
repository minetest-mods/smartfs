-----------------------------------------------------------------
--- Exemple nested container
-----------------------------------------------------------------

local header_form_function = function(state)
	local label = state:label(0,0,"lbl","SmartFS formspec using nested containers")
	label:setSize(10,0.5)
	state:toggle(0,0.5,3,1,"img_tog",{"img on","img off"}):onToggle(function(self,func)
		if state:get("img"):getVisible() then
			state:get("img"):setVisible(false)
		else
			state:get("img"):setVisible(true)
		end
	end)
	local tog1 = state:toggle(3,0.5,3,1,"container1_tog",{"container1 on","container1 off"})
	tog1:onToggle(function(self,func)
		if state:get("container1"):getVisible() then
			state:get("container1"):setVisible(false)
		else
			state:get("container1"):setVisible()
		end
	end)
	state:toggle(6,0.5,3,1,"container2_tog",{"container2 on","container2 off"}):onToggle(function(self,func)
		local container2 = state:get("container1"):getContainerState():get("container2")
		if container2:getVisible() then
			container2:setVisible(false)
		else
			container2:setVisible()
		end
	end)
end

local main_form_function = function(state)
	-- load the header inplace to the current state
	state:size(10,10)
	header_form_function(state)
	local image = state:image(0,2,1,1,"img","default_ladder_steel.png")
	state:toggle(0,3,3,1,"tg",{"plenty..","of..","custom..","elements"})
	state:onInput(function(state, fields, player)
		print("hook 1")
	end)

	local container1_element = state:view(0, 4, "container1")
	container1_element:setBackground("default_stone.png")
	local sub_state1 = container1_element:getContainerState()
	sub_state1:size(10,6)
	-- all x/y values needs to be "real"
	sub_state1:image(0,4,1,1,"img","default_ladder_wood.png")
	sub_state1:toggle(0,5,3,1,"tg",{"plenty..","of..","custom..","elements"})
	sub_state1:onInput(function(state, fields, player)
		print("sub_state1 hook 2")
	end)

	local container2_element = sub_state1:container(0, 7, "container2") --nested to sub_state1

	container2_element:setBackground("default_brick.png")
	local sub_state2 = container2_element:getContainerState()
	sub_state2:size(10,3)
	-- all the x/y values in relation to container
	sub_state2:image(0,0,1,1,"img", "default_stone.png")
	local tog2 = sub_state2:toggle(0,1,3,1,"tg",{"second..","toggle..","with..","same..","name.."})
	tog2:setBackground("default_gold_block.png")
	sub_state2:onInput(function(state, fields, player)
		print("sub_state2 hook 1")
	end)
end


local form_container = smartfs.create("smartfs:container_form",main_form_function)

minetest.register_chatcommand("sfs_v", {
	params = "",
	description = "SmartFS test formspec with nested containers",
	func = function(name, param)
		form_container:show(name)
	end,
})


-----------------------------------------------------------------
--- Exemple tabbed container
-----------------------------------------------------------------
local tab1_def = function(state)
	state:label(0,0,"lbl","Tab1 Content")
	state:toggle(0,1,2,2,"tog",{"plenty..","of..","custom..","elements"})
end

local tab2_def = function(state)
	state:label(0,0,"lbl","Tab2 Content")
	state:field(0.5,2,4,1,"txt","Textbox")
	local listbox = state:listbox(0,3,9,5,"list")
	listbox:addItem("First entry")
	listbox:addItem("Second entry")
end

local tab3_def = function(state)
	state:label(0,0,"lbl","Tab3 Content")
	local area = state:textarea(0.5,1,9,5,"ta","Text:")
	area:setText("Hallo")
end


local tab_form_function = function(state)
	state:size(10,10)
	local tab_element = state:container(0, 0, "tab_container")
	local tab_state = tab_element:getContainerState()
	tab_state:size(10,10)

	local tab_controller = {
		_tabs = {},
		set_active = function(self, tabname)
			for name, def in pairs(self._tabs) do
				if name == tabname then
					def.button:setBackground("default_gold_block.png")
					def.container:setVisible()
				else
					def.button:setBackground(nil)
					def.container:setVisible(false)
				end
			end
		end,
		tab_add = function(self, name, def)
			self._tabs[name] = def
		end,
	}
 
	local tab1 = {}
	tab1.button = tab_state:button(0,0,2,1,"tab1_btn","Tab 1")
	tab1.button:onClick(function(self)
		tab_controller:set_active("tab1")
	end)
	tab1.container = tab_state:container(0,1,"tab1_container")
	tab1.containerstate = tab1.container:getContainerState()
	tab1_def(tab1.containerstate)
	tab1.containerstate:size(10,9)
	tab_controller:tab_add("tab1", tab1)

	local tab2 = {}
	tab2.button = tab_state:button(2,0,2,1,"tab2_btn","Tab 2")
	tab2.button:onClick(function(self)
		tab_controller:set_active("tab2")
	end)
	tab2.container = tab_state:container(0,1,"tab2_container")
	tab2.containerstate = tab2.container:getContainerState()
	tab2_def(tab2.containerstate)
	tab2.containerstate:size(10,9)
	tab_controller:tab_add("tab2", tab2)

	local tab3 = {}
	tab3.button = tab_state:button(4,0,2,1,"tab3_btn","Tab 3")
	tab3.button:onClick(function(self)
		tab_controller:set_active("tab3")
	end)
	tab3.container = tab_state:container(0,1,"tab3_container")
	tab3.containerstate = tab3.container:getContainerState()
	tab3_def(tab3.containerstate)
	tab3.containerstate:size(10,9)
	tab_controller:tab_add("tab3", tab3)

	tab_controller:set_active("tab1") --default tab
end


local form_tab = smartfs.create("smartfs:container_tab", tab_form_function)
minetest.register_chatcommand("sfs_t", {
	params = "",
	description = "SmartFS test formspec with tabbed containers",
	func = function(name, param)
		form_tab:show(name)
	end,
})

--smartfs.set_player_inventory(form_tab)
