/datum/stored_items/vending_products
	var/price
	var/display_color
	var/category
	var/rarity
	/// Image as base64. Used in vendor's UI
	var/image

/datum/stored_items/vending_products/New(atom/vending_machine, atom/path, name, amount, price, color, category, rarity, image)
	..()
	src.price = price
	src.display_color = color
	src.category = category
	src.rarity = rarity
	src.image = image
