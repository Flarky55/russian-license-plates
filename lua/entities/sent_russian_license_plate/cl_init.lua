include("shared.lua")


function ENT:Draw()
    self:DrawModel()

    if not self.DrawPlate then return end

    local pos = self:GetPos()

    local angs = self:GetAngles()
    angs:RotateAroundAxis(angs:Up(), 90)

    cam.Start3D2D(pos + angs:Up() * 0.1, angs, .05)
        self:DrawPlate()
    cam.End3D2D()
end