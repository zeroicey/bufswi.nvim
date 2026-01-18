# bufswi.nvim

Lightweight buffer switcher for Neovim. Opens a centered floating window listing your "listed" buffers (ordered by last used), with simple, ergonomic keys to move, select, and close. Minimal surface, no dependencies.

– Repository: https://github.com/zeroicey/bufswi.nvim

## Features
- Centered floating window with adjustable `width`/`height` and `border`.
- Highlights via `highlight_group` and `current_highlight`.
- Wrap-around selection (move past end → back to top).
- Customizable in-window keymaps; sensible defaults.
- No external dependencies; works with built-in Neovim APIs.

## Requirements
- Neovim 0.8+ (0.9+ recommended).

## Installation (lazy.nvim)
Add the spec to your lazy.nvim plugin list. Lazy will call `require("bufswi").setup(opts)` automatically.

```lua
{
	-- 1) Point to your GitHub repo
	"zeroicey/bufswi.nvim",

	-- 2) Lazy-load on a key: only loads when pressing <leader><Tab>
	--    This keeps startup fast
	keys = {
		{
			"<leader><Tab>", -- <leader> is often Space by default
			function()
				require("bufswi").open()
			end,
			desc = "Switch Buffer (Bufswi)", -- shows in which-key and command palettes
		},
	},

	-- 3) Options passed to setup()
	--    Lazy will automatically call require("bufswi").setup(opts)
	opts = {
		-- Window appearance
		width = 60,
		height = 10,
		border = "rounded", -- options: 'single', 'double', 'rounded', 'solid', 'shadow'
		highlight_group = "Normal", -- background highlight group for the window
		current_highlight = "Visual", -- highlight group for the selected line

		-- In-window keymap configuration (override defaults)
		-- If you prefer defaults, you can omit this entire keymaps section
		keymaps = {
			-- Accepts strings or lists, e.g. next = { "<Tab>", "j", "<C-n>" }
			next = { "<Tab>", "j" },
			prev = { "<S-Tab>", "k" },
			select = { "<CR>", "<Space>" },
			close = { "<Esc>", "q" },
		},
	},
}
```

## Usage
- Press `<leader><Tab>` (from the example above) to open the buffer switcher.
- Move selection with `Tab`/`j` (Next) and `Shift-Tab`/`k` (Previous).
- Confirm with `Enter` or `Space`; close with `Esc` or `q`.
- You can also call directly:

```lua
require("bufswi").open()
```

Buffers are shown using Neovim's "listed" buffers. Unnamed buffers appear as `[No Name]`. The currently active buffer is pinned to the top of the list for quick toggling.

## Configuration
Below are the defaults. You can pass a partial table to `setup()`; missing keys will fall back to these values.

```lua
require("bufswi").setup({
	width = 60,
	height = 10,
	border = "rounded",
	highlight_group = "Normal",
	current_highlight = "Visual",
	keymaps = {
		next = { "<Tab>", "j" },
		prev = { "<S-Tab>", "k" },
		select = { "<CR>", "<Space>" },
		close = { "<Esc>", "q" },
	},
})
```

### Notes on highlights
- `highlight_group` applies to the window background (via `winhl`).
- `current_highlight` applies to the selected line (`CursorLine`).

Example tweak:

```lua
require("bufswi").setup({
	highlight_group = "NormalFloat",
	current_highlight = "Visual",
})
```

## API
- `setup(opts)`: Initialize configuration.
- `open()`: Open the floating buffer switcher window.

## Troubleshooting
- Nothing shows up: ensure you have listed buffers (e.g. `:ls`) and you are not filtering them out elsewhere.
- Window looks off-center: happens in very small terminals; reduce `width`/`height`.
- Custom highlights not visible: verify your colorscheme defines the specified highlight groups.

## Contributing
Issues and PRs are welcome. Please keep changes small and focused.

## License
MIT. See `LICENSE`.

