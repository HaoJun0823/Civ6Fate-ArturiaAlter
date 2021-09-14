-- Okita_Souji_Core
-- Author: GIGABYTE
-- DateCreated: 8/8/2018 6:54:55 AM
--------------------------------------------------------------

print("Saber Alter Spatter Damage Test begin!\n");
--------------------------------------------------------------
local AttackerEnt = 1431908133;
local DefenderEnt = -1632097141;
local IDEnt = 1472654640;
local DamageEnt = -958805242;
local LocationEnt = CombatResultParameters.LOCATION;

function Ent_Test_SaberAlter(SaberAlterTable)
    print("Spatter Detection Activated!\n");
    local AttackerPlayerID = SaberAlterTable[AttackerEnt][IDEnt]["player"];
    local DefenderPlayerID = SaberAlterTable[DefenderEnt][IDEnt]["player"];

	print("Attacker:"..AttackerPlayerID);
	print("Defender:"..DefenderPlayerID);
	local xPlayerConfig = PlayerConfigurations[AttackerPlayerID];
	local pPlayerConfig = PlayerConfigurations[DefenderPlayerID];
	if xPlayerConfig:GetLeaderTypeName() == "LEADER_ARTURIAENT_ALTER" then
		local AttackerUnitID = SaberAlterTable[AttackerEnt][IDEnt]["id"];
	    local AttackerUnitXY = SaberAlterTable[AttackerEnt][LocationEnt];
		local DefenderUnitID = SaberAlterTable[DefenderEnt][IDEnt]["id"];
		local DefenderUnitXY = SaberAlterTable[DefenderEnt][LocationEnt];
		local DefenderUnitType = SaberAlterTable[DefenderEnt][IDEnt]["type"];
		if  DefenderUnitType == 1 then
		    print("Spatter System Loaded!\n");
			local PlayerDefender = Players[DefenderPlayerID];
			local pUnits = PlayerDefender:GetUnits();
			local PlayerAttacker = Players[AttackerPlayerID];
			local xUnits = PlayerAttacker:GetUnits();
			local DamageAmount = SaberAlterTable[DefenderEnt][DamageEnt];
			for  i = 0, GameDefines.MAX_PLAYERS-1, 1 do
				if i ~= AttackerPlayerID and (PlayerAttacker:GetDiplomacy():IsAtWarWith(i) or Players[i]:IsBarbarian()) then
				    local vPlayer=Players[i];
					local vUnits=vPlayer:GetUnits();
				    local UnitsMember = vUnits:Members();
					local UnitsXMember = xUnits:Members();
					for ii, xUnit in xUnits:Members() do
						if xUnit:GetID() == AttackerUnitID then
							local PromotionName:string = GameInfo.Units[xUnit:GetType()].PromotionClass;
							if PromotionName == "PROMOTION_CLASS_HEAVY_CAVALRY" or  PromotionName == "PROMOTION_CLASS_MELEE" or PromotionName == "PROMOTION_CLASS_LIGHT_CAVALRY"  then
								print("Promotion pass checked!");
								for ii, pUnit in vUnits:Members() do
									local VictimUnitXY = pUnit:GetLocation();
									local Criterion = SpatterCriterion(AttackerUnitXY,DefenderUnitXY,VictimUnitXY);
									print("Criterion:"..Criterion);
									if Criterion ==1 then
										local DamageAmountScalared = DamageAmount*0.8;
										local remaining = (100 - pUnit:GetDamage());
										if (remaining <= DamageAmountScalared) then
											UnitManager.Kill(pUnit, false);
										else
											pUnit:ChangeDamage(DamageAmountScalared);											
										end
									end

									if Criterion ==2 then
										local DamageAmountScalared = DamageAmount*0.6;
										local remaining = (100 - pUnit:GetDamage());
										if (remaining <= DamageAmountScalared) then
											UnitManager.Kill(pUnit, false);
										else
											pUnit:ChangeDamage(DamageAmountScalared);											
										end
									end												
								end		
							end
						end			
					end	
				end 			

			end
		   
		end
	end
end

Events.Combat.Add(Ent_Test_SaberAlter);
--------------------------------------------------------------

function FindPlotSpatter(Axy,Dxy)
    dx=Axy["x"]-Dxy["x"];
    dy=Axy["y"]-Dxy["y"];
    L={};
    if dx==1 and dy==0 then
        L[1]={0,1};
	    L[2]={-1,0};
        L[3]={-1,-1};
    elseif dx==1 and dy==1 then
        L[1]={-1,0};
	    L[2]={-1,-1};
	    L[3]={0,-1};
    elseif dx==0 and dy==1 then
        L[1]={-1,-1};
	    L[2]={0,-1};
	    L[3]={1,0};
    elseif dx==-1 and dy==0 then
	    L[1]={0,-1};
		L[2]={1,0};
		L[3]={1,1};
	elseif dx==-1 and dy==-1 then
		L[1]={1,0};
		L[2]={1,1};
		L[3]={0,1};
	elseif dx==0 and dy==-1 then
	    L[1]={1,1};
		L[2]={0,1};
		L[3]={-1,0};
    else
	    print("Relative Position Error!");
	end
    return L;

end


function SpatterCriterion(Axy,Dxy,Pxy)


	
    L=FindPlotSpatter(Axy,Dxy);
	if Plus(Dxy,L[2])[1]==Pxy["x"] and Plus(Dxy,L[2])[2]==Pxy["y"] then
		return 1; 
	elseif Plus(Dxy,L[1])[1]==Pxy["x"] and Plus(Dxy,L[1])[2]==Pxy["y"] then
	    return 2;
	elseif Plus(Dxy,L[3])[1]==Pxy["x"] and Plus(Dxy,L[3])[2]==Pxy["y"] then
		return 2;
	else
	    return 0;
	end
end

function Plus(Axy,Delta)
    local W
	local H
	W,H = Map.GetGridSize();
	P={};
    P[1]=Axy["x"]+Delta[1];
    P[2]=Axy["y"]+Delta[2]; 
    if P[1]<0 then
	    P[1]=P[1]+W;
    end	
	if P[1]>W-1 then
		P[1]=P[1]-W;
	end
	
    if P[2]<0 then
	    P[2]=P[2]+H;
    end	
	if P[2]>H-1 then
		P[2]=P[2]-H;
	end	
	return P;
end
