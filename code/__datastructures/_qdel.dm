#define QDELING(X) (X.gc_destroyed)
#define QDELETED(X) (!X || QDELING(X))
#define QDESTROYING(X) (!X || X.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)

/// Destroy() return value. Queue the instance for eventual hard deletion.
#define QDEL_HINT_QUEUE 0

/// Destroy() return value. Do not queue the instance for hard deletion. Does not expect to be refcount GCd.
#define QDEL_HINT_LETMELIVE 1

/// Destroy() return value. Same as QDEL_HINT_LETMELIVE but the instance expects to refcount GC without help.
#define QDEL_HINT_IWILLGC 2

/// Destroy() return value. Queue this instance for hard deletion regardless of its refcount GC state.
#define QDEL_HINT_HARDDEL 3

/// Destroy() return value. Immediately hard delete the instance.
#define QDEL_HINT_HARDDEL_NOW 4


/// datum.gc_destroyed signal value
#define GC_CURRENTLY_BEING_QDELETED -1
