include("shared.lua")


function ENT:Draw()
    self:DrawModel()

    if not self.DrawPlate then return end

    local pos = self:GetPos()

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)

    cam.Start3D2D(pos, ang, .05)
        self:DrawPlate()
    cam.End3D2D()
end