--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		-- width = 400,
		-- height = 800, 

		-- width = display.pixelWidth,
		-- height = display.pixelHeight,
		scale = "adaptive",
		fps = 60,
		
		imageSuffix =
		{
			    ["@2x"] = 1.5,
			    ["@4x"] = 2.5,
		},

		-- shaderPrecision = "highp",
	},
}
