dofile(minetest.get_modpath("smartfs").."/smartfs.lua")

s = smartfs.create("smartfs:form",function(state)
	state:size(10,7)
	state:label(2,0,"lbl","SmartFS example formspec!")
	state:field(7,1,3,1,"txt","Textbox")
	state:image(0,0,2,2,"img","default_stone.png")
	state:toggle(0,2,3,1,"tg",{"plenty..","of..","custom..","elements"})
	state:checkbox(2,1,"c","Easy code",true)
	local res = "smartfs.create(\"smartfs:form\",function(state)\n"
	res = res .. "\tstate:size(10,7)\n"
	res = res .. "\tstate:label(2,0,\"lbl\",\"SmartFS example formspec!\")\n"
	res = res .. "\tstate:field(7,1,3,1,\"txt\",\"Textbox\")\n"
	res = res .. "\tstate:image(0,0,2,2,\"img\",\"default_stone.png\")\n"
	res = res .. "\tstate:toggle(0,2,3,1,\"tg\",{\"plenty..\",\"of..\",\"custom..\",\"elements\"})\n"
	res = res .. "\tstate:checkbox(2,1,\"c\",\"Easy code\",true)\n"
	res = res .. "end)"
	state:textarea(1,3.5,9,4,"ta","Code:"):setText(res)
	return true
end)

l = smartfs.create("smartfs:load",function(state)
	state:load(minetest.get_modpath("smartfs").."/example.smartfs")
	state:get("btn"):onClick(function(self,state)
		print("Button clicked!")
	end)
	return true
end)

minetest.register_chatcommand("s", {
	params = "",
	description = "SmartFS test formspec 1: basics",
	func = function(name, param)
		s:show(name)
	end,
})
minetest.register_chatcommand("l", {
	params = "",
	description = "SmartFS test formspec 2: loading",
	func = function(name, param)
		l:show(name)
	end,
})
