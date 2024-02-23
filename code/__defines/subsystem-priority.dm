// Something to remember when setting priorities: SS_TICKER runs before Normal, which runs before SS_BACKGROUND.
// Each group has its own priority bracket.
// SS_BACKGROUND handles high server load differently than Normal and SS_TICKER do.
// Higher priority also means a larger share of a given tick before sleep checks.

#define FIRE_PRIORITY_INPUT 1000 // Input MUST ALWAYS BE HIGHEST PRIORITY!!!
#define FIRE_PRIORITY_TIMER 950
#define FIRE_PRIORITY_OVERLAYS 900
#define FIRE_PRIORITY_CHAT 850  // Chat
#define FIRE_PRIORITY_TICKER 800 // Gameticker.
#define FIRE_PRIORITY_TGUI 750
#define FIRE_PRIORITY_NANO 749 // Updates to nanoui uis.

#define FIRE_PRIORITY_PROCESSING 700 // Default priority for all processing subsystems

#define FIRE_PRIORITY_MOB 650  // Mob Life().
#define FIRE_PRIORITY_MACHINERY 600  // Machinery + powernet ticks.
#define FIRE_PRIORITY_PLANTS 550
#define FIRE_PRIORITY_AIR 500  // ZAS processing.
#define FIRE_PRIORITY_THROWING 450  // Throwing calculation and constant checks
#define FIRE_PRIORITY_CHEMISTRY 400  // Multi-tick chemical reactions.

#define FIRE_PRIORITY_DEFAULT 50 // Default priority for all subsystems

#define FIRE_PRIORITY_VINES 50 // Spreading vine effects.
#define FIRE_PRIORITY_PSYCHICS 45 // Psychic complexus processing.
#define FIRE_PRIORITY_SPACEDRIFT 45 // Drifting things
#define FIRE_PRIORITY_TURF 30   // Radioactive walls/blob.
#define FIRE_PRIORITY_EVAC 30   // Processes the evac controller.
#define FIRE_PRIORITY_CIRCUIT 30   // Processing Circuit's ticks and all that
#define FIRE_PRIORITY_GRAPH 30   // Merging and splitting of graphs
#define FIRE_PRIORITY_CHAR_SETUP 25   // Writes player preferences to savefiles.
#define FIRE_PRIORITY_AI 25  // Mob AI
#define FIRE_PRIORITY_GARBAGE 20   // Garbage collection.
#define FIRE_PRIORITY_ALARM 20  // Alarm processing.
#define FIRE_PRIORITY_EVENT 20  // Event processing and queue handling.
#define FIRE_PRIORITY_SHUTTLE 20  // Shuttle movement.
#define FIRE_PRIORITY_CIRCUIT_COMP 20  // Processing circuit component do_work.
#define FIRE_PRIORITY_TEMPERATURE 20  // Cooling and heating of atoms.
#define FIRE_PRIORITY_RADIATION 20  // Radiation processing and cache updates.
#define FIRE_PRIORITY_OPEN_SPACE 20  // Open turf updates.
#define FIRE_PRIORITY_AIRFLOW 15  // Object movement from ZAS airflow.
#define FIRE_PRIORITY_OVERMAP 12
#define FIRE_PRIORITY_ICON_UPDATE 10
#define FIRE_PRIORITY_INACTIVITY 10  // Idle kicking.
#define FIRE_PRIORITY_PRESENCE 10  // z-level player presence testing
#define FIRE_PRIORITY_VOTE 10  // Vote management.
#define FIRE_PRIORITY_SUPPLY 10  // Supply point accumulation.
#define FIRE_PRIORITY_TRADE 10  // Adds/removes traders.
#define FIRE_PRIORITY_GHOST_IMAGES 10  // Updates ghost client images.
#define FIRE_PRIORITY_PING 10
#define FIRE_PRIORITY_ZCOPY 10  // Builds appearances for Z-Mimic.

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)
