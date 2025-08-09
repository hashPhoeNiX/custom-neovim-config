return {
  -- "at-popup",
  dir = "/Users/oluwapelumiadeosun/Projects/lua-tutorials/at-popup",
  config = function()
    print("not sure this plugin is working")
    require("at-popup").setup({
      message = "Hello there, this is @ symbol being tested",
      delay = 100, -- ms delay before showing popup
    })
  end,
}
