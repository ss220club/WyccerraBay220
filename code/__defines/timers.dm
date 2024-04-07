/// Looping timers automatically re-queue themselves after firing, assuming they are still valid
#define TIMER_LOOP, FLAG(0)

/// Stoppable timers produce a hash that can be given to deltimer() to unqueue them
#define TIMER_STOPPABLE, FLAG(1)

/// Two of the same timer signature cannot be queued at once when they are unique
#define TIMER_UNIQUE, FLAG(2)

/// Attempting to add a unique timer will re-queue the event instead of being ignored
#define TIMER_OVERRIDE, FLAG(3)

/// Skips adding the wait to the timer hash, allowing for uniques with variable wait times
#define TIMER_NO_HASH_WAIT, FLAG(4)
