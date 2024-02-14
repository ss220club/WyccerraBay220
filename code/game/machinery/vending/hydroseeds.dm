/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon_state = "seeds"
	icon_vend = "seeds-vend"
	max_overlays = 3
	icon_deny = "seeds-deny"
	base_type = /obj/machinery/vending/hydroseeds
	product_slogans = {"\
		THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;\
		Hands down the best seed selection this half of the galaxy!;\
		Also certain mushroom varieties available, more for experts! Get certified today!\
	"}
	product_ads = {"\
		We like plants!;\
		Grow some crops!;\
		Grow, baby, growww!;\
		Aw h'yeah son!
	"}
	possible_vendor_flags = VENDOR_CATEGORY_NORMAL|VENDOR_CATEGORY_HIDDEN|VENDOR_CATEGORY_COIN
	products = list(
		/obj/item/seeds/bananaseed = 3,
		/obj/item/seeds/berryseed = 3,
		/obj/item/seeds/carrotseed = 3,
		/obj/item/seeds/chantermycelium = 3,
		/obj/item/seeds/chiliseed = 3,
		/obj/item/seeds/cornseed = 3,
		/obj/item/seeds/eggplantseed = 3,
		/obj/item/seeds/potatoseed = 3,
		/obj/item/seeds/replicapod = 3,
		/obj/item/seeds/soyaseed = 3,
		/obj/item/seeds/sunflowerseed = 3,
		/obj/item/seeds/tomatoseed = 3,
		/obj/item/seeds/towermycelium = 3,
		/obj/item/seeds/wheatseed = 3,
		/obj/item/seeds/appleseed = 3,
		/obj/item/seeds/poppyseed = 3,
		/obj/item/seeds/sugarcaneseed = 3,
		/obj/item/seeds/ambrosiavulgarisseed = 3,
		/obj/item/seeds/peanutseed = 3,
		/obj/item/seeds/whitebeetseed = 3,
		/obj/item/seeds/watermelonseed = 3,
		/obj/item/seeds/limeseed = 3,
		/obj/item/seeds/lemonseed = 3,
		/obj/item/seeds/lettuceseed = 3,
		/obj/item/seeds/orangeseed = 3,
		/obj/item/seeds/grassseed = 3,
		/obj/item/seeds/cocoapodseed = 3,
		/obj/item/seeds/plumpmycelium = 2,
		/obj/item/seeds/cabbageseed = 3,
		/obj/item/seeds/grapeseed = 3,
		/obj/item/seeds/pumpkinseed = 3,
		/obj/item/seeds/cherryseed = 3,
		/obj/item/seeds/plastiseed = 3,
		/obj/item/seeds/riceseed = 3,
		/obj/item/seeds/lavenderseed = 3
	)
	contraband = list(
		/obj/item/seeds/amanitamycelium = 2,
		/obj/item/seeds/glowshroom = 2,
		/obj/item/seeds/libertymycelium = 2,
		/obj/item/seeds/mtearseed = 2,
		/obj/item/seeds/nettleseed = 2,
		/obj/item/seeds/reishimycelium = 2,
		/obj/item/seeds/reishimycelium = 2,
		/obj/item/seeds/shandseed = 2
	)
	premium = list(
		/obj/item/reagent_containers/spray/waterflower = 1
	)

/obj/machinery/vending/hydroseeds/generate_product_record(atom/dummy, category, amount, image, populate_parts)
	return new/datum/stored_items/vending_products(
		src,
		dummy.type,
		dummy.name,
		price = prices[dummy.type] || 0,
		amount = amount || 1,
		category = category,
		image = image)

/obj/machinery/vending/hydroseeds/generic
	icon_state = "seeds_generic"
	icon_vend = "seeds_generic-vend"
	icon_deny = "seeds_generic-deny"
