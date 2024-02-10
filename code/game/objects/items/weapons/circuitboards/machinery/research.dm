/obj/item/stock_parts/circuitboard/rdserver
	name = "печатная плата (R&D сервер)"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3)
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/destructive_analyzer
	name = "печатная плата (деструктивный анализатор)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/autolathe
	name = "печатная плата (автолат)"
	build_path = /obj/machinery/fabricator
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/manipulator = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/autolathe/micro
	name = "печатная плата (микролат)"
	build_path = /obj/machinery/fabricator/micro
	origin_tech = list(TECH_ENGINEERING = 1, TECH_DATA = 1)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1
	)
/obj/item/stock_parts/circuitboard/replicator
	name = "печатная плата (репликатор)"
	build_path = /obj/machinery/fabricator/replicator
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 2, TECH_BIO = 2)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/manipulator = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/protolathe
	name = "печатная плата (протолат)"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/reagent_containers/glass/beaker = 2)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/circuit_imprinter
	name = "печатная плата (принтер плат)"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/reagent_containers/glass/beaker = 2)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/mechfab
	name = "печатная плата (экзо-фабрикатор)"
	build_path = /obj/machinery/robotics_fabricator
	board_type = "machine"
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/ntnet_relay
	name = "печатная плата (NTNet кватовое реле)"
	build_path = /obj/machinery/ntnet_relay
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4)
	req_components = list(/obj/item/stack/cable_coil = 15)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/apc/buildable = 1,
		/obj/item/stock_parts/computer/hard_drive/portable = 1
	)

/obj/item/stock_parts/circuitboard/suspension_gen
	name = "печатная плата (генератор гравитации)"
	build_path = /obj/machinery/suspension_gen
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 3, TECH_MAGNET = 4)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/battery/buildable/stock = 1,
		/obj/item/cell/high = 1
	)

/obj/item/stock_parts/circuitboard/anomaly_container
	name = "печатная плата (контейнер аномалий)"
	build_path = /obj/machinery/anomaly_container
	board_type = "machine"
	origin_tech = list(TECH_BLUESPACE = 3, TECH_ENGINEERING = 4, TECH_MAGNET = 4)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/keyboard = 1,
		/obj/item/stock_parts/power/battery/buildable/stock = 1,
		/obj/item/cell/high = 1
	)

/obj/item/stock_parts/circuitboard/stasis_cage
	name = "печатная плата (стазисная клетка)"
	build_path = /obj/machinery/stasis_cage
	board_type = "machine"
	origin_tech = list(TECH_BLUESPACE = 3, TECH_ENGINEERING = 4, TECH_BIO = 3)
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1
	)
	additional_spawn_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/power/battery/buildable/stock = 1,
		/obj/item/cell/high = 1,
		/obj/item/stock_parts/power/apc = 1
	)

/obj/item/stock_parts/circuitboard/cracker
	name = "печатная плата (молекулярная крекинговая установка)"
	build_path = /obj/machinery/portable_atmospherics/cracker
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 4, TECH_ENGINEERING = 3, TECH_MATERIAL = 3)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/micro_laser = 3,
							/obj/item/stock_parts/manipulator = 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)

/obj/item/stock_parts/circuitboard/doppler_array
	name = "печатная плата (допплеровский массив)"
	build_path = /obj/machinery/doppler_array
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 7, TECH_MATERIAL = 4, TECH_DATA = 4, TECH_BLUESPACE = 3)
	req_components = list(
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/computer/hard_drive/cluster = 2,
							/obj/item/stock_parts/computer/processor_unit/photonic= 1)
	additional_spawn_components = list(
		/obj/item/stock_parts/power/apc/buildable = 1
	)
