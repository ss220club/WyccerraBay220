/mob/living/carbon/human/examine(mob/user, distance)
	. = list()
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE

	if(wear_mask)
		skipeyes |= wear_mask.flags_inv & HIDEEYES
		skipears |= wear_mask.flags_inv & HIDEEARS
		skipface |= wear_mask.flags_inv & HIDEFACE

	//no accuately spotting headsets from across the room.
	if(distance > 3)
		skipears = 1

	var/name_and_species = "This is "

	if(icon)
		name_and_species += "[icon2html(icon, user)] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated

	if(!user.knows_target(src))
		name_and_species += "<EM>Unknown</EM>"
	else
		if(src.fake_name)
			name_and_species += "<EM>[src.fake_name]</EM>"
		else
			name_and_species += "<EM>[src.name]</EM>"

	var/is_synth = isSynthetic()
	if(!(skipjumpsuit && skipface))
		var/species_name = "\improper "
		if(is_synth && species.cyborg_noun)
			species_name += "[species.cyborg_noun] [species.get_bodytype(src)]"
		else
			species_name += "[species.name]"
		name_and_species += ", <b>[SPAN_COLOR(species.get_flesh_colour(src), "\a [species_name]!")]</b>[(user.can_use_codex() && SScodex.get_codex_entry(get_codex_value())) ?  SPAN_NOTICE(" \[<a href='?src=\ref[SScodex];show_examined_info=\ref[src];show_to=\ref[user]'>?</a>\]") : ""]"

	var/extra_species_text = species.get_additional_examine_text(src)
	if(extra_species_text)
		name_and_species += "[extra_species_text]"

	. += SPAN_NOTICE("[name_and_species]")

	//uniform
	if(w_uniform && !skipjumpsuit)
		. += SPAN_NOTICE("[p_They()] [p_are()] wearing [w_uniform.get_examine_line()].")

	//head
	if(head)
		. += SPAN_NOTICE("[p_They()] [p_are()] wearing [head.get_examine_line()] on [p_their()] head.")

	//suit/armour
	if(wear_suit)
		. += SPAN_NOTICE("[p_They()] [p_are()] wearing [wear_suit.get_examine_line()].")
		//suit/armour storage
		if(s_store && !skipsuitstorage)
			. += SPAN_NOTICE("[p_They()] [p_are()] carrying [s_store.get_examine_line()] on [p_their()] [wear_suit.name].")

	//back
	if(back)
		. += SPAN_NOTICE("[p_They()] [p_have()] [back.get_examine_line()] on [p_their()] back.")

	//left hand
	if(l_hand)
		. += SPAN_NOTICE("[p_They()] [p_are()] holding [l_hand.get_examine_line()] in [p_their()] left hand.")

	//right hand
	if(r_hand)
		. += SPAN_NOTICE("[p_They()] [p_are()] holding [r_hand.get_examine_line()] in [p_their()] right hand.")

	//gloves
	if(gloves && !skipgloves)
		. += SPAN_NOTICE("[p_They()] [p_have()] [gloves.get_examine_line()] on [p_their()] hands.")
	else if(blood_DNA)
		. += SPAN_WARNING("[p_They()] [p_have()] [(hand_blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained hands!")

	//belt
	if(belt)
		. += SPAN_NOTICE("[p_They()] [p_have()] [belt.get_examine_line()] about [p_their()] waist.")

	//shoes
	if(shoes && !skipshoes)
		. += SPAN_NOTICE("[p_They()] [p_are()] wearing [shoes.get_examine_line()] on [p_their()] feet.")
	else if(feet_blood_color)
		. += SPAN_WARNING("[p_They()] [p_have()] [(feet_blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained feet!")

	//mask
	if(wear_mask && !skipmask)
		. += SPAN_NOTICE("[p_They()] [p_have()] [wear_mask.get_examine_line()] on [p_their()] face.")

	//eyes
	if(glasses && !skipeyes)
		. += SPAN_NOTICE("[p_They()] [p_have()] [glasses.get_examine_line()] covering [p_their()] eyes.")

	//left ear
	if(l_ear && !skipears)
		. += SPAN_NOTICE("[p_They()] [p_have()] [l_ear.get_examine_line()] on [p_their()] left ear.")

	//right ear
	if(r_ear && !skipears)
		. += SPAN_NOTICE("[p_They()] [p_have()] [r_ear.get_examine_line()] on [p_their()] right ear.")

	//ID
	if(wear_id)
		. += SPAN_NOTICE("[p_They()] [p_are()] wearing [wear_id.get_examine_line()].")

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/handcuffs/cable))
			. += SPAN_WARNING("[p_They()] [p_are()] [icon2html(handcuffed, user)] restrained with cable!")
		else
			. += SPAN_WARNING("[p_They()] [p_are()] [icon2html(handcuffed, user)] handcuffed!")

	//buckled
	if(buckled)
		. += SPAN_WARNING("[p_They()] [p_are()] [icon2html(buckled, user)] buckled to [buckled]!")

	//Jitters
	if(is_jittery)
		if(jitteriness >= 300)
			. += SPAN_WARNING("<B>[p_they()] [p_are()] convulsing violently!</B>")
		else if(jitteriness >= 200)
			. += SPAN_WARNING("[p_They()] [p_are()] extremely jittery.")
		else if(jitteriness >= 100)
			. += SPAN_WARNING("[p_They()] [p_are()] twitching ever so slightly.")

	//Disfigured face
	if(!skipface) //Disfigurement only matters for the head currently.
		var/obj/item/organ/external/head/E = get_organ(BP_HEAD)
		if(E && (E.status & ORGAN_DISFIGURED)) //Check to see if we even have a head and if the head's disfigured.
			if(E.species) //Check to make sure we have a species
				. += SPAN_NOTICE("[E.species.disfigure_msg(src)]")
			else //Just in case they lack a species for whatever reason.
				. += SPAN_WARNING("[p_their()] face is horribly mangled!")
		var/datum/robolimb/robohead = all_robolimbs[E.model]
		if(length(robohead?.display_text) && facial_hair_style == "Text")
			. += SPAN_NOTICE("The message \"[robohead.display_text]\" is displayed on its screen.")

	//splints
	for(var/organ in list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM))
		var/obj/item/organ/external/o = get_organ(organ)
		if(o && o.splinted && o.splinted.loc == o)
			. += SPAN_WARNING("[p_They()] [p_have()] \a [o.splinted] on [p_their()] [o.name]!")

	if(mSmallsize in mutations)
		. += SPAN_NOTICE("[p_They()] [p_are()] small halfling!")

	if (src.stat)
		. += SPAN_WARNING("[p_They()] [p_are()]n't responding to anything around [p_them()] and seems to be unconscious.")
		if((stat == DEAD || is_asystole() || losebreath || status_flags & FAKEDEATH) && distance <= 3)
			. += SPAN_WARNING("[p_They()] [p_do()] not appear to be breathing.")
	if (fire_stacks > 0)
		. += SPAN_NOTICE("[p_They()] looks flammable.")
	else if (fire_stacks < 0)
		. += SPAN_NOTICE("[p_They()] looks wet.")
	if(on_fire)
		. += SPAN_WARNING("[p_They()] [p_are()] on fire!.")

	var/ssd_msg = species.get_ssd(src)
	if(ssd_msg && (!should_have_organ(BP_BRAIN) || has_brain()) && stat != DEAD)
		if(!key)
			. += SPAN_DEBUG("[p_They()] [p_are()] [ssd_msg]. [p_they()] won't be recovering any time soon. (Ghosted)")
		else if(!client)
			. += SPAN_DEBUG("[p_They()] [p_are()] [ssd_msg]. (Disconnected)")

	if (admin_paralyzed)
		. += SPAN_DEBUG("OOC: [p_they()] [p_have()] been paralyzed by staff. Please avoid interacting with [p_them()] unless cleared to do so by staff.")

	var/obj/item/organ/external/head/H = organs_by_name[BP_HEAD]
	if(istype(H) && H.forehead_graffiti && H.graffiti_style)
		. += SPAN_NOTICE("[p_They()] [p_have()] \"[H.forehead_graffiti]\" written on [p_their()] [H.name] in [H.graffiti_style]!")

	if (changed_age)
		var/scale = abs(changed_age) / age
		if (scale > 0.5)
			scale = "a lot "
		else if (scale > 0.25)
			scale = ""
		else
			scale = "a little "
		. += SPAN_NOTICE("[p_They()] looks [scale][changed_age > 0 ? "older" : "younger"] than you remember.")

	for (var/obj/aura/web/W in auras)
		. += SPAN_WARNING("[p_They()] is covered in webs!")
		break

	var/list/wound_flavor_text = list()
	var/applying_pressure = ""
	var/list/shown_objects = list()
	var/list/hidden_bleeders = list()

	for(var/organ_tag in species.has_limbs)

		var/list/organ_data = species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]
		var/obj/item/organ/external/E = organs_by_name[organ_tag]

		if(!E)
			wound_flavor_text[organ_descriptor] = "<b>[p_They()] [p_are()] missing [p_their()] [organ_descriptor].</b>\n"
			continue

		wound_flavor_text[E.name] = ""

		if(E.applied_pressure == src)
			applying_pressure = "[SPAN_INFO("[p_They()] [p_are()] applying pressure to [p_their()] [E.name].")]<br>"

		var/obj/item/clothing/hidden
		var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
		for(var/obj/item/clothing/C in clothing_items)
			if(istype(C) && (C.body_parts_covered & E.body_part))
				hidden = C
				break

		if(hidden && user != src)
			if(E.status & ORGAN_BLEEDING && !(hidden.item_flags & ITEM_FLAG_THICKMATERIAL)) //not through a spacesuit
				if(!hidden_bleeders[hidden])
					hidden_bleeders[hidden] = list()
				hidden_bleeders[hidden] += E.name
		else
			if(E.is_stump())
				wound_flavor_text[E.name] += "<b>[p_They()] [p_have()] a stump where [p_their()] [organ_descriptor] should be.</b>\n"
				if(LAZYLEN(E.wounds) && E.parent)
					wound_flavor_text[E.name] += "[p_They()] [p_have()] [E.get_wounds_desc()] on [p_their()] [E.parent.name].<br>"
			else
				if(!is_synth && BP_IS_ROBOTIC(E) && (E.parent && !BP_IS_ROBOTIC(E.parent) && !BP_IS_ASSISTED(E.parent)))
					wound_flavor_text[E.name] = "[p_They()] [p_have()] a [E.name].\n"
				var/wounddesc = E.get_wounds_desc()
				if(wounddesc != "nothing")
					wound_flavor_text[E.name] += "[p_They()] [p_have()] [wounddesc] on [p_their()] [E.name].<br>"
		if(!hidden || distance <=1)
			if(E.dislocated > 0)
				wound_flavor_text[E.name] += "[p_Their()] [E.joint] is dislocated!<br>"
			if(((E.status & ORGAN_BROKEN) && E.brute_dam > E.min_broken_damage) || (E.status & ORGAN_MUTATED))
				wound_flavor_text[E.name] += "[p_Their()] [E.name] is dented and swollen!<br>"

		for(var/datum/wound/wound in E.wounds)
			var/list/embedlist = wound.embedded_objects
			if(LAZYLEN(embedlist))
				shown_objects += embedlist
				var/parsedembed[0]
				for(var/obj/embedded in embedlist)
					if(!length(parsedembed) || (!parsedembed.Find(embedded.name) && !parsedembed.Find("multiple [embedded.name]")))
						parsedembed.Add(embedded.name)
					else if(!parsedembed.Find("multiple [embedded.name]"))
						parsedembed.Remove(embedded.name)
						parsedembed.Add("multiple "+embedded.name)
				wound_flavor_text["[E.name]"] += "The [wound.desc] on [p_their()] [E.name] has \a [english_list(parsedembed, and_text = " and a ", comma_text = ", a ")] sticking out of it!<br>"
	for(var/hidden in hidden_bleeders)
		wound_flavor_text[hidden] = "[p_They()] [p_have()] blood soaking through [hidden] around [p_their()] [english_list(hidden_bleeders[hidden])]!<br>"

	var/wound_msg = ""
	for(var/limb in wound_flavor_text)
		wound_msg += wound_flavor_text[limb]
	if(wound_msg)
		. += SPAN_WARNING(wound_msg)

	for(var/obj/implant in get_visible_implants(0))
		if(implant in shown_objects)
			continue
		if(src.fake_name)
			. += SPAN_DANGER("[src.fake_name] [p_have()] \a [implant.name] sticking out of [p_their()] flesh!")
		else
			. += SPAN_DANGER("[src] [p_have()] \a [implant.name] sticking out of [p_their()] flesh!")
	if(digitalcamo)
		. += SPAN_NOTICE("[p_They()] [p_are()] repulsively uncanny!")

	if(hasHUD(user, HUD_SECURITY))
		var/perpname = "wot"
		var/criminal = "None"

		var/obj/item/card/id/id = GetIdCard()
		if(istype(id))
			perpname = id.registered_name
		else
			if(src.fake_name)
				perpname=src.fake_name
			else
				perpname=src.name

		if(perpname)
			var/datum/computer_file/report/crew_record/R = get_crewmember_record(perpname)
			if(R)
				criminal = R.get_criminalStatus()

			. += "[SPAN_CLASS("deptradio", "Criminal status:")] <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>"
			. += "[SPAN_CLASS("deptradio", "Security records:")] <a href='?src=\ref[src];secrecord=`'>\[View\]</a>"

	if(hasHUD(user, HUD_MEDICAL))
		var/perpname = "wot"
		var/medical = "None"

		var/obj/item/card/id/id = GetIdCard()
		if(istype(id))
			perpname = id.registered_name
		else
			if(src.fake_name)
				perpname=src.fake_name
			else
				perpname=src.name

		var/datum/computer_file/report/crew_record/R = get_crewmember_record(perpname)
		if(R)
			medical = R.get_status()

		. += "[SPAN_CLASS("deptradio", "Physical status:")] <a href='?src=\ref[src];medical=1'>\[[medical]\]</a>"
		. += "[SPAN_CLASS("deptradio", "Medical records:")] <a href='?src=\ref[src];medrecord=`'>\[View\]</a>"


	if(print_flavor_text())
		. += SPAN_NOTICE("[print_flavor_text()]")

	if(applying_pressure)
		. += applying_pressure

	if(pose)
		if(findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0)
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		. += SPAN_NOTICE("[p_They()] [pose]")

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M as mob, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/clothing/glasses/G = H.glasses
		var/obj/item/card/id/ID = M.GetIdCard()
		var/obj/item/organ/internal/augment/active/hud/AUG
		for (var/obj/item/organ/internal/augment/active/hud/A in H.internal_organs) // Check for installed and active HUD implants
			if (A.hud_type & hudtype)
				AUG = A
				break
		// [SIERRA-EDIT] - NTNET
		// return ((istype(G) && ((G.hud_type & hudtype) || (G.hud && (G.hud.hud_type & hudtype)))) && G.check_access(ID)) || AUG?.active && AUG.check_access(ID) // SIERRA-EDIT - ORIGINAL
		return ((istype(G) && ((G.hud_type & hudtype) || (G.hud && (G.hud.hud_type & hudtype)))) && G.check_access(ID) && (G.toggleable ? G.active : TRUE)) || AUG?.active && AUG.check_access(ID)
		// [/SIERRA-EDIT]
	else if(istype(M, /mob/living/silicon/robot))
		for (var/obj/item/borg/sight/sight as anything in M.GetAllHeld(/obj/item/borg/sight))
			if (sight.hud_type & hudtype)
				return TRUE
	return FALSE

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	if(src.fake_name)
		pose =  sanitize(input(usr, "This is [src.fake_name]. [p_they()]...", "Pose", null)  as text)
	else
		pose =  sanitize(input(usr, "This is [src]. [p_they()]...", "Pose", null)  as text)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	var/list/HTML = list()
	HTML += "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Update Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[src];flavor_change=done'>\[Done\]</a>"
	HTML += "<tt>"
	show_browser(src, jointext(HTML,null), "window=flavor_changes;size=430x300")
