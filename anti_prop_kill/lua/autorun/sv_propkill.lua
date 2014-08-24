if (!SERVER) then return; end

local function notify(text)
	for k,v in ipairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTTALK, text);
	end
end

hook.Add("PhysgunPickup", "ZGPropKilLPickup", function(ply, ent)
	if (ent:GetClass() != "prop_physics") then return; end
	
	ent.oldColor = ent:GetColor();
	ent.oldMat = ent:GetMaterial();
	
	ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 100));
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
end)

hook.Add("PhysgunDrop", "ZGPropKilLDrop", function(ply, ent)	
end)

local function freezeReal(ent)

	if (timer.Exists(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal")) then
		timer.Destroy(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal");
	end
	
	ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 255));
	ent:SetMaterial(ent.oldMat);
	ent:SetCollisionGroup(COLLISION_GROUP_NONE);
	
end

local function waitForPlayersToLeave(ent)
	timer.Create(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal", 1, 0, function()
		local min = ent:LocalToWorld(ent:OBBMins());
		local max = ent:LocalToWorld(ent:OBBMaxs());
		local entities = ents.FindInBox(min, max);
		for k,v in ipairs(entities) do
			if (v:IsPlayer()) then
				return;
			end
		end
		
		freezeReal(ent);
	end)
end

hook.Add("OnPhysgunFreeze", "ZGPropKillFreeze", function(weap, physobj, ent, ply)
	if (ent:GetClass() != "prop_physics") then return; end
	
	local min = ent:LocalToWorld(ent:OBBMins());
	local max = ent:LocalToWorld(ent:OBBMaxs());
	local foundEnts = ents.FindInBox(min, max);
	
	for k,v in ipairs(foundEnts) do
		if (v:IsPlayer()) then
			waitForPlayersToLeave(ent);
			return;
		end
	end	
	
	freezeReal(ent);
end)

hook.Add("OnEntityCreated", "ZGPropKillSpawnProp", function(ent)
	if (ent:GetClass() != "prop_physics") then return; end
	
	ent.oldColor = ent.oldColor or ent:GetColor();
	ent.oldMat = ent.oldMat or ent:GetMaterial();
	
	ent:SetRenderMode(RENDERMODE_TRANSALPHA);
	ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 100));
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
end)