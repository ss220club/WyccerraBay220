#define TURF_REMOVE_CROWBAR FLAG(0)
#define TURF_REMOVE_SCREWDRIVER FLAG(1)
#define TURF_REMOVE_SHOVEL FLAG(2)
#define TURF_REMOVE_WRENCH FLAG(3)
#define TURF_CAN_BREAK FLAG(4)
#define TURF_CAN_BURN FLAG(5)
#define TURF_HAS_EDGES FLAG(6)
#define TURF_HAS_CORNERS FLAG(7)
#define TURF_HAS_INNER_CORNERS FLAG(8)
#define TURF_IS_FRAGILE FLAG(9)
#define TURF_ACID_IMMUNE FLAG(10)
#define TURF_IS_WET FLAG(11)
#define TURF_HAS_RANDOM_BORDER FLAG(12)
#define TURF_DISALLOW_BLOB FLAG(13)

//Used for floor/wall smoothing
#define SMOOTH_NONE 0	//Smooth only with itself
#define SMOOTH_ALL 1	//Smooth with all of type
#define SMOOTH_WHITELIST 2	//Smooth with a whitelist of subtypes
#define SMOOTH_BLACKLIST 3 //Smooth with all but a blacklist of subtypes

/// Finds turfs block with desired center and radius. Make sure that `center` has valid x,y,z. If it's in loc of another non-turf atom, it's coordinates will be (0,0,0)
#define RANGE_TURFS(CENTER, RADIUS) block(locate(max(CENTER.x-(RADIUS), 1), max(CENTER.y-(RADIUS),1), CENTER.z), locate(min(CENTER.x+(RADIUS), world.maxx), min(CENTER.y+(RADIUS), world.maxy), CENTER.z))
/// The same as `RANGE_TURFS` but with center excluded
#define ORANGE_TURFS(CENTER, RADIUS) RANGE_TURFS(CENTER, RADIUS) - CENTER

///Returns all currently loaded turfs
#define ALL_TURFS(...) block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
