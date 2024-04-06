g_FUGITIVE_PERK = {
	id = "fugitive perk id",
	name = "Fugitive",
	description = "After reaching the quota, become temporarily invisible."
}
g_MECHANIC_PERK = {
	id = "mechanic perk id",
	name = "Mechanic",
	description = "Stand still to slowly regain health."
}
g_HOTSHOT_PERK = {
	id = "hotshot perk id",
	name = "Hotshot",
	description = "The lower your health, the higher your top speed."
}
g_PERK_SELECTION_DURATION = 15000

g_PLAYER_ROLE_SELECTED_EVENT = "onPlayerRoleSelected" -- role

g_POLICE_ROLE = "PoliceRole"
g_CRIMINAL_ROLE = "CriminalRole"
g_POLICE_TEAM_NAME = "The Police"

g_SHOW_JOB_EVENT = "onShowJob" -- jobId, jobType, jobPos
g_HIDE_JOB_EVENT = "onHideJob" -- jobId
g_START_JOB_EVENT = "onStartJob" -- jobId, jobType
g_STOP_JOB_EVENT = "onStopJob" -- jobId, jobType
g_FINISH_JOB_EVENT = "onFinishJob" -- jobId (jobType) (reportedplayers) (client only)
g_JOB_STATUS_UPDATE_EVENT = "onJobStatusUpdate" -- jobId, jobType, data (depends on jobType)

g_MONEY_UPDATE_EVENT = "onMoneyUpdate"
g_GAME_STATE_UPDATE_EVENT = "onGameStateUpdate" -- state
g_ESCAPE_ROUTE_APPEARED = "onEscapeRouteAppeared"
g_COREGAME_STATE = "coregame"
g_ENDGAME_STATE = "endgame"
g_ENDENDGAME_STATE = "endendgame"
g_BADEND_STATE = "badend"

g_PICKUP_JOB = {
	elementType = "pickup_job",
	type = "pickup job",
	detectionRadius = 250,
	zoneRadius = 5,
	blip = 52,
	color = { r = 20, g = 150, b = 0, a = 100 },
	jobWeight = 1,
	progressRate = 0.15
}
g_DELIVERY_JOB = {
	elementType = "delivery_job_start",
	type = "delivery job",
	subtypes = {
		ELIMINATION = "elimination",
		DELIVERY = "delivery",
	},
	detectionRadius = 250,
	zoneRadius = 5,
	blip = 51,
	color = { r = 255, g = 0, b = 0, a = 100 },
	jobWeight = 1.2 -- and bonus
}
g_EXTORTION_JOB = {
	elementType = "extortion_job",
	type = "extortion job",
	detectionRadius = 250,
	zoneRadius = 5,
	blip = 55,
	color = { r = 0, g = 0, b = 160, a = 100 },
	jobWeight = 1.2,
	progressRate = 0.025, -- per interval
	decayRate = 0.05, -- per interval
	interval = 100 -- in ms
}
g_GROUP_JOB = {
	elementType = "group_job",
	type = "group job",
	detectionRadius = 1000,
	zoneRadius = 22,
	blip = 6,
	color = { r = 255, g = 255, b = 255, a = 100 },
	jobWeight = 3,
	progressRate = 0.05,
	decayRate = 0.1,
	minPlayers = 3
}
g_JOBS_BY_TYPE = {
	[g_PICKUP_JOB.type] = g_PICKUP_JOB,
	[g_DELIVERY_JOB.type] = g_DELIVERY_JOB,
	[g_EXTORTION_JOB.type] = g_EXTORTION_JOB,
	[g_GROUP_JOB.type] = g_GROUP_JOB
}