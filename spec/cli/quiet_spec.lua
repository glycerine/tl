local util = require("spec.util")

describe("-q --quiet flag", function()
   setup(util.chdir_setup)
   teardown(util.chdir_teardown)
   it("silences stdout when running tl check", function()
      local name = util.write_tmp_file(finally, [[
         local x: number = 123
      ]])

      local pd = io.popen(util.tl_cmd("check", "-q", name), "r")
      local output = pd:read("*a")
      util.assert_popen_close(true, "exit", 0, pd:close())
      assert.match("", output, 1, true)
   end)
   it("does NOT silence stderr when running tl check", function()
      local name = util.write_tmp_file(finally, [[
         local function add(a: number, b: number): number
            return a + b
         end

         print(add("string", 20))
         print(add(10, true))
      ]])
      local pd = io.popen(util.tl_cmd("check", "-q", name) .. "2>&1", "r")
      local output = pd:read("*a")
      util.assert_popen_close(nil, "exit", 1, pd:close())
      assert.match("2 errors:", output, 1, true)
   end)
   it("silences stdout when running tl gen", function()
      local name = util.write_tmp_file(finally, [[
         local function add(a: number, b: number): number
            return a + b
         end

         print(add(10, 20))
      ]])
      local pd = io.popen(util.tl_cmd("gen", "--quiet", name), "r")
      local output = pd:read("*a")
      util.assert_popen_close(true, "exit", 0, pd:close())
      local lua_name = name:gsub("tl$", "lua")
      assert.match("", output, 1, true)
      util.assert_line_by_line([[
         local function add(a, b)
            return a + b
         end

         print(add(10, 20))
      ]], util.read_file(lua_name))
   end)
   it("does NOT silence stderr when running tl gen", function()
      local name = util.write_tmp_file(finally, [[
         print(add("string", 20))))))
      ]])
      local pd = io.popen(util.tl_cmd("gen", "--quiet", name) .. "2>&1", "r")
      local output = pd:read("*a")
      util.assert_popen_close(nil, "exit", 1, pd:close())
      assert.match("1 syntax error:", output, 1, true)
   end)
end)
