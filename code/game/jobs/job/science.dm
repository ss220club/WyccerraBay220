/datum/job/rd
	title = "Chief Science Officer"
	head_position = 1
	department = "Science"
	department_flag = COM|SCI

	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ad6bad"
	req_admin_notify = 1
	economic_power = 15
	access = list(access_rd, GLOB.access_bridge, GLOB.access_tox, GLOB.access_morgue,
			            GLOB.access_tox_storage, GLOB.access_teleporter, GLOB.access_sec_doors, GLOB.access_heads,
			            GLOB.access_research, GLOB.access_robotics, GLOB.access_xenobiology, GLOB.access_ai_upload, GLOB.access_tech_storage,
			            GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_tcomsat, GLOB.access_gateway, GLOB.access_xenoarch, GLOB.access_network, GLOB.access_network_admin, GLOB.access_research_storage)
	minimal_player_age = 14
	ideal_character_age = 50
	outfit_type = /singleton/hierarchy/outfit/job/science/rd

/datum/job/scientist
	title = "Scientist"
	department = "Science"
	department_flag = SCI

	total_positions = 5
	spawn_positions = 3
	supervisors = "the Chief Science Officer"
	selection_color = "#633d63"
	economic_power = 7
	access = list(access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_xenoarch, GLOB.access_network, GLOB.access_research_storage)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Phoron Researcher")
	minimal_player_age = 7
	outfit_type = /singleton/hierarchy/outfit/job/science/scientist

/datum/job/xenobiologist
	title = "Xenobiologist"
	department = "Science"
	department_flag = SCI

	total_positions = 3
	spawn_positions = 2
	supervisors = "the Chief Science Officer"
	selection_color = "#633d63"
	economic_power = 7
	access = list(access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_research, GLOB.access_xenobiology, GLOB.access_hydroponics, GLOB.access_research_storage)
	alt_titles = list("Xenobotanist")
	minimal_player_age = 7
	outfit_type = /singleton/hierarchy/outfit/job/science/xenobiologist

/datum/job/roboticist
	title = "Roboticist"
	department = "Science"
	department_flag = SCI

	total_positions = 2
	spawn_positions = 2
	supervisors = "the Chief Science Officer"
	selection_color = "#633d63"
	economic_power = 5
	access = list(access_robotics, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_tech_storage, GLOB.access_morgue, GLOB.access_research, GLOB.access_network) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_age = 3
	outfit_type = /singleton/hierarchy/outfit/job/science/roboticist
