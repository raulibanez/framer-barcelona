# Web Audio API Panner Example
# Inspiration and some code extracted from https://developer.mozilla.org/en-US/docs/Web/API/PannerNode
# Foodsteps sound by Alexander (http://www.orangefreesounds.com/scary-whispers/)
# Photo credit 4x6
#
# Code: Raul Ibáñez

# Element positioning
person.z=1

# speaker icon above all
speaker.x=Align.center
speaker.y=Align.center
speaker.z=2

# Shadow animation for the speaker // Infinite loop
animateShadow = () ->
	oval.shadowColor="#FFDF3D"
	oval.shadowSpread=0
	oval.animate
		shadowColor: "rgba(255,255,255,0)"
		shadowSpread: 20
		options:
			time: 1.2
			curve: Bezier.easeIn
oval.onAnimationEnd ->
	animateShadow()
animateShadow()

# Disable Hints
Framer.Extras.Hints.disable()

# Initial position values for the sound source
# The listener will be initially at (0, 0, 0) so we place the sound source a bit far on the Z axis (400)
xPos = 0
yPos = 0
zPos = 400

# Context creation
context = new (window.AudioContext || window.webkitAudioContext)();
#context = new webkitAudioContext()

# Buffer source
# It's OK to see the error "TypeError: null is not an object...", just refresh the page CMD+R or save CMD+S
source = context.createBufferSource()
request = new XMLHttpRequest()

# We usually need a CORS Proxy to play sounds from external websites
request.open("GET", "https://cors-anywhere.herokuapp.com/http://www.orangefreesounds.com/wp-content/uploads/2014/05/Footsteps-walking-on-dry-leaves.mp3?_=1", true)

# ResponseType must be of arraybuffer type
request.responseType = "arraybuffer"

# Panner configuration
# Values explanation here :) -> https://developer.mozilla.org/en-US/docs/Web/API/PannerNode
panner = context.createPanner()
panner.panningModel = 'HRTF'
panner.distanceModel = 'linear'
panner.refDistance = 1
panner.maxDistance = 500
panner.rolloffFactor = 1
panner.coneInnerAngle = 360
panner.coneOuterAngle = 0
panner.coneOuterGain = 0

# Listener setup
listener = context.listener

# Panner orientation (lookng towards the listener) and initial position
panner.setOrientation(0,0,-1)
panner.setPosition(xPos,yPos,zPos)

# Listener orientation (looking towards the forest) and initial position
# First three parameters describes the direction (vector) of the face of the listener
# last three parameters describes the direction (vector) of the top of the listener's head
# The two vectors must be separated by an angle of 90° 
listener.setOrientation(0,0,1,0,1,0)
# We set the listener at position (0,0,0)
listener.setPosition(0, 0, 0)

# We decode audio once it's been loaded
request.onload = ->
	context.decodeAudioData(request.response,((buffer) ->
		source.buffer = buffer
		
		# We connect the buffer sound to the panner and then to destination (output)
		source.connect(panner)
		panner.connect(context.destination)
		
		# Gapless loop. Sooooo nice :)
		source.loop = true
		
		# Play sound
		source.start(0)
		)
	,((e) -> print "Error with decoding audio data" + e.err))

# Speaker positioning function
# We throttle the number of call when the speaker are being dragged
positionPanner = Utils.throttle 0.1, ->
	panner.setPosition(xPos,yPos,zPos)
	#print 'dX: ' + (Screen.midX-xPos) + ' dY: ' + (Screen.midY-yPos) + ' dZ: ' + (0-zPos)
	#print 'dX: ' + xPos + ' dY: ' + yPos + ' dZ: ' + zPos

# We allow the user to move the speaker
speaker.draggable=true
speaker.draggable.momentum = false

# Move event
speaker.onPan ->
	disableAutoMode()
	xPos=Screen.midX-speaker.midX
	yPos=Screen.midY-speaker.midY
	positionPanner() 

# changeDepth function
changeDepth = (value) ->
	# zPos calculation
	zPos=Utils.modulate(value, [0.5, 5],[400, -100])
	
	# Speaker image positioning
	if zPos<0
		# Speaker behind the listener
		person.opacity=1
		person.z=1
		speaker.z=2
	else
		# Speaker beyond the listener
		person.opacity=0.5
		person.z=2
		speaker.z=1

	# Scale/Opacity calculation
	speaker.animate
		scale: Math.max Utils.modulate(value, [0.5, 5],[0.5, 2]), 0.5
		opacity: Math.max Utils.modulate(value, [0.5, 5],[0.5, 1]), 0.5
		options:
			time: 0.1
			
	# Set panner position
	positionPanner() 

# Force touch events
speaker.on Events.ForceTapStart, (event, layer) ->
	disableAutoMode()
	changeDepth(Math.max event.force*5, 0.1)
	
speaker.on Events.ForceTapChange, (event, layer) ->
	disableAutoMode()
	changeDepth(Math.max event.force*5, 0.1)
	
speaker.on Events.ForceTapEnd, (event, layer) ->
	changeDepth(Math.min event.force*5, 0.5)

speaker.onTapEnd ->
	changeDepth(Math.min event.force*5, 0.5)

# Automode is enabled/disabled by doubletapping the speaker
# Panner Automode
autoInterval=0
steps = 720
x0=0
z0=87.5
x=0
z=0
r=375/2
pos=0

# Calulate Speaker position
updateCoords = () ->
	x = Utils.round(x0 + r * Math.cos(2 * Math.PI * pos / steps))
	z = Utils.round(z0 + r * Math.sin(2 * Math.PI * pos / steps))
	#print x,z
	pos = if pos<steps then pos+1 else 0

enableAutoMode = () ->
	yPos=0
	autoInterval = Utils.interval 0.01, ->
		updateCoords()
		speaker.x=x
		speaker.y=Align.center
		xPos=Screen.midX-speaker.midX
		changeDepth(Utils.modulate(z, [275, -100],[0.5, 5]))

disableAutoMode = () ->
	clearInterval autoInterval
	autoInterval=0
	
# Double tap event
speaker.onDoubleTap ->
	if autoInterval==0		
		enableAutoMode()
	else
		disableAutoMode()

# Initial depth
changeDepth(0.5)

# We kick the loading of the buffer sound
request.send()

# Enable AutoMode by default
enableAutoMode()
