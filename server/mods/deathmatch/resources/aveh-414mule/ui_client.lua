-- SHOW_TUTORIAL = false
-- SHOW_MID_PLAY_TUTORIAL = false
-- SHOW_CAR = false

-- TEXT = ""
-- TUTORIAL_BLURB = "<blurb>"
-- MID_PLAY_BLURB = nil
-- CAR_BLURB = "wwwwwwww"

-- function drawHudOverlay()
-- 	if (SHOW_TUTORIAL) then
-- 		drawBorderedText(TUTORIAL_BLURB, 2, SCREENWIDTH*0.20, SCREENHEIGHT*0.25, SCREENWIDTH*0.8, SCREENHEIGHT, tocolor(255, 255, 255, 255), 3, "default-bold", "center", "top", false, true, true, true)
-- 	end
-- 	if (SHOW_MID_PLAY_TUTORIAL) then
-- 		drawBorderedText(MID_PLAY_BLURB, 2, SCREENWIDTH*0.25, SCREENHEIGHT*0.75, SCREENWIDTH*0.75, SCREENHEIGHT, tocolor(255, 255, 255, 255), 2, "default-bold", "center", "top", false, true, true, true)
-- 	end
-- 	if (SHOW_CAR) then
-- 		drawBorderedText(CAR_BLURB, 2, SCREENWIDTH*0.2, SCREENHEIGHT*0.88, SCREENWIDTH*0.98, SCREENHEIGHT, tocolor(54, 104, 44, 255), 3, "bankgothic", "left", "top", false, false, true, true)
-- 	end
-- end
-- addEventHandler("onClientRender", root, drawHudOverlay)


-- alignX: horizontal alignment of the text within the bounding box. Can be "left", "center" or "right".
-- alignY: vertical alignment of the text within the bounding box. Can be "top", "center" or "bottom".

-- font: Either a custom DX font element or the name of a built-in DX font: Note: Some fonts are incompatible with certain languages such as Arabic.
-- "default": Tahoma
-- "default-bold": Tahoma Bold
-- "clear": Verdana
-- "arial": Arial
-- "sans": Microsoft Sans Serif
-- "pricedown": Pricedown (GTA's theme text)
-- "bankgothic": Bank Gothic Medium
-- "diploma": Diploma Regular
-- "beckett": Beckett Regular
-- "unifont": Unifont



function drawBorderedTextScreenRelative(text, borderSize, left, top, right, bottom, color, size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	SCREENWIDTH, SCREENHEIGHT = guiGetScreenSize()
	drawBorderedText(text, 2, SCREENWIDTH*left, SCREENHEIGHT*top, SCREENWIDTH*right, SCREENHEIGHT*bottom, color, size, font, horizAlign, vertiAlignclip, wordBreak, postGui, colorCoded)
end

function drawBorderedText(text, borderSize, left, top, right, bottom, color, size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	text2 = string.gsub(text, "#%x%x%x%x%x%x", "")

	dxDrawText(text2, left+borderSize, top, right+borderSize, bottom, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left, top+borderSize, right, bottom+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left, top-borderSize, right, bottom-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left-borderSize, top, right-borderSize, bottom, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left+borderSize, top+borderSize, right+borderSize, bottom+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left-borderSize, top-borderSize, right-borderSize, bottom-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left+borderSize, top-borderSize, right+borderSize, bottom-borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text2, left-borderSize, top+borderSize, right-borderSize, bottom+borderSize, tocolor(5, 17, 26, 255), size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
	dxDrawText(text, left, top, right, bottom, color, size, font, horizAlign, vertiAlign, clip, wordBreak, postGui, colorCoded)
end