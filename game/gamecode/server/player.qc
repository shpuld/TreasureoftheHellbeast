//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() PlayerJump =
{
	//if ( !(self.flags & FL_JUMPRELEASED) )
	//	return;	
	//self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	if(time < self.attack_finished || time < self.roll_cooldown)
		return;
	
	self.attack_finished = time + 1;
	self.roll_cooldown = time + 1.5;
	self.frame = 10;
	makevectors(self.fixed_angles);
	self.speedmod = 2;
	
	msg_entity = self;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, JUMP);
	multicast(self.origin, MULTICAST_ONE);
}

void() debug_newfloor;

void() CheckImpulses =
{
	if(self.impulse == 10)
	{
		PlayerJump();
	}
	else if(self.impulse == 222)
	{
		debug_newfloor();
	}

	self.impulse = 0;
}

void() PlayerPreThink =
{
	if(self.deadflag == 1)
	{
		if(self.impulse == 231)
			localcmd("restart\n");
		return;
	}
	
	if(self.isspec != 0)
	{
		if(self.button0 && time > self.ready)
		{
			self.aiment = find(self.aiment, classname, "player");
			if(self.aiment != world)
			{
				sprint(self, PRINT_HIGH, "Now spectating ");
				sprint(self, PRINT_HIGH, self.aiment.netname);
				sprint(self, PRINT_HIGH, "\n");
				
				self.solid = SOLID_NOT;
				self.movetype = MOVETYPE_NONE;
			}
			else
			{
				sprint(self, PRINT_HIGH, "Freefly spectate\n");
				self.movetype = MOVETYPE_FLY;
			}
			self.ready = time + 0.5;
		}
		if(self.aiment != world)
		{
			self.origin = self.aiment.origin;
			self.angles = self.aiment.v_angle;
			self.velocity = self.aiment.velocity;
			self.fixangle = TRUE;
		}
		return;
	}
	
	if(self.armorvalue < 100)
	{
		self.armorvalue += 0.1;
		if(self.armorvalue > 100)
			self.armorvalue = 100;
	}
	
	CheckImpulses();
};

void() PlayerPostThink =
{
	if(self.isspec)
		return;
	
	//footsteps
	if((vlen(self.velocity) > 315) &&( time - self.lastsound_time > 0.5) && (time > self.attack_finished))
	{
		local float movelen = vlen(input_movevalues);
		if(movelen > 300)
		{
			sound(self, CHAN_BODY, "sounds/step.wav", 0.075, 0.5);
			self.lastsound_time = time;
		}
	}
	
	self.oldvelocity = self.velocity;
};

void() ClientKill =
{
};

//called when a client connects to the server
void() ClientConnect =
{
	bprint(PRINT_HIGH, self.netname); //print player name
	bprint(PRINT_HIGH, " connected.\n");
};

void(float floor) load_level;

void() PlayerSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = FALSE;
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/player.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	self.armorvalue = 100;
	self.armortype = 5;
	self.origin = spawnpoint.origin + [0,0,1];
	self.angles = '0 0 0';
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.items = 0;
	self.ready = 0;
	self.readystate = READY;
	self.frame = 1;
	self.animcycle = 0;
	
	the_player = self;
	
	self.slots[0] = spawn();
	self.slots[0].owner = self;
	self.slots[0].attack = attack_quick;

	self.slots[1] = spawn();
	self.slots[1].owner = self;
	self.slots[1].attack = attack_slow;

	self.slots[2] = spawn();
	self.slots[2].owner = self;
	self.slots[2].attack = attack_pound;

	self.slots[3] = spawn();
	self.slots[3].owner = self;
	self.slots[3].attack = attack_heal;
	
	objectives = 0;
	floorcolor = '0.6 0.65 0.8';
	load_level(0);
};

void() SpectatorSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = TRUE;
	self.classname = "spectator";
	self.solid = SOLID_NOT;
	setmodel(self, "");
	self.movetype = MOVETYPE_FLY;
	self.origin = spawnpoint.origin + [0,0,1];
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.aiment = world;
};

//called when a client loads a map
void() PutClientInServer =
{
	//stuffcmd(self, "promptjoin\n");
	//SpectatorSpawn();
	PlayerSpawn();
};

//called when client disconnects from the server
void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};

void() info_player_start =
{
	
};

void(float num) Cmd_action_f =
{
	if(self.deadflag)
		return;
	//sprint(self, PRINT_HIGH, strcat("action number: ", ftos(num), "\n"));
	if(num < 4)
	{
		if(time < self.attack_finished)
			return;
	
		if(self.slots[num] != world)
		{
			local entity oldself = self;
			self = self.slots[num];
	
			if(time > self.attack_finished && time > self.slots[num].attack_finished)
				self.attack();
			
			self = oldself;
		}
	}
	else
	{
		
	}
}

void(float num) Cmd_stopaction_f =
{
	
}

void(string com) SV_ParseClientCommand =
{
	if(com == "joingame")
	{
		if(self.isspec)
		{
			bprint(PRINT_HIGH, self.netname);
			bprint(PRINT_HIGH, " has joined the game.\n");
			PlayerSpawn();
		}
		else
			sprint(self, PRINT_HIGH, "You're already in game!\n");
	}
	else if(com == "specgame")
	{
		if(self.isspec)
			return;
		else
		{
			SpectatorSpawn();
			bprint(PRINT_HIGH, self.netname); //print player name
			bprint(PRINT_HIGH, " has joined the spectators.\n");
		}
	}
	else
	{
		clientcommand(self, com);
	}
};

void() SV_RunClientCommand =
{
	if(self.deadflag == 1)
		return;
	
	if(self.attack_finished > time)
	{
		input_movevalues *= self.speedmod;
		if(self.speedmod > 1)
		{
			makevectors(self.fixed_angles);
			self.velocity = (800*(self.attack_finished - time) + 200) * v_forward;
			runstandardplayerphysics(self);
			return;
		}
	}
	else
	{
		self.speedmod = 1;
	}
	runstandardplayerphysics(self);
	input_angles = '0 0 0';
	if(vlen(input_movevalues) > 100)
	{
		if(self.frame != 2 && time > self.attack_finished)
			self.frame = 2;
		local vector newvec = input_movevalues;
		newvec_y *= -1;
		self.fixed_angles = vectoangles(newvec);
		self.fixed_angles_x = 0;
		self.fixed_angles_z = 0;
	}
	else
	{
		if(self.frame != 1  && time > self.attack_finished)
			self.frame = 1;
	}
	self.angles = self.fixed_angles;
	self.fixangle = TRUE;
} 