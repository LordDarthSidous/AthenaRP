# Progress bar

function QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
	exports['sith-hud']:Progress({
		name = name:lower(),
		duration = duration,
		label = label,
		useWhileDead = useWhileDead,
		canCancel = canCancel,
		controlDisables = disableControls,
		animation = animation,
		prop = prop,
		propTwo = propTwo,
	}, function(cancelled)
		if not cancelled then
			if onFinish then
				onFinish()
			end
		else
			if onCancel then
				onCancel()
			end
		end
	end)
end

# Notification

function QBCore.Functions.Notify(text, texttype, length)
	texttype = texttype == "success" and "success" or texttype == "error" and "error" or "inform"
	length = length or 5000
	if type(text) == 'table' then
		local ttext = text.text or 'Placeholder'
		local caption = text.caption or 'Placeholder'
		exports['sith-hud']:addNotification(type, ttext, caption, length)
	else
        exports['sith-hud']:addNotification(type, texttype == 'error' and 'Error' or texttype == 'success' and 'Success' or 'Notify', text, length)
	end
end

# Stress Events (client side)

TriggerEvent("sith-hud:client:gainStress", math.random(1, 3))
TriggerEvent("sith-hud:client:relieveStress", math.random(1, 3))