ENT.Type        = "anim"
ENT.Base        = "base_gmodentity"


function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Number")
    self:NetworkVar("String", 1, "Region")
    self:NetworkVar("String", 2, "Type")
    self:NetworkVar("String", 3, "Category")
end

function ENT:Initialize()
    local data_category, data_type = RussianLicensePlates.GetData(self:GetCategory(), self:GetType())

    if SERVER then
        self:SetModel(data_category.model or "models/tyut23/nomernoy_znak.mdl")
        self:SetSkin(data_type.skin or 0)
        self:PhysicsInit(SOLID_VPHYSICS)
    else
        self.DrawPlate = data_type.draw or data_category.draw
        self.Color = data_type.color or color_black
    end
end