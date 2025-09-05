local Path = require('plenary.path')
local Enum = require('plenary.enum')

local path_replacer = '__'
local colon_replacer = '++'

local resession_replacer = '_'

---@class SessionManagerConfig: SessionManagerConfig.default
local config = {
  ---@class Mode
  ---@class AutoloadMode: Enum
  ---@field Disabled Mode
  ---@field CurrentDir Mode
  ---@field LastSession Mode
  ---@field GitSession Mode
  AutoloadMode = Enum({
    'Disabled',
    'CurrentDir',
    'LastSession',
    'GitSession',
  }),
}

--- Replaces symbols into separators and colons to transform filename into a session directory.
---@param filename string: Filename with expressions to replace.
---@return table: Session directory
local function session_filename_to_dir(filename)
  -- Get session filename.
  if config.resession_backend then
    config.defaults.sessions_dir = Path:new(vim.fn.stdpath('data'), 'resession')
    local dir = filename:sub(#tostring(config.sessions_dir) + 2, -6)
    dir = dir:gsub('__', ':' .. Path.path.sep):gsub(resession_replacer, Path.path.sep):gsub('++', '_')
    return Path:new(dir)
  else
    local dir = filename:sub(#tostring(config.sessions_dir) + 2)

    dir = dir:gsub(colon_replacer, ':')
    dir = dir:gsub(path_replacer, Path.path.sep)
    return Path:new(dir)
  end
end

--- Replaces separators and colons into special symbols to transform session directory into a filename.
---@param dir string: Path to session directory.
---@return table: Session filename.
local function dir_to_session_filename(dir)
  if config.resession_backend then
    local filename = string.format('%s.json', dir:gsub('_', '++'):gsub(Path.path.sep, '_'):gsub(':', '_'))
    return Path:new(config.sessions_dir):joinpath(filename)
  else
    local filename = dir:gsub(':', colon_replacer)
    filename = filename:gsub(Path.path.sep, path_replacer)
    return Path:new(config.sessions_dir):joinpath(filename)
  end
end

---@class SessionManagerConfig.default
config.defaults = {
  resession_backend = false,
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
  session_filename_to_dir = session_filename_to_dir,
  dir_to_session_filename = dir_to_session_filename,
  ---@type Mode|Mode[]
  autoload_mode = config.AutoloadMode.LastSession,
  autosave_last_session = true,
  autosave_ignore_not_normal = true,
  autosave_ignore_dirs = {},
  ---@type string[] All buffers of these file types will be closed before the session is saved.
  autosave_ignore_filetypes = {
    'gitcommit',
    'gitrebase',
  },
  autosave_ignore_buftypes = {},
  ---@type boolean Always autosaves session. If true, only autosaves after a session is active.
  autosave_only_in_session = false,
  max_path_length = 80,
  load_include_current = false,
}

setmetatable(config, { __index = config.defaults })

return config
