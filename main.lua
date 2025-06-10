local image_extensions = { "png", "jpg", "bmp", "webp", "jpeg", "tiff" }

local function is_image(file)
  local ext = file:match("^.+%.(.+)$")  
  if not ext then
    return false
  end
  for _, im_ext in ipairs(image_extensions) do
    if ext == im_ext then
      return true
    end
  end
  return false
end

local function n(msg, lvl)
  ya.notify({
    title = "Copy Image",
    content = msg,
    timeout = 3,
    level = lvl
  })
end

local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

return {
  entry = function()
    ya.manager_emit("escape", { visual = true })
    local selected = selected_or_hovered()

    if #selected == 0 then
      n("No file selected", "error")
      return
    end

    if #selected > 1 then
      n("Only one image can be copied at a time", "error")
      return
    end

    local file = selected[1]
    local file_name = file:match("[^/\\]+$")

    if not is_image(file) then
      n("Unsupported file type", "error")
      return
    end
    local clip = false

    if not os.execute("test -r " .. file) then
      n("File is not readable: " .. file, "error")
      return
    end

    if os.getenv("XDG_SESSION_TYPE") == "wayland" then
      if file:match("^.+%.(.+)$") == "webp" then
        if not Command("convert"):status() then
          n("You need ImageMagick to copy .webp images", "warn")
          return;
        end
        clip = Command("sh"):arg("-c"):arg("convert " .. file .. " png:- | wl-copy --type image/png") 
      else
        clip = Command("sh"):arg("-c"):arg("wl-copy < " .. file)
      end

      local success, out = clip:output();
      if success then
        n("Copied " .. file_name .. " to clipboard")
        return
      end

      n("Could not copy " .. file_name, "error")
      return
    elseif os.getenv("XDG_SESSION_TYPE") == "x11" then
      local success, cmd = os.execute("xclip -sel c -t image/png -i " .. file .. ">/dev/null 2>&1") 
      if not success then
        n("Could not copy " .. file_name, "error")
        return
      end
        n("Copied " .. file_name)
        return
    else
      n("Unsupported display protocol", "error")
      return
    end

  end
}
