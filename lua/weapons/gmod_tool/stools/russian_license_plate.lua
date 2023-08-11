local CVAR_STRICT_BYPATTERN = GetConVar("rlp_strict_bypattern")

local TOOL_NAME = TOOL.Mode


TOOL.Category = "Русские Номерные Знаки"
TOOL.Name = "#rlp.tool.name"
TOOL.Information = {
    {name = "left"},
    {name = "right"},
    {name = "reload"}
}

TOOL.ClientConVar["category"] = "car"
TOOL.ClientConVar["type"] = "standart"
TOOL.ClientConVar["number"] = ""
TOOL.ClientConVar["region"] = ""
TOOL.ClientConVar["weld"] = "1"
TOOL.ClientConVar["nocollide"] = "1"
TOOL.ClientConVar["freeze"] = ""


function TOOL:LeftClick(trace)
    local license_category, license_type = self:GetClientInfo("category"), self:GetClientInfo("type")
    local data_category, data_type = RussianLicensePlates.GetData(license_category, license_type)
    if data_category == nil then return end

    local number = self:GetClientInfo("number")
    
    if CVAR_STRICT_BYPATTERN:GetBool() and number ~= "" and not RussianLicensePlates.IsMatchPattern(number, data_type.pattern) then return end

    local ply = self:GetOwner()

    if SERVER then
        if not ply:CheckLimit(self.Mode) then return end 

        local ent = ents.Create("sent_russian_license_plate")
            ent:SetPos(trace.HitPos)
            ent:SetAngles(trace.HitNormal:Angle())

            ent:SetCategory(license_category)
            ent:SetType(license_type)

            self:UpdateEntity(ent)
        ent:Spawn()

        if self:GetClientInfo("weld") == "1" then
            constraint.Weld(ent, trace.Entity, 0, trace.PhysicsBone, 0, self:GetClientInfo("nocollide") == "1")
        end
        
        if self:GetClientInfo("freeze") == "1" then
            ent:GetPhysicsObject():EnableMotion(false)
        end

        ply:AddCount(TOOL_NAME, ent)
        ply:AddCleanup(TOOL_NAME, ent)

        undo.Create("Russian License Plate")
            undo.AddEntity(ent)
            undo.SetPlayer(self:GetOwner())
        undo.Finish()
    end

    return true
end

function TOOL:RightClick(trace)
    if not RussianLicensePlates.IsValid(self:GetClientInfo("category"), self:GetClientInfo("type")) then return end
    
    local ent = trace.Entity
    if not IsValid(ent) or ent:GetClass() ~= "sent_russian_license_plate" then return end

    if SERVER then
        self:UpdateEntity(ent) 
    end

    return true
end

function TOOL:Reload(trace)    
    local ent = trace.Entity
    if not IsValid(ent) or ent:GetClass() ~= "sent_russian_license_plate" then return end

    if CLIENT or game.SinglePlayer() then
        RunConsoleCommand(TOOL_NAME .. "_category", ent:GetCategory())
        RunConsoleCommand(TOOL_NAME .. "_type", ent:GetType())
        RunConsoleCommand(TOOL_NAME .. "_number", ent:GetNumber())
        RunConsoleCommand(TOOL_NAME .. "_region", ent:GetRegion())
    end

    return true
end


function TOOL:UpdateEntity(ent)
    local _, data_type = RussianLicensePlates.GetData(self:GetClientInfo("category"), self:GetClientInfo("type"))

    local number = self:GetClientInfo("number"):sub(1, 7)
    local region = self:GetClientInfo("region"):sub(1, 3)

    ent:SetNumber(RussianLicensePlates.GenerateByPattern(number ~= "" and number or data_type.pattern))
    ent:SetRegion(region ~= "" and region or math.random(1000))
end


cleanup.Register(TOOL_NAME)

if SERVER then
    CreateConVar("sbox_max" .. TOOL_NAME, 8)
else
    local CVars = TOOL:BuildConVarList()

    function TOOL.BuildCPanel(panel)
        local toolpresets = panel:ToolPresets(TOOL_NAME, CVars)

        local combobox_category = panel:ComboBox("#rlp.category.title", TOOL_NAME .. "_category")
        combobox_category:AddChoice("#rlp.category.car", "car")
        combobox_category:AddChoice("#rlp.category.moto", "moto")
        combobox_category:AddChoice("#rlp.category.spec", "spec")

        local combobox_type = panel:ComboBox("#rlp.type.title", TOOL_NAME .. "_type")

        combobox_category.OnSelect = function(s, index, value, data)
            RunConsoleCommand(TOOL_NAME .. "_category", data)

            combobox_type:Clear()

            for license_type in pairs(RussianLicensePlates.GetData(data).types) do
                combobox_type:AddChoice("#rlp.type." .. license_type, license_type)    
            end
        end
        
        combobox_category:ChooseOptionID(1)
    
        
        local textentry_number = panel:TextEntry("#rlp.tool.number", TOOL_NAME.. "_number")
        textentry_number.AllowInput = function(s, char)
            return #s:GetValue() > 6
        end
        textentry_number.OnChange = function(s)
            s:SetText(RussianLicensePlates.FormatNumber(s:GetValue()))
            s:SetCaretPos(#s:GetValue())
        end
        panel:Help("#rlp.tool.number.help")
    
        local textentry_region = panel:TextEntry("#rlp.tool.region", TOOL_NAME .. "_region")
        textentry_region:SetNumeric(true)
        textentry_region.AllowInput = function(s, char)
            return #s:GetValue() > 2 or s:CheckNumeric(char)
        end
        panel:Help("#rlp.tool.region.help")


        panel:CheckBox("#rlp.tool.weld", TOOL_NAME .. "_weld")
        
        panel:CheckBox("#rlp.tool.nocollide", TOOL_NAME .. "_nocollide")
        panel:Help("#rlp.tool.nocollide.help")

        panel:CheckBox("#rlp.tool.freeze", TOOL_NAME .. "_freeze")
    end 
end