
float(entity viewer, entity target) is_infront =
{
	local vector dir = vectoangles(target.origin - viewer.origin);
	local float angle = viewer.angles_y - dir_y;
	
	if(angle < -180)
		angle += 360;
	
	if(angle > 180)
		angle -= 360;
	
	if(fabs(angle) < 35)
		return TRUE;
	else
		return FALSE;
}

void() enemy_think;

void() dmgtouch =
{
	switch(self.model)
	{
		case "models/blob.iqm":
			if(other == the_player)
				damage(the_player, 8);
			self.touch = 0;
			self.readystate = 0;
			self.velocity = '0 0 0';
			break;
		case "models/zombie.iqm":
			if(other == the_player)
				damage(the_player, 12);
			else if(other == world && vlen(the_player.origin - self.origin) < 40)
				damage (the_player, 12);
			self.readystate = 0;
			self.velocity = '0 0 0';
			break;
		case "models/orc.iqm":
			if(other == the_player)
				damage(the_player, 14);
			else if(other == world && vlen(the_player.origin - self.origin) < 40)
				damage (the_player, 14);
			self.readystate = 0;
			self.velocity = '0 0 0';
			break;
		case "models/demon.iqm":
			if(other == the_player)
				damage(the_player, 16);
			else if(other == world && vlen(the_player.origin - self.origin) < 40)
				damage (the_player, 14);
			self.readystate = 0;
			self.velocity = '0 0 0';
			break;
	}
}

void() enemy_attack =
{
	switch(self.model)
	{
		case "models/blob.iqm":
			self.touch = dmgtouch;
			self.think = enemy_think;
			self.readystate = 0;
			self.frame = 2;
			self.velocity = (normalize(the_player.origin - self.origin) + '0 0 0.2') * 350;
			self.nextthink = time + 1;
			break;
		case "models/zombie.iqm":
			self.touch = dmgtouch;
			self.think = enemy_think;
			self.readystate = 0;
			self.frame = 2;
			self.velocity = (normalize(the_player.origin - self.origin) + '0 0 0.2') * 150;
			self.nextthink = time + 1;
			break;
		case "models/orc.iqm":
			self.touch = dmgtouch;
			self.think = enemy_think;
			self.readystate = 0;
			self.frame = 2;
			self.velocity = (normalize(the_player.origin - self.origin) + '0 0 0.2') * 150;
			self.nextthink = time + 0.6;
			break;
		case "models/demon.iqm":
			self.touch = dmgtouch;
			self.think = enemy_think;
			self.readystate = 0;
			self.frame = 2;
			self.velocity = (normalize(the_player.origin - self.origin) + '0 0 0.2') * 150;
			self.nextthink = time + 0.6;
			break;
	}
	self.think = enemy_think;
}

void() enemy_think =
{
	self.angles_y += self.anglehack;
	self.fixangle = TRUE;
	if(self.flags == self.flags | FL_ONGROUND)
		self.velocity = self.velocity * 0.85;
	
	local vector tempangle;
	
	if(self.stuntime > time)
	{
		self.nextthink = time + 0.05;
		self.think = enemy_think;
		self.readystate = 0;
		self.ready = 0;
		self.touch = 0;
		self.angles_y -= self.anglehack;
		self.fixangle = TRUE;
		return;
	}
	
	if(self.touch != 0)
		self.touch = 0;
	
	if(self.alerted == 0)
	{
		local float distance = vlen(self.origin - the_player.origin);

		if(is_infront(self, the_player))
		{

			if(distance < 650)
			{
				msg_entity = the_player;
				WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
				WriteByte(MSG_MULTICAST, ENEMY_SUSP);
				WriteEntity(MSG_MULTICAST, self);
				multicast(self.origin, MULTICAST_ONE);
				tempangle = vectoangles(the_player.origin - self.origin);
				self.targetyaw = tempangle_y;
				self.alerted = 1;
				self.alerttime = time + 3;
			}
		}
		else if(distance < 350)
		{
			if(vlen(the_player.velocity) > 270)
			{
				msg_entity = the_player;
				WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
				WriteByte(MSG_MULTICAST, ENEMY_SUSP);
				WriteEntity(MSG_MULTICAST, self);
				multicast(self.origin, MULTICAST_ONE);
				tempangle = vectoangles(the_player.origin - self.origin);
				self.targetyaw = tempangle_y;
				self.alerted = 1;
				self.alerttime = time + 5;
			}
		}
		if(self.alerted == 1)
		{
			self.movetarget = the_player.origin;
		}
	}	
	else if(self.alerted == 1)
	{
		if(is_infront(self, the_player))
		{
			local float distance2 = vlen(self.origin - the_player.origin);
			if(distance2 < 450)
			{
				msg_entity = the_player;
				WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
				WriteByte(MSG_MULTICAST, ENEMY_ALERT);
				WriteEntity(MSG_MULTICAST, self);
				multicast(self.origin, MULTICAST_ONE);
				self.alerted = 2;
			}
		}
		else
		{
			if(time > self.alerttime)
				self.alerted = 0;
	
			local float sub = self.angles_y - self.targetyaw;
			if(sub < -180)
				sub += 360;
	
			if(sub > 180)
				sub -= 360;
	
			if(sub > 0)
			{
				self.angles_y -= 8.5;
				self.fixangle = TRUE;
			}
			else
			{
				self.angles_y += 8.5;
				self.fixangle = TRUE;
			}
	
			if(fabs(sub) < 10)
			{
				if(vlen(self.velocity) < self.maxspeed*0.5)
				{
					self.velocity += normalize(self.movetarget - self.origin) * 40;
				}
				if(vlen(self.movetarget - self.origin) < 150)
				{
					self.alerted = 0;
				}
			}
		}
	}
	else if(self.alerted == 2)
	{
		tempangle = vectoangles(the_player.origin - self.origin);
	
		local float sub2 = self.angles_y - tempangle_y;
	
		if(sub2 < -180)
			sub2 += 360;
	
		if(sub2 > 180)
			sub2 -= 360;
	
		if(sub2 > 0)
		{
			self.angles_y -= 13;
			if(self.angles_y < tempangle_y)
				self.angles_y = tempangle_y;
			self.fixangle = TRUE;
		}
		else
		{
			self.angles_y += 13;
			if(self.angles_y > tempangle_y)
				self.angles_y = tempangle_y;
			self.fixangle = TRUE;
		}
	
		if(vlen(the_player.origin - self.origin) < 150 && self.readystate == 0)
		{
			self.ready = time + 0.6;
			self.readystate = 1;
			self.frame = 0;
		}
	
		switch(self.readystate)
		{
			case 0:
				break;
			case 1:
				if(time > self.ready)
				{
					self.nextthink = time + 0.1;
					self.think = enemy_attack;
					self.readystate = 0;
					self.angles_y -= self.anglehack;
					self.fixangle = TRUE;
					return;
				}
				break;
			default:
				break;
		}
	
		if(fabs(sub2) < 10 && self.readystate == 0)
		{
			if(vlen(self.velocity) < self.maxspeed)
			{
				self.velocity += normalize(the_player.origin - self.origin) * 40;
			}
		}
	}
	
	if(time > self.stuntime)
	{
		if(vlen(self.velocity) > 50)
			self.frame = 1;
		else
			self.frame = 0;
	}
	
	self.nextthink = time + 0.05;
	self.think = enemy_think;
	self.angles_y -= self.anglehack;
	self.fixangle = TRUE;
}

entity() enemy_blob =
{
	local entity newent = spawn();
	newent.classname = "enemy"; //keep classnames same for clearing
	newent.health = 40;
	newent.takedamage = 1;
	setmodel(newent, "models/blob.iqm");
	setsize(newent, '-20 -20 0', '20 20 64');
	newent.solid = SOLID_BBOX;
	newent.movetype = MOVETYPE_WALK;
	newent.maxspeed = 365;
	newent.gravity = 1;
	newent.alerted = 0;
	newent.angles_y = random() * 360;
	newent.fixangle = TRUE;
	newent.think = enemy_think;
	newent.nextthink = time + random();
	return newent;
}

entity() enemy_blobsmall =
{
	local entity newent = spawn();
	newent.classname = "enemy"; //keep classnames same for clearing
	newent.health = 20;
	newent.scale = 0.6;
	newent.colormod = '0.7 0.5 0.5';
	newent.takedamage = 1;
	setmodel(newent, "models/blob.iqm");
	setsize(newent, '-20 -20 0', '20 20 64');
	newent.solid = SOLID_BBOX;
	newent.movetype = MOVETYPE_WALK;
	newent.maxspeed = 365;
	newent.gravity = 1;
	newent.alerted = 0;
	newent.angles_y = random() * 360;
	newent.fixangle = TRUE;
	newent.think = enemy_think;
	newent.nextthink = time + random();
	return newent;
}

entity() enemy_zombie =
{
	local entity newent = spawn();
	newent.classname = "enemy"; //keep classnames same for clearing
	newent.health = 60;
	newent.takedamage = 1;
	newent.scale = 0.9;
	setmodel(newent, "models/zombie.iqm");
	setsize(newent, '-20 -20 0', '20 20 64');
	newent.solid = SOLID_BBOX;
	newent.movetype = MOVETYPE_WALK;
	newent.maxspeed = 150;
	newent.gravity = 1;
	newent.alerted = 0;
	newent.angles_y = random() * 360;
	newent.fixangle = TRUE;
	newent.think = enemy_think;
	newent.nextthink = time + random();
	newent.anglehack = 90;
	return newent;
}

entity() enemy_orc =
{
	local entity newent = spawn();
	newent.classname = "enemy"; //keep classnames same for clearing
	newent.health = 70;
	newent.takedamage = 1;
	newent.scale = 1.1;
	setmodel(newent, "models/orc.iqm");
	setsize(newent, '-20 -20 -8', '20 20 64');
	newent.solid = SOLID_BBOX;
	newent.movetype = MOVETYPE_WALK;
	newent.maxspeed = 220;
	newent.gravity = 1;
	newent.alerted = 0;
	newent.angles_y = random() * 360;
	newent.fixangle = TRUE;
	newent.think = enemy_think;
	newent.nextthink = time + random();
	newent.anglehack = 90;
	return newent;
}

entity() enemy_demon =
{
	local entity newent = spawn();
	newent.classname = "enemy"; //keep classnames same for clearing
	newent.health = 90;
	newent.takedamage = 1;
	newent.scale = 1.4;
	setmodel(newent, "models/demon.iqm");
	setsize(newent, '-20 -20 -32', '20 20 64');
	newent.solid = SOLID_BBOX;
	newent.movetype = MOVETYPE_WALK;
	newent.maxspeed = 280;
	newent.gravity = 1;
	newent.alerted = 0;
	newent.angles_y = random() * 360;
	newent.fixangle = TRUE;
	newent.think = enemy_think;
	newent.nextthink = time + random();
	newent.anglehack = 90;
	return newent;
}


void() enemy_test =
{
	self.takedamage = 1;
	setmodel(self, "models/testenemy.iqm");
	setsize(self, '-16 -16 -24', '16 16 32');
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_WALK;
	self.gravity = 1;
	self.alerted = 0;
	self.think = enemy_think;
	self.nextthink = time + random();
} 