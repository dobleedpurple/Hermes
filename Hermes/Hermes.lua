SLASH_HERMES1 = '/common'
SLASH_HERMES2 = '/hermes'
SLASH_HERMES3 = '/orcish'
SLASH_HERMES4 = '/crossfaction'
SLASH_HERMES5 = '/cf'
SlashCmdList["HERMES"] = function(msg)
	sayToOtherFaction(msg, "SAY")
end

SLASH_YHERMES1 = '/ycommon'
SLASH_YHERMES2 = '/yorcish'
SLASH_YHERMES3 = '/yhermes'
SLASH_YHERMES4 = '/ycrossfaction'
SLASH_YHERMES5 = '/ycf'
SlashCmdList["YHERMES"] = function(msg)
	sayToOtherFaction(msg, "YELL")
end

function sayToOtherFaction(msg, tone)
	local DICTIONARY = chooseDictionary()
	if not DICTIONARY then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Hermes] Unsupported race or faction.")
		return
	end

	local youSay, theySee = unpack(translate(msg, DICTIONARY))

	if strlen(youSay) > 210 then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Hermes] Message too long, must be under 210 characters.")
		return
	end

	--does this pepega know my language?
	local knowsLanguage = false
	for i = 1, GetNumLanguages() do
		local name = GetLanguageByIndex(i)
		if name == DICTIONARY["LanguageID"] then
			knowsLanguage = true
			break
		end
	end

	if not knowsLanguage then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Hermes] You don't know the language: " .. DICTIONARY["LanguageID"])
		return
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Hermes] They see: |cffff0000" .. theySee)
	SendChatMessage(youSay, tone, DICTIONARY["LanguageID"])
end


function translate(msg, dictionary)
	local YOU_SAY = ""
	local THEY_SEE = ""
	local RAW_STRING = string.upper(msg)

	while strlen(RAW_STRING) > 0 do
		local letter_found = false

		-- Try matching known letters/phrases
		for _, pair in ipairs(dictionary["ALPHABET"]) do
			local key = pair[1]
			local val = pair[2]
			if string.find(RAW_STRING, "^" .. key) then
				YOU_SAY = YOU_SAY .. val .. " "
				THEY_SEE = THEY_SEE .. key .. " "
				RAW_STRING = string.gsub(RAW_STRING, "^" .. key, "", 1)
				letter_found = true
				break
			end
		end

		if not letter_found then
			-- Try substituting unavailable letters
			for key, val in pairs(dictionary["SUBSTITUTES"]) do
				if string.find(RAW_STRING, "^" .. key) then
					RAW_STRING = string.gsub(RAW_STRING, "^" .. key, val, 1)
					letter_found = true
					break
				end
			end
		end

		if not letter_found then
			-- Replace whitespace with separator
			if string.find(RAW_STRING, "^%s") then
				YOU_SAY = YOU_SAY .. dictionary["SEPARATOR"]["INPUT"] .. " "
				THEY_SEE = THEY_SEE .. dictionary["SEPARATOR"]["OUTPUT"] .. " "
				RAW_STRING = string.gsub(RAW_STRING, "^%s+", "")
				letter_found = true
			end
		end

		if not letter_found then
			-- Ignore any remaining character
			RAW_STRING = string.gsub(RAW_STRING, "^.", "")
		end
	end

	return { YOU_SAY, THEY_SEE }
end

function chooseDictionary()
	local faction = UnitFactionGroup("player")
	if faction == "Alliance" then
		return HERMES_COMMON
	elseif faction == "Horde" then
		return HERMES_ORCISH
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Hermes] Unsupported faction.")
		return nil
	end
end
