
void() sub_remove =
{
	remove(self);
}

void(entity target, float amount, vector org) knockback =
{
	target.velocity = normalize(target.origin - org) * amount;
	
	if(target.flags == target.flags | FL_ONGROUND)
		target.flags -= FL_ONGROUND;
}

void() gibtouch =
{
	if(other == self.owner || other == the_player)
		return;
}

void(entity target, float amount) damage =
{
	if(target.armortype == 6)
		return;
	
	if(time < target.dmg_cooldown)
	{
		return;
	}
	
	target.health -= amount;
	
	if(target == the_player)
		target.dmg_cooldown = time + 0.3;
	
	if(target.health <= 0)
	{
		if(target == the_player)
		{
			the_player.frame = 8;
			the_player.deadflag = 1;
		}
		else if(target.takedamage == 1)
		{
			sound(self, 0, "sounds/gib.wav", 0.5, 0.2, 90 + random() * 20);
			WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
			WriteByte(MSG_MULTICAST, GIBS);
			WriteByte(MSG_MULTICAST, 2);
			WriteCoord(MSG_MULTICAST, target.origin_x);
			WriteCoord(MSG_MULTICAST, target.origin_y);
			WriteCoord(MSG_MULTICAST, target.origin_z + 80);
			multicast(target.origin, MULTICAST_PHS);
			remove(target);
		}
	}
	else if(target.takedamage == 1 || target.alerted != 2)
	{
		msg_entity = the_player;
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, ENEMY_ALERT);
		WriteEntity(MSG_MULTICAST, target);
		multicast(self.origin, MULTICAST_ONE);
		self.alerted = 2;
	}
}

void(entity tgt, float tim) stun =
{
	switch(tgt.model)
	{
		case "models/blob.iqm":
			tgt.frame = 2;
			break;
		default:
			tgt.frame = 3;
	}
	tgt.stuntime = time + tim;
}

void() attack_quick =
{
	local entity head = findradius(self.owner.origin, 95);
	local float angle;
	local vector enemyangle;
	local float hit = FALSE;

	self.owner.attack_finished = time + 0.25;
	self.owner.animcycle = !self.owner.animcycle;
	self.owner.frame = 4 + self.owner.animcycle;
	self.owner.speedmod = 0.35;
	sound(self, 0, "sounds/swing1.wav", 0.5, 0.2, 90 + random() * 20);
	
	msg_entity = self.owner;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, WEAP);
	WriteByte(MSG_MULTICAST, 0);
	multicast(self.origin, MULTICAST_ONE);
	
	while(head != world)
	{
		if(head.takedamage == 1)
		{
			enemyangle = vectoangles(head.origin - self.owner.origin);
			angle = self.owner.angles_y - enemyangle_y;
	
			if(angle < -180)
				angle += 360;
	
			if(fabs(angle) < 60)
			{
				hit = TRUE;
				knockback(head, 300, self.owner.origin);
				pointparticles(particleeffectnum("weapons.slap"),(self.owner.origin + head.origin)*0.5 + '0 0 48');
				stun(head, 0.25);
				damage(head, 10);		
			}
		}
		head = head.chain;
	}
	
	if(hit)
		sound(self, 0, "sounds/slap2.wav", 0.5, 0.2, 95 + random() * 10);
}

void() attack_slow =
{
	if(self.owner.armorvalue < 25)
		return;
	
	local entity head = findradius(self.owner.origin, 130);
	local float angle;
	local vector enemyangle;
	local float hit = FALSE;

	self.owner.attack_finished = time + 0.6;
	self.attack_finished = time + 1.4;
	self.owner.frame = 3;
	self.owner.speedmod = 0.1;
	sound(self, 0, "sounds/swing2.wav", 0.4, 0.2, 80 + random() * 15);
	self.owner.armorvalue -= 25;
	
	msg_entity = self.owner;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, WEAP);
	WriteByte(MSG_MULTICAST, 1);
	multicast(self.origin, MULTICAST_ONE);
	
	while(head != world)
	{
		if(head.takedamage == 1)
		{
			enemyangle = vectoangles(head.origin - self.owner.origin);
			angle = self.owner.angles_y - enemyangle_y;
	
			if(angle < -180)
				angle += 360;
	
			if(fabs(angle) < 100)
			{
				hit = TRUE;
				knockback(head, 700, self.owner.origin);
				stun(head, 0.7);
				pointparticles(particleeffectnum("weapons.slowhit"),(((self.owner.origin + head.origin)*0.5) + head.origin)*0.5 + '0 0 48');
				damage(head, 20);
			}
		}
		head = head.chain;
	}
	
	if(hit)
		sound(self, 0, "sounds/clang.wav", 0.5, 0.2, 95 + random() * 10);
}

void() attack_pound2 =
{
	local entity head = findradius(self.owner.origin, 150);
	local float angle;
	local vector enemyangle;
	
	makevectors(self.owner.fixed_angles);
	sound(self, 0, "sounds/stomp.wav", 0.9, 0.2, 80 + random() * 15);
	pointparticles(particleeffectnum("weapons.stomp"),(self.owner.origin + v_forward * 32) + '0 0 24', '0 0 1');
	
	while(head != world)
	{
		if(head.takedamage == 1)
		{
			enemyangle = vectoangles(head.origin - self.owner.origin);
			angle = self.owner.angles_y - enemyangle_y;
	
			if(angle < -180)
				angle += 360;
	
			if(fabs(angle) <= 180)
			{
				knockback(head, 450, self.owner.origin);
				stun(head, 0.8);
				damage(head, 15 + 50 * 1-(vlen(self.owner.origin - head.origin)/150));
			}
		}
		head = head.chain;
	}
	self.nextthink = -1;	
}

void() attack_pound =
{
	if(self.owner.armorvalue < 40)
		return;
	
	self.owner.attack_finished = time + 1.2;
	self.attack_finished = time + 2.8;
	self.owner.frame = 6;
	self.owner.speedmod = 0.1;
	self.nextthink = time + 0.4;
	self.think = attack_pound2;
	sound(self, 0, "sounds/swing2.wav", 0.4, 0.2, 80 + random() * 15);
	self.owner.armorvalue -= 40;

	msg_entity = self.owner;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, WEAP);
	WriteByte(MSG_MULTICAST, 2);
	multicast(self.origin, MULTICAST_ONE);
}

void() attack_heal =
{
	//local entity head = findradius(self.owner.origin, 130);
	//local float angle;
	//local vector enemyangle;

	if(self.owner.armorvalue < 65 || self.owner.health >= 100)
		return;

	self.owner.attack_finished = time + 0.8;
	self.attack_finished = time + 5;
	self.owner.frame = 7;
	self.owner.speedmod = 0.4;
	
	msg_entity = self.owner;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, WEAP);
	WriteByte(MSG_MULTICAST, 3);
	multicast(self.origin, MULTICAST_ONE);
	self.owner.armorvalue -= 65;
	self.owner.health += 40;
	if(self.owner.health > 100)
		self.owner.health = 100;
	
	sound(self, 0, "sounds/heal.wav", 0.6, 0.2, 80 + random() * 15);
	
	/*while(head != world)
	{
		if(head.takedamage == 1)
		{
			enemyangle = vectoangles(head.origin - self.owner.origin);
			angle = self.owner.angles_y - enemyangle_y;
	
			if(angle < -180)
				angle += 360;
	
			if(fabs(angle) < 90)
			{
				knockback(head, 450, self.owner.origin);
				sprint(self.owner, PRINT_HIGH, "hit\n");
			}
		}
		head = head.chain;
	}*/
} 