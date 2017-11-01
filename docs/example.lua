
local s = smartfs.create("smartfs:form", function(state)
	state:size(10,7)
	state:label(2,0,"lbl","SmartFS example formspec!")
	local usr = state:label(7,0,"user","")
	if state.location.type ~= "nodemeta" then -- display location user name if it is user or inventory formspec
		usr:setText(state.location.player)
	end
	usr:setSize(3,0.5)
	usr:setBackground("halo.png")
	local textbox = state:field(7.25,1.25,3,1,"txt","Textbox")
	textbox:setCloseOnEnter(false)
	textbox:onKeyEnter(function(self, state, playername)
		print("Enter pressed in Textbox field")
	end)

	state:image(0,0,2,2,"img","default_stone.png")
	local toggle = state:toggle(0,2,3,1,"tg",{"plenty..","of..","custom..","elements"})
	toggle:onToggle(function(self, state, player)
		if state:get("ta"):getVisible() == false then
			state:get("ta"):setVisible()
		else
			state:get("ta"):setVisible(false)
		end
	end)

	state:checkbox(2,1,"c","Easy code",true)
	state:vertlabel(0,3.5,"vlbl","Example!")
	local area = state:textarea(1,3.5,9,4,"ta","Code:")
	local res = [[
smartfs.create("smartfs:form",function(state)
	state:size(10,7)
	state:label(2,0,"lbl","SmartFS example formspec!")
	state:field(7,1,3,1,"txt","Textbox")
	state:image(0,0,2,2,"img","default_stone.png")
	state:toggle(0,2,3,1,"tg",{"plenty..","of..","custom..","elements"})
	state:checkbox(2,1,"c","Easy code",true)
end)]]

	area:setText(res)

	state:onInput(function(self, fields, user) -- processed on any (supported) input
		if state.location.type == "nodemeta" then
			usr:setText(user) -- display current user who sent the data
		end
	end)
	return true
end)

local l = smartfs.create("smartfs:load", function(state)
	state:load(minetest.get_modpath("smartfs").."/docs/example.smartfs")
	state:get("btn"):click(function(self,state)
		print("Button clicked!")
	end)
	return true
end)

smartfs.add_to_inventory(l,"icon.png","SmartFS")

minetest.register_chatcommand("sfs_s", {
	params = "",
	description = "SmartFS test formspec 1: basics",
	func = function(name, param)
		s:show(name)
	end,
})
minetest.register_chatcommand("sfs_l", {
	params = "",
	description = "SmartFS test formspec 2: loading",
	func = function(name, param)
		l:show(name)
	end,
})

minetest.register_chatcommand("sfs_d", {
	params = "",
	description = "SmartFS test formspec 3: dynamic",
	func = function(name, param)
		local state = smartfs.dynamic("smartfs:dyn_form", name)
		state:load(minetest.get_modpath("smartfs").."/docs/example.smartfs")
		state:get("btn"):click(function(self,state)
			print("Button clicked!")
		end)
		state:show()
	end,
})

minetest.register_chatcommand("sfs_lc", {
	params = "",
	description = "SmartFS test formspec 4: smartfs.create error catching",
	func = function(name, param)
		smartfs.create("asdinas", function() end)
	end
})

minetest.register_node("smartfs:demoblock", {
	description = "SmartFS Demo block",
	groups = {cracky = 3},
	tiles = {"demo.png"},
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		s:attach_to_node(pos, placer)
	end,
	on_receive_fields = smartfs.nodemeta_on_receive_fields
})
