/datum/game_mode/devil
	name = "devil"
	config_tag = "devil"
	protected_jobs = list("Lawyer", "Librarian", "Chaplain", "Head of Security", "Captain", "AI")
	required_players = 2
	required_enemies = 1
	recommended_enemies = 4

	var/traitors_possible = 4 //hard limit on devils if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/objective_count = 2
	var/minimum_devils = 1

/datum/game_mode/devil/announce()
	to_chat(world, {"<B>The current game mode is - Devil!</B><br>)
		<span class='danger'>Devils</span>: Purchase souls and tempt the crew to sin!<br>
		<span class='notice'>Crew</span>: Resist the lure of sin and remain pure!"})

/datum/game_mode/devil/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/num_devils = 1

	num_devils = max(minimum_devils, min(round(num_players()/8)+ 2))


	for(var/j = 0, j < num_devils, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/devil = pick(antag_candidates)
		devils += devil
		devil.special_role = ROLE_DEVIL
		devil.restricted_roles = restricted_jobs

		log_game("[devil.key] (ckey) has been selected as a [config_tag]")
		antag_candidates.Remove(devil)

	if(devils.len < required_enemies)
		return 0
	return 1


/datum/game_mode/devil/post_setup()
	for(var/datum/mind/devil in devils)
		spawn(rand(10,100))
			finalize_devil(devil, objective_count)
			spawn(100)
				add_devil_objectives(devil, objective_count) //This has to be in a separate loop, as we need devil names to be generated before we give objectives in devil agent.
				devil.announceDevilLaws()
				devil.announce_objectives()
	modePlayer += devils
	..()
	return 1
