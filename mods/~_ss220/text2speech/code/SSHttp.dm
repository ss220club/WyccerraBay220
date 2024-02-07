SUBSYSTEM_DEF(http)
	name = "HTTP"
	flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT // Measure in ticks, but also only run if we have the spare CPU.
	wait = 1
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY // All the time
	// Assuming for the worst, since only discord is hooked into this for now, but that may change
	/// List of all async HTTP requests in the processing chain
	var/list/datum/http_request/active_async_requests = list()
	/// Variable to define if logging is enabled or not. Disabled by default since we know the requests the server is making. Enable with VV if you need to debug requests
	var/logging_enabled = FALSE
	/// Total requests the SS has processed in a round
	var/total_requests

/datum/controller/subsystem/http/PreInit()
	. = ..()
	rustg_create_async_http_client() // Open the door

/datum/controller/subsystem/http/get_stat_details()
	return "P: [length(active_async_requests)] | T: [total_requests]"

/datum/controller/subsystem/http/fire(resumed)
	for(var/r in active_async_requests)
		var/datum/http_request/req = r
		// Check if we are complete
		if(req.is_complete())
			// If so, take it out the processing list
			active_async_requests -= req
			var/datum/http_response/res = req.into_response()

			// If the request has a callback, invoke it.Async of course to avoid choking the SS
			if(req.cb)
				req.cb.invoke_async(res)

			// And log the result
			if(logging_enabled)
				var/list/log_data = list()
				log_data += "BEGIN ASYNC RESPONSE (ID: [req.id])"
				if(res.errored)
					log_data += "\t ----- RESPONSE ERRROR -----"
					log_data += "\t [res.error]"
				else
					log_data += "\tResponse status code: [res.status_code]"
					log_data += "\tResponse body: [res.body]"
					log_data += "\tResponse headers: [json_encode(res.headers)]"
				log_data += "END ASYNC RESPONSE (ID: [req.id])"
				log_debug(log_data.Join("\n[GLOB.log_end]"))

/**
  * Async request creator
  *
  * Generates an async request, and adds it to the subsystem's processing list
  * These should be used as they do not lock the entire DD process up as they execute inside their own thread pool inside RUSTG
  */
/datum/controller/subsystem/http/proc/create_async_request(method, url, body = "", list/headers, datum/callback/proc_callback)
	var/datum/http_request/req = new()
	req.prepare(method, url, body, headers)
	if(proc_callback)
		req.cb = proc_callback

	// Begin it and add it to the SS active list
	req.begin_async()
	active_async_requests += req
	total_requests++

	if(logging_enabled)
		// Create a log holder
		var/list/log_data = list()
		log_data += "BEGIN ASYNC REQUEST (ID: [req.id])"
		log_data += "\t[uppertext(req.method)] [req.url]"
		log_data += "\tRequest body: [req.body]"
		log_data += "\tRequest headers: [req.headers]"
		log_data += "END ASYNC REQUEST (ID: [req.id])"

		// Write the log data
		log_debug(log_data.Join("\n[GLOB.log_end]"))

/**
  * Blocking request creator
  *
  * Generates a blocking request, executes it, logs the info then cleanly returns the response
  * Exists as a proof of concept, and should never be used
  */
/datum/controller/subsystem/http/proc/make_blocking_request(method, url, body = "", list/headers)
	CRASH("Attempted use of a blocking HTTP request")

/**
  * # HTTP Request
  *
  * Holder datum for ingame HTTP requests
  *
  * Holds information regarding to methods used, URL, and response,
  * as well as job IDs and progress tracking for async requests
  */
/datum/http_request
	/// The ID of the request (Only set if it is an async request)
	var/id
	/// Is the request in progress? (Only set if it is an async request)
	var/in_progress = FALSE
	/// HTTP method used
	var/method
	/// Body of the request being sent
	var/body
	/// Request headers being sent
	var/headers
	/// URL that the request is being sent to
	var/url
	/// If present, response body will be saved to this file.
	var/output_file
	/// The raw response, which will be decoeded into a [/datum/http_response]
	var/_raw_response
	/// Callback for executing after async requests. Will be called with an argument of [/datum/http_response] as first argument
	var/datum/callback/cb

/*
###########################################################################
THE METHODS IN THIS FILE ARE TO BE USED BY THE SUBSYSTEM AS A MANGEMENT HUB
----------------------- DO NOT MANUALLY INVOKE THEM -----------------------
###########################################################################
*/

/**
  * Preparation handler
  *
  * Call this with relevant parameters to form the request you want to make
  *
  * Arguments:
  * * _method - HTTP Method to use, see code/__DEFINES/rust_g.dm for a full list
  * * _url - The URL to send the request to
  * * _body - The body of the request, if applicable
  * * _headers - Associative list of HTTP headers to send, if applicab;e
  */
/datum/http_request/proc/prepare(_method, _url, _body = "", list/_headers, _output_file)
	if(!length(_headers))
		headers = ""
	else
		headers = json_encode(_headers)

	method = _method
	url = _url
	body = _body
	output_file = _output_file

/**
  * Blocking executor
  *
  * Remains as a proof of concept to show it works, but should NEVER be used to do FFI halting the entire DD process up
  * Async rqeuests are much preferred, but also require the subsystem to be firing for them to be answered
  */
/datum/http_request/proc/execute_blocking()
	CRASH("Attempted to execute a blocking HTTP request")
	// _raw_response = rustg_http_request_blocking(method, url, body, headers, build_options())

/**
  * Async execution starter
  *
  * Tells the request to start executing inside its own thread inside RUSTG
  * Preferred over blocking, but also requires SShttp to be active
  * As such, you cannot use this for events which may happen at roundstart (EG: IPIntel, BYOND account tracking, etc)
  */
/datum/http_request/proc/begin_async()
	if(in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, build_options())

	if(isnull(text2num(id)))
		_raw_response = "Proc error: [id]"
		CRASH("Proc error: [id]")
	else
		in_progress = TRUE

/**
  * Options builder
  *
  * Builds options for if we want to download files with SShttp
  */
/datum/http_request/proc/build_options()
	if(output_file)
		return json_encode(list("output_filename" = output_file, "body_filename" = null))
	return null

/**
  * Async completion checker
  *
  * Checks if an async request has been complete
  * Has safety checks built in to compensate if you call this on blocking requests,
  * or async requests which have already finished
  */
/datum/http_request/proc/is_complete()
	// If we dont have an ID, were blocking, so assume complete
	if(isnull(id))
		return TRUE

	// If we arent in progress, assume complete
	if(!in_progress)
		return TRUE

	// We got here, so check the status
	var/result = rustg_http_check_request(id)

	// If we have no result, were not finished
	if(result == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		// If we got here, we have a result to parse
		_raw_response = result
		in_progress = FALSE
		return TRUE

/**
  * Response deserializer
  *
  * Takes a HTTP request object, and converts it into a [/datum/http_response]
  * The entire thing is wrapped in try/catch to ensure it doesnt break on invalid requests
  * Can be called on async and blocking requests
  */
/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

	return R

/**
  * # HTTP Response
  *
  * Holder datum for HTTP responses
  *
  * Created from calling [/datum/http_request/proc/into_response()]
  * Contains vars about the result of the response
  */
/datum/http_response
	/// The HTTP status code of the response
	var/status_code
	/// The body of the response from the server
	var/body
	/// Associative list of headers sent from the server
	var/list/headers
	/// Has the request errored
	var/errored = FALSE
	/// Raw response if we errored
	var/error
