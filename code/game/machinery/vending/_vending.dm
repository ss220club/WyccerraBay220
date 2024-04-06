/obj/machinery/vending
	abstract_type = /obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ROTATABLE
	clicksound = "button"
	clickvol = 40
	base_type = /obj/machinery/vending/generic //NB: Ugly hack. Allows products to be added to vendors that don't specify a correct base type.
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	machine_name = "vending machine"
	machine_desc = "Holds an internal stock of items that can be dispensed on-demand or when a charged ID card is swiped, depending on the brand."
	idle_power_usage = 10
	wires = /datum/wires/vending
	health_max = 100
	var/colored_entries = TRUE
	var/last_reply = 0
	var/scan_id = TRUE
	var/light_max_bright_on = 0.2
	var/light_outer_range_on = 2
	var/list/ads_list = list()
	var/list/slogan_list = list()
	var/list/product_records = list()
	var/obj/item/material/coin/coin
	/// The machine's wires, but typed.
	var/datum/wires/vending/vendor_wires
	/// icon_state to flick() when vending
	var/icon_vend
	/// Total number of overlays that can be randomly picked from when an item is being vended.
	var/max_overlays = 1
	/// icon_state to flick() when refusing to vend
	var/icon_deny
	/// Power to one-off spend on successfully vending.
	var/vend_power_usage = 150
	/// No sales pitches if off!
	var/active = TRUE
	/// Are we ready to vend?? Is it time??
	var/vend_ready = TRUE
	/// A field associated with vending machines from the below flags.
	var/vendor_flags = VENDOR_CATEGORY_NORMAL
	/// Possible vendor flags
	var/possible_vendor_flags = VENDOR_CATEGORY_NORMAL|VENDOR_CATEGORY_HIDDEN|VENDOR_CATEGORY_COIN|VENDOR_CATEGORY_ANTAG
	///Minimum number of possible non-rare product that can be randomly spawned. This can be set by vending machine not item. Minimum rare product is set as 1 by default.
	var/minrandom = 1
	///Maximum number of possible non-rare products that can be randomly spawned. This can be set by vending machine not item. Maximum rare product depends on rarity.
	var/maxrandom = 10
	///Maximum number of randomly generated antag items. Default of 1 so it is usually only 0 or 1. This var is used as exceptions when large amounts of ammo needs to be randomly spawned.
	var/antagrandom = 1
	/// When did we last pitch?
	var/last_slogan = 0
	/// How long until we can pitch again?
	var/slogan_delay = 2 MINUTES
	/// Shock customers like an airlock.
	var/seconds_electrified = 0
	/// Fire items at customers! We're broken!
	var/shoot_inventory = FALSE
	/// The chance that items are being shot per tick
	var/shooting_chance = 2
	/// String of slogans spoken out loud, separated by semicolons
	var/product_slogans = ""
	/// String of anag slogans spoken out loud, separated by semicolons
	var/antag_slogans = ""
	/// String of small ad messages in the vending screen
	var/product_ads = ""
	/// Status screen messages like "insufficient funds", displayed in TGUI
	var/status_message = ""
	/// Set to 1 if status_message is an error
	var/status_error = 0
	/// Stop spouting those godawful pitches!
	var/shut_up = TRUE
	/// Thank you for shopping!
	var/vend_reply
	/// What we're requesting payment for right now
	var/datum/stored_items/vending_products/currently_vending
	/// Prices for each product as (/item/path = price). Unlisted items are free.
	var/list/prices = list()
	/// Stock for each product as (/item/path = count). Set to '0' if you want the vendor to randomly spawn between 1 and 10 items.
	var/list/products = list()
	///Probability of each rare product of spawning in, max amount increases with large value. Need to have value of '0' associated with it in product list for this to work.
	var/list/rare_products = list()
	/// Stock for products hidden by the contraband wire as (/item/path = count)
	var/list/contraband	= list()
	/// Stock for products hidden by coin insertion as (/item/path = count)
	var/list/premium = list()
	/// Stock for antag items unlocked by challenge coin purchased from uplink. Each coin costs 10 TCs; value in vendor should be 10 at baseline with rare chance going up to 30.
	var/list/antag = list()
	/// 2D list of products as: list(list(category, products))
	var/list/all_products = list()

	var/const/VENDOR_CATEGORY_NORMAL = FLAG(0)
	var/const/VENDOR_CATEGORY_HIDDEN = FLAG(1)
	var/const/VENDOR_CATEGORY_COIN = FLAG(2)
	var/const/VENDOR_CATEGORY_ANTAG = FLAG(3)

/obj/machinery/vending/Destroy()
	vendor_wires = null
	currently_vending = null
	QDEL_NULL_LIST(product_records)
	QDEL_NULL(coin)
	return ..()

/obj/machinery/vending/Initialize(mapload, d = 0, populate_parts = TRUE)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/vending/LateInitialize(mapload, d = 0, populate_parts = TRUE)
	. = ..()
	vendor_wires = wires
	if(product_slogans)
		slogan_list += splittext(product_slogans, ";")
		last_slogan = world.time + rand(0, slogan_delay)
	if(product_ads)
		ads_list += splittext(product_ads, ";")
	if(minrandom > maxrandom)
		minrandom = maxrandom

	build_inventory(populate_parts)
	update_icon()


/obj/machinery/vending/examine(mob/user)
	. = ..()
	if(IsShowingAntag())
		. += SPAN_WARNING("A secret panel is open, revealing a small compartment that is dimly lit with red lighting.")

/obj/machinery/vending/Process()
	if(inoperable())
		return
	if(!active)
		return
	if(seconds_electrified > 0)
		seconds_electrified--
	if(!shut_up && prob(5) && length(slogan_list) && last_slogan + slogan_delay <= world.time)
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time
	if(shoot_inventory && prob(shooting_chance))
		throw_item()

/obj/machinery/vending/post_health_change(health_mod, prior_health, damage_type)
	. = ..()
	queue_icon_update()
	if(health_mod < 0 && !health_dead())
		var/initial_damage_percentage = Percent(get_max_health() - prior_health, get_max_health(), 0)
		var/damage_percentage = get_damage_percentage()
		if(damage_percentage >= 25 && initial_damage_percentage < 25 && prob(75))
			shut_up = FALSE
		else if(damage_percentage >= 50 && initial_damage_percentage < 50)
			vendor_wires.RandomCut()
		else if(damage_percentage >= 75 && initial_damage_percentage < 75 && prob(10))
			malfunction()

/obj/machinery/vending/powered()
	return anchored && ..()

/obj/machinery/vending/proc/update_glow()
	var/light_color
	if(IsShowingAntag())
		light_color = COLOR_RED
		light_max_bright_on = 0.4
	if(!is_powered() || MACHINE_IS_BROKEN(src))
		set_light(0)
	else
		set_light(light_outer_range_on, light_max_bright_on, light_color)

/obj/machinery/vending/on_update_icon()
	ClearOverlays()
	update_glow()
	if(MACHINE_IS_BROKEN(src))
		icon_state = "[initial(icon_state)]-broken"
	else if(is_powered())
		icon_state = initial(icon_state)
	else
		spawn(rand(0, 15))
		icon_state = "[initial(icon_state)]-off"
	if(panel_open || IsShowingAntag())
		AddOverlays(image(icon, "[initial(icon_state)]-panel"))
	if((IsShowingAntag() || get_damage_percentage() >= 50) && is_powered())
		AddOverlays(image(icon, "sparks"))
		AddOverlays(emissive_appearance(icon, "sparks"))
	if(!vend_ready)
		AddOverlays(image(icon, "[initial(icon_state)]-shelf[rand(max_overlays)]"))

/obj/machinery/vending/emag_act(remaining_charges, mob/living/user)
	if(emagged)
		return
	emagged = TRUE
	req_access.Cut()
	if(antag_slogans)
		shut_up = FALSE
		slogan_list.Cut()
		slogan_list += splittext(antag_slogans, ";")
		last_slogan = world.time + rand(0, slogan_delay)
	for(var/datum/stored_items/vending_products/product as anything in product_records)
		product.price = 0
	UpdateShowContraband(TRUE)
	SStgui.update_uis(src)
	to_chat(user, "You short out the product lock on \the [src].")
	return TRUE

/obj/machinery/vending/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(panel_open)
		attack_hand(user)

/obj/machinery/vending/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(panel_open)
		attack_hand(user)

/obj/machinery/vending/use_tool(obj/item/item, mob/living/user, list/click_params)
	var/obj/item/card/id/id = item.GetIdCard()
	var/static/list/simple_coins = subtypesof(/obj/item/material/coin) - typesof(/obj/item/material/coin/challenge)
	if(currently_vending && vendor_account && !vendor_account.suspended)
		var/handled
		var/paid
		if(id)
			paid = pay_with_card(id, item)
			handled = TRUE
		else if(istype(item, /obj/item/spacecash/ewallet))
			paid = pay_with_ewallet(item)
			handled = TRUE
		else if(istype(item, /obj/item/spacecash/bundle))
			paid = pay_with_cash(item)
			handled = TRUE
		if(paid)
			vend(currently_vending, user)
			return TRUE
		else if(handled)
			SStgui.update_uis(src)
			return TRUE

	if(id || istype(item, /obj/item/spacecash))
		attack_hand(user)
		return TRUE
	if(is_type_in_list(item, simple_coins))
		if(!length(premium))
			to_chat(user, SPAN_WARNING("\The [src] does not accept the [item]."))
			return TRUE
		if(!user.unEquip(item, src))
			return FALSE
		coin = item
		UpdateShowPremium(TRUE)
		to_chat(user, SPAN_NOTICE("You insert \the [item] into \the [src]."))
		SStgui.update_uis(src)
		return TRUE

	if(istype(item, /obj/item/material/coin/challenge/syndie))
		if(!LAZYLEN(antag))
			to_chat(user, SPAN_WARNING("\The [src] does not have a secret compartment installed."))
			return TRUE
		if(IsShowingAntag())
			to_chat(user, SPAN_WARNING("\The [src]'s secret compartment is already unlocked!"))
			return TRUE
		if(!user.unEquip(item, src))
			to_chat(user, SPAN_WARNING("You can't drop \the [item]."))
			return TRUE
		ProcessAntag(item, user)
		return TRUE

	if((user.a_intent == I_HELP) && attempt_to_stock(item, user))
		return TRUE

	return ..()

/// Proc that enables hidden antag items and replaces slogan list with anti-Sol slogans if any.
/obj/machinery/vending/proc/ProcessAntag(obj/item/item, mob/living/user)
	to_chat(user, SPAN_NOTICE("You insert \the [item] into \the [src]."))
	visible_message(SPAN_WARNING("\The [src] hisses as a hidden panel swings open with a loud thud."))
	playsound(loc, 'sound/items/metal_clack.ogg', 50)
	UpdateShowAntag(TRUE)
	req_access.Cut()
	SStgui.update_uis(src)
	update_icon()
	var/obj/item/material/coin/challenge/syndie/antagcoin = item
	if(antag_slogans)
		shut_up = FALSE
		slogan_list.Cut()
		slogan_list += splittext(antag_slogans, ";")
		last_slogan = world.time + rand(0, slogan_delay)
	if(!isnull(antagcoin.string_color))
		if(prob(10))
			user.put_in_hands(item)
			to_chat(user, SPAN_NOTICE("You successfully pull \the [item] out before \the [src] could swallow it."))
			return TRUE
		else
			to_chat(user, SPAN_NOTICE("You weren't able to pull \the [item] out fast enough, \the [src] ate it, string and all."))
			qdel(item)
			return TRUE
	else
		to_chat(user, SPAN_NOTICE("You hear a loud clink as \the [item] is swallowed by \the [src]"))
		qdel(item)
		return TRUE

/obj/machinery/vending/MouseDrop_T(obj/item/item, mob/living/user)
	if(!CanMouseDrop(item, user) || (item.loc != user))
		return
	return attempt_to_stock(item, user)

/obj/machinery/vending/state_transition(singleton/machine_construction/new_state)
	. = ..()
	SStgui.update_uis(src)

/obj/machinery/vending/physical_attack_hand(mob/living/user)
	if(!seconds_electrified)
		return FALSE
	return shock(user, 100)

/obj/machinery/vending/interface_interact(mob/living/user)
	tgui_interact(user)
	return TRUE

/obj/machinery/vending/tgui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/vending/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vending", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/vending/tgui_data(mob/user)
	var/list/data = list()

	if(currently_vending)
		data["mode"] = TRUE
		data["product"] = currently_vending.item_name
		data["price"] = currently_vending.price
		data["image"] = currently_vending.image
	else
		data["mode"] = FALSE

	data["message"] = status_message
	data["message_err"] = status_error
	data["vend_ready"] = vend_ready
	data["coin"] = coin
	data["panel"] = panel_open
	data["speaker"] = shut_up

	var/list/listed_products = list()

	var/product_position = 0
	for(var/datum/stored_items/vending_products/product as anything in product_records)
		if(!(product.category & vendor_flags))
			continue

		listed_products += list(list(
			"key" = ++product_position,
			"name" = product.item_name,
			"price" = product.price,
			"category" = product.category,
			"ammount" = product.get_amount(),
			"image" = product.image
		))
	data["products"] = listed_products

	return data

/obj/machinery/vending/tgui_static_data(mob/user)
	var/list/data = list()
	data["isSilicon"] = istype(usr, /mob/living/silicon)
	return data

/obj/machinery/vending/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("remove_coin")
			coin.dropInto(loc)
			if(!usr.get_active_hand())
				usr.put_in_hands(coin)
			to_chat(usr, SPAN_NOTICE("You remove \the [coin] from \the [src]"))
			coin = null
			UpdateShowPremium(FALSE)
			return TRUE
		if("vend")
			var/key = text2num(params["vend"])
			if(!is_valid_index(key, product_records))
				return  FALSE
			var/datum/stored_items/vending_products/product = product_records[key]
			if(!istype(product))
				return FALSE
			if(!(product.category & vendor_flags))
				return FALSE
			if(product.price <= 0)
				vend(product, usr)
			else if(istype(usr, /mob/living/silicon))
				to_chat(usr, SPAN_WARNING("Artificial unit recognized. Purchase canceled."))
			else
				currently_vending = product
				if(!vendor_account || vendor_account.suspended)
					status_message = "Ошибка: Проблема со связанным счётом, платёж невозможен."
					status_error = TRUE
				else
					status_error = FALSE
			return TRUE
		if("cancelpurchase")
			currently_vending = null
			return TRUE
		if("togglevoice")
			shut_up = !shut_up
			return TRUE

/obj/machinery/vending/get_req_access()
	if(!scan_id)
		return list()
	return ..()

/obj/machinery/vending/dismantle()
	var/obj/structure/vending_refill/dump = new (loc)
	dump.SetName("[dump.name] ([name])")
	dump.expected_type = base_type || type
	for (var/datum/stored_items/vending_products/product in product_records)
		product.migrate(dump)
	dump.product_records = product_records
	product_records = null
	return ..()

/obj/machinery/vending/proc/attempt_to_stock(obj/item/item, mob/living/user)
	for (var/datum/stored_items/vending_products/product in product_records)
		if (item.type == product.item_path)
			stock(item, product, user)
			return TRUE

/obj/machinery/vending/proc/pay_with_cash(obj/item/spacecash/bundle/cash)
	if (currently_vending.price > cash.worth)
		to_chat(usr, "[icon2html(cash, usr)] [SPAN_WARNING("That is not enough money.")]")
		return FALSE
	visible_message(SPAN_INFO("\The [usr] inserts some cash into \the [src]."))
	cash.worth -= currently_vending.price
	if (cash.worth <= 0)
		qdel(cash)
	else
		cash.update_icon()
	credit_purchase("(cash)")
	return TRUE

/obj/machinery/vending/proc/pay_with_ewallet(obj/item/spacecash/ewallet/ewallet)
	visible_message(SPAN_INFO("\The [usr] swipes \the [ewallet] through \the [src]."))
	if (currently_vending.price > ewallet.worth)
		status_message = "Insufficient funds on chargecard."
		status_error = TRUE
		return FALSE
	ewallet.worth -= currently_vending.price
	credit_purchase("[ewallet.owner_name] (chargecard)")
	return TRUE

/obj/machinery/vending/proc/pay_with_card(obj/item/card/id/id, obj/item/item)
	if (id == item || isnull(item))
		visible_message(SPAN_INFO("\The [usr] swipes \the [id] through \the [src]."))
	else
		visible_message(SPAN_INFO("\The [usr] swipes \the [item] through \the [src]."))
	var/datum/money_account/customer_account = get_account(id.associated_account_number)
	if (!customer_account)
		status_message = "Ошибка: Нет доступа к аккаунту. Обратитесь в поддержку."
		status_error = TRUE
		return FALSE
	if (customer_account.suspended)
		status_message = "Ошибка: Нет доступа к аккаунту. Аккаунт заморожен."
		status_error = TRUE
		return FALSE
	if (customer_account.security_level)
		var/response = input("Enter pin code", "Vendor transaction") as null | num
		if (isnull(response) || !Adjacent(usr) || usr.incapacitated())
			status_message = "Пользователь отменил транзакцию."
			status_error = FALSE
			return FALSE
		customer_account = attempt_account_access(id.associated_account_number, response, 2)
		if (!customer_account)
			status_message = "Ошибка: Нет доступа к аккаунту. Обратитесь в поддержку."
			status_error = TRUE
			return FALSE
	if (currently_vending.price > customer_account.money)
		status_message = "Недостаточно средств на счету."
		status_error = TRUE
		return FALSE
	customer_account.transfer(vendor_account, currently_vending.price, "Purchase of [currently_vending.item_name]")
	return TRUE

/obj/machinery/vending/proc/credit_purchase(target)
	vendor_account.deposit(currently_vending.price, "Purchase of [currently_vending.item_name]", target)

/obj/machinery/vending/proc/vend(datum/stored_items/vending_products/product, mob/user)
	if (scan_id && !emagged && !allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		flick(icon_deny, src)
		return
	vend_ready = FALSE
	status_message = "Vending..."
	status_error = FALSE
	SStgui.update_uis(src)
	update_icon()
	if (product.category & VENDOR_CATEGORY_COIN)
		if(!coin)
			to_chat(user, SPAN_NOTICE("You need to insert a coin to get this item."))
			return
		if(!isnull(coin.string_color))
			if(prob(50))
				to_chat(user, SPAN_NOTICE("You successfully pull the coin out before \the [src] could swallow it."))
			else
				to_chat(user, SPAN_NOTICE("You weren't able to pull the coin out fast enough, the machine ate it, string and all."))
				qdel(coin)
				coin = null
				UpdateShowPremium(FALSE)
		else
			qdel(coin)
			coin = null
			UpdateShowPremium(FALSE)
	if (vend_reply && (last_reply + 20 SECONDS) <= world.time)
		spawn(0)
			speak(vend_reply)
			last_reply = world.time
	use_power_oneoff(vend_power_usage)
	if (icon_vend)
		flick(icon_vend, src)
	spawn(1 SECOND)
		product.get_product(get_turf(src))
		visible_message("\The [src] clunks as it vends \the [product.item_name].")
		playsound(src, 'sound/machines/vending_machine.ogg', 25, 1)
		if (prob(1))
			sleep(3)
			if (product.get_product(get_turf(src)))
				visible_message(SPAN_NOTICE("\The [src] clunks as it vends an additional [product.item_name]."))
		status_message = ""
		status_error = FALSE
		vend_ready = TRUE
		update_icon()
		currently_vending = null
		SStgui.update_uis(src)

/obj/machinery/vending/proc/stock(obj/item/item, datum/stored_items/vending_products/stored, mob/living/user)
	if (!user.unEquip(item))
		return
	if (stored.add_product(item))
		to_chat(user, SPAN_NOTICE("You insert \the [item] into \the [src]."))
		SStgui.update_uis(src)
		return TRUE
	SStgui.update_uis(src)

/obj/machinery/vending/proc/speak(message)
	if (!is_powered())
		return
	if (!message)
		return
	audible_message(SPAN_CLASS("game say", "[SPAN_CLASS("name", "\The [src]")] beeps, \"[message]\""))
	return

/obj/machinery/vending/proc/malfunction()
	for (var/datum/stored_items/vending_products/product in shuffle(product_records))
		if (product.category == VENDOR_CATEGORY_ANTAG)
			continue
		while (product.get_amount() > 0)
			product.get_product(loc)
		break
	set_broken(TRUE)

/obj/machinery/vending/proc/throw_item()
	var/mob/living/target = locate() in view(7, src)
	if (!target)
		return FALSE
	var/obj/item/throw_item
	for (var/datum/stored_items/vending_products/product in shuffle(product_records))
		if (product.category == VENDOR_CATEGORY_ANTAG)
			continue
		throw_item = product.get_product(loc)
		if (throw_item)
			break
	if (!throw_item)
		return FALSE
	spawn(0)
		throw_item.throw_at(target, rand(1,2), 3)
	visible_message(SPAN_WARNING("\The [src] launches \a [throw_item] at \the [target]!"))
	return TRUE

/obj/machinery/vending/proc/build_inventory(populate_parts)
	SHOULD_NOT_OVERRIDE(TRUE)

	for (var/list/entry in get_all_products())
		var/category = entry[1]
		var/list/products = entry[2]
		for (var/product_path in products)
			if(!product_path)
				stack_trace("Product path is null")
				continue

			var/atom/dummy = new product_path
			dummy.ImmediateOverlayUpdate()
			product_records += generate_product_record(dummy, category, products[product_path], get_product_image(dummy), populate_parts)
			qdel(dummy)

/obj/machinery/vending/proc/get_product_image(atom/dummy)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/static/list/product_image_cache = list()
	var/cache_key = "[dummy.name]:[dummy.icon]:[dummy.icon_state]:[dummy.color]"
	var/base64image = product_image_cache[cache_key]
	if(!base64image)
		base64image = icon2base64(getFlatIcon(dummy))
		product_image_cache[cache_key] = base64image

	return base64image

/obj/machinery/vending/proc/generate_product_record(atom/dummy, category, amount, image, populate_parts)
	var/datum/stored_items/vending_products/product = new(
		src,
		dummy.type,
		dummy.name,
		price = prices[dummy.type] || 0,
		category = category,
		rarity = rare_products[dummy.type] || 100,
		image = image)

	if (populate_parts)
		if(!amount)
			if (product.rarity == 100)
				amount = rand(minrandom, maxrandom)

			else if (product.rarity < 100 && product.category != VENDOR_CATEGORY_ANTAG)
				amount = prob(product.rarity) * rand(1,ceil(product.rarity / 10))

			else if (product.category == VENDOR_CATEGORY_ANTAG)
				amount = prob(product.rarity) * ceil(rand(1, antagrandom)) //Either 0 or 1 of a rare antag product, for balance purposes. Exception if antagrandom is redefined from default of 1.

		product.amount = amount

	if (colored_entries)
		switch(product.category)
			if (VENDOR_CATEGORY_HIDDEN)
				product.display_color = COLOR_DARK_ORANGE
			if (VENDOR_CATEGORY_COIN)
				product.display_color = COLOR_LIME
			if (VENDOR_CATEGORY_ANTAG)
				product.display_color = COLOR_RED
			if (VENDOR_CATEGORY_NORMAL)
				if (product.rarity < 100)
					product.display_color = COLOR_GOLD

	return product

/obj/machinery/vending/proc/get_all_products()
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!length(all_products))
		if(possible_vendor_flags & VENDOR_CATEGORY_NORMAL)
			all_products += list(list(VENDOR_CATEGORY_NORMAL, products))
		if(possible_vendor_flags & VENDOR_CATEGORY_HIDDEN)
			all_products += list(list(VENDOR_CATEGORY_HIDDEN, contraband))
		if(possible_vendor_flags & VENDOR_CATEGORY_COIN)
			all_products += list(list(VENDOR_CATEGORY_COIN, premium))
		if(possible_vendor_flags & VENDOR_CATEGORY_ANTAG)
			all_products += list(list(VENDOR_CATEGORY_ANTAG, antag))

	return all_products

/obj/machinery/vending/proc/IsShowingProducts()
	return HAS_FLAGS(vendor_flags, VENDOR_CATEGORY_NORMAL)

/// Update whether the vendor should show the normal products category, flipping if null.
/obj/machinery/vending/proc/UpdateShowProducts(show)
	if (isnull(show))
		FLIP_FLAGS(vendor_flags, VENDOR_CATEGORY_NORMAL)
	else if (show)
		SET_FLAGS(vendor_flags, VENDOR_CATEGORY_NORMAL)
	else
		CLEAR_FLAGS(vendor_flags, VENDOR_CATEGORY_NORMAL)

/obj/machinery/vending/proc/IsShowingContraband()
	return HAS_FLAGS(vendor_flags, VENDOR_CATEGORY_HIDDEN)

/// Update whether the vendor should show the contraband category, flipping if null.
/obj/machinery/vending/proc/UpdateShowContraband(show)
	if (isnull(show))
		FLIP_FLAGS(vendor_flags, VENDOR_CATEGORY_HIDDEN)
	else if (show)
		SET_FLAGS(vendor_flags, VENDOR_CATEGORY_HIDDEN)
	else
		CLEAR_FLAGS(vendor_flags, VENDOR_CATEGORY_HIDDEN)

/obj/machinery/vending/proc/IsShowingPremium()
	return HAS_FLAGS(vendor_flags, VENDOR_CATEGORY_COIN)

/// Update whether the vendor should show the premium category, flipping if null.
/obj/machinery/vending/proc/UpdateShowPremium(show)
	if (isnull(show))
		FLIP_FLAGS(vendor_flags, VENDOR_CATEGORY_COIN)
	else if (show)
		SET_FLAGS(vendor_flags, VENDOR_CATEGORY_COIN)
	else
		CLEAR_FLAGS(vendor_flags, VENDOR_CATEGORY_COIN)

/obj/machinery/vending/proc/IsShowingAntag()
	return HAS_FLAGS(vendor_flags, VENDOR_CATEGORY_ANTAG)

/// Update whether the vendor should show the antag category, flipping if null.
/obj/machinery/vending/proc/UpdateShowAntag(show)
	if (isnull(show))
		FLIP_FLAGS(vendor_flags, VENDOR_CATEGORY_ANTAG)
	else if (show)
		SET_FLAGS(vendor_flags, VENDOR_CATEGORY_ANTAG)
	else
		CLEAR_FLAGS(vendor_flags, VENDOR_CATEGORY_ANTAG)
