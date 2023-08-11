local random = math.random
local utf8 = utf8
local SimpleText = CLIENT and draw.SimpleText
local utf8_sub = utf8.sub


local utf8_SetChar = function(s, k, v)
    return utf8_sub(s, 0, k - 1) .. v .. utf8_sub(s, k + 1)
end


RussianLicensePlates = {}
RussianLicensePlates.Data = {
    ["car"] = {
        model = "models/conred/license_plate_auto.mdl",
        types = {
            ["standart"] = {
                pattern = "lnnnll",
                skin = 0
            },
            ["public"] = {
                pattern = "ll  nnn",
                skin = 1,
                bodygroups = "0001"
            },
            ["diplomatic"] = {
                color = color_white,
                pattern = "nnnDnnn",
                skin = 2,
                bodygroups = "0001",
                draw = function(self)
                    local number = self:GetNumber()

                    SimpleText(number:sub(1, -4), "RussianLicensePlates.Number", -15, 0, self.Color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2)
                    SimpleText(number:sub(-3), "RussianLicensePlates.Number.Diplomatic", -15, 8, self.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2)
                    SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 148, -16, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
                end,
            },
            ["police"] = {
                color = color_white,
                pattern = "lnnnn",
                skin = 3,
                bodygroups = "0001"
            },
            ["military"] = {
                color = color_white,
                pattern = "NNNNLL",
                skin = 4,
                bodygroups = "0001"
            },
            ["trailer_standart"] = {
                pattern = "llnnnn",
                skin = 0
            },
            ["trailer_police"] = {
                color = color_white,
                pattern = "n n n l",
                skin = 3,
                bodygroups = "0001"
            },
            ["trailer_military"] = {
                color = color_white,
                pattern = "llnnnn",
                skin = 4,
                bodygroups = "0001"
            }
        },
        draw = function(self)
            SimpleText(self:GetNumber(), "RussianLicensePlates.Number", -48, 0, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            SimpleText(self:GetRegion(), "RussianLicensePlates.Region", 148, -16, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        end
    },
    ["moto"] = {
        model = "models/conred/license_plate_auto.mdl",
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
        model = "models/conred/license_plate_auto.mdl",
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

    return data_category and data_category.types[license_type] ~= nil
end


local letters = {"A", "B", "E", "K", "M", "H", "O", "P", "C", "T", "Y", "X"}
local generators = {
    ["L"] = function() return letters[random(#letters)] end,
    ["N"] = function() return random(9) end,
}
function RussianLicensePlates.GenerateByPattern(pattern)
    local result = ""
    for i = 1, #pattern do 
        local char = pattern[i]
        local generator = generators[char:upper()]

        result = result .. (generator and generator() or char)
    end
    return result
end

local letters_check = {}; do
    for i = 1, #letters do
        letters_check[letters[i]] = true
    end
end
local generators_check = {
    ["L"] = function(char)
        return letters_check[char] or false
    end,
    ["N"] = function(char)
        return tonumber(char) ~= nil
    end
}
function RussianLicensePlates.IsMatchPattern(text, pattern)
    if #text ~= #pattern then return false end

    for i = 1, #text do
        local char_text = text[i]
        local char_pattern = pattern[i]
        local generator_check = generators_check[char_pattern:upper()]

        if generator_check then
            if not generator_check(char_text:upper()) then
                return false
            end
        elseif char_text ~= char_pattern then
            return false
        end
    end

    return true
end


local letters_upper = {["а"]="А",["б"]="Б",["в"]="В",["г"]="Г",["д"]="Д",["е"]="Е",["ё"]="Ё",["ж"]="Ж",["з"]="З",["и"]="И",["й"]="Й",["к"]="К",["л"]="Л",["м"]="М",["н"]="Н",["о"]="О",["п"]="П",["р"]="Р",["с"]="С",["т"]="Т",["у"]="У",["ф"]="Ф",["х"]="Х",["ц"]="Ц",["ч"]="Ч",["ш"]="Ш",["щ"]="Щ",["ъ"]="Ъ",["ы"]="Ы",["ь"]="Ь",["э"]="Э",["ю"]="Ю",["я"]="Я"}
local letters_transfrom = {
    ["А"] = "A",
    ["В"] = "B",
    ["Е"] = "E",
    ["К"] = "K",
    ["М"] = "M",
    ["Н"] = "H",
    ["О"] = "O",
    ["Р"] = "P",
    ["С"] = "C",
    ["Т"] = "T",
    ["У"] = "Y",
    ["Х"] = "X"
}
function RussianLicensePlates.FormatNumber(text)
    for i = 1, utf8.len(text) do
        local char = letters_upper[ utf8.GetChar(text, i) ]
        if char == nil or letters_transfrom[char] == nil then continue end

        text = utf8_SetChar(text, i, letters_transfrom[ char ])
    end

    return text
end


if CLIENT then
    surface.CreateFont("RussianLicensePlates.Number", {
        font = "RoadNumbers",
        extended = true,
        size = 64,
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
else
    CreateConVar("rlp_strict_bypattern", "0", FCVAR_ARCHIVE, "Strict players` custom license plates by pattern")
end


MsgC("Russian License Plates > Intiailized!\n")