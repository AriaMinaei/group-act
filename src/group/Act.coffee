module.exports = class Act

	constructor: (@delay, @duration, @curve, @fn) ->

		@_lastProgress = 0

	gotoTime: (t) ->

		localTime = t - @delay

		progress = localTime / @duration

		if progress > 1 then progress = 1

		if progress is 1

			return if @_lastProgress is 1

		@_lastProgress = progress

		curvedProgress = @curve progress

		@fn curvedProgress

		return