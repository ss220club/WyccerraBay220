/datum/map/torch
	emergency_shuttle_docked_message = "Attention all hands: the escape pods are now unlocked. You have %ETD% to board the escape pods."
	emergency_shuttle_leaving_message = "Attention all hands: the escape pods have been launched, arriving at rendezvous point in %ETA%."

	emergency_shuttle_called_message = "Attention all hands: emergency evacuation procedures are now in effect. Escape pods will unlock in %ETA%"
	emergency_shuttle_called_sound = sound(ANNOUNCER_ABANDONSHIP, volume = 45)

	emergency_shuttle_recall_message = "Attention all hands: emergency evacuation sequence aborted. Return to normal operating conditions."

	command_report_sound = sound(ANNOUNCER_COMMANDREPORT, volume = 45)

	grid_check_message = "Abnormal activity detected in the %STATION_NAME%'s power network. As a precaution, the %STATION_NAME%'s power must be shut down for an indefinite duration."
	grid_check_sound = sound(ANNOUNCER_POWEROFF, volume = 45)

	grid_restored_message = "Ship power to the %STATION_NAME% will be restored at this time"
	grid_restored_sound = sound(ANNOUNCER_POWERON, volume = 45)

	meteor_detected_sound = sound(ANNOUNCER_METEORS, volume = 45)

	radiation_detected_message = "High levels of radiation detected in proximity of the %STATION_NAME%. Please evacuate into one of the shielded maintenance tunnels."
	radiation_detected_sound = sound(ANNOUNCER_RADIATION, volume = 45)

	space_time_anomaly_sound = sound(ANNOUNCER_SPANOMALIES, volume = 45)

	unknown_biological_entities_message = "Unknown biological entities have been detected near the %STATION_NAME%, please stand-by."

	unidentified_lifesigns_message = "Unidentified lifesigns detected. Please lock down all exterior access points."
	unidentified_lifesigns_sound = sound(ANNOUNCER_ALIENS, volume = 45)

	lifesign_spawn_sound = sound(ANNOUNCER_ALIENS, volume = 45)

	electrical_storm_moderate_sound = sound(ANNOUNCER_ELECTRICALSTORM_MOD, volume = 45)
	electrical_storm_major_sound = sound(ANNOUNCER_ELECTRICALSTORM_MAJ, volume = 45)

/datum/map/torch/level_x_biohazard_sound(bio_level)
	switch(bio_level)
		if(7)
			return sound(ANNOUNCER_OUTBREAK7, volume = 45)
		else
			return sound(ANNOUNCER_OUTBREAK5, volume = 45)
