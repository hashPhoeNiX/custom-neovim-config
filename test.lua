local f = io.open('init.lua', 'r') 
print(f:read("*all"))
f:close()

local http = require("http")

-- response, err = http.request("GET", "")
