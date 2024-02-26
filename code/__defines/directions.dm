//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define N_NORTH     2
#define N_SOUTH     4
#define N_EAST      16
#define N_WEST      256
#define N_NORTHEAST 32
#define N_NORTHWEST 512
#define N_SOUTHEAST 64
#define N_SOUTHWEST 1024

#define IS_DIR_DIAGONAL(dir) (dir & (dir - 1))
#define DIR_TO_CARDINAL(dir) (IS_DIR_DIAGONAL(dir) ? (dir & ~(dir & dir - 1)) : dir)
