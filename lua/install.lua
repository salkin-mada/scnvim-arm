--- SCNvim installation module
--- Cross platform installation of SCNvim SuperCollider classes.

local M = {}
local utils = require('utils')
local uv = vim.loop

local scnvim_root_dir = vim.api.nvim_get_var('scnvim_root_dir')
local home_dir = uv.os_homedir()
-- indexed with keys returned by uname
local extension_dirs = {
  Darwin = home_dir .. '/Library/Application Support/SuperCollider/Extensions',
  Linux = home_dir .. '/.local/share/SuperCollider/Extensions',
  Windows = '%LOCALAPPDATA%/SuperCollider/Extensions',
}

-- Utils

local function is_symlink(path)
  local stat = uv.fs_lstat(path)
  if stat then
    return stat.type == 'link'
  end
  return false
end

local function is_dir(path)
  local stat = uv.fs_stat(path)
  if stat then
    return stat.type == 'directory'
  end
  return false
end

local function get_ext_dir()
  local sysname = uv.os_uname().sysname
  local dir = extension_dirs[sysname]
  if not dir then
    return nil, 'Could not get SuperCollider Extensions dir'
  end
  return dir
end

local function get_target_dir()
  local ext_dir = assert(get_ext_dir())
  return ext_dir .. '/scide_scnvim'
end

-- Interface

--- Create a symlink to the SCNvim classes
function M.link_classes()
  local link_target = get_target_dir()
  local target_exists = uv.fs_stat(link_target)
  -- create the link
  if not target_exists then
    local source = scnvim_root_dir .. '/scide_scnvim'
    assert(uv.fs_symlink(source, link_target, {'dir', true}))
    print('[scnvim] Installed to: ' .. link_target)
  end
end

--- Remove symlink to the SCNvim classes
function M.unlink_classes()
  local link_target = get_target_dir()
  local target_exists = uv.fs_stat(link_target)
  -- remove the link
  if is_symlink(link_target) then
    assert(uv.fs_unlink(link_target))
    print('[scnvim] Uninstalled ' .. link_target)
  end
end

return M
