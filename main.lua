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
      return ya.notify({ title = "Copy Image", content = "No file selected", timeout = 3 })
    end

    if #selected > 1 then
      return ya.notify({ title = "Copy Image", content = "Only one image can be copied at a time", timeout = 3 })
    end

    local file = selected[1]
    if not is_image(file) then
      return ya.notify({ title = "Copy Image", content = "Unsupported file (" .. tostring(file) .. ")", timeout = 3 })
    end

    local clip = false
    if os.getenv("WAYLAND_DISPLAY") then
      clip = Command("sh"):arg("-c"):arg("wl-copy < " .. file)
    else
      return ya.notify({ title = "Copy Image", content = "Could not copy image", timeout = 3})
    end

    -- TODO: add support for X11

    if not os.execute("test -r " .. file) then
      return ya.notify({ title = "Copy Image", content = "File is not readable: " .. file, timeout = 3 })
    end
    local success, out = clip:output();
    if success then
      return ya.notify({ title = "Copy Image", content = "Copied image to clipboard", timeout = 3})
    end

    return ya.notify({ title = "Copy Image", content = "Could not copy image", timeout = 3})
  end
}
