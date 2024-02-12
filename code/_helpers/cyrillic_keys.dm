/proc/convert_ru_symbols_to_en(text)
	for(var/i in 1 to length(text))
		var/letter = lowertext(copytext_char(text, i, i + 1))
		var/ru_letter = GLOB.ru_symbol_to_en[letter]
		if(ru_letter)
			. += ru_letter
			continue
		. += letter

GLOBAL_LIST_INIT(ru_symbol_to_en, list(
	"й" = "i", "ц" = "c", "у" = "u", "к" = "k", "е" = "e", "н" = "n", "г" = "g", "ш" = "sh", "щ" = "sh", "з" = "z", "х" = "h", "ъ" = "",
	"ф" = "f", "ы" = "y", "в" = "v", "а" = "a", "п" = "p", "р" = "r", "о" = "o", "л" = "l", "д" = "d", "ж" = "zh", "э" = "e",
	"я" = "ja", "ч" = "ch", "с" = "s", "м" = "m", "и" = "i", "т" = "t", "ь" = "", "б" = "b", "ю" = "iu", "ё" = "e"
))
