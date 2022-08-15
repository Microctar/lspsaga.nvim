local wrap = {}
local space = ' '

-- If the content too long.
-- auto wrap according width
-- fill the space with wrap text
function wrap.wrap_text(text, width)
  local ret = {}

  if #text <= width then
    table.insert(ret, text)
    return ret
  end

  local tbl = vim.tbl_filter(function(a)
    return #a ~= 0
  end, vim.split(text, '%s'))

  local start_index, length = 1, 0
  for i, v in pairs(tbl) do
    length = length + #v
    if length > width and i ~= #tbl then
      table.insert(ret, table.concat(tbl, space, start_index, i - 1))
      start_index = i
      length = 0
    end

    if length < width and i == #tbl then
      table.insert(ret, table.concat(tbl, space, start_index))
    end
  end
  return ret
end

function wrap.diagnostic_msg(msg, width)
  if msg:find('\n') then
    local t = vim.tbl_filter(function(s)
      return string.len(s) ~= 0
    end, vim.split(msg, '\n'))

    -- local tmp = vim.tbl_deep_extend('force',{},t)
    return t
  end

  if #msg < width then
    return { msg }
  end

  return wrap.wrap_text(msg, width)
end

function wrap.wrap_contents(contents, width)
  if type(contents) ~= 'table' then
    error('Wrong params type of function wrap_contents')
    return
  end
  local stripped = {}

  for _, text in ipairs(contents) do
    if #text < width then
      table.insert(stripped, text)
    else
      local tmp = wrap.wrap_text(text, width)
      for _, j in ipairs(tmp) do
        table.insert(stripped, j)
      end
    end
  end

  return stripped
end

function wrap.add_truncate_line(contents)
  local line_widths = {}
  local width = 0
  local char = '─'
  local truncate_line = char

  for i, line in ipairs(contents) do
    line_widths[i] = vim.fn.strdisplaywidth(line)
    width = math.max(line_widths[i], width)
  end

  for _ = 1, width, 1 do
    truncate_line = truncate_line .. char
  end

  return truncate_line
end

return wrap
