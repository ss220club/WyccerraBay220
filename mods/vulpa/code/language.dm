/datum/language/vulpkanin
	name = LANGUAGE_KANILUNTS
	desc = "Живущие в системе Ваззенд обитатели говорят и используют гуттуральный язык, состоящий из рычаний, лаяний, хлопков и интенсивного использования движений ушей и хвоста. \
	Вульпканины легко говорят на этом языке."
	speech_verb = "rawrs"
	ask_verb = "rurs"
	exclaim_verb = "barks"
	colour = "vulpkanin"
	key = "7"
	flags = RESTRICTED
	syllables = list("rur","ya","cen","rawr","bar","kuk","tek","qat","uk","wu","vuh","tah","tch","schz","auch", \
	"ist","ein","entch","zwichs","tut","mir","wo","bis","es","vor","nic","gro","lll","enem","zandt","tzch","noch", \
	"hel","ischt","far","wa","baram","iereng","tech","lach","sam","mak","lich","gen","or","ag","eck","gec","stag","onn", \
	"bin","ket","jarl","vulf","einech","cresthz","azunein","ghzth")

/datum/language/vulpkanin/get_random_name(gender)
	var/new_name
	if(gender == FEMALE)
		new_name = pick(GLOB.first_names_female_vulp)
	else
		new_name = pick(GLOB.first_names_male_vulp)
	new_name += " " + pick(GLOB.last_names_vulp)
	return new_name
