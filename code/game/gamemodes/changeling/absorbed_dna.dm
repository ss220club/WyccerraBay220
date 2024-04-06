/datum/absorbed_dna
	var/name
	var/datum/dna/dna
	var/speciesName
	var/list/languages

/datum/absorbed_dna/New(newName, newDNA, newSpecies, newLanguages, newPronouns)
	..()
	name = newName
	dna = newDNA
	speciesName = newSpecies
	languages = newLanguages
