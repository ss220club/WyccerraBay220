#define RADIO_LOW_FREQ 1200
#define PUBLIC_LOW_FREQ 1441
#define PUBLIC_HIGH_FREQ 1489
#define RADIO_HIGH_FREQ 1600

#define BOT_FREQ 1447
#define COMM_FREQ 1353
#define ERT_FREQ 1345
#define AI_FREQ 1343
#define ENT_FREQ 1461 //entertainment frequency. This is not a diona exclusive frequency.
#define ICCGN_FREQ 1344
#define SFV_FREQ 1346

//antagonist channels
#define DTH_FREQ 1341
#define SYND_FREQ 1213
#define RAID_FREQ 1277
#define V_RAID_FREQ 1245

// department channels
#define PUB_FREQ 1459
#define HAIL_FREQ 1463
#define SEC_FREQ 1359
#define ENG_FREQ 1357
#define MED_FREQ 1355
#define SCI_FREQ 1351
#define SRV_FREQ 1349
#define SUP_FREQ 1347
#define EXP_FREQ 1361

// internal department channels
#define MED_I_FREQ 1485
#define SEC_I_FREQ 1475

// Device signal frequencies
#define ATMOS_ENGINE_FREQ 1438 // Used by atmos monitoring in the engine.
#define PUMP_FREQ 1439 // Used by air alarms and their progeny.
#define FUEL_FREQ 1447 // Used by fuel atmos stuff, and currently default for digital valves
#define ATMOS_TANK_FREQ 1441 // Used for gas tank sensors and monitoring.
#define ATMOS_DIST_FREQ 1443 // Alternative atmos frequency.
#define BUTTON_FREQ 1301 // Used by generic buttons controlling stuff
#define BLAST_DOORS_FREQ 1303 // Used by blast doors, buttons controlling them, and mass drivers.
#define AIRLOCK_FREQ 1305 // Used by airlocks and buttons controlling them.
#define SHUTTLE_AIR_FREQ 1331 // Used by shuttles and shuttle-related atmos systems.
#define AIRLOCK_AIR_FREQ 1379 // Used by some airlocks for atmos devices.
#define EXTERNAL_AIR_FREQ 1380 // Used by some external airlocks.

/* filters */
//When devices register with the radio controller, they might register under a certain filter.
//Other devices can then choose to send signals to only those devices that belong to a particular filter.
//This is done for performance, so we don't send signals to lots of machines unnecessarily.

//This filter is special because devices belonging to default also recieve signals sent to any other filter.
#define RADIO_DEFAULT "radio_default"

#define RADIO_TO_AIRALARM "radio_airalarm" //air alarms
#define RADIO_FROM_AIRALARM "radio_airalarm_rcvr" //devices interested in recieving signals from air alarms
#define RADIO_CHAT "radio_telecoms"
#define RADIO_ATMOSIA "radio_atmos"
#define RADIO_NAVBEACONS "radio_navbeacon"
#define RADIO_AIRLOCK "radio_airlock"
#define RADIO_SECBOT "radio_secbot"
#define RADIO_MULEBOT "radio_mulebot"
#define RADIO_MAGNETS "radio_magnet"
