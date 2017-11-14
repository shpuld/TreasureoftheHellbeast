
void() ToggleMenu =
{
	in_menu = !in_menu;
	localcmd("pause\n");
}

float(float isnew) playerlisten =
{
	if(isnew)
	{

	}
	if(getstatf(STAT_HEALTH) <= 0)
	{
		self.angles = pl_angles;
		return FALSE;
	}
	if(self.entnum == player_localentnum)
	{
		player = self;
		if(vlen(input_movevalues) > 100)
		{
			local vector newvec = input_movevalues;
			newvec_y *= -1;
			pl_angles = vectoangles(newvec);
			pl_angles_y -= 90;
			pl_angles_x = pl_angles_z = 0;
		}
		if(time < jump_finished)
		{
			pl_angles = vectoangles(self.velocity);
			pl_angles_y -= 90;
			pl_angles_x = pl_angles_z = 0;
		}
	}

	self.angles = pl_angles;
	
	if(weapontime < time && weap.model != "")
	{
		setmodel(weap, "");
	}
	else if((weapontime - time) < 0.2)
	{
		weap.alpha = (weapontime - time) * 5;
	}
	
	local vector pos = gettaginfo(self, gettagindex(self, "weap"));
	setorigin(weap, pos);
	weap.angles = vectoangles(v_right * -1);
	addentity(weap);
	
	return FALSE;
}

float(float isnew) fixlisten = 
{
	self.angles_y -= 90;
	return TRUE;
}


noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	registercommand("togglemenu");
	registercommand("startwalk");
	registercommand("stopwalk");
	registercommand("action");
	registercommand("stopaction");
	registercommand("quitmenu");
	if(serverkey("constate") == "disconnected")
	{
		localcmd("map LD32\n");
	}
	weap = spawn();
	setmodel(weap, "");
	wstr[0] = "H";
	wstr[1] = "J";
	wstr[2] = "K";
	wstr[3] = "L";
	floortime = 0;
	cfloor = 0;
	floorcolor = '0.65 0.6 0.7';
	hp = 100;
	starttime = 0;
	deltalisten("models/player.iqm", playerlisten, 0);
	//deltalisten("models/zombie.iqm", fixlisten, 0);
	//deltalisten("models/demon.iqm", fixlisten, 0);
	//deltalisten("models/orc.iqm", fixlisten, 0);
	ToggleMenu();
};

noref void() CSQC_WorldLoaded =
{	
	precache_model("models/gib1.iqm");
	precache_model("models/gib2.iqm");
	precache_model("models/gib3.iqm");
	precache_model("models/gib4.iqm");
	precache_model("models/stopsign.iqm");
	precache_model("models/fish.iqm");
	precache_model("models/anvil.iqm");
	precache_model("models/flowers.iqm");

	particleeffectnum("weapons.q");
	particleeffectnum("weapons.e");
};

noref void(float isnew) CSQC_Ent_Update =
{
	if(isnew)
		print(strcat(etos(self),"\n"));
}

void() CSQC_Ent_Remove =
{
	remove(self);
}

void() drawfloor =
{
	R_BeginPolygon("floor");
	
	R_PolygonVertex('-2048 2048 0.1', '0 1 0' * (32), floorcolor, 1);
	R_PolygonVertex('2048 2048 0.1', '1 1 0' * (32), floorcolor, 1);
	R_PolygonVertex('2048 -2048 0.1', '1 0 0' * (32), floorcolor, 1);
	R_PolygonVertex('-2048 -2048 0.1', '0 0 0' * (32), floorcolor, 1);
	
	R_EndPolygon();
}

void() drawtransition =
{
	if(floortime > 0)
	{
		floortime -= frametime;
		if(floortime > 2.5)
		{
			drawfill([0, 0, 0], [g_width, g_height, 0], '0 0 0', (3 - floortime)*2, 0);
			drawstring([g_width/2 - 96 + random(), g_height/2 - 12+ random(), 0], strcat(ftos(cfloor), ". FLOOR"), [24, 24, 0], [0.9, 0.4, 0.1],  (3 - floortime)*2, 1);
			drawpic([0, 0, 0], "gfx/overlay2", [g_width, g_height, 0], '1 1 1', (3 - floortime)*2, 1);
		}
		else if(floortime > 0.5)
		{
			drawfill([0, 0, 0], [g_width, g_height, 0], '0 0 0', 1, 0);
			drawstring([g_width/2 - 96+ random(), g_height/2 - 12+ random(), 0], strcat(ftos(cfloor), ". FLOOR"), [24, 24, 0], [0.9, 0.4, 0.1],  1, 1);
			drawpic([0, 0, 0], "gfx/overlay2", [g_width, g_height, 0], '1 1 1', 1, 1);
		}
		else
		{
			drawfill([0, 0, 0], [g_width, g_height, 0], '0 0 0', floortime*2, 0);
			drawstring([g_width/2 - 96+ random(), g_height/2 - 12+ random(), 0], strcat(ftos(cfloor), ". FLOOR"), [24, 24, 0], [0.9, 0.4, 0.1],  floortime*2, 1);
			drawpic([0, 0, 0], "gfx/overlay2", [g_width, g_height, 0], '1 1 1', floortime*2, 1);
		}
	}
}

noref void(float width, float height, float menushown) CSQC_UpdateView =
{
	clearscene();
	g_width = width;
	g_height = height;

	setviewprop(VF_DRAWENGINESBAR, 0);	
	setviewprop(VF_DRAWCROSSHAIR, 0);
	local vector playerorg;
	playerorg = getviewprop(VF_ORIGIN);
	setviewprop(VF_ORIGIN, playerorg + '-400 0 308');
	setviewprop(VF_ANGLES, '35 0 0');
			
	addentities(MASK_ENGINE);
	
	drawfloor();
	
	renderscene();
	drawpic([0, 0, 0], "gfx/overlay", [g_width, g_height, 0], '1 1 1', 1);
	drawpic([0, 0, 0], "gfx/overlay2", [g_width, g_height, 0], '1 1 1', 1, 1);
	
	hp = getstatf(STAT_HEALTH);
	mp = getstatf(STAT_ARMOR);
	
	if(hp < prevhealth)
	{
		hptime = (25 + prevhealth - hp) * 0.1;
		if(hptime > 6)
			hptime = 6;
	}
	else if(hp > prevhealth)
	{
		hptime = (25 + hp - prevhealth) * -0.1;
		if(hptime < -6)
			hptime = -6;
	}
	
	if(hptime > 0)
	{
		hptime -= frametime * 3;
		drawfill([0, 0, 0], [g_width, g_height, 0], '0.65 0 0', 0.1 * hptime, 1);
		if(hptime < 0)
			hptime = 0;
	}
	else if(hptime < 0)
	{
		hptime += frametime * 3;
		drawfill([0, 0, 0], [g_width, g_height, 0], '0.3 0.25 0.5', -0.1 * hptime, 1);
		if(hptime > 0)
			hptime = 0;
	}
	
	prevhealth = hp;
	/*
	drawfill([8, g_height - 56 + 40 * (1 - (hp/100)), 0], [16, 40 * (hp/100), 0], '0.8 0.1 0.15', 1);
	drawfill([g_width - 24, g_height - 56 + 40 * (1 - (mp/100)), 0], [16, 40 * (mp/100), 0], '0.15 0.1 0.8', 1);
	
	drawpic([-16, g_height - 68, 0], "gfx/vial", [64, 64, 0], '1 1 1', 1);
	drawpic([g_width - 64 + 16, g_height - 68, 0], "gfx/vial", [64, 64, 0], '1 1 1', 1);
	
	drawpic([g_width/2 - 64, g_height - 68, 0], "gfx/bar", [128, 64, 0], '1 1 1', 1);
	*/
	local float i = 0;
	local float alp = 1;

	for(i = 0; i < 4; i++)
	{
		alp = 1;
		if(cooldown[i] > 0)
		{
			alp = 0.5;
			cooldown[i] -= frametime;
		}
		if(cooldown[i] < 0)
			cooldown[i] = 0;
	
		//drawstring([g_width/2 - 64 + 22 + i * 24, g_height - 22, 0], wstr[i], [12, 12, 0], [1, alp, alp], alp, 0);
	}
		
	drawtransition();
	
	if(hp <= 0)
	{
		gameovertime += frametime;
		if(gameovertime > 0.75)
			gameovertime = 0.75;
	
		drawfill([0, 0, 0], [g_width, g_height, 0], '0 0 0', gameovertime, 0);
		drawstring([g_width/2 - 108+ random(), g_height/2 - 24+ random(), 0], "GAME OVER", [24, 24, 0], [0.9, 0.4, 0.1],  gameovertime, 1);
		drawstring([g_width/2 - 84+ random(), g_height/2 + 12+ random(), 0], "Restart: ENTER", [12, 12, 0], [0.9, 0.4, 0.1],  gameovertime, 1);
	}
		
	if(starttime < 3)
	{
		starttime += frametime;
		drawfill([0, 0, 0], [g_width, g_height, 0], '0 0 0', (3 - starttime)/2, 0);
	}
	
	if(win)
	{
		drawstring([g_width/2 - 130+ random()*4, g_height/2 - 22+ random()*4, 0], "YOU WIN GG", [24, 24, 0], [0.3, 0.2, 0.05],  0.5, 0);
		drawstring([g_width/2 - 130+ random()*4, g_height/2 - 22+ random()*4, 0], "YOU WIN GG", [24, 24, 0], [0.9, 0.4, 0.1],  1, 0);
	}
	
	if(in_menu)
	{
		Draw_Menu();
	}
};

noref float(string cmd) CSQC_ConsoleCommand =
{
	//self = theplayer;
	//if (!self)
	//	return FALSE;

	tokenize(cmd);
	switch(argv(0))
	{
		case "togglemenu":
			ToggleMenu();
			return TRUE;
			break;
		case "map":
			return FALSE;
			break;
		case "startwalk":
			walk = TRUE;
			return FALSE;
		case "stopwalk":
			walk = FALSE;
			return FALSE;
		case "action":
			sendevent("action", "f", stof(argv(1)));
			return TRUE;
			break;
		case "stopaction":
			sendevent("stopaction", "f", stof(argv(1)));
			return TRUE;
			break;
		case "quitmenu":
			localcmd("quit\n");
			return TRUE;
			break;
		default:
			return FALSE;
	}
	return FALSE;
};

noref float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch(evtype)
	{
	case IE_KEYDOWN:
		return FALSE;
	case IE_KEYUP:
		return FALSE;
	case IE_MOUSEDELTA:
		return FALSE;
	case IE_MOUSEABS:
		//if(devid != 0 && devid != 1)
		//	return FALSE;
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		return FALSE;
	}
	return FALSE;
};

noref void() CSQC_Input_Frame =
{
	//+x = up
	//+y = right
	if(walk)
	{
		input_movevalues *= 0.35;
	}

	input_angles = '0 0 0';
}

noref void() CSQC_Parse_Event =
{
	float firstbyte = readbyte();
	switch(firstbyte)
	{
		case ENEMY_ALERT:
			local float enem = readentitynum();
			break;
		case ENEMY_SUSP:
			local float enem2 = readentitynum();
			break;
		case GIBS:
			local float amount = readbyte();
			local vector pos; 
			pos_x = readcoord();
			pos_y = readcoord();
			pos_z = readcoord();
			local float i;
			for(i = 0; i < amount; i++)
				spawn_gibs(pos);
			break;
		case JUMP:
			jump_finished = time + 1;
			break;
		case WEAP:
			local float num = readbyte();
			if(num == 0)
			{
				setmodel(weap, "models/fish.iqm");
				weapontime = time + 0.5;
				weap.alpha = 1;
				cooldown[0] = 0.35;
			}
			else if(num == 1)
			{
				setmodel(weap, "models/stopsign.iqm");
				weapontime = time + 0.8;
				weap.alpha = 1;
				cooldown[1] = 1.4;
			}
			else if(num == 2)
			{
				setmodel(weap, "models/anvil.iqm");
				weapontime = time + 1.4;
				weap.alpha = 1;
				cooldown[2] = 2.8;
			}
			else if(num == 3)
			{
				setmodel(weap, "models/flowers.iqm");
				weapontime = time + 1;
				weap.alpha = 1;
				pointparticles(particleeffectnum("weapons.heal"), player.origin + '0 0 72', '0 0 24'); 
				cooldown[3] = 5;
			}
			break;
		case NEW_FLOOR:
			if(cfloor <= 2)
			{
				floorcolor = '0.7 0.65 0.6';
			}
			else if(cfloor <= 4)
			{
				floorcolor = '0.7 0.8 0.45';
			}
			else if(cfloor <= 6)
			{
				floorcolor = '0.7 0.6 0.2';
			}
			else if(cfloor <= 8)
			{
				floorcolor = '0.9 0.4 0.3';
			}
			else
			{
				floorcolor = '0.2 0.1 0.35';
			}
			break;
		case NEW_FLOOR1:
			cfloor += 1;
			floortime = 3;
			break;
		case 99:
			local float second = readbyte();
			print(strcat("You still need ", ftos(second), " more.\n"));
			break;
		case 100:
			win = 1;
			break;
	}
}



 