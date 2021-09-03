-- ansicolors.lua
-- v1.1.2
-- Ansi colors for console
-- ![Ansi Colors](http://i.piccy.info/i9/5302080eb549332b420c736af1a1a8da/1629987471/985/1439927/180392021_08_26_171510.png)
-- Tags format: **<#xya>**, **x** - foreground color **0..f**, **y** - background color **0..f**, **a** - attributes [rbdiul]
-- **r** - restore default color for foreground/background, **s** - skip, don't change foreground/background color
-- Examples:
-- ``` lua
--   local colors = require'ansicolors'
--   print(colors('%{bright italic red underline}hello'))
--   print(colors('<#ecuib>Hello<#rrr>, World!'))
-- ```

-- Copyright (c) 2009 Rob Hoelz <rob@hoelzro.net>
-- Copyright (c) 2011 Enrique García Cota <enrique.garcia.cota@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local s = string
local char,find,format,rep,sub,gsub,match,gmatch = s.char,s.find,s.format,s.rep,s.sub,s.gsub,s.match,s.gmatch

local b = bit
local band = b.band

local t = table
local concat = t.concat

-- support detection
local function isWindows()
  return type(package) == "table" and type(package.config) == "string" and sub(package.config,1,1) == "\\"
end

local supported = not isWindows()
if isWindows() then supported = win.GetEnv("ANSICON") end

local keys = {
  -- reset
  r         = 0, -- reset all attributes
  reset     = 0, -- reset all attributes

  -- attributes
  b         = 1, -- bold for 8..15 color value
  bright    = 1, -- bold for 8..15 color value
  bold      = 60,
  d         = 2, -- dim
  dim       = 2,
  i         = 3, -- italic
  italic    = 3,
  u         = 4, -- underline
  underline = 4,
  l         = 5, -- blink
  blink     = 5,
  reverse   = 7,
  hidden    = 8,

  -- foreground colors
  black     = 30,
  red       = 31,
  green     = 32,
  yellow    = 33,
  blue      = 34,
  magenta   = 35,
  cyan      = 36,
  white     = 37,
  dfg       = 39, -- default foreground color

  -- background colors
  blackbg   = 40,
  redbg     = 41,
  greenbg   = 42,
  yellowbg  = 43,
  bluebg    = 44,
  magentabg = 45,
  cyanbg    = 46,
  whitebg   = 47,
  dbg       = 49  -- default background color
}

local colors = {
  --[[0]] 0, -- black
  --[[1]] 4, -- blue
  --[[2]] 2, -- green
  --[[3]] 6, -- cyan
  --[[4]] 1, -- red
  --[[5]] 5, -- magenta
  --[[6]] 3, -- yellow
  --[[7]] 7  -- white
}

local esc,pbuffer,buffer = char(27) .. "["

local function escapeNumber(number) pbuffer = pbuffer + 1 buffer[pbuffer] = esc .. tostring(number) .. "m" end

local function color(symbol, base)
  local number
  if     symbol == "s" then -- skip
  elseif symbol == "r" then number = base + 9
  else
    symbol = tonumber(symbol, 16)
    number = colors[band(symbol, 7) + 1] + base
    if band(symbol, 8) > 0 then number = number + 60 end
  end
  escapeNumber(number)
end

local function attributes(str, mask)
  local bold
  for word in gmatch(str, mask) do if word == "bold" then bold = true break end end
  for word in gmatch(str, mask) do
    local number = keys[word]
    assert(number, "Unknown key: " .. word)
    if number ~= 60 then 
      if bold and number >= 30 and number <= 37 or number >= 40 and number <= 47 then number = number + 60 end
      escapeNumber(number)
    end
  end
end

local function escapeKeys(str)
  if not supported then return "" end
  pbuffer,buffer = 0,{}
  if find(str, "^#[%xsr][%xsr][rbdiul]*$") then
    local fg,bg,str = match(str, "^#(.)(.)(.*)$")
    color(fg, 30) color(bg, 40)
    attributes(str, "%w")
  else attributes(str, "%w+")
  end
  return concat(buffer)
end

local function replaceCodes(str)
  str = gsub(str, "(%%{([a-z ]-)})", function(_, str) return escapeKeys(str) end)
  str = gsub(str, "(<(#[%xsr][%xsr][rbdiul]*)>)", function(_, str) return escapeKeys(str) end)
  return str
end

local function ansicolors(str) return replaceCodes("%{reset}".. tostring(str or '') .. "%{reset}") end

return setmetatable({noReset = replaceCodes}, {__call = function (_, str) return ansicolors(str) end})
