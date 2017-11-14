
void() Draw_Menu =
{
	drawfill([0, 0, 0], [g_width, g_height, 0], [0, 0, 0], 0.8);
	local float asd = 256;
	drawstring([g_width/2 - strlen("Treasure") * 16, 24 + 32, 0], "Treasure", [32, 32, 0], '1 1 1', 1, 0);
	drawstring([g_width/2 - strlen("of the") * 10, 54 + 32, 0], "of the", [20, 20, 0], '1 1 1', 1, 0);
	drawstring([g_width/2 - strlen("Hellbeast") * 16, 76 + 32, 0], "Hellbeast", [32, 32, 0], '1 1 1', 1, 0);
	drawstring([g_width/2 - strlen("Paused")*12, asd, 0], "Paused", [24, 24, 0], '1 1 1', 1, 0);
	drawstring([24, 60 + asd, 0], "Press ESCAPE to pause/unpause.", [12, 12, 0], '1 1 1', 1, 0);
	drawstring([24, 84 + asd, 0], "Use WSAD to move, HJKL to attack, SPACE to roll.", [12, 12, 0], '1 1 1', 1, 0);
	drawstring([24, 108 + asd, 0],"Abilities use energy and have their own cooldowns.", [12, 12, 0], '1 1 1', 1, 0);
	drawstring([24, 132 + asd, 0],"Go down to hell and steal the demon treasure.", [12, 12, 0], '1 1 1', 1, 0);
	drawstring([24, 204 + asd, 0],"Ludum Dare 32 Compo entry by Shpuld.", [12, 12, 0], '1 1 1', 1, 0);
};