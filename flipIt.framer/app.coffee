# Defaults
Framer.Extras.Hints.disable()
Framer.Extras.Preloader.enable()
Framer.Defaults.Animation =
	time: 0.2

# Time
getTime = ->
	currentTime = new Date()
	hours = "#{if currentTime.getHours() < 10 then 0 else ''}#{currentTime.getHours()}"
	min = "#{if currentTime.getMinutes() < 10 then 0 else ''}#{currentTime.getMinutes()}"
	return "#{hours}:#{min}"
	
# Set the time every minute
setTime = ->
	timeFacebook.text = getTime()
	timeSafari.text = getTime()
	Utils.delay 60, ->
		setTime()

setTime()

# Flow Component
flow = new FlowComponent

# Initial slide
flow.showNext(facebook)

# App Store
linkAppStore.onTap ->
	flow.showNext(appStore)
	#appStore sticky OPEN button animation
	flow.scroll.onMove ->
		if abrirGrouper.opacity==0 and  flow.scroll.content.y < -110
			abrirGrouper.y=54
			abrirGrouper.animate
				opacity:1
				y:49
		if abrirGrouper.opacity==1 and  flow.scroll.content.y > -110
			abrirGrouper.animate
				opacity:0
				y:54

# sticky OPEN button
abrirStickyButton.onTap ->
	flow.showOverlayRight(appStart)

# main OPEN button
abrirButton.onTap ->
	flow.showOverlayRight(appStart)	

# main BACK button
hoy.onTap ->
	flow.showPrevious(facebook)	

# App Launch
flow.onTransitionEnd ->
	if flow.current.name=="appStart"
		# Coin Loading Animation
		coinMask.animate
			y:-186
			options:
				time: 3
				curve: Bezier.linear
		Utils.delay 3, ->
			flow.showOverlayCenter(app)

# Ad Manager
ads=[ad1, ad2, ad3]
for a in ads
	a.opacity=0
	
# Ad Manager
showAd = () ->
	randomAd=Utils.randomChoice(ads)
	randomAd.opacity=1
	ad.y=Screen.height
	ad.animate
		y: Screen.height-randomAd.height
		options:
			curve: Spring
	
hideAds = () ->
	for a in ads
		a.opacity=0 if a.opacity=1
	ad.animate
		y: Screen.height
		options:
			curve: Spring
	
# App
cointainer.x= Align.center
cointainer.y= Align.center
cointainer.z=500
hand.z=0

names=["Heads","Tails"]

audio = new Audio("sounds/coin.wav")

cointainer.onTap ->
	hideAds()
	winner.text=""
	cointainer.animate
		rotationX: cointainer.rotationX+90*8
		options:
			time: 1
			curve: Spring
		scale: 5
		opacity: 0
	audio.play()
	hand.animate
		scale: 1.4
		y: 316-20
		options:
			time: 0.1
	Utils.delay 0.2, ->
		hand.animate
			opacity:0
			y: 1500
			scale: 1
	Utils.delay 1, ->
		cointainer.animate
			rotationX: cointainer.rotationX+90*8
			scale: 1
			opacity:1
			options:
				time: 1
				curve: Bezier.easeIn
	Utils.delay 2, ->
		coin.animate
			scale: 1.1
			options:
				time: 0.1
	Utils.delay 2.1, ->
		coin.animate
			scale: 1
			options:
				time: 0.1
		winner.text=Utils.randomChoice(names)
		winner.animate
			opacity:1
			options:
				time: 0.3
		hand.opacity=1
		showAd()
	#print Utils.randomChoice(names)
