float() gib_predraw =
{
	if(time + 0.5 > self.life)
	{
		self.alpha = self.life - time;
		if(time > self.life)
			remove(self);
	}
	if(self.origin_z < 0)
		self.velocity_z *= -1;
	
	return FALSE;
}

void(vector pos) spawn_gibs =
{
	local float i;
	local entity gib;
	pointparticles(particleeffectnum("weapons.gib"), pos, '0 0 1');
	for(i = 0; i < 2; i++)
	{
		gib = spawn();
		setmodel(gib, "models/gib1.iqm");
		setorigin(gib, pos + (randomvec() * 20));
		gib.movetype = MOVETYPE_BOUNCE;
		gib.velocity = (randomvec() * 520) + '0 0 75';
		setsize(gib, '-4 -4 -4', '4 4 4');
		gib.avelocity = randomvec() * 1000;
		gib.modelflags = MF_GIB;
		gib.solid = SOLID_NOT;
		gib.scale = 3;
		gib.life = time + 5 + random() * 5;
		gib.drawmask = 1;
		gib.predraw = gib_predraw;
		gib.owner = player;
	}
	for(i = 0; i < 2; i++)
	{
		gib = spawn();
		setmodel(gib, "models/gib2.iqm");
		setorigin(gib, pos + (randomvec() * 20));
		gib.movetype = MOVETYPE_BOUNCE;
		gib.velocity = (randomvec() * 400) + '0 0 75';
		setsize(gib, '-4 -4 -4', '4 4 4');
		gib.avelocity = randomvec() * 1000;
		gib.modelflags = MF_GIB;
		gib.solid = SOLID_NOT;
		gib.scale = 4;
		gib.life = time + 5 + random() * 5;
		gib.drawmask = 1;
		gib.predraw = gib_predraw;
		gib.owner = player;
	}
	for(i = 0; i < 1; i++)
	{
		gib = spawn();
		setmodel(gib, "models/gib3.iqm");
		setorigin(gib, pos + (randomvec() * 20));
		gib.movetype = MOVETYPE_BOUNCE;
		gib.velocity = (randomvec() * 280) + '0 0 75';
		gib.avelocity = randomvec() * 1000;
		setsize(gib, '-4 -4 -4', '4 4 4');
		gib.modelflags = MF_GIB;
		gib.solid = SOLID_NOT;
		gib.scale = 5;
		gib.life = time + 5 + random() * 5;
		gib.drawmask = 1;
		gib.predraw = gib_predraw;
		gib.owner = player;
	}
	for(i = 0; i < 3; i++)
	{
		gib = spawn();
		setmodel(gib, "models/gib4.iqm");
		setorigin(gib, pos + (randomvec() * 20));
		gib.movetype = MOVETYPE_BOUNCE;
		gib.velocity = (randomvec() * 560) + '0 0 75';
		gib.avelocity = randomvec() * 1000;
		setsize(gib, '-4 -4 -4', '4 4 4');
		gib.modelflags = MF_GIB;
		gib.solid = SOLID_NOT;
		gib.scale = 3;
		gib.life = time + 5 + random() * 5;
		gib.drawmask = 1;
		gib.predraw = gib_predraw;
		gib.owner = player;
	}
} 