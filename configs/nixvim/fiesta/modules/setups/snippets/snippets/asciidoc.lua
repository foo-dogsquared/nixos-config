function max_asciidoc_header(level)
	return math.min(level, 6)
end

return {
	parse("bf", "**$1**"),
	parse("it", "__$1__"),
	parse("sp", "^$1^"),
	parse("sb", "~$1~"),
	s(
		"tt",
		fmt("{}{}{}", {
			c(1, { t("`"), t("`+") }),
			i(2, "TEXT"),
			rep(1),
		})
	),

	parse("foot", "footnote:[$1]"),

	s(
		"link",
		fmt("link:{}[{}]", {
			i(1, "LINK"),
			rep(1),
		})
	),

	parse("var", ":$1: $2"),

	parse("audio", "audio::$1[$2]"),
	parse("video", "video::$1[$2]"),

	s(
		"img",
		fmt(
			[[
        .{}
        image::{}[{}, {}]
        {}
      ]],
			{
				i(1, "CAPTION"),
				i(2, "IMAGE_PATH"),
				i(3, "ALT_TEXT"),
				i(4, "width=100%,height=100%"),
				i(0),
			}
		)
	),

	s(
		"fmt",
		fmt("{}{}{}", {
			c(1, {
				t("**"),
				t("__"),
				t("`"),
			}),
			i(2),
			rep(1),
		})
	),

	s(
		"dt",
		fmt(
			[[
        {}::
        {}
      ]],
			{
				i(1, "TERM"),
				i(2, "DEFINITION"),
			}
		)
	),

	s(
		"src",
		fmt(
			[[
        [source, {}]
        ----
        {}
        ----
        {}
      ]],
			{
				i(1, "LANGUAGE"),
				i(2, "CODE"),
				i(0),
			}
		)
	),

	s(
		{ trig = "h(%d)", regTrig = true },
		fmt(
			[[
          {} {}
          {}
          {}
        ]],
			{
				f(function(_, snip)
					local level = max_asciidoc_header(snip.captures[1])
					return string.rep("=", level)
				end),
				i(1, "CHAPTER"),
				d(2, function(_, snip)
					local nodes = {}
					table.insert(nodes, t(""))

					local level = max_asciidoc_header(snip.captures[1])

					if level == 1 then
						table.insert(nodes, t(":toc:"))
					end

					local parent = c(1, nodes)
					if level > 1 then
						parent = t("")
					end

					return sn(nil, parent)
				end, {}),
				i(0),
			}
		)
	),

	s(
		"admon",
		fmt("{}: {}", {
			c(1, {
				t("NOTE"),
				t("TIP"),
				t("IMPORTANT"),
				t("CAUTION"),
				t("WARNING"),
			}),
			i(0),
		})
	),

	s(
		"admonB",
		fmt(
			[[
        [{}]
        ====
        {}
        ====
        {}
      ]],
			{
				c(1, {
					t("NOTE"),
					t("TIP"),
					t("IMPORTANT"),
					t("CAUTION"),
					t("WARNING"),
				}),
				i(2, "BODY"),
				i(0),
			}
		)
	),
}
