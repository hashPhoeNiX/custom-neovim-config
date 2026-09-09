-- Kitty graphics protocol only works in terminals that implement it (Kitty,
-- WezTerm, Ghostty); it's hardcoded=false in Termux specifically (open
-- upstream request: https://github.com/termux/termux-app/issues/5068), and
-- plenty of plain Linux VM/SSH terminals don't support it either. Detect at
-- runtime instead of assuming Kitty everywhere, falling back to sixel (the
-- best broadly-supported option, though also not universal).
local function detect_image_backend()
	if os.getenv("KITTY_WINDOW_ID")
		or os.getenv("WEZTERM_PANE")
		or os.getenv("GHOSTTY_RESOURCES_DIR")
		or (os.getenv("TERM") or ""):match("kitty")
	then
		return "kitty"
	end
	return "sixel"
end

return {
	-- see the image.nvim readme for more information about configuring this plugin
	"3rd/image.nvim",
	opts = {
		backend = detect_image_backend(),
		max_width = 100,
		max_height = 12,
		max_height_window_percentage = math.huge,
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
	},
}
