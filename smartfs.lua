---------------------------
-- SmartFS: Smart Formspecs
--    by Rubenwardy
---------------------------

smartfs = {
	_fdef = {},
	_edef = {},
	opened = {}
}

-----------------------------------------------------------------
--------------------------  THE API  ----------------------------
-----------------------------------------------------------------

-- Register forms and elements
function smartfs.create(name,onload)
	if smartfs._fdef[name] then
		throw("Form "..name.." already exists!")
	end
	
	smartfs._fdef[name] = {
		_reg = onload,
		name = name,
		show = smartfs._show_
	}
	
	return smartfs._fdef[name]
end
function smartfs.element(name,data)
	if smartfs._edef[name] then
		throw("Element type "..name.." already exists!")
	end
	smartfs._edef[name] = data
	return smartfs._edef[name]
end

-- Show a formspec to a user
function smartfs._show_(form,player)
	local state = {
		_ele = {},
		def = form,
		player = player,
		get = function(self,name)
			return self._ele[name]
		end,
		close = function(self)
			self.closed = true
		end,
		size = function(self,w,h)
			self._size = {w=w,h=h}
		end,
		_show_ = function(self)
			local res = ""
			if self._size then
				res = "size["..self._size.w..","..self._size.h.."]"
			end
			for key,val in pairs(self._ele) do
				res = res .. val:build()
			end
			print ("FS: "..res)
			minetest.show_formspec(player,form.name,res)
			return res
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
		button = function(self,x,y,w,h,name,text)
			return self:element("button",{pos={x=x,y=y},size={w=w,h=h},name=name,value=text})
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
		element = function(self,typen,data)
			local type = smartfs._edef[typen]
			
			if not type then
				throw("Element type "..typen.." does not exist!")
			end

			if self._ele[data.name] then
				throw("Element "..data.name.." already exists")
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
	if form._reg(state)~=false then
		smartfs.opened[player] = state
		state:_show_()
	end
end

-- Receive fields from formspec
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	if smartfs.opened[name] then
		if smartfs.opened[name].def.name == formname then
			local state = smartfs.opened[name]
			for key,val in pairs(fields) do
				if state._ele[key] then
					state._ele[key].data.value = val
				end
			end
			for key,val in pairs(state._ele) do
				if val.submit then
					val:submit(fields)
				end
			end
			if state.closed ~= true then
				state:_show_()
			else
				minetest.show_formspec(name,"","size[5,1]label[0,0;Formspec closing not yet created!]")
				smartfs.opened[name] = nil
			end
			return true
		else
			smartfs.opened[name] = nil
		end
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
	end,
	submit = function(self,fields)
		if fields[self.name] and self._click then
			self:_click(self.root)
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