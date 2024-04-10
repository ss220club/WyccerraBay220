//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

/// All /obj/structure/cable, managed by instances
GLOBAL_LIST_EMPTY(cable_list)

/// All medical side effects
GLOBAL_LIST_EMPTY(side_effects)

/// All character setup mannequins
GLOBAL_LIST_EMPTY(mannequins)

GLOBAL_LIST_INIT(landmarks_list, list())				//list of all landmarks created

#define all_genders_define_list list(MALE,FEMALE,PLURAL,NEUTER)
#define all_genders_text_list list("Male","Female","Plural","Neuter")

//Languages/species/whitelist.
var/global/list/all_species[0]
GLOBAL_LIST_EMPTY(all_languages)
var/global/list/language_keys[0]					// Table of say codes for all languages
GLOBAL_LIST_INIT(playable_species, list())    // A list of ALL playable species, whitelisted, latejoin or otherwise.


GLOBAL_LIST_EMPTY(all_particles)

// Grabs
var/global/list/all_grabstates[0]
var/global/list/all_grabobjects[0]

// Uplinks
GLOBAL_LIST_EMPTY(world_uplinks)

//Preferences stuff
//Hairstyles
GLOBAL_LIST_EMPTY(hair_styles_list)        //stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_list) //stores /datum/sprite_accessory/facial_hair indexed by name

GLOBAL_LIST_INIT(skin_styles_female_list, list())		//unused
GLOBAL_LIST_EMPTY(body_marking_styles_list)		//stores /datum/sprite_accessory/marking indexed by name

GLOBAL_DATUM_INIT(underwear, /datum/category_collection/underwear, new())

// Visual nets
GLOBAL_LIST_EMPTY(visual_nets)
GLOBAL_DATUM_INIT(cameranet, /datum/visualnet/camera, new)

// Runes
GLOBAL_LIST_INIT(rune_list, new)
GLOBAL_LIST_INIT(endgame_exits, list())
GLOBAL_LIST_INIT(endgame_safespawns, list())

GLOBAL_LIST_INIT(syndicate_access, list(GLOB.access_maint_tunnels, GLOB.access_syndicate, GLOB.access_external_airlocks))

// Strings which corraspond to bodypart covering flags, useful for outputting what something covers.
GLOBAL_LIST_INIT(string_part_flags, list(
	"head" = HEAD,
	"face" = FACE,
	"eyes" = EYES,
	"upper body" = UPPER_TORSO,
	"lower body" = LOWER_TORSO,
	"legs" = LEGS,
	"feet" = FEET,
	"arms" = ARMS,
	"hands" = HANDS
))

// Strings which corraspond to slot flags, useful for outputting what slot something is.
GLOBAL_LIST_INIT(string_slot_flags, list(
	"back" = SLOT_BACK,
	"face" = SLOT_MASK,
	"waist" = SLOT_BELT,
	"ID slot" = SLOT_ID,
	"ears" = SLOT_EARS,
	"eyes" = SLOT_EYES,
	"hands" = SLOT_GLOVES,
	"head" = SLOT_HEAD,
	"feet" = SLOT_FEET,
	"exo slot" = SLOT_OCLOTHING,
	"body" = SLOT_ICLOTHING,
	"uniform" = SLOT_TIE,
	"holster" = SLOT_HOLSTER
))

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/get_mannequin(ckey)
	RETURN_TYPE(/mob/living/carbon/human/dummy/mannequin)
	if (!GLOB.mannequins[ckey])
		GLOB.mannequins[ckey] = new /mob/living/carbon/human/dummy/mannequin
	return GLOB.mannequins[ckey]


/hook/global_init/proc/makeDatumRefLists()
	var/list/paths

	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	paths = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	for(var/path in paths)
		var/datum/sprite_accessory/hair/H = path
		if (is_abstract(H) || !initial(H.name))
			continue
		H = new path()
		GLOB.hair_styles_list[H.name] = H

	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	paths = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	for(var/path in paths)
		var/datum/sprite_accessory/facial_hair/H = path
		if (is_abstract(H) || !initial(H.name))
			continue
		H = new path()
		GLOB.facial_hair_styles_list[H.name] = H

	//Body markings - Initialise all /datum/sprite_accessory/marking into an list indexed by marking name
	paths = typesof(/datum/sprite_accessory/marking) - /datum/sprite_accessory/marking
	for(var/path in paths)
		var/datum/sprite_accessory/marking/M = path
		if (!initial(M.name))
			continue
		M = new path()
		GLOB.body_marking_styles_list[M.name] = M

	//Languages and species.
	paths = typesof(/datum/language)-/datum/language
	for(var/T in paths)
		var/datum/language/L = new T
		GLOB.all_languages[L.name] = L

	for (var/language_name in GLOB.all_languages)
		var/datum/language/L = GLOB.all_languages[language_name]
		if(!(L.flags & NONGLOBAL))
			language_keys[lowertext(L.key)] = L

	var/rkey = 0
	paths = typesof(/datum/species)
	for(var/T in paths)

		rkey++

		var/datum/species/S = T
		if(!initial(S.name))
			continue

		S = new T
		S.race_key = rkey //Used in mob icon caching.
		all_species[S.name] = S
		if(!(S.spawn_flags & SPECIES_IS_RESTRICTED))
			GLOB.playable_species += S.name

	//Grabs
	paths = typesof(/datum/grab) - /datum/grab
	for(var/T in paths)
		var/datum/grab/G = new T
		if(G.state_name)
			all_grabstates[G.state_name] = G

	paths = typesof(/obj/item/grab) - /obj/item/grab
	for(var/T in paths)
		var/obj/item/grab/G = T
		all_grabobjects[initial(G.type_name)] = T

	for(var/grabstate_name in all_grabstates)
		var/datum/grab/G = all_grabstates[grabstate_name]
		G.refresh_updown()

	paths = typesof(/particles)
	for (var/path in paths)
		var/particles/P = new path()
		GLOB.all_particles[P.name] = P

	for(var/datum/tech/tech_type as anything in subtypesof(/datum/tech))
		GLOB.tech_id_to_name[initial(tech_type.id)] = initial(tech_type.name)

	// Setup world topic handlers
	for(var/topic_handler_type in subtypesof(/datum/world_topic_handler))
		var/datum/world_topic_handler/wth = new topic_handler_type()
		if(!wth.topic_key)
			stack_trace("[wth.type] has no topic key!")
			continue
		if(GLOB.world_topic_handlers[wth.topic_key])
			stack_trace("[wth.type] has the same topic key as [GLOB.world_topic_handlers[wth.topic_key]]! ([wth.topic_key])")
			continue
		GLOB.world_topic_handlers[wth.topic_key] = topic_handler_type

	return TRUE

//*** params cache
GLOBAL_LIST_INIT(paramslist_cache, list())

#define cached_key_number_decode(key_number_data) cached_params_decode(key_number_data, GLOBAL_PROC_REF(key_number_decode))
#define cached_number_list_decode(number_list_data) cached_params_decode(number_list_data, GLOBAL_PROC_REF(number_list_decode))

/proc/cached_params_decode(params_data, decode_proc)
	. = GLOB.paramslist_cache[params_data]
	if(!.)
		. = call(decode_proc)(params_data)
		GLOB.paramslist_cache[params_data] = .

/proc/key_number_decode(key_number_data)
	RETURN_TYPE(/list)
	var/list/L = params2list(key_number_data)
	for(var/key in L)
		L[key] = text2num(L[key])
	return L

/proc/number_list_decode(number_list_data)
	RETURN_TYPE(/list)
	var/list/L = params2list(number_list_data)
	for(var/i in 1 to length(L))
		L[i] = text2num(L[i])
	return L
