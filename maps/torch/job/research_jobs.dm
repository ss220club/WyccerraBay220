/datum/job/senior_scientist
	title = "Senior Researcher"
	department = "Science"
	department_flag = SCI

	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Science Officer"
	selection_color = "#633d63"
	economic_power = 12
	minimal_player_age = 3
	minimum_character_age = list(SPECIES_HUMAN = 30)
	ideal_character_age = 50
	alt_titles = list(
		"Research Supervisor")
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/research/senior_scientist
	allowed_branches = list(
		/datum/mil_branch/expeditionary_corps
	)
	allowed_ranks = list(
		/datum/mil_rank/ec/o1
	)

	access = list(
		GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_maint_tunnels, GLOB.access_research, GLOB.access_mining_office,
		GLOB.access_mining_station, GLOB.access_xenobiology, GLOB.access_xenoarch, access_nanotrasen, access_solgov_crew,
		GLOB.access_expedition_shuttle, GLOB.access_guppy, GLOB.access_hangar, GLOB.access_petrov, GLOB.access_petrov_helm, GLOB.access_guppy_helm,
		GLOB.access_petrov_analysis, GLOB.access_petrov_phoron, GLOB.access_petrov_toxins, GLOB.access_petrov_chemistry, GLOB.access_petrov_control,
		GLOB.access_petrov_maint, access_torch_fax, access_radio_sci, access_radio_exp, GLOB.access_research_storage
	)

	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_COMPUTER    = SKILL_BASIC,
	                    SKILL_FINANCE     = SKILL_BASIC,
	                    SKILL_BOTANY      = SKILL_BASIC,
	                    SKILL_ANATOMY     = SKILL_BASIC,
	                    SKILL_DEVICES     = SKILL_TRAINED,
	                    SKILL_SCIENCE     = SKILL_TRAINED)

	max_skill = list(   SKILL_ANATOMY     = SKILL_MAX,
	                    SKILL_DEVICES     = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX)
	skill_points = 20
	possible_goals = list(/datum/goal/achievement/notslimefodder)

/datum/job/scientist
	title = "Scientist"
	total_positions = 6
	spawn_positions = 6
	supervisors = "the Chief Science Officer"
	economic_power = 10
	minimum_character_age = list(SPECIES_HUMAN = 25)
	ideal_character_age = 45
	minimal_player_age = 0
	alt_titles = list(
		"Xenoarcheologist",
		"Anomalist",
		"Researcher",
		"Xenobiologist",
		"Xenobotanist"
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_COMPUTER    = SKILL_BASIC,
	                    SKILL_DEVICES     = SKILL_BASIC,
	                    SKILL_SCIENCE     = SKILL_TRAINED)

	max_skill = list(   SKILL_ANATOMY     = SKILL_MAX,
	                    SKILL_DEVICES     = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX)

	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/research/scientist
	allowed_branches = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/solgov,
		/datum/mil_branch/expeditionary_corps
	)
	allowed_ranks = list(
		/datum/mil_rank/ec/o1,
		/datum/mil_rank/civ/contractor = /singleton/hierarchy/outfit/job/torch/passenger/research/scientist,
		/datum/mil_rank/sol/scientist = /singleton/hierarchy/outfit/job/torch/passenger/research/scientist/solgov
	)

	access = list(
		GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_petrov, GLOB.access_petrov_helm,
		GLOB.access_mining_office, GLOB.access_mining_station, GLOB.access_xenobiology, GLOB.access_guppy_helm,
		GLOB.access_xenoarch, access_nanotrasen, access_solgov_crew, GLOB.access_expedition_shuttle, GLOB.access_guppy, GLOB.access_hangar,
		GLOB.access_petrov_analysis, GLOB.access_petrov_phoron, GLOB.access_petrov_toxins, GLOB.access_petrov_chemistry, GLOB.access_petrov_control, access_torch_fax,
		GLOB.access_petrov_maint, access_radio_sci, access_radio_exp, GLOB.access_research_storage
	)
	skill_points = 20
	possible_goals = list(/datum/goal/achievement/notslimefodder)

/datum/job/scientist_assistant
	title = "Research Assistant"
	department = "Science"
	department_flag = SCI
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Chief Science Officer and science personnel"
	selection_color = "#633d63"
	economic_power = 3
	minimum_character_age = list(SPECIES_HUMAN = 18)
	ideal_character_age = 30
	alt_titles = list(
		"Testing Assistant",
		"Intern",
		"Clerk",
		"Field Assistant")

	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/research
	allowed_branches = list(
		/datum/mil_branch/civilian,
		/datum/mil_branch/solgov,
		/datum/mil_branch/expeditionary_corps
	)
	allowed_ranks = list(
		/datum/mil_rank/ec/e3,
		/datum/mil_rank/ec/e5,
		/datum/mil_rank/civ/contractor = /singleton/hierarchy/outfit/job/torch/passenger/research/assist,
		/datum/mil_rank/sol/scientist = /singleton/hierarchy/outfit/job/torch/passenger/research/assist/solgov
	)
	max_skill = list(   SKILL_ANATOMY     = SKILL_MAX,
	                    SKILL_DEVICES     = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX)

	access = list(
		GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_petrov,
		GLOB.access_mining_office, GLOB.access_mining_station, GLOB.access_xenobiology, GLOB.access_guppy_helm,
		GLOB.access_xenoarch, access_nanotrasen, access_solgov_crew, GLOB.access_expedition_shuttle, GLOB.access_guppy, GLOB.access_hangar,
		GLOB.access_petrov_analysis, GLOB.access_petrov_phoron, GLOB.access_petrov_toxins, GLOB.access_petrov_chemistry, GLOB.access_petrov_control,
		access_radio_sci, access_radio_exp, GLOB.access_research_storage
	)
	possible_goals = list(/datum/goal/achievement/notslimefodder)
