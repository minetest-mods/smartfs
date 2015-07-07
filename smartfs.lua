---------------------------
-- SmartFS: Smart Formspecs
--    by Rubenwardy
---------------------------

smartfs = {
	_fdef = {},
	_edef = {},
	opened = {},
	inv = {}
}

-- the smartfs() function
function smartfs.__call(self, name)
	return smartfs._fdef[name]
end

-- Register forms and elements
function smartfs.create(name,onload)
	if smartfs._fdef[name] then
		error("SmartFS - (Error) Form "..name.." already exists!")
	end
	if smartfs.loaded and not smartfs._loaded_override then
		error("SmartFS - (Error) Forms should be declared while the game loads.")
	end

	smartfs._fdef[name] = {
		_reg = onload,
		name = name,
		show = smartfs._show_
	}

	return smartfs._fdef[name]
end
function smartfs.override_load_checks()
	smartfs._loaded_override = true
end

minetest.after(0, function()
	smartfs.loaded = true
end)
function smartfs.dynamic(name,player)
	if not smartfs._dynamic_warned then
		smartfs._dynamic_warned = true
		print("SmartFS - (Warning) On the fly forms are being used. May cause bad things to happen")
	end
	local state = smartfs._makeState_({name=name},player,nil,false)
	state.show = state._show_
	smartfs.opened[player] = state
	return state
end
function smartfs.element(name,data)
	if smartfs._edef[name] then
		error("SmartFS - (Error) Element type "..name.." already exists!")
	end
	smartfs._edef[name] = data
	return smartfs._edef[name]
end

function smartfs.inventory_mod()
	if unified_inventory then
		return "unified_inventory"
	elseif inventory_plus then
		return "inventory_plus"
	else
		return nil
	end
end

function smartfs.add_to_inventory(form,icon,title)
	if unified_inventory then
		unified_inventory.register_button(form.name, {
			type = "image",
			image = icon,
		})
		unified_inventory.register_page(form.name, {
			get_formspec = function(player, formspec)
				local name = player:get_player_name()
				local opened = smartfs._show_(form, name, nil, true)
				return {formspec = opened:_getFS_(false)}
			end
		})
		return true
	elseif inventory_plus then
		minetest.register_on_joinplayer(function(player)
			inventory_plus.register_button(player, form.name, title)
		end)
		minetest.register_on_player_receive_fields(function(player, formname, fields)
			if formname == "" and fields[form.name] then
				local name = player:get_player_name()
				local opened = smartfs._show_(form, name, nil, true)
				inventory_plus.set_inventory_formspec(player, opened:_getFS_(true))
			end
		end)
		return true
	else
		return false
	end
end

function smartfs._makeState_(form,player,params,is_inv)
	return {
		_ele = {},
		def = form,
		player = player,
		param = params,
		is_inv = is_inv,
		get = function(self,name)
			return self._ele[name]
		end,
		close = function(self)
			self.closed = true
		end,
		size = function(self,w,h)
			self._size = {w=w,h=h}
		end,
		_getFS_ = function(self,size)
			local res = ""
			if self._size and size then
				res = "size["..self._size.w..","..self._size.h.."]"
			end
			for key,val in pairs(self._ele) do
				res = res .. val:build()
			end
			return res
		end,
		_show_ = function(self)
			if self.is_inv then
				if unified_inventory then
					unified_inventory.set_inventory_formspec(minetest.get_player_by_name(self.player), self.def.name)
				elseif inventory_plus then
					inventory_plus.set_inventory_formspec(minetest.get_player_by_name(self.player), self:_getFS_(true))
				end
			else
				local res = self:_getFS_(true)
				minetest.show_formspec(player,form.name,res)
			end
		end,
		load = function(self,file)
			local file = io.open(file, "r")
			if file then
				local table = minetest.deserialize(file:read("*all"))
				if type(table) == "table" then
					if table.size then
						self._size = table.size
					end
					for key,val in pairs(table.ele) do
						self:element(val.type,val)
					end
					return true
				end
			end
			return false
		end,
		save = function(self,file)
			local res = {ele={}}

			if self._size then
				res.size = self._size
			end

			for key,val in pairs(self._ele) do
				res.ele[key] = val.data
			end

			local file = io.open(file, "w")
			if file then
				file:write(minetest.serialize(res))
				file:close()
				return true
			end
			return false
		end,
		button = function(self,x,y,w,h,name,text,exitf)
			if exitf == nil then exitf = false end
			return self:element("button",{pos={x=x,y=y},size={w=w,h=h},name=name,value=text,closes=exitf})
		end,
		label = function(self,x,y,name,text)
			return self:element("label",{pos={x=x,y=y},name=name,value=text})
		end,
		toggle = function(self,x,y,w,h,name,list)
			return self:element("toggle",{pos={x=x,y=y},size={w=w,h=h},name=name,id=1,list=list})
		end,
		field = function(self,x,y,w,h,name,label)
			return self:element("field",{pos={x=x,y=y},size={w=w,h=h},name=name,value="",label=label})
		end,
		pwdfield = function(self,x,y,w,h,name,label)
			local res = self:element("field",{pos={x=x,y=y},size={w=w,h=h},name=name,value="",label=label})
			res:isPassword(true)
			return res
		end,
		textarea = function(self,x,y,w,h,name,label)
			local res = self:element("field",{pos={x=x,y=y},size={w=w,h=h},name=name,value="",label=label})
			res:isMultiline(true)
			return res
		end,
		image = function(self,x,y,w,h,name,img)
			return self:element("image",{pos={x=x,y=y},size={w=w,h=h},name=name,value=img})
		end,
		checkbox = function(self,x,y,name,label,selected)
			return self:element("checkbox",{pos={x=x,y=y},name=name,value=selected,label=label})
		end,
		listbox = function(self,x,y,w,h,name)
			return self:element("list", { pos={x=x,y=y}, size={w=w,h=h}, name=name })
		end,
		inventory = function(self,x,y,w,h,name)
			return self:element("inventory", { pos={x=x,y=y}, size={w=w,h=h}, name=name })
		end,
		element = function(self,typen,data)
			local type = smartfs._edef[typen]

			if not type then
				error("Element type "..typen.." does not exist!")
			end

			if self._ele[data.name] then
				error("Element "..data.name.." already exists")
			end
			data.type = typen

			local ele = {
				name = data.name,
				root = self,
				data = data,
				remove = function(self)
					self.root._ele[self.name] = nil
				end
			}

			for key,val in pairs(type) do
				ele[key] = val
			end

			self._ele[data.name] = ele

			return self._ele[data.name]
		end
	}
end

-- Show a formspec to a user
function smartfs._show_(form, player, params, is_inv)
	local state = smartfs._makeState_(form, player, params, is_inv)
	state.show = state._show_
	if form._reg(state)~=false then
		if not is_inv then
			smartfs.opened[player] = state
			state:_show_()
		else
			smartfs.inv[player] = state
		end
	end
	return state
end

-- Receive fields from formspec
local function _sfs_recieve_(state,name,fields)
	if (fields.quit == "true") then
		if not state.is_inv then
			smartfs.opened[name] = nil
		end
		return true
	end

	for key,val in pairs(fields) do
		if state._ele[key] then
			state._ele[key].data.value = val
		end
	end
	for key,val in pairs(state._ele) do
		if val.submit then
			if (val:submit(fields)==true) then
				return true
			end
		end
	end
	if state.closed ~= true then
		state:_show_()
	else
		minetest.show_formspec(name,"","size[5,1]label[0,0;Formspec closing not yet created!]")
		if not state.is_inv then
			smartfs.opened[name] = nil
		end
	end
	return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if smartfs.opened[name] and not smartfs.opened[name].is_inv then
		if smartfs.opened[name].def.name == formname then
			local state = smartfs.opened[name]
			return _sfs_recieve_(state,name,fields)
		else
			smartfs.opened[name] = nil
		end
	elseif smartfs.inv[name] and smartfs.inv[name].is_inv then
		local state = smartfs.inv[name]
		_sfs_recieve_(state,name,fields)
	end
	return false
end)


-----------------------------------------------------------------
-------------------------  ELEMENTS  ----------------------------
-----------------------------------------------------------------

smartfs.element("button",{
	build = function(self)
		if self.data.img then
			return "image_button["..
				self.data.pos.x..","..self.data.pos.y..
				";"..
				self.data.size.w..","..self.data.size.h..
				";"..
				self.data.img..
				";"..
				self.name..
				";"..
				self.data.value..
				"]"
		else
			if self.data.closes then
				return "button_exit["..
					self.data.pos.x..","..self.data.pos.y..
					";"..
					self.data.size.w..","..self.data.size.h..
					";"..
					self.name..
					";"..
					self.data.value..
					"]"
			else
				return "button["..
					self.data.pos.x..","..self.data.pos.y..
					";"..
					self.data.size.w..","..self.data.size.h..
					";"..
					self.name..
					";"..
					self.data.value..
					"]"
			end
		end
	end,
	submit = function(self,fields,state)
		if fields[self.name] and self._click then
			self:_click(self.root)
		end

		if self.data.closes then
			return true
		end
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	onClick = function(self,func)
		self._click = func
	end,
	click = function(self,func)
		self._click = func
	end,
	setText = function(self,text)
		self.data.value = text
	end,
	getText = function(self)
		return self.data.value
	end,
	setImage = function(self,image)
		self.data.img = image
	end,
	getImage = function(self)
		return self.data.img
	end,
	setClose = function(self,bool)
		self.data.closes = bool
	end
})

smartfs.element("toggle",{
	build = function(self)
		return "button["..
			self.data.pos.x..","..self.data.pos.y..
			";"..
			self.data.size.w..","..self.data.size.h..
			";"..
			self.name..
			";"..
			self.data.list[self.data.id]..
			"]"
	end,
	submit = function(self,fields)
		if fields[self.name] then
			self.data.id = self.data.id + 1
			if self.data.id > #self.data.list then
				self.data.id = 1
			end
			if self._tog then
				self:_tog(self.root)
			end
		end
	end,
	onToggle = function(self,func)
		self._tog = func
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	setId = function(self,id)
		self.data.id = id
	end,
	getId = function(self)
		return self.data.id
	end,
	getText = function(self)
		return self.data.list[self.data.id]
	end
})

smartfs.element("label",{
	build = function(self)
		return "label["..
			self.data.pos.x..","..self.data.pos.y..
			";"..
			self.data.value..
			"]"
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setText = function(self,text)
		self.data.value = text
	end,
	getText = function(self)
		return self.data.value
	end
})

smartfs.element("field",{
	build = function(self)
		if self.data.ml then
			return "textarea["..
				self.data.pos.x..","..self.data.pos.y..
				";"..
				self.data.size.w..","..self.data.size.h..
				";"..
				self.name..
				";"..
				self.data.label..
				";"..
				self.data.value..
				"]"
		elseif self.data.pwd then
			return "pwdfield["..
				self.data.pos.x..","..self.data.pos.y..
				";"..
				self.data.size.w..","..self.data.size.h..
				";"..
				self.name..
				";"..
				self.data.label..
				"]"
		else
			return "field["..
				self.data.pos.x..","..self.data.pos.y..
				";"..
				self.data.size.w..","..self.data.size.h..
				";"..
				self.name..
				";"..
				self.data.label..
				";"..
				self.data.value..
				"]"
		end
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	setText = function(self,text)
		self.data.value = text
	end,
	getText = function(self)
		return self.data.value
	end,
	isPassword = function(self,bool)
		self.data.pwd = bool
	end,
	isMultiline = function(self,bool)
		self.data.ml = bool
	end
})

smartfs.element("image",{
	build = function(self)
		return "image["..
			self.data.pos.x..","..self.data.pos.y..
			";"..
			self.data.size.w..","..self.data.size.h..
			";"..
			self.data.value..
			"]"
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	setImage = function(self,text)
		self.data.value = text
	end,
	getImage = function(self)
		return self.data.value
	end
})

smartfs.element("checkbox",{
	build = function(self)
		if self.data.value then
			return "checkbox["..
				self.data.pos.x..","..self.data.pos.y..
				";"..
				self.name..
				";"..
				self.data.label..
				";true]"
		else
			return "checkbox["..
				self.data.pos.x..","..self.data.pos.y..
				";"..
				self.name..
				";"..
				self.data.label..
				";false]"
		end
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	setText = function(self,text)
		self.data.value = text
	end,
	getText = function(self)
		return self.data.value
	end
})

smartfs.element("list",{
        build = function(self)
                local listformspec = "textlist["..
                                     self.data.pos.x..","..self.data.pos.y..
                                     ";"..
                                     self.data.size.w..","..self.data.size.h..
                                     ";"..
                                     self.data.name..
                                     ";"

                --loop through the list's items and add them to the formspec
		if not self.data.items then
			self.data.items = {" "}
		end
                for i,value in ipairs(self.data.items) do
                    listformspec = listformspec..value..","
                end
                listformspec = string.sub(listformspec, 0, -2) --removes extra ,
                --close out the list items section
                listformspec = listformspec..";"

                --TODO support selected idx and transparency

                --close formspec definition and return formspec
                listformspec = listformspec.."]"
                return listformspec
        end,
        submit = function(self,fields)
                if fields[self.name] then
                    local _type = string.sub(fields[self.data.name],1,3)
                    local index = string.sub(fields[self.data.name],5)
                    if _type == "CHG" and self._click then
                        self:_click(self.root, index)
                    elseif _type == "DCL" and self._doubleClick then
                        self:_doubleClick(self.root, index)
                    end
                end
        end,
	onClick = function(self, func)
		self._click = func
	end,
	click = function(self, func)
		self._click = func
	end,
	onDoubleClick = function(self, func)
		self._doubleClick = func
	end,
	doubleclick = function(self, func)
		self._doubleClick = func
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	addItem = function(self, item)
		if not self.data.items then
			self.data.items = {" "}
		end
		table.insert(self.data.items, item)
	end,
	removeItem = function(self,idx)
		if not self.data.items then
			self.data.items = {" "}
		end
		table.remove(self.data.items,idx)
	end,
	popItem = function(self)
		if not self.data.items then
			self.data.items = {" "}
		end
		local item = self.data.items[#self.data.items]
		table.remove(self.data.items)
		return item
	end
})

smartfs.element("inventory",{
	build = function(self)
		return "list["..
			(self.data.location or "current_player") ..
			";"..
			self.name..
			";"..
			self.data.pos.x..","..self.data.pos.y..
			";"..
			self.data.size.w..","..self.data.size.h..
			";"..
			(self.data.index or "") ..
			"]"
	end,
	setPosition = function(self,x,y)
		self.data.pos = {x=x,y=y}
	end,
	getPosition = function(self,x,y)
		return self.data.pos
	end,
	setSize = function(self,w,h)
		self.data.size = {w=w,h=h}
	end,
	getSize = function(self,x,y)
		return self.data.size
	end,
	-- available inventory locations
	-- "current_player": Player to whom the menu is shown
	-- "player:<name>": Any player
	-- "nodemeta:<X>,<Y>,<Z>": Any node metadata
	-- "detached:<name>": A detached inventory
	-- "context" does not apply to smartfs, since there is no node-metadata as context available
	setLocation = function(self,location)
		self.data.location = location
	end,
	getLocation = function(self)
		return self.data.location or "current_player"
	end,
	usePosition = function(self, pos)
		self.data.location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z)
	end,
	usePlayer = function(self, name)
		self.data.location = "player:" .. name
	end,
	useDetached = function(self, name)
		self.data.location = "detached:" .. name
	end,
	setIndex = function(self,index)
		self.data.index = index
	end,
	getIndex = function(self)
		return self.data.index
	end
})

smartfs.element("code",{
	build = function(self)
		if self._build then
			self:_build()
		end

		return self.data.code
	end,
	submit = function(self,fields)
		if self._sub then
			self:_sub(fields)
		end
	end,
	onSubmit = function(self,func)
		self._sub = func
	end,
	onBuild = function(self,func)
		self._build = func
	end,
	setCode = function(self,code)
		self.data.code = code
	end,
	getCode = function(self)
		return self.data.code
	end
})
