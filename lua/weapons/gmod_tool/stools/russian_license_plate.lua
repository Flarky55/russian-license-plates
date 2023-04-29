TOOL.Category = "#tool.russian_license_plate.name"
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


function TOOL:LeftClick(trace)
    local license_category, license_type = self:GetClientInfo("category"), self:GetClientInfo("type")
    if not RussianLicensePlates.IsValid(license_category, license_type) then return end
 
    local ply = self:GetOwner()

    if SERVER then
        if not ply:CheckLimit(self.Mode) then return end 

        local angs = trace.HitNormal:Angle()
        angs:RotateAroundAxis(angs:Right(), -90)

        local ent = ents.Create("sent_russian_license_plate")
            ent:SetPos(trace.HitPos)
            ent:SetAngles(angs)

            ent:SetCategory(license_category)
            ent:SetType(license_type)

            self:UpdateEntity(ent)
        ent:Spawn()

        if self:GetClientInfo("weld") == "1" then
            constraint.Weld(ent, trace.Entity, 0, trace.PhysicsBone, 0, self:GetClientInfo("nocollide") == "1")
        end

        ply:AddCount(self.Mode, ent)
        ply:AddCleanup(self.Mode, ent)

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
    if CLIENT then
        local ent = trace.Entity
        if not IsValid(ent) or ent:GetClass() ~= "sent_russian_license_plate" then return end
    
        GetConVar(self.Mode .. "_category"):SetString(ent:GetCategory())
        GetConVar(self.Mode .. "_type"):SetString(ent:GetType())
        GetConVar(self.Mode .. "_number"):SetString(ent:GetNumber())
        GetConVar(self.Mode .. "_region"):SetString(ent:GetRegion())

        return true
    end
end


function TOOL:UpdateEntity(ent)
    local _, data_type = RussianLicensePlates.GetData(self:GetClientInfo("category"), self:GetClientInfo("type"))

    local number = self:GetClientInfo("number"):sub(1, 7)
    local region = self:GetClientInfo("region"):sub(1, 3)

    ent:SetNumber(RussianLicensePlates.GenerateByPattern(number ~= "" and number or data_type.pattern))
    ent:SetRegion(region ~= "" and region or math.random(1000))
end


cleanup.Register(TOOL.Mode)

if SERVER then
    CreateConVar("sbox_max" .. TOOL.Mode, 8)
else
    function TOOL.BuildCPanel(panel)
        local combobox_category = panel:ComboBox("#rlp.category.title", "russian_license_plate_category")
        combobox_category:AddChoice("#rlp.category.car", "car")
        combobox_category:AddChoice("#rlp.category.moto", "moto")
        combobox_category:AddChoice("#rlp.category.spec", "spec")
    
        local combobox_type = panel:ComboBox("#rlp.type.title", "russian_license_plate_type")
        combobox_type:AddChoice("#rlp.type.standart", "standart")
        combobox_type:AddChoice("#rlp.type.public", "public")
        combobox_type:AddChoice("#rlp.type.police", "police")
        combobox_type:AddChoice("#rlp.type.diplomatic", "diplomatic")
        combobox_type:AddChoice("#rlp.type.military", "military")

    
        local textentry = panel:TextEntry("#rlp.tool.number", "russian_license_plate_number")
        textentry.AllowInput = function(s, char)
            return #s:GetValue() > 6
        end
        panel:Help("#rlp.tool.number.help")
    
        panel:TextEntry("#rlp.tool.region", "russian_license_plate_region")
        panel:Help("#rlp.tool.region.help")


        panel:CheckBox("#rlp.tool.weld", "russian_license_plate_weld")
        
        panel:CheckBox("#rlp.tool.nocollide", "russian_license_plate_nocollide")
        panel:Help("#rlp.tool.nocollide.help")
    end 
end