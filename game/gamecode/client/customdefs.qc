//Various globals that are used in this FTEQW example are defined here, they are not used by the engine itself

#pragma warning disable Q302
vector cursor_pos; /* Current mouse cursor position, updated in csqc_inputevent */
float g_width, g_height; /* Globals for screen width and height */

float walk;

//Menu stuff
float in_menu; //what menu are we in
float time_in_menu;

entity weap;
entity player;
vector pl_angles;

float jump_finished;
float weapontime;
float cooldown[4];
string wstr[4];
vector floorcolor;
float cfloor;
float prevhealth;
float hptime;
float floortime;
float gameovertime;
float hp;
float mp;
float starttime;
float win;

.float life;

const float ENEMY_ALERT = 10;
const float ENEMY_SUSP = 11;
const float GIBS = 9;
const float JUMP = 8;
const float WEAP = 1;
const float NEW_FLOOR = 7;
const float NEW_FLOOR1 = 6;

const float MENU_NONE = 0;
const float MENU_MAIN = 1;
const float MENU_SINGLE = 2;
const float MENU_MULTI = 4;
const float MENU_SETTINGS = 8;
const float MENU_ABOUT = 16;
const float MENU_JOIN = 32; 