//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called when starting server/loading the map
void() main =
{
	localcmd("echo Server starting...\n");

}

//called for each frame that QC runs
void() StartFrame =
{
	deathmatch = cvar("deathmatch");
	framecount = framecount + 1;
}

//called when map loaded
void() worldspawn =
{
	precache_model("models/testplayer.iqm");
	precache_model("models/testenemy.iqm");
	precache_model("models/testblock.iqm");
	precache_model("models/ladder.iqm");
	precache_model("models/player.iqm");
	precache_model("models/blob.iqm");
	precache_model("models/zombie.iqm");
	precache_model("models/orc.iqm");
	precache_model("models/demon.iqm");
	precache_model("models/treasure.iqm");
		
	precache_model("models/gib1.iqm");
	precache_model("models/gib2.iqm");
	precache_model("models/gib3.iqm");
	precache_model("models/gib4.iqm");
	
	precache_sound("sounds/step.wav");
	precache_sound("sounds/swing1.wav");
	precache_sound("sounds/swing2.wav");
	precache_sound("sounds/slap.wav");
	precache_sound("sounds/slap2.wav");
	precache_sound("sounds/clang.wav");
	precache_sound("sounds/stomp.wav");
	precache_sound("sounds/hurt.wav");
	precache_sound("sounds/gib.wav");
	precache_sound("sounds/step.wav");
	precache_sound("sounds/heal.wav");
		
	particleeffectnum("weapons.gib");
	particleeffectnum("weapons.slap");
	particleeffectnum("weapons.slowhit");
	particleeffectnum("weapons.stomp");
	particleeffectnum("weapons.heal");
}

void() SpectatorConnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the spectators.\n");
}

 