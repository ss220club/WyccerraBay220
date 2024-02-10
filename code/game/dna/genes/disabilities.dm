/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability, or sdisability.
//
// Gene is always activated.
/////////////////////

/datum/dna/gene/disability
	name="DISABILITY"

	// Mutation to give (or 0)
	var/mutation=0

	// Disability to give (or 0)
	var/disability=0

	// SDisability to give (or 0)
	var/sdisability=0

	// Activation message
	var/activation_message=""

	// Yay, you're no longer growing 3 arms
	var/deactivation_message=""

/datum/dna/gene/disability/can_activate(mob/M,flags)
	return 1 // Always set!

/datum/dna/gene/disability/activate(mob/M, connected, flags)
	if(mutation && !(mutation in M.mutations))
		M.mutations.Add(mutation)
	if(disability)
		M.disabilities|=disability
	if(sdisability)
		M.set_sdisability(sdisability)
	if(activation_message)
		to_chat(M, SPAN_WARNING("[activation_message]"))
	else
		testing("[name] не имеет сообщения активации.")

/datum/dna/gene/disability/deactivate(mob/M, connected, flags)
	if(mutation && (mutation in M.mutations))
		M.mutations.Remove(mutation)
	if(disability)
		M.disabilities &= (~disability)
	if(sdisability)
		M.unset_sdisability(sdisability)
	if(deactivation_message)
		to_chat(M, SPAN_WARNING("[deactivation_message]"))
	else
		testing("[name] не имеет сообщения деактивации.")

// Note: Doesn't seem to do squat, at the moment.
/datum/dna/gene/disability/hallucinate
	name="Галлюцинация"
	activation_message="Твой разум говорит 'Привет, ГЫ'"
	mutation=mHallucination

/datum/dna/gene/disability/hallucinate/New()
	block=GLOB.HALLUCINATIONBLOCK

/datum/dna/gene/disability/epilepsy
	name="Эпилепсия"
	activation_message="У тебя болит голова."
	disability=EPILEPSY

/datum/dna/gene/disability/epilepsy/New()
	block=GLOB.HEADACHEBLOCK

/datum/dna/gene/disability/cough
	name="Кашель"
	activation_message="Вы начинаете кашлять."
	disability=COUGHING

/datum/dna/gene/disability/cough/New()
	block=GLOB.COUGHBLOCK

/datum/dna/gene/disability/clumsy
	name="Неуклюжесть"
	activation_message="Вы чувствуете головокружение."
	mutation=MUTATION_CLUMSY

/datum/dna/gene/disability/clumsy/New()
	block=GLOB.CLUMSYBLOCK

/datum/dna/gene/disability/nervousness
	name="Нервозность"
	activation_message="Вы нервничаете."
	disability=NERVOUS

/datum/dna/gene/disability/nervousness/New()
	block=GLOB.NERVOUSBLOCK

/datum/dna/gene/disability/blindness
	name="Слепота"
	activation_message="Вы не можете ничего увидеть."
	sdisability=BLINDED

/datum/dna/gene/disability/blindness/New()
	block=GLOB.BLINDBLOCK

/datum/dna/gene/disability/deaf
	name="Глухота"
	activation_message="Кажется очень тихо."
	sdisability=DEAFENED

/datum/dna/gene/disability/deaf/New()
	block=GLOB.DEAFBLOCK

/datum/dna/gene/disability/deaf/activate(mob/M, connected, flags)
	..(M,connected,flags)
	M.ear_deaf = 1

/datum/dna/gene/disability/nearsighted
	name="Близорукость"
	activation_message="Твои глаза кажутся странными..."
	disability=NEARSIGHTED

/datum/dna/gene/disability/nearsighted/New()
	block=GLOB.GLASSESBLOCK
