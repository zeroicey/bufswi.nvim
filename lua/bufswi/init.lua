local M = {}
local api = vim.api

-- 1. Add keymaps to the default configuration
local default_config = {
	width = 60,
	height = 10,
	border = "rounded",
	highlight_group = "Normal",
	current_highlight = "Visual",
	-- Key mappings inside the window
	keymaps = {
		next = { "<Tab>", "j" }, -- Next
		prev = { "<S-Tab>", "k" }, -- Previous
		select = { "<CR>", "<Space>" }, -- Confirm selection
		close = { "<Esc>", "q" }, -- Close window
	},
}

M.config = {}

local state = {
	buf = nil,
	win = nil,
	buffers = {},
	current_idx = 1,
}

local function get_valid_buffers()
	local buffers = {}
	local current_bufnr = api.nvim_get_current_buf()
	local current_entry = nil

	local all_bufs_info = vim.fn.getbufinfo({ buflisted = 1 })

	table.sort(all_bufs_info, function(a, b)
		return a.lastused > b.lastused
	end)

	for _, info in ipairs(all_bufs_info) do
		local name = info.name
		if name == "" then
			name = "[No Name]"
		end
		name = vim.fn.fnamemodify(name, ":~:.")

		local entry = { bufnr = info.bufnr, name = name }

		if info.bufnr == current_bufnr then
			current_entry = entry
		else
			table.insert(buffers, entry)
		end
	end

	if current_entry then
		table.insert(buffers, 1, current_entry)
	end

	return buffers
end

local function close_window()
	if state.win and api.nvim_win_is_valid(state.win) then
		api.nvim_win_close(state.win, true)
	end
	state.win = nil
	state.buf = nil
end

local function select_buffer()
	local target = state.buffers[state.current_idx]
	close_window()
	if target then
		api.nvim_set_current_buf(target.bufnr)
	end
end

local function move_selection(offset)
	local new_idx = state.current_idx + offset
	if new_idx > #state.buffers then
		new_idx = 1
	elseif new_idx < 1 then
		new_idx = #state.buffers
	end
	state.current_idx = new_idx

	if state.win and api.nvim_win_is_valid(state.win) then
		api.nvim_win_set_cursor(state.win, { state.current_idx, 0 })
	end
end

function M.open()
	if state.win and api.nvim_win_is_valid(state.win) then
		move_selection(1)
		return
	end

	state.buffers = get_valid_buffers()
	if #state.buffers == 0 then
		return
	end

	state.current_idx = 1
	if #state.buffers > 1 then
		state.current_idx = 2
	end

	state.buf = api.nvim_create_buf(false, true)
	local lines = {}
	for _, b in ipairs(state.buffers) do
		table.insert(lines, " " .. b.name)
	end
	api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

	local ui = api.nvim_list_uis()[1]
	local width = math.min(M.config.width, ui.width - 4)
	local height = math.min(M.config.height, #state.buffers)
	local row = (ui.height - height) / 2
	local col = (ui.width - width) / 2

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = M.config.border,
	}

	state.win = api.nvim_open_win(state.buf, true, opts)

	api.nvim_win_set_option(state.win, "cursorline", true)
	api.nvim_win_set_option(
		state.win,
		"winhl",
		"Normal:" .. M.config.highlight_group .. ",CursorLine:" .. M.config.current_highlight
	)
	api.nvim_buf_set_option(state.buf, "modifiable", false)

	api.nvim_win_set_cursor(state.win, { state.current_idx, 0 })

	-- 2. Dynamic key binding logic
	local map_opts = { noremap = true, silent = true, buffer = state.buf }

	-- Define the action mapping table
	local actions = {
		next = function()
			move_selection(1)
		end,
		prev = function()
			move_selection(-1)
		end,
		select = select_buffer,
		close = close_window,
	}

	-- Iterate over the config and bind keys
	for action_name, func in pairs(actions) do
		local keys = M.config.keymaps[action_name]
		if keys then
			if type(keys) == "string" then
				vim.keymap.set("n", keys, func, map_opts)
			elseif type(keys) == "table" then
				for _, key in ipairs(keys) do
					vim.keymap.set("n", key, func, map_opts)
				end
			end
		end
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

return M
