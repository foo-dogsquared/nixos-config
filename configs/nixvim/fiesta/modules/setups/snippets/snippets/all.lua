return {
	s(
		"today",
		f(function()
			return os.date("%F")
		end)
	),

	s(
		"retrieve",
		f(function()
			return string.format("(retrieved %s)", os.date("%F"))
		end)
	),

	s(
		{ trig = 'reldate (-?%d+) "(.+)"', regTrig = true },
		f(function(_, snip)
			-- The point is in number of days.
			local point = 60 * 60 * 24 * snip.captures[1]

			local now = os.time()
			return os.date(snip.captures[2], now + point)
		end)
	),

	s("#!", fmt("#!{}", i(1, "/usr/bin/env bash"))),

	parse("ie", "(i.e., $1)"),
	parse("eg", "(e.g., $1)"),
}
