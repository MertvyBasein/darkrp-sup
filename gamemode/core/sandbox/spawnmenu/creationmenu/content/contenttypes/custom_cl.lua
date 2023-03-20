local AddCustomizableNode = nil

local function SetupCustomNode(node, pnlContent, needsapp)

	node.OnModified = function()
		hook.Run("SpawnlistContentChanged")
	end

	node.SetupCopy = function(self, copy)

		SetupCustomNode(copy, pnlContent)

		self:DoPopulate()
		copy.PropPanel = self.PropPanel:Copy()

		copy.PropPanel:SetVisible(false)
		copy.PropPanel:SetTriggerSpawnlistChange(true)

		copy.DoPopulate = function() end

	end

	node.DoPopulate = function(self)

		if (!self.PropPanel) then

			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(true)

		end

	end

	node.DoClick = function(self)

		self:DoPopulate()
		pnlContent:SwitchPanel(self.PropPanel)

	end

end

local function AddCustomizableNode(pnlContent, name, icon, parent, needsapp)

	local node = parent:AddNode(name, icon)

	SetupCustomNode(node, pnlContent, needsapp)

	return node;

end

local blacklist = {
	//['vehicles'] = true,
	['weapons'] = true,
	['characters'] = true,
	['items'] = true
}

local function AddPropsOfParent(pnlContent, node, parentid)
	local Props = spawnmenu.GetPropTable()

	for FileName, Info in SortedPairs(Props) do

		if (parentid != Info.parentid) or blacklist[Info.name:lower()] then continue end

		local pnlnode = AddCustomizableNode(pnlContent, Info.name, Info.icon, node, Info.needsapp)
		pnlnode:SetExpanded(true)
		pnlnode.DoPopulate = function(self)

			if (self.PropPanel) then return end

			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)

			for i, object in pairs(Info.contents) do

				local cp = spawnmenu.GetContentType(object.type)
				if (cp ) then cp(self.PropPanel, object) end

			end

			self.PropPanel:SetTriggerSpawnlistChange(true)

		end

		AddPropsOfParent(pnlContent, pnlnode, Info.id)

	end

end

hook("PopulateContent", "AddCustomContent", function(pnlContent, tree, node)

	local node = AddCustomizableNode(pnlContent, "#spawnmenu.category.your_spawnlists", "", tree)
	node:SetDraggableName("CustomContent")

	--
	-- Save the spawnlist when children drag and dropped
	--
	node.OnModified = function()
		hook.Run("SpawnlistContentChanged")
	end

	AddPropsOfParent(pnlContent, node, 0)

	node:SetExpanded(true)
	node:MoveToBack();

	CustomizableSpawnlistNode = node;

	-- Select the first panel
	local FirstNode = node:GetChildNode(0)
	if (IsValid(FirstNode)) then
		FirstNode:InternalDoClick()
	end
end)
