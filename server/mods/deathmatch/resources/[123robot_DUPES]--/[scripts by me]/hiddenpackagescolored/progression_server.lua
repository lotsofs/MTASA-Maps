function spamChatReward(text)
    outputChatBox(text, root, 231, 217, 176, true)
end
addEvent("onSpamChatReward", true)
addEventHandler("onSpamChatReward", resourceRoot, spamChatReward)

function spamKillFeed(packType, player)
	local resource = getResourceFromName("killmessages")
	if not resource then return end
	local state = getResourceState(resource)
	if (state ~= "running") then return end
	--Output a killmessage
	exports.killmessages:outputMessage(
		{
			{"image",path="icons/"..PACKAGE_TYPES[packType].forwardName..".png",resource=getThisResource(),width=PACKAGE_TYPES[packType].iconWidth},
			getPlayerName(player),
		},
		root,
		PACKAGE_TYPES[packType].r,PACKAGE_TYPES[packType].g,PACKAGE_TYPES[packType].b
	)
end