/**
 * Generic attack and damage proc, called on the attacked atom.
 *
 * **Parameters**:
 * - `user` - The attacking mob.
 * - `damage` (int) - The damage value.
 * - `attack_verb` (string) - The verb/string used for attack messages.
 * - `wallbreaker` (boolean) - Whether or not the attack is considered a 'wallbreaker' attack.
 * - `damtype` (string, one of `DAMAGE_*`) - The attack's damage type.
 * - `armorcheck` (string) - TODO: Unused. Remove.
 * - `dam_flags` (bitfield, any of `DAMAGE_FLAG_*`) - Damage flags associated with the attack.
 *
 * Returns boolean.
 */
/atom/proc/attack_generic(mob/user, damage, attack_verb = "hits", wallbreaker = FALSE, damtype = DAMAGE_BRUTE, armorcheck = "melee", dam_flags = EMPTY_BITFIELD)
	if (damage && get_max_health())
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
		if (!can_damage_health(damage, damtype))
			playsound(src, damage_hitsound, 50, TRUE)
			user.visible_message(
				SPAN_WARNING("\The [user] bonks \the [src] harmlessly!"),
				SPAN_WARNING("You bonk \the [src] harmlessly!")
			)
			return
		var/damage_flags = EMPTY_BITFIELD
		if (wallbreaker)
			SET_FLAGS(damage_flags, DAMAGE_FLAG_TURF_BREAKER)
		playsound(src, damage_hitsound, 75, TRUE)
		if (damage_health(damage, damtype, damage_flags, skip_can_damage_check = TRUE))
			user.visible_message(
				SPAN_DANGER("\The [user] smashes through \the [src]!"),
				SPAN_DANGER("You smash through \the [src]!")
			)
		else
			user.visible_message(
				SPAN_DANGER("\The [user] [attack_verb] \the [src]!"),
				SPAN_DANGER("You [attack_verb] \the [src]!")
			)

/**
 * Called when the unarmed attack hasn't been stopped by the LIVING_UNARMED_ATTACK_BLOCKED macro or the right_click_attack_chain proc.
 * This will call an attack proc that can vary from mob type to mob type on the target.
 */
/mob/living/proc/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_animal(src, modifiers)

/// Checks for RIGHT_CLICK in modifiers and runs resolve_right_click_attack if so. Returns TRUE if normal chain blocked.
/mob/living/proc/right_click_attack_chain(atom/target, list/modifiers)
	if (!LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	var/secondary_result = resolve_right_click_attack(target, modifiers)

	if (secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
		return TRUE
	else if (secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
		CRASH("resolve_right_click_attack (probably attack_hand_secondary) did not return a SECONDARY_ATTACK_* define.")

/mob/living/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	// The sole reason for this signal needing to exist is making FotNS incompatible with Hulk.
	// Note that it is send before [proc/can_unarmed_attack] is called, keep this in mind.
	var/sigreturn = SEND_SIGNAL(src, COMSIG_LIVING_EARLY_UNARMED_ATTACK, target, proximity_flag, modifiers)
	if(sigreturn & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(sigreturn & COMPONENT_SKIP_ATTACK)
		return FALSE

	sigreturn = SEND_SIGNAL(src, COMSIG_LIVING_UNARMED_ATTACK, target, proximity_flag, modifiers)
	if(sigreturn & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(sigreturn & COMPONENT_SKIP_ATTACK)
		return FALSE

	if(!right_click_attack_chain(target, modifiers))
		resolve_unarmed_attack(target, modifiers)
	return TRUE

/mob/living/carbon/human/resolve_unarmed_attack(atom/target, list/modifiers)
	return target.attack_hand(src, modifiers)

/mob/living/carbon/human/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_hand_secondary(src, modifiers)

/**
 * Called when the atom is clicked on by a mob with an empty hand.
 *
 * **Parameters**:
 * - `user` - The mob that clicked on the atom.
 */
/atom/proc/attack_hand(mob/living/user, list/modifiers)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE

/atom/proc/attack_hand_secondary(mob/living/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND_SECONDARY, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

/**
 * Called when a mob attempts to use an empty hand on itself.
 *
 * **Parameters**:
 * - `bp_hand` (string, `BP_R_HAND` or `BP_L_HAND`) - The targeted and used hand's bodypart slot.
 */
/mob/proc/attack_empty_hand(bp_hand)
	return


/mob/living/carbon/human/RestrainedClickOn(atom/A)
	return

/mob/living/CtrlClickOn(atom/A)
	. = ..()
	if(!. && a_intent == I_GRAB && length(available_maneuvers))
		. = perform_maneuver(prepared_maneuver || available_maneuvers[1], A)

/mob/living/carbon/human/ranged_attack(atom/target, modifiers)
	//Climbing up open spaces
	if((istype(target, /turf/simulated/floor) || istype(target, /turf/unsimulated/floor) || istype(target, /obj/structure/lattice) || istype(target, /obj/structure/catwalk)) && isturf(loc) && bound_overlay && !is_physically_disabled()) //Climbing through openspace
		return climb_up(target)

	. = ..()

/mob/living/RestrainedClickOn(atom/A)
	return

/**
 * Called when an unarmed attack performed with right click hasn't been stopped by the LIVING_UNARMED_ATTACK_BLOCKED macro.
 * This will call a secondary attack proc that can vary from mob type to mob type on the target.
 * Sometimes, a target is interacted differently when right_clicked, in that case the secondary attack proc should return
 * a SECONDARY_ATTACK_* value that's not SECONDARY_ATTACK_CALL_NORMAL.
 * Otherwise, it should just return SECONDARY_ATTACK_CALL_NORMAL. Failure to do so will result in an exception (runtime error).
 */
/mob/living/proc/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_animal_secondary(src, modifiers)

/**
 * Called when a simple animal is unarmed attacking / clicking on this atom.
 */
/atom/proc/attack_animal(mob/user, list/modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)
	attack_hand(user)

/**
 * Called when a simple animal or basic mob right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_animal_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/*
	Aliens
*/

/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

/mob/living/carbon/alien/resolve_unarmed_attack(atom/target, list/modifiers)
	target.attack_generic(src, rand(5,6), "bitten")

/*
	Slimes
	Nothing happening here
*/

/mob/living/carbon/slime/RestrainedClickOn(atom/A)
	return

/mob/living/carbon/slime/UnarmedAttack(atom/target, proximity_flag, list/modifiers)

	if(!..())
		return

	// Eating
	if(Victim)
		if (Victim == target)
			Feedstop()
		return

	//should have already been set if we are attacking a mob, but it doesn't hurt and will cover attacking non-mobs too
	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/mob/living/M = target
	if(!istype(M))
		target.attack_generic(src, (is_adult ? rand(20,40) : rand(5,25)), "glomped") // Basic attack.
	else
		var/power = max(0, min(10, (powerlevel + rand(0, 3))))

		switch(src.a_intent)
			if (I_HELP) // We just poke the other
				M.visible_message(SPAN_NOTICE("[src] gently pokes [M]!"), SPAN_NOTICE("[src] gently pokes you!"))
			if (I_DISARM) // We stun the target, with the intention to feed
				var/stunprob = 1

				if (powerlevel > 0 && !istype(target, /mob/living/carbon/slime))
					switch(power * 10)
						if(0) stunprob *= 10
						if(1 to 2) stunprob *= 20
						if(3 to 4) stunprob *= 30
						if(5 to 6) stunprob *= 40
						if(7 to 8) stunprob *= 60
						if(9) 	   stunprob *= 70
						if(10) 	   stunprob *= 95

				if(prob(stunprob))
					var/shock_damage = max(0, powerlevel-3) * rand(6,10)
					M.electrocute_act(shock_damage, src, 1.0, ran_zone())
				else if(prob(40))
					M.visible_message(SPAN_DANGER("[src] has pounced at [M]!"), SPAN_DANGER("[src] has pounced at you!"))
					M.Weaken(power)
				else
					M.visible_message(SPAN_DANGER("[src] has tried to pounce at [M]!"), SPAN_DANGER("[src] has tried to pounce at you!"))
				M.updatehealth()
			if (I_GRAB) // We feed
				Wrap(M)
			if (I_HURT) // Attacking
				if(iscarbon(M) && prob(15))
					M.visible_message(SPAN_DANGER("[src] has pounced at [M]!"), SPAN_DANGER("[src] has pounced at you!"))
					M.Weaken(power)
				else
					target.attack_generic(src, (is_adult ? rand(20,40) : rand(5,25)), "glomped")

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return

/*
	Animals
*/
/mob/living/simple_animal/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	if (!..())
		return
	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if (isliving(target))
		if (!get_natural_weapon() || a_intent == I_HELP)
			custom_emote(VISIBLE_MESSAGE, "[friendly] [target]!")
			return
		if (ckey)
			admin_attack_log(src, target, "Has attacked its victim.", "Has been attacked by its attacker.")
	if (a_intent == I_HELP)
		target.attack_animal(src)
	else if (get_natural_weapon())
		var/obj/item/weapon = get_natural_weapon()
		weapon.resolve_attackby(target, src)
