-- lua/custom/head_command.lua
-- Command: :Head
-- Works in normal buffers; previews generated code in a split; uses vim.fn.input() prompts.

local api = vim.api

local function format_title(str)
  return (str:gsub("(%S+)", function(w)
    return w:sub(1, 1):upper() .. w:sub(2):lower()
  end))
end

local function open_preview_in_split(lines, title)
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "modifiable", false)

  local orig_win = api.nvim_get_current_win()
  local height = math.min(#lines + 2, 10)
  vim.cmd("belowright " .. height .. "split")
  local win = api.nvim_get_current_win()
  api.nvim_win_set_buf(win, buf)
  api.nvim_win_set_option(win, "number", false)
  api.nvim_win_set_option(win, "relativenumber", false)
  api.nvim_win_set_option(win, "wrap", false)
  api.nvim_buf_set_name(buf, title or "Head Preview")

  -- return focus to original window
  api.nvim_set_current_win(orig_win)
  return { buf = buf, win = win }
end

local function close_preview(preview)
  if not preview then
    return
  end
  if preview.win and api.nvim_win_is_valid(preview.win) then
    pcall(api.nvim_win_close, preview.win, true)
  end
  if preview.buf and api.nvim_buf_is_valid(preview.buf) then
    pcall(api.nvim_buf_delete, preview.buf, { force = true })
  end
end

local function build_block(head_text, tag_base)
  return {
    string.format("1.012  HEAD         {%s}", head_text),
    string.format("# Tag.Name = %s", tag_base),
    string.format("# Tag.Start = START_%s", tag_base),
    string.format("# Tag.End = END_%s", tag_base),
    string.format("  1.005  LABEL        START_%s", tag_base),
    "",
    string.format("  1.005  LABEL        END_%s", tag_base),
  }
end

api.nvim_create_user_command("Head", function()
  local orig_win = api.nvim_get_current_win()
  local orig_row = api.nvim_win_get_cursor(orig_win)[1]

  -- Step 1: ask for head text (visible prompt + input)
  print("What would you like the head text to be?")
  local head_text = vim.fn.input("Head Text: ")
  if head_text == "" then
    print("Cancelled — no input provided.")
    return
  end

  local formatted = format_title(head_text)
  local tag_base = formatted:gsub("%s+", "_")
  local lines = build_block(head_text, tag_base)
  local preview = open_preview_in_split(lines, "Generated Code Preview")

  -- Step 2: ask segmentation option
  print("Would you like a segmented syntax? (y/n/e)")
  local resp = vim.fn.input("Segmented syntax: ")

  close_preview(preview)

  if resp == "" or resp:lower() == "y" then
    api.nvim_put(lines, "l", true, true)
  elseif resp:lower() == "n" then
    api.nvim_put({ lines[1] }, "l", true, true)
  elseif resp:lower() == "e" then
    print("What would you like to change the tag/LABEL title to?")
    local edit_title = vim.fn.input("New Tag/LABEL Title: ")
    if edit_title == "" then
      print("Edit cancelled.")
      return
    end

    local new_tag = edit_title:gsub("%s+", "_")
    local edited = build_block(head_text, new_tag)
    local preview2 = open_preview_in_split(edited, "Edited Code Preview")

    print("Would you like a segmented syntax? (y/n)")
    local final = vim.fn.input("Segmented syntax: ")

    close_preview(preview2)

    if final == "" or final:lower() == "y" then
      api.nvim_put(edited, "l", true, true)
    else
      api.nvim_put({ edited[1] }, "l", true, true)
    end
  else
    print("Cancelled.")
  end
end, {
  desc = "Insert a formatted HEAD command with optional segmentation",
})
