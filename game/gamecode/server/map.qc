
void() new_floor;

void() debug_newfloor =
{
	new_floor();
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, NEW_FLOOR1);
	multicast('0 0 0', MULTICAST_ALL_R);
}

void() ladder_touch =
{
	self.touch = 0;
	self.nextthink = time + 0.5;
	self.think = new_floor;
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, NEW_FLOOR1);
	multicast('0 0 0', MULTICAST_ALL_R);
}

void() treasure_touch =
{
	objectives += 1;
	if(objectives != 4)
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 99);
		WriteByte(MSG_MULTICAST, 4 - objectives);
		multicast('0 0 0', MULTICAST_ALL_R);
	}
	else
	{
		other.armortype = 6;
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 100);
		multicast('0 0 0', MULTICAST_ALL_R);
	}

	pointparticles(particleeffectnum("weapons.slowhit"), self.origin + '0 0 32');
	remove(self);
}

void(string line, float i) spawnrow =
{
	local string char;
	local entity newblock;
	local float j;
	for(j = 0; j < 32; j++)
	{
		char = substring(line, j, 1);
		if(char == "X")
		{
			newblock = spawn();
			setmodel(newblock, "models/testblock.iqm");
			newblock.classname = "block";
			setsize(newblock, '-64 -64 -16', '64 64 64');
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 0] - [2048 + 64, 2048 + 64, 0]);
			newblock.solid = SOLID_BBOX;
			newblock.colormod = floorcolor;
		}
		else if(char == "B")
		{
			newblock = enemy_blob();
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 0] - [2048 + 64, 2048 + 64, 0]);
		}
		else if(char == "b")
		{
			newblock = enemy_blobsmall();
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 0] - [2048 + 64, 2048 + 64, 0]);
		}
		else if(char == "Z")
		{
			newblock = enemy_zombie();
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 0] - [2048 + 64, 2048 + 64, 0]);
		}
		else if(char == "O")
		{
			newblock = enemy_orc();
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 8] - [2048 + 64, 2048 + 64, 0]);
		}
		else if(char == "d")
		{
			newblock = enemy_demon();
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 32] - [2048 + 64, 2048 + 64, 0]);
		}
		else if(char == "D") //ladder down
		{
			newblock = spawn();
			setmodel(newblock, "models/ladder.iqm");
			newblock.classname = "block";
			setsize(newblock, '-64 -64 -16', '64 64 64');
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 0] - [2048 + 64, 2048 + 64, 0]);
			newblock.solid = SOLID_TRIGGER;
			newblock.touch = ladder_touch;
		}
		else if(char == "S") //start
		{
			setorigin(the_player, [(32 - i) * 128, (32 - j) * 128, 64] - [2048 + 64, 2048 + 64, 0]);
		}
		else if(char == "1") //objective
		{
			newblock = spawn();
			setmodel(newblock, "models/treasure.iqm");
			newblock.classname = "block";
			setsize(newblock, '-64 -64 -16', '64 64 64');
			setorigin(newblock, [(32 - i) * 128, (32 - j) * 128, 0] - [2048 + 64, 2048 + 64, 0]);
			newblock.solid = SOLID_TRIGGER;
			newblock.modelflags += MF_ROTATE;
			newblock.touch = treasure_touch;
		}
	}
}

void(float floor) load_level =
{
	local float filehandle = fopen(strcat("levels/", ftos(floor)), FILE_READ);
	if(filehandle == -1)
		sprint(the_player, PRINT_HIGH, "no such level\n");
	else
	{
		local string line = fgets(filehandle);
		local float i;
		for(i = 0; i < 32; i++)
		{
			spawnrow(line, i);
			line = fgets(filehandle);
		}
		fclose(filehandle);
	}
}

void() clear_level =
{
	local entity head = find(world, classname, "block");
	local entity tempent = head;

	while(tempent != world)
	{
		tempent = find(head, classname, "block");
		remove(head);
		head = tempent;
	}
	
	head = find(world, classname, "enemy");
	tempent = head;
	while(tempent != world)
	{
		tempent = find(head, classname, "enemy");
		remove(head);
		head = tempent;
	}
}


void() new_floor =
{
	clear_level();
	cfloor += 1;
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, NEW_FLOOR);
	multicast('0 0 0', MULTICAST_ALL_R);
	
	if(cfloor <= 2)
	{
		floorcolor = '0.4 0.45 0.5';
	}
	else if(cfloor <= 4)
	{
		floorcolor = '0.35 0.5 0.15';
	}
	else if(cfloor <= 6)
	{
		floorcolor = '0.5 0.3 0.1';
	}
	else if(cfloor <= 8)
	{
		floorcolor = '0.4 0.1 0.05';
	}
	else
	{
		floorcolor = '0.1 0.05 0.15';
	}
	
	load_level(cfloor);
} 