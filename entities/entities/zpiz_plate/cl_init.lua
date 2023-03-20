include("shared.lua")

function ENT:Initialize()
	CreateMaterial("zpiz_pizzaMat", "VertexLitGeneric", {
		["$basetexture"] = "color/white",
		["$model"] = 1,
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1
	})

	self:SetMaterial("!zpiz_pizzaMat")
end

function ENT:Draw()
	self:DrawModel()

	local inView, dist = self:InDistance(125000)
	if (not inView) then return end
		self:Draw_MainInfo()

end

function ENT:DrawTranslucent()
	self:Draw()
end
local function LerpColor(t, c1, c2)
	local c3 = Color(0, 0, 0)
	c3.r = Lerp(t, c1.r, c2.r)
	c3.g = Lerp(t, c1.g, c2.g)
	c3.b = Lerp(t, c1.b, c2.b)
	c3.a = Lerp(t, c1.a, c2.a)

	return c3
end
function ENT:Draw_MainInfo()


	local time = self:GetFoodWaitTime()

	if (time > 0) then

		local pizzaID = self:GetFoodIndex()
		local pizzaData = HFM_Config.FoodTable[pizzaID] or 0

		local maxTime = (pizzaData.CookingTime or 0) + rp.cfg.CustomerExtraWaitTime

		local Pos = self:GetPos() + self:GetForward() * -15 + Vector(0, 0, 25)
		Pos = Pos + self:GetUp() * math.abs(math.sin(CurTime() * 2) * 5)
		local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)


		time = math.Round(time - CurTime())
		local progress = (1 / maxTime) * time
		local c = LerpColor(progress, Color(255, 0, 0, 255), Color(0, 255, 0, 255))

		cam.Start3D2D(Pos , Ang, 0.1)
			DrawBText(time .. " секунд", "MetaHub.Font50", "MetaHub.Font50", 0, -50,  c, 1,1)
			DrawBText(pizzaData.Name, "MetaHub.Font.Bold67", "MetaHub.Font.Bold67", 0, -100,  color_white, 1,1 )
		cam.End3D2D()
	end
end
