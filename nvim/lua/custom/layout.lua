-- Keep Neovim's keys on their physical QWERTY positions while the keyboard types
-- Colemak-DH.
--
-- A Karabiner rule turns plain key presses into Colemak-DH characters while its
-- layout toggle is on, but leaves any key pressed with Cmd/Ctrl/Opt on its QWERTY
-- position. This module makes Neovim cope with both halves of that:
--
--   * 'langmap' translates each typed Colemak character back to the QWERTY character
--     on the same key, so Normal-mode commands, operators and mappings stay put.
--   * langmap also translates Alt chords, which Karabiner already sent on their QWERTY
--     positions. To cancel that double translation, Alt chords in mapping lhs are
--     moved to where langmap will look for them while the layout is on.
--
-- The current layout lives in ~/.local/state/keyboard-layout. Karabiner writes it when
-- toggled; every running Neovim reads it on startup and focus and watches it for
-- changes. Toggling from Neovim writes it too and sets Karabiner's variable to match.
--
--   :Layout [toggle|qwerty|colemak-dh]   show / flip / force a layout
--   <C-\><C-l>                           force QWERTY from any mode
local M = {}
local uv = vim.uv or vim.loop

local COLEMAK = 'colemak-dh' -- the only non-QWERTY layout; any other state means QWERTY
local STATE_FILE = vim.fn.expand('~/.local/state/keyboard-layout')

M.current = 'qwerty'

-- Layout data and translation -----------------------------------------------

-- The character each key types, key for key: top, home, bottom row (ANSI).
local QWERTY_KEYS = 'qwertyuiop' .. 'asdfghjkl;' .. 'zxcvbnm,./'
local COLEMAK_KEYS = 'qwfpbjluy;' .. 'arstgmneio' .. 'zxcdvkh,./'

local SHIFTED = { [';'] = ':', [','] = '<', ['.'] = '>', ['/'] = '?' }
local LANGMAP_ESCAPES = { [';'] = '\\;', [','] = '\\,', ['\\'] = '\\\\' }

local function shifted(ch) return SHIFTED[ch] or ch:upper() end
local function langmap_escape(ch) return LANGMAP_ESCAPES[ch] or ch end

-- TO_QWERTY maps a character typed under Colemak-DH to the QWERTY character on the
-- same physical key, unshifted and shifted (e.g. 'o' -> ';', 'O' -> ':', ':' -> 'P').
-- LANGMAP is the same table in 'langmap' syntax.
local TO_QWERTY, langmap_pairs = {}, {}
local function add_translation(from, to)
  TO_QWERTY[from] = to
  langmap_pairs[#langmap_pairs + 1] = langmap_escape(from) .. langmap_escape(to)
end
for i = 1, #COLEMAK_KEYS do
  local c, q = COLEMAK_KEYS:sub(i, i), QWERTY_KEYS:sub(i, i)
  if c ~= q then
    add_translation(c, q)
    add_translation(shifted(c), shifted(q))
  end
end
local LANGMAP = table.concat(langmap_pairs, ',')

-- Alt-chord relocation ------------------------------------------------------
--
-- Karabiner sends <M-k> from the physical K key, and langmap then rewrites it as if
-- it had been typed on Colemak, so a mapping on <M-k> is looked up at <M-n> instead.
-- While Colemak is on, every mapping whose lhs contains Alt chords (global and
-- buffer-local, single chords and sequences like <M-k><M-c>) is moved to that
-- translated lhs, and moved back when the layout is turned off. Plain characters
-- in an lhs are not moved: Karabiner sends those as Colemak, and langmap's
-- translation is exactly what puts them back on their QWERTY keys.

local ALT_MODES = { 'n', 'x', 's', 'o', 'i', 'c', 't' }

-- Mappings currently relocated, as { buf, mode, from, to, rhs, opts }; buf is nil
-- for global mappings.
local relocated = {}

-- The lhs with each Alt chord replaced by the chord langmap turns it into, and
-- whether anything changed.
local function translate_alt_chords(lhs)
  local changed = false
  local out = lhs:gsub('<[MA]%-(.)>', function(ch)
    if TO_QWERTY[ch] then
      changed = true
      return '<M-' .. TO_QWERTY[ch] .. '>'
    end
  end)
  return out, changed
end

-- Options to recreate a mapping from a nvim_get_keymap() entry.
local function keymap_opts(m)
  return {
    noremap = m.noremap == 1, silent = m.silent == 1, nowait = m.nowait == 1,
    expr = m.expr == 1, desc = m.desc, callback = m.callback,
    replace_keycodes = m.replace_keycodes == 1 or nil,
  }
end

local function set_map(buf, mode, lhs, rhs, opts)
  if buf then
    vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs or '', opts)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs or '', opts)
  end
end

local function del_map(buf, mode, lhs)
  if buf then
    pcall(vim.api.nvim_buf_del_keymap, buf, mode, lhs)
  else
    pcall(vim.api.nvim_del_keymap, mode, lhs)
  end
end

local function scope_exists(buf)
  return not buf or vim.api.nvim_buf_is_valid(buf)
end

-- Every mapping, global or in a loaded buffer, whose lhs has an Alt chord to move.
local function find_alt_mappings()
  local scopes = { false } -- false = global
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then scopes[#scopes + 1] = b end
  end
  local found, seen = {}, {}
  for _, buf in ipairs(scopes) do
    for _, mode in ipairs(ALT_MODES) do
      local maps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
      for _, m in ipairs(maps) do
        local to, changed = translate_alt_chords(m.lhs)
        -- A mapping spanning several modes (e.g. :map) is listed under each of them.
        local key = tostring(buf) .. m.mode .. m.lhs
        if changed and not seen[key] then
          seen[key] = true
          found[#found + 1] = {
            buf = buf or nil, mode = m.mode, from = m.lhs, to = to, rhs = m.rhs, opts = keymap_opts(m),
          }
        end
      end
    end
  end
  return found
end

local function relocate_alt_mappings()
  relocated = find_alt_mappings()
  -- Delete every original before creating any relocated mapping: the translation is a
  -- permutation of the letters, so one mapping's new lhs may be another's old one.
  for _, r in ipairs(relocated) do del_map(r.buf, r.mode, r.from) end
  for _, r in ipairs(relocated) do set_map(r.buf, r.mode, r.to, r.rhs, r.opts) end
end

local function restore_alt_mappings()
  for _, r in ipairs(relocated) do
    if scope_exists(r.buf) then del_map(r.buf, r.mode, r.to) end
  end
  for _, r in ipairs(relocated) do
    if scope_exists(r.buf) then set_map(r.buf, r.mode, r.from, r.rhs, r.opts) end
  end
  relocated = {}
end

-- Bring all mappings in line with the current layout, including ones added since the
-- last sync.
local function sync_alt_mappings()
  restore_alt_mappings()
  if M.current == COLEMAK then relocate_alt_mappings() end
end

-- Shared state file ---------------------------------------------------------

local function read_state()
  local f = io.open(STATE_FILE, 'r')
  if not f then return 'qwerty' end
  local s = (f:read('*l') or ''):gsub('%s+', '')
  f:close()
  return s
end

local function write_state(name)
  vim.fn.mkdir(vim.fs.dirname(STATE_FILE), 'p')
  local f = io.open(STATE_FILE, 'w')
  if f then f:write(name .. '\n'); f:close() end
end

local function set_karabiner_variable(name)
  if vim.fn.executable('karabiner_cli') == 1 then
    vim.system({ 'karabiner_cli', '--set-variables',
      vim.json.encode({ layout_alt = name == COLEMAK and 1 or 0 }) })
  end
end

-- Watch the directory rather than the file: the file may not exist yet, and a
-- writer that replaces it (rather than writing in place) would end a watch on the
-- file itself. Events for other files in the directory are ignored.
local function watch_state(on_change)
  local handle = uv.new_fs_event()
  if not handle then return end
  local dir, base = vim.fs.dirname(STATE_FILE), vim.fs.basename(STATE_FILE)
  vim.fn.mkdir(dir, 'p')
  handle:start(dir, {}, function(err, filename)
    if err or (filename and filename ~= base) then return end
    vim.schedule(on_change)
  end)
end

-- Public API ----------------------------------------------------------------

--- Apply a layout to this Neovim only. Anything but 'colemak-dh' means QWERTY.
function M.apply(name, quiet)
  name = name == COLEMAK and COLEMAK or 'qwerty'
  local changed = name ~= M.current
  M.current = name
  vim.o.langmap = name == COLEMAK and LANGMAP or ''
  sync_alt_mappings()
  if changed and not quiet then
    vim.notify('Keyboard layout: ' .. name, vim.log.levels.INFO)
  end
end

--- Set the layout everywhere: state file (other Neovims), Karabiner, this Neovim.
function M.set(name)
  if name ~= 'qwerty' and name ~= COLEMAK then
    return vim.notify('Unknown layout: ' .. tostring(name), vim.log.levels.ERROR)
  end
  write_state(name)
  set_karabiner_variable(name)
  M.apply(name)
end

function M.toggle()
  M.set(M.current == 'qwerty' and COLEMAK or 'qwerty')
end

--- For a statusline: empty on QWERTY, the layout name otherwise.
function M.status() return M.current == 'qwerty' and '' or M.current end

-- Setup ---------------------------------------------------------------------

local function layout_command(o)
  if o.args == '' then
    vim.notify('Keyboard layout: ' .. M.current)
  elseif o.args == 'toggle' then
    M.toggle()
  else
    M.set(o.args)
  end
end

function M.setup()
  M.apply(read_state(), true)
  watch_state(function() M.apply(read_state()) end)

  local group = vim.api.nvim_create_augroup('keyboard-layout', { clear = true })
  vim.api.nvim_create_autocmd('FocusGained', {
    group = group,
    callback = function() M.apply(read_state(), true) end,
  })
  -- Plugins add their own mappings after startup.
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = { 'VeryLazy', 'LazyDone' },
    callback = sync_alt_mappings,
  })
  -- Buffer-local mappings arrive with filetypes and LSP attach.
  vim.api.nvim_create_autocmd({ 'FileType', 'LspAttach' }, {
    group = group,
    callback = function()
      if M.current == COLEMAK then vim.schedule(sync_alt_mappings) end
    end,
  })

  vim.api.nvim_create_user_command('Layout', layout_command, {
    nargs = '?',
    complete = function() return { 'toggle', 'qwerty', COLEMAK } end,
  })
  -- An escape hatch that works whatever state things are in: Ctrl chords are sent on
  -- their QWERTY keys and langmap never translates them, in every mode.
  vim.keymap.set({ 'n', 'i', 'v', 'x', 'c', 't', 'o' }, '<C-\\><C-l>', function()
    M.set('qwerty')
  end, { desc = 'Force QWERTY layout' })
end

return M
