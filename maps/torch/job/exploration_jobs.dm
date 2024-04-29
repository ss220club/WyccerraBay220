/datum/job/pathfinder
	title = "Pathfinder"
	department = "Exploration"
	department_flag = EXP
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Science Officer"
	selection_color = "#68099e"
	minimal_player_age = 1
	economic_power = 10
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 35
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/exploration/pathfinder
	allowed_branches = list(/datum/mil_branch/expeditionary_corps)
	allowed_ranks = list(
		/datum/mil_rank/ec/o1
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_EVA         = SKILL_TRAINED,
	                    SKILL_SCIENCE     = SKILL_TRAINED,
	                    SKILL_PILOT       = SKILL_BASIC)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX,
	                    SKILL_COMBAT      = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS     = SKILL_EXPERIENCED)
	skill_points = 22

	access = list(
		access_pathfinder, GLOB.access_explorer, GLOB.access_eva, GLOB.access_maint_tunnels, GLOB.access_bridge, GLOB.access_emergency_storage,
		GLOB.access_guppy_helm, access_solgov_crew, GLOB.access_expedition_shuttle, GLOB.access_expedition_shuttle_helm,
		GLOB.access_guppy, GLOB.access_hangar, GLOB.access_petrov, GLOB.access_petrov_helm, GLOB.access_petrov_analysis, GLOB.access_petrov_phoron,
		GLOB.access_petrov_toxins, GLOB.access_petrov_chemistry, GLOB.access_petrov_maint, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research,
		GLOB.access_xenobiology, GLOB.access_xenoarch, access_torch_fax, access_radio_comm, access_radio_exp, access_radio_sci, GLOB.access_research_storage
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management,
							/datum/computer_file/program/reports)

/datum/job/pathfinder/get_description_blurb()
	return "You are the Pathfinder. Your duty is to organize and lead the expeditions to away sites, carrying out the EC's Primary Mission. You command Explorers. You make sure that expedition has the supplies and personnel it needs. You can pilot Charon if nobody else provides a pilot. Once on the away mission, your duty is to ensure that anything of scientific interest is brought back to the ship and passed to the relevant research lab."

/datum/job/nt_pilot
	title = "Shuttle Pilot"
	supervisors = "the Pathfinder"
	department = "Exploration"
	department_flag = EXP
	total_positions = 1
	spawn_positions = 1
	selection_color = "#68099e"
	economic_power = 8
	minimal_player_age = 0
	minimum_character_age = list(SPECIES_HUMAN = 24)
	ideal_character_age = 25
	outfit_type = /singleton/hierarchy/outfit/job/torch/passenger/pilot
	allowed_branches = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/expeditionary_corps = /singleton/hierarchy/outfit/job/torch/crew/exploration/pilot,
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/exploration/pilot/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/civ/contractor = /singleton/hierarchy/outfit/job/torch/passenger/research/nt_pilot,
		/datum/mil_rank/ec/e7,
		/datum/mil_rank/fleet/e6,
		/datum/mil_rank/fleet/e7
	)

	access = list(
		GLOB.access_mining_office, GLOB.access_petrov, GLOB.access_petrov_helm, GLOB.access_petrov_maint, GLOB.access_mining_station,
		GLOB.access_expedition_shuttle, GLOB.access_expedition_shuttle_helm, GLOB.access_guppy, GLOB.access_hangar, GLOB.access_guppy_helm,
		GLOB.access_mining, GLOB.access_pilot, access_solgov_crew, GLOB.access_eva, GLOB.access_explorer, GLOB.access_research,
		access_radio_exp, access_radio_sci, access_radio_sup, GLOB.access_maint_tunnels, GLOB.access_emergency_storage
	)
	min_skill = list(	SKILL_EVA   = SKILL_BASIC,
						SKILL_PILOT = SKILL_TRAINED)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX)

/datum/job/explorer
	title = "Explorer"
	department = "Exploration"
	department_flag = EXP
	total_positions = 5
	spawn_positions = 5
	supervisors = "the Pathfinder"
	selection_color = "#68099e"
	minimum_character_age = list(SPECIES_HUMAN = 18)
	ideal_character_age = 20
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/exploration/explorer
	allowed_branches = list(/datum/mil_branch/expeditionary_corps)

	allowed_ranks = list(
		/datum/mil_rank/ec/e3,
		/datum/mil_rank/ec/e5
	)
	min_skill = list(   SKILL_EVA = SKILL_BASIC)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX,
	                    SKILL_COMBAT      = SKILL_EXPERIENCED,
	                    SKILL_WEAPONS     = SKILL_EXPERIENCED)

	access = list(
		GLOB.access_explorer, GLOB.access_maint_tunnels, GLOB.access_eva, GLOB.access_emergency_storage,
		GLOB.access_guppy_helm, access_solgov_crew, GLOB.access_expedition_shuttle, GLOB.access_guppy, GLOB.access_hangar,
		GLOB.access_petrov, GLOB.access_petrov_maint, GLOB.access_research, access_radio_exp
	)

	software_on_spawn = list(/datum/computer_file/program/deck_management)

/datum/job/explorer/get_description_blurb()
	return "You are an Explorer. Your duty is to go on expeditions to away sites. The Pathfinder is your team leader. You are to look for anything of economic or scientific interest to the SCG - mineral deposits, alien flora/fauna, artifacts. You will also likely encounter hazardous environments, aggressive wildlife or malfunctioning defense systems, so tread carefully."
