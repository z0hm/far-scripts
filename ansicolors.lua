-- ansicolors.lua
-- v1.1
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

-- support detection
local function isWindows()
  return type(package)=="table" and type(package.config)=="string" and package.config:sub(1,1)=="\\"
end

local supported = not isWindows()
if isWindows() then supported = os.getenv("ANSICON") end

local keys = {
  -- reset
  reset      = 0, -- reset all attributes

  -- attributes
  bright     = 1, -- bold for 8..15 color value
  dim        = 2,
  italic     = 3,
  underline  = 4,
  blink      = 5,
  reverse    = 7,
  hidden     = 8,

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

local colors = {0, 4, 2, 6, 1, 5, 3, 7}

local attrib = {
  r = 0, -- reset all attributes
  b = 1, -- bright
  d = 2, -- dim
  i = 3, -- italic
  u = 4, -- underline
  l = 5, -- blink
}

local escapeString = string.char(27) .. "[%dm"
local function escapeNumber(number)
  return escapeString:format(number)
end

local function escapeKeys(str)

  if not supported then return "" end

  local buffer = {}
  local number
  if string.find(str,"^#[%xsr][%xsr][rbdiul]*$") then
    local fg,bg,atr = string.match(str,"^#(.)(.)(.*)$")
    if     fg=="r" then number=39 table.insert(buffer, escapeNumber(number))
    elseif fg=="s" then -- skip
    else
      fg=tonumber(fg,16)
      number=colors[bit.band(fg,0x7)+1]+30
      if bit.band(fg,0x8)>0 then number=number+60 end
      table.insert(buffer, escapeNumber(number))
    end
    if     bg=="r" then number=49 table.insert(buffer, escapeNumber(number))
    elseif bg=="s" then -- skip
    else
      bg=tonumber(bg,16)
      number=colors[bit.band(bg,0x7)+1]+40
      if bit.band(bg,0x8)>0 then number=number+60 end
      table.insert(buffer, escapeNumber(number))
    end
    for symbol in atr:gmatch("%w") do
      number = attrib[symbol]
      assert(number, "Unknown symbol: " .. symbol)
      table.insert(buffer, escapeNumber(number))
    end
  else
    for word in str:gmatch("%w+") do
      number = keys[word]
      assert(number, "Unknown key: " .. word)
      table.insert(buffer, escapeNumber(number))
    end
  end

  return table.concat(buffer)
end

local function replaceCodes(str)
  str = string.gsub(str,"(%%{(.-)})", function(_, str) return escapeKeys(str) end)
  str = string.gsub(str,"(<(#[%xsr][%xsr][rbdiul]*)>)", function(_, str) return escapeKeys(str) end)
  return str
end

-- public

local function ansicolors(str)
  str = tostring(str or '')

  return replaceCodes("%{reset}" .. str .. "%{reset}")
end


return setmetatable({noReset = replaceCodes}, {__call = function (_, str) return ansicolors (str) end})
