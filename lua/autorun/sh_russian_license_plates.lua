local random = math.random
local SimpleText = CLIENT and draw.SimpleText


RussianLicensePlates = {}
RussianLicensePlates.Data = {
    ["car"] = {
        model = "models/tyut23/nomernoy_znak.mdl",
        types = {
            ["standart"] = {
                pattern = "lnnnll",
                skin = 0
            },
            ["public"] = {
                pattern = "ll  nnn",
                skin = 1
            },
            ["diplomatic"] = {
                color = color_white,
                pattern = "nnnDnnn",
                skin = 2,
                draw = function(self)
                    local number = self:GetNumber()

                    SimpleText(number:sub(1, -4), "RussianLicensePlates.Number", -15, 0, self.Color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2)
                    SimpleText(number:sub(-3), "RussianLicensePlates.Number.Diplomatic", -15, 8, self.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2)
                    SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 156, -16, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
                end,
            },
            ["police"] = {
                color = color_white,
                pattern = "lnnnn",
                skin = 3
            },
            ["military"] = {
                color = color_white,
                pattern = "NNNNLL",
                skin = 4
            },
            ["trailer_standart"] = {
                pattern = "llnnnn",
                skin = 0
            },
            ["trailer_police"] = {
                color = color_white,
                pattern = "n n n l",
                skin = 3
            },
            ["trailer_military"] = {
                color = color_white,
                pattern = "llnnnn",
                skin = 4
            }
        },
        draw = function(self)
            SimpleText(self:GetNumber(), "RussianLicensePlates.Number", -48, 0, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 156, -16, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        end
    },
    ["moto"] = {
        model = "models/tyut23/moto_znak.mdl",
        types = {
            ["standart"] = {
                pattern = "NNNNLL",
                skin = 0
            },
            ["police"] = {
                color = color_white,
                pattern = "NNNNL",
                skin = 1,
                draw = function(self)
                    local number = self:GetNumber()
        
                    SimpleText(number:sub(1, -2), "RussianLicensePlates.Number", 0, -42, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
                    SimpleText(number:sub(-1), "RussianLicensePlates.Number", -52, 48, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
                    SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 52, 48, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
                end,
            },
            ["military"] = {
                color = color_white,
                pattern = "NNNNLL",
                skin = 2
            }
        },
        draw = function(self)
            local number = self:GetNumber()

            SimpleText(number:sub(1, -3), "RussianLicensePlates.Number", 0, -42, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            SimpleText(number:sub(-2), "RussianLicensePlates.Number", -52, 48, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 52, 48, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        end,
    },
    ["spec"] = {
        model = "models/tyut23/special_znak.mdl",
        types = {
            ["standart"] = {
                pattern = "NNNNLL",
                skin = 0
            },
            ["military"] = {
                color = color_white,
                pattern = "NNNNLL",
                skin = 1
            }
        },
        draw = function(self)
            local number = self:GetNumber()

            SimpleText(number:sub(1, -3), "RussianLicensePlates.Number", 0, -48, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            SimpleText(number:sub(-2), "RussianLicensePlates.Number", -64, 48, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 72, 56, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        end,
    }
}

function RussianLicensePlates.GetData(license_category, license_type)
    local data_category = RussianLicensePlates.Data[license_category]
    if license_type == nil then return data_category end
    
    return data_category, data_category.types[license_type] or data_category.types.standart
end

function RussianLicensePlates.IsValid(license_category, license_type)
    local data_category = RussianLicensePlates.Data[license_category]

    return data_category and data_category.types[license_type] and true or false
end


local letters = {"A", "B", "E", "K", "M", "H", "O", "P", "C", "T", "Y", "X"}
local generators = {
    ["L"] = function() return letters[random(#letters)] end,
    ["N"] = function() return random(9) end,
}
function RussianLicensePlates.GenerateByPattern(pattern)
    local result = ""
    for i = 1, #pattern do 
        local id = pattern[i]
        local generator = generators[id:upper()]

        result = result .. (generator and generator() or id)
    end
    return result
end


if CLIENT then
    surface.CreateFont("RussianLicensePlates.Number", {
        font = "RoadNumbers",
        extended = true,
        size = 68,
    })
    surface.CreateFont("RussianLicensePlates.Number.Diplomatic", {
        font = "RoadNumbers",
        extended = true,
        size = 50,
    })

    surface.CreateFont("RussianLicensePlates.Region", {
        font = "RoadNumbers",
        extended = true,
        size = 42,
    })
end


MsgC("Russian License Plates > Intiailized!\n")