luaunicodespace = { }

local format = string.format

local glyph = node.id("glyph")
local hlist = node.id("hlist")
local vlist = node.id("vlist")
local glue = node.id("glue")
local glue_spec = node.id("glue_spec")
local penalty = node.id("penalty")

-- derived from
-- http://en.wikipedia.org/wiki/Space_(punctuation)#Spaces_in_Unicode
luaunicodespace.spaces = {
    [0x00A0] = { -- No-Break Space
        width = "space",
        nobreak = true,
    },
    [0x2002] = { -- En Space
        width = ".5em",
    },
    [0x2003] = { -- Em Space
        width = "1em",
    },
    [0x2004] = { -- Three-Per-Em Space
        width = ".33em",
    },
    [0x2005] = { -- Four-Per-Em Space
        width = ".25em",
    },
    [0x2006] = { -- Six-Per-Em Space
        width = ".17em",
    },
--  [0x2007] = { -- Figure Space
--      width = "digit",
--      fixed = true,
--      nobreak = true,
--  },
--  [0x2008] = { -- Punctuation Space
--      width = "punc",
--  },
    [0x2009] = { -- Thin Space
        width = ".2em",
    },
    [0x200A] = { -- Hair Space
        width = ".1em",
    },
    [0x200B] = { -- Zero Width Space
        width = "0em",
    },
    [0x202F] = { -- Narrow No-Break Space
        width = ".2em",
        nobreak = true,
    },
    [0x2060] = { -- Word Joiner
        width = "0em",
        nobreak = true,
    },
}

luaunicodespace.spaces[0x2000] = luaunicodespace.spaces[0x2002]
luaunicodespace.spaces[0x2001] = luaunicodespace.spaces[0x2003]

-- cache font parameters, calling font.fonts is expesnive
local parameters = {}

local function new_glue(space)
    local n = node.new(glue)
    local s = node.new(glue_spec)
    if space.width == "space" then
        local f = font.current()
        if not parameters[f] then
            parameters[f] = font.fonts[f].parameters
        end
        s.width = parameters[f].space
        s.stretch = parameters[f].space_stretch
        s.shrink = parameters[f].space_shrink
--      s.stretch_order = 0
--      s.shrink_order = 0
    else
        s.width = tex.sp(space.width)
--      s.stretch = ???
--      s.shrink = ???
    end
    n.spec = s
    return n
end

local function new_penalty(value)
    local n = node.new(penalty)
    n.penalty = value
    return n
end

function luaunicodespace.handler(head)
    local n = head
    while n do
        if n.id == hlist or n.id == vlist then
            luaunicodespace.handler(n.list)
        elseif n.id == glyph then
            local spaces = luaunicodespace.spaces
            if spaces[n.char] then
                local glue = new_glue(spaces[n.char])
                local n_prev = n.prev
                local n_next = n.next
                if spaces[n.char].nobreak then
                    local penalty = new_penalty(10000)
                    n_prev.next = penalty
                    penalty.prev = n_prev
                    penalty.next = glue
                    glue.prev = penalty
                else
                    glue.prev = n_prev
                    n_prev.next = glue
                end
                glue.next = n_next
                n_next.prev = glue
            end
        end
    n = n.next
    end
    return head
end
