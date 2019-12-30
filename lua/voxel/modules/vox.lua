AddCSLuaFile()

module("vox", package.seeall)

function Import(f)
	if f:Read(4) != "VOX " then
		error("Invalid file signature")
	end
end