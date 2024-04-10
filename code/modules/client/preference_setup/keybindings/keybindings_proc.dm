/datum/category_item/player_setup_item/controls/keybindings/proc/pretty_keybinding_name(keybinding)
	var/list/keys = list()
	var/static/regex/modKeys = regex("Shift|Ctrl|Alt")

	while(modKeys.Find(keybinding))
		keys += modKeys.match
		keybinding = copytext(keybinding, length(modKeys.match)+1)

	if (keybinding)
		keys += keybinding

	return jointext(keys, "+")

/datum/category_item/player_setup_item/controls/keybindings/proc/capture_keybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div class='Section fill'id='focus' style="outline: 0; text-align:center;" tabindex=0>
		Keybinding: [kb.full_name]<br>[kb.description]
		<br><br>
		<b>Press any key to change<br>Press ESC to clear</b>
	</div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var sanitizedKey = e.key;
		if (47 < e.keyCode && e.keyCode < 58) {
			sanitizedKey = String.fromCharCode(e.keyCode);
		}
		else if (64 < e.keyCode && e.keyCode < 91) {
			sanitizedKey = String.fromCharCode(e.keyCode);
		}
		var url = 'byond://?src=\ref[src];preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+sanitizedKey+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)

/proc/sanitize_keybindings(value)
	var/list/base_bindings = sanitize_islist(value,list())
	for(var/key in base_bindings)
		base_bindings[key] = base_bindings[key] & global.keybindings_by_name
		if(!length(base_bindings[key]))
			base_bindings -= key
	return base_bindings

/proc/sanitize_islist(value, default)
	if(islist(value) && length(value))
		return value
	if(default)
		return default
