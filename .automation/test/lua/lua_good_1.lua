local embracer = {}

local function helper()
   -- NYI wontfix
end

function embracer.embrace(opt)
   opt = opt or "default"
   return helper(opt.."?")
end

return embracer
