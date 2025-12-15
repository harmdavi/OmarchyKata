-- :SectionAll

local M = {}

local function title_case(str)
  return (str:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end))
end

local function to_tag_name(str)
  return (str:gsub("%s+", "_"))
end

local function has_existing_tags(bufnr, start_line)
  local max_check = math.min(start_line + 10, vim.api.nvim_buf_line_count(bufnr))
  for i = start_line + 1, max_check do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if line:match("Tag%.Name") or line:match("Tag%.Start") or line:match("LABEL%s+START_") then
      return true
    end
  end
  return false
end

function M.section_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if not filename:match("%.mc$") then
    vim.notify("This command only works on .mc files", vim.log.levels.WARN)
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local i = cursor_pos[1]
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local auto_keep_all = false
  local modified_ranges = {} -- store inserted ranges for !q revert

  while i <= total_lines do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    local head_match = line:match("HEAD%s*{%s*(.-)%s*}")

    if head_match and not has_existing_tags(bufnr, i) then
      local title = title_case(head_match)
      local tag = to_tag_name(title)

      -- Build initial insert block
      local insert_block = {
        string.format("# Tag.Name = %s", tag),
        string.format("# Tag.Start = START_%s", tag),
        string.format("# Tag.End = END_%s", tag),
        string.format("  1.005  LABEL        START_%s", tag),
        "",
        string.format("  1.005  LABEL        END_%s", tag),
      }

      -- Insert block into buffer
      vim.api.nvim_buf_set_lines(bufnr, i, i, false, insert_block)
      table.insert(modified_ranges, { start = i, finish = i + #insert_block })

      -- Show inserted block
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.cmd("normal! zz")
      vim.cmd("redraw")

      local ans
      while true do
        if not auto_keep_all then
          local prompt = string.format(
            "Keep changes for '%s'? (y/n/e=edit) [Enter=y, q=quit, !q=quit & revert, a=auto keep]: ",
            head_match
          )
          ans = vim.fn.input(prompt):lower()
        else
          ans = "y"
        end

        if ans == "" then
          ans = "y"
        end

        if ans == "e" then
          -- Prompt user for custom tag name
          local user_input = vim.fn.input("What would you like the name to be changed to? ")
          if user_input ~= "" then
            tag = to_tag_name(user_input)
            -- Update the inserted block with new tag
            local new_block = {
              string.format("# Tag.Name = %s", tag),
              string.format("# Tag.Start = START_%s", tag),
              string.format("# Tag.End = END_%s", tag),
              string.format("  1.005  LABEL        START_%s", tag),
              "",
              string.format("  1.005  LABEL        END_%s", tag),
            }
            vim.api.nvim_buf_set_lines(bufnr, i, i + #insert_block, false, new_block)
            -- Update modified_ranges
            modified_ranges[#modified_ranges].finish = i + #new_block
            insert_block = new_block -- for future calculations
          end
          -- Show updated block
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          vim.cmd("normal! zz")
          vim.cmd("redraw")
          -- After editing, loop back to ask "Keep changes..." again
        else
          break -- exit while loop if not "e"
        end
      end

      -- Handle final decision
      if ans == "y" then
        i = i + #insert_block
        total_lines = vim.api.nvim_buf_line_count(bufnr)
      elseif ans == "n" then
        vim.api.nvim_buf_set_lines(bufnr, i, i + #insert_block, false, {})
      elseif ans == "q" then
        vim.notify("SectionAll stopped by user (keeping changes).", vim.log.levels.INFO)
        break
      elseif ans == "!q" then
        -- revert all modifications
        for idx = #modified_ranges, 1, -1 do
          local range = modified_ranges[idx]
          vim.api.nvim_buf_set_lines(bufnr, range.start, range.finish, false, {})
        end
        vim.notify("SectionAll aborted (all changes reverted).", vim.log.levels.WARN)
        return
      elseif ans == "a" then
        auto_keep_all = true
      else
        -- treat unknown input as 'y'
      end

      vim.cmd("redraw")
    end

    i = i + 1
  end

  vim.notify("SectionAll processing complete.", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("SectionAll", M.section_all, {})

return M
