local api, ffi, expand = vim.api, require('ffi'), vim.fn.expand
local ns = api.nvim_create_namespace('CursorWord')
local set_decoration_provider = api.nvim_set_decoration_provider
local cword = nil
ffi.cdef([[
  typedef int32_t linenr_T;
  char *ml_get(linenr_T lnum);
]])
local ml_get = ffi.C.ml_get

local function find_occurences(str, pattern)
  local startPos = 1
  pattern = '%f[%w_]' .. pattern .. '%f[^%w_]'
  return function()
    local foundPos, endPos = string.find(str, pattern, startPos)
    if foundPos then
      startPos = endPos + 1
      return foundPos
    end
  end
end

return {
  setup = function(opt)
    opt = opt or {}
    local exclude = { 'dashboard', 'lazy', 'help', 'markdown', 'nofile', 'terminal', 'prompt' }
    vim.list_extend(exclude, opt.exclude or {})
    api.nvim_set_hl(0, 'CursorWord', {
      underline = true,
      default = true,
    })
    set_decoration_provider(ns, {
      on_win = function(_, winid, bufnr)
        if
          bufnr ~= api.nvim_get_current_buf()
          or vim.iter(exclude):find(function(v)
            return v == vim.bo[bufnr].ft or v == vim.bo[bufnr].buftype
          end)
        then
          return false
        end
        cword = expand('<cword>')
        if not cword:find('%w') then
          return false
        end
        api.nvim_win_set_hl_ns(winid, ns)
      end,
      on_line = function(_, _, bufnr, row)
        local line = ffi.string(ml_get(row + 1))
        local len = #cword
        for spos in find_occurences(line, cword) do
          api.nvim_buf_set_extmark(bufnr, ns, row, spos - 1, {
            end_col = spos + len - 1,
            end_row = row,
            hl_group = 'CursorWord',
            ephemeral = true,
          })
        end
      end,
    })
  end,
}
