/datum/dna/gene/basic/nobreath
	name = "Воздух+"
	activation_messages = list("Кажется теперь вам не нужно дышать.")
	mutation = mNobreath

/datum/dna/gene/basic/nobreath/New()
	block = GLOB.NOBREATHBLOCK

/datum/dna/gene/basic/feral
	name = "Дикость"
	activation_messages = list("Ты чувствуешь себя диким.")
	mutation = MUTATION_FERAL

/datum/dna/gene/basic/feral/New()
	block = GLOB.FERALBLOCK

/datum/dna/gene/basic/remoteview
	name = "Удаленный просмотр"
	activation_messages = list("Ваш разум расширяется.")
	mutation = mRemote


/datum/dna/gene/basic/remoteview/New()
	block = GLOB.REMOTEVIEWBLOCK


/datum/dna/gene/basic/remoteview/activate(mob/M, connected, flags)
	..(M, connected, flags)
	M.verbs += /mob/living/carbon/human/proc/remoteobserve


/datum/dna/gene/basic/regenerate
	name = "Регенарция"
	activation_messages = list("Вы чувствуете себя лучше.")
	mutation = mRegen


/datum/dna/gene/basic/regenerate/New()
	block = GLOB.REGENERATEBLOCK


/datum/dna/gene/basic/increaserun
	name = "Супер скорость"
	activation_messages = list("Ваши мышцы ног пульсируют.")
	mutation = mRun


/datum/dna/gene/basic/increaserun/New()
	block = GLOB.INCREASERUNBLOCK


/datum/dna/gene/basic/remotetalk
	name = "Телепатия"
	activation_messages = list("Вы расширяете свой разум вовне.")
	mutation = mRemotetalk


/datum/dna/gene/basic/remotetalk/New()
	block = GLOB.REMOTETALKBLOCK


/datum/dna/gene/basic/remotetalk/activate(mob/M, connected, flags)
	..(M, connected, flags)
	M.verbs += /mob/living/carbon/human/proc/remotesay


/datum/dna/gene/basic/morph
	name = "Морф"
	activation_messages = list("Ваша кожа чувствует себя странно.")
	mutation = mMorph


/datum/dna/gene/basic/morph/New()
		block = GLOB.MORPHBLOCK


/datum/dna/gene/basic/morph/activate(mob/M)
	..(M)
	M.verbs += /mob/living/carbon/human/proc/morph


/datum/dna/gene/basic/cold_resist
	name = "Сопротивление холоду"
	activation_messages = list("Ваше тело наполняется теплом.")
	mutation = MUTATION_COLD_RESISTANCE


/datum/dna/gene/basic/cold_resist/New()
	block = GLOB.FIREBLOCK


/datum/dna/gene/basic/cold_resist/can_activate(mob/M, flags)
	if (flags & MUTCHK_FORCED)
		return TRUE
	return prob(30)


/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(mob/M, g, fat)
	return "fire[fat]_s"


/datum/dna/gene/basic/noprints
	name = "Отпечатки-"
	activation_messages = list("Ваши отпечатки сходят на нет")
	mutation = mFingerprints


/datum/dna/gene/basic/noprints/New()
	block = GLOB.NOPRINTSBLOCK


/datum/dna/gene/basic/noshock
	name = "Иммунитет к шоку"
	activation_messages = list("Ваша кожа чувствует себя странно.")
	mutation = mShock


/datum/dna/gene/basic/noshock/New()
	block = GLOB.SHOCKIMMUNITYBLOCK


/datum/dna/gene/basic/midget
	name = "Карлик"
	activation_messages = list("Ваша кожа становится резиновой.")
	mutation = mSmallsize


/datum/dna/gene/basic/midget/New()
	block = GLOB.SMALLSIZEBLOCK


/datum/dna/gene/basic/midget/activate(mob/M, connected, flags)
	..(M,connected, flags)
	M.pass_flags |= PASS_FLAG_TABLE


/datum/dna/gene/basic/midget/deactivate(mob/M, connected, flags)
	..(M,connected, flags)
	M.pass_flags &= ~PASS_FLAG_TABLE


/datum/dna/gene/basic/xray
	name = "Рентген+"
	activation_messages = list("Стены внезапно исчезают.")
	mutation = MUTATION_XRAY


/datum/dna/gene/basic/xray/New()
	block = GLOB.XRAYBLOCK
