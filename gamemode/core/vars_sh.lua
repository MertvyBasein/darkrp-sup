rp.JobTypes = {
    reix = 'reix',
    police = 'reix',
    ss = 'reix',
    rkka = 'cccr',
    usa = 'usa',
    nkvd = 'cccr',
}

nw.Register("Bonus")
    :Write(net.WriteTable)
    :Read(net.ReadTable)
    :SetPlayer()

nw.Register("BPChallanges")
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetPlayer()

nw.Register("Diplomacy")
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetGlobal()

nw.Register("BPClaimed")
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetPlayer()

nw.Register("DailyStage")
	:Write(net.WriteUInt, 6)
	:Read(net.ReadUInt, 6)
	:SetPlayer()

nw.Register("Skills")
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetPlayer()

nw.Register 'Freq'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetLocalPlayer()

nw.Register 'Privilege'
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetLocalPlayer()

-- Global vars
nw.Register 'JobUnlocks'
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetLocalPlayer()

nw.Register 'Static'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetPlayer()

nw.Register 'AdminMode'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'EventMode'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'PointsHistory'
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetPlayer()

nw.Register 'NLR'
	:Write(function(v)
		net.WriteUInt(v.Time, 32)
		net.WriteVector(v.Pos)
	end)
	:Read(function()
		return {
			Time = net.ReadUInt(32),
			Pos = net.ReadVector()
		}
	end)
	:SetLocalPlayer()

nw.Register 'bonustime'
	:Write(net.WriteUInt, 8)
	:Read(net.ReadUInt, 8)
	:SetLocalPlayer()

nw.Register 'TheLaws'
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetGlobal()

nw.Register 'lockdown'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetGlobal()

nw.Register 'lockdown_reason'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetGlobal()

nw.Register 'lockdown_left'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetGlobal()

nw.Register 'lockdown_kd'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetGlobal()

-- Player Vars
nw.Register 'Report'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'rp.LastReport'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetPlayer()

nw.Register 'rp.ReportClaimed'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'HasGunlicense'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'Name'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()

nw.Register 'Money'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetLocalPlayer()

nw.Register 'BankMoney'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetLocalPlayer()

nw.Register 'B'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetLocalPlayer()

nw.Register 'Energy'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)
	:SetLocalPlayer()

nw.Register 'job'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer()

nw.Register 'Hat'
	:Write(net.WriteUInt, 6)
	:Read(net.ReadUInt, 6)
	:SetPlayer()

nw.Register 'ShareProps'
	:Write(net.WriteTable)
	:Read(net.ReadTable)
	:SetLocalPlayer()

nw.Register 'PropIsOwned'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:Filter(function(self)
		return self:CPPIGetOwner()
	end)
	:SetNoSync()

nw.Register 'IsWanted'
	:Write(net.WriteBool)
	:Read(net.ReadBool)
	:SetPlayer()

nw.Register 'WantedReason'
	:Write(net.WriteString)
	:Read(net.ReadString)
	:SetPlayer() // ранее Local

nw.Register 'ArrestedInfo'
	:Write(function(v)
		net.WriteUInt(v.Release, 32)
	end)
	:Read(function()
		return {
			Release = net.ReadUInt(32)
		}
	end)
	:SetLocalPlayer()

nw.Register 'DoorID'
	:Write(net.WriteUInt, 32)
	:Read(net.ReadUInt, 32)