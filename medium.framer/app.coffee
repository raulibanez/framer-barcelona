# Framer Barcelona Meetup #2
# Code by: Raul Ibañez

# Original Design by: Medium
# Medium article by Yuriy Oparenko

#   https://uxdesign.cc/visual-sugar-f46b47ee04e5

# Init
# Deshabilitamos las ayudas visuales (cuadros azules)
Framer.Extras.Hints.disable()

# Defaults
# Animación por defecto 0.3 segundos
Framer.Defaults.Animation =
    time: 0.3

# Variables
confetti.opacity=0
counter.opacity=0
numClaps = 0

# Circle Glow
glow = () ->
	circle.shadowSpread = 0
	circle.shadowColor = "#0098C9"
	circle.animate
		shadowSpread: 8
		shadowColor: "rgba(218,78,45,0)"
		options:
			time: 0.6
			
timer = Utils.interval 3, ->
	glow()

# Circle Animation + Clap/ClapFull
animateCircle = Utils.throttle 0.6, ->
	circle.scale=1
	clapFull.scale=1
	clapFull.animate
		scale: 1.1
		options:
			time:0.3
	clapFull.onAnimationEnd ->
		clapFull.animate
			scale: 1
			options:
				time: 0.3
	circle.animate
		scale: 1.1
		options:
			time:0.3
	circle.onAnimationEnd ->
		circle.animate
			scale: 1
			options:
				time: 0.3

# Confetti Animation
animateConfetti = () ->
	confettiCopy=confetti.copy()
	confettiCopy.opacity=1
	confettiCopy.scale=1
	confettiCopy.rotation=Utils.randomNumber(0,360)
	confettiCopy.animate
		opacity: 0
		scale: 1.2
		options:
			time: 0.5
			curve: Bezier.ease

# Counter Animation
animateCounter = () ->
	counter.y=74
	counterValue.text="+#{numClaps}" if numClaps < 51
	counter.animate
		y: 64
		opacity: 1
		options:
			time: 0.3
	counter.onAnimationEnd ->
		Utils.delay 1, ->
			counter.animate
				y: 54
				opacity: 0
				options:
					time: 0.3
			counterTotal.opacity=1

# Reset Animation
animateReset = Utils.throttle 3, ->
	reset.x=81
	reset.animate
		x: 91
		opacity: 1
		options:
			time: 0.4
			curve: Spring
		reset.onAnimationEnd
	Utils.delay 3, ->
		reset.animate
			opacity:0
			x:81
			options:
				time:0.3

# Events
circle.onTapStart ->
	clearInterval resetTimer
	numClaps++ if numClaps<50
	counterTotal.opacity=0
	counterTotal.text="1,5#{numClaps+28}"
	# Circle Animation
	clapFull.opacity=1
	clap.opacity=0
	animateCircle()
	animateConfetti()
	animateCounter()

# We declare resetTimer here to use it globally (circle.onMouseOver)
resetTimer = 0
circle.onMouseOver ->
	glow() if numClaps==0
	circle.borderColor="#0098C9"
	if numClaps > 0
		resetTimer = Utils.delay 1, ->
			animateReset()

reset.onTap ->
	numClaps = 0
	counterTotal.text="1,528"
	clapFull.opacity=0
	clap.opacity=1
	reset.opacity=0

circle.onMouseOut ->
	circle.borderColor="#B0B0B0"
	clearInterval resetTimer
	
# Scroll
scroll = ScrollComponent.wrap(content)
scroll.scrollHorizontal = false
scroll.mouseWheelEnabled = true
scroll.content.on "change:y", ->
    scrollBar.y=Utils.modulate(-1*scroll.content.y,[0,2619],[4,634])

scrollBar.draggable=true
scrollBar.draggable.horizontal=false
scrollBar.draggable.constraints = {
    x: 1140
    y: 3
    width: 0
    height: 634+77
}
scrollBar.on "change:y", ->
	scroll.content.y=-1*Utils.modulate(scrollBar.y,[4,634],[0,2619])

