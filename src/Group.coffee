timingFunction = require 'timing-function'
Act = require './group/Act'

module.exports = class GroupAct

	constructor: (options) ->

		@_shouldCalculateDuration = no

		if options.duration?

			@_duration = options.duration|0

		else

			@_shouldCalculateDuration = yes

			@_duration = 0

		if options.timelineCurve?

			@_timelineCurve = timingFunction.get options.timelineCurve

		else

			@_timelineCurve = timingFunction.get 'linear'

		if options.defaultCurve?

			@_defaultCurve = timingFunction.get options.defaultCurve

		else

			@_defaultCurve = timingFunction.get 'linear'

		@_defaultDuration = options.defaultDuration ? 1000

		@_acts = []

		@_isPlaying = no

		@_t = 0

	add: (opts) ->

		duration = opts.duration ? @_defaultDuration
		delay = opts.delay ? 0

		if opts.curve?

			curve = timingFunction.get opts.curve

		else

			curve = @_defaultCurve

		unless opts.fn? then throw Error "No fn?"

		act = new Act delay, duration, curve, opts.fn

		@_acts.push act

		if @_shouldCalculateDuration

			@_duration = Math.max @_duration, delay + duration

		this

	play: ->

		return if @_isPlaying

		if @_t >= @_duration

			@progress 0

		@_lastWindowTime = Date.now()

		@_isPlaying = yes

		self._timing.beforeEachFrame @_rafTick

		this

	pause: ->

		return unless @_isPlaying

		@_isPlaying = no

		self._timing.cancelBeforeEachFrame @_rafTick

		this

	_rafTick: =>

		return unless @_isPlaying

		currentWindowTime = Date.now()

		t = @_t + currentWindowTime - @_lastWindowTime

		@_lastWindowTime = currentWindowTime

		if t > @_duration

			@pause()

			t = @_duration

		@gotoTime t

		return

	gotoTime: (t) ->

		@_t = t

		p = @_timelineCurve(t / @_duration)

		curvedTime = t * p

		for act in @_acts

			act.gotoTime curvedTime

		this

	progress: (p) ->

		@gotoTime @_duration * p

	self = this

	@setDefaultTiming: (timing) ->

		self._timing = timing