additive
{
	cull disable
	{
		map $diffuse
		blendFunc GL_SRC_ALPHA GL_ONE
		rgbGen identity
		alphaGen entity
	}
}

vcol
{
	program shaders/vcol.glsl
	{
		rgbGen entity
		alphaGen entity
	}
}

block
{
	{
		map $nearest:models/block/block.png
		rgbGen entity
		alphaGen entity
	}
}

floor
{
	{
		map $nearest:models/block/floor.png
		rgbGen vertex
		alphaGen entity
	}
}