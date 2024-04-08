GLOBAL_LIST_EMPTY(gear_tweak_free_color_choice_)
/proc/gear_tweak_free_color_choice()
	if(!GLOB.gear_tweak_free_color_choice_) GLOB.gear_tweak_free_color_choice_ = new()
	return GLOB.gear_tweak_free_color_choice_

//var/datum/gear_tweak/color/gear_tweak_free_color_choice_
//#define gear_tweak_free_color_choice (gear_tweak_free_color_choice_ ? gear_tweak_free_color_choice_ : (gear_tweak_free_color_choice_ = new()))
// Might work in 511 assuming x=y=5 gets implemented.

GLOBAL_LIST_EMPTY(gear_tweak_free_name_)

/proc/gear_tweak_free_name()
	if(!GLOB.gear_tweak_free_name_) GLOB.gear_tweak_free_name_ = new()
	return GLOB.gear_tweak_free_name_

GLOBAL_LIST_EMPTY(gear_tweak_free_desc_)

/proc/gear_tweak_free_desc()
	if(!GLOB.gear_tweak_free_desc_) GLOB.gear_tweak_free_desc_ = new()
	return GLOB.gear_tweak_free_desc_
