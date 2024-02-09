/singleton/vv_set_handler/mob_confused
	handled_type = /mob
	predicates = list(global_proc_ref(is_num_predicate), global_proc_ref(is_non_negative_predicate), global_proc_ref(is_int_predicate))
	handled_vars = list("confused")


/singleton/vv_set_handler/mob_confused/handle_set_var(datum/O, variable, var_value, client)
	var/mob/mob = O
	mob.set_confused(var_value, var_value)
