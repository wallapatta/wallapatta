COLORS =
 reset: ''
 bold: ';1'
 red: ';31'
 green: ';32'

log = exports.log = (message, color = 'reset', explanation = '') ->
 if Array.isArray color
  c = ''
  for i in color
   c += COLORS[i] ? ''
  color = c
 else
  color = COLORS[color] ? COLORS.reset
 color = "\x1B[0#{color}m"
 reset = "\x1B[0#{COLORS.reset}m"
 color = '' if process.env.NODE_DISABLE_COLORS
 reset = '' if process.env.NODE_DISABLE_COLORS

 console.log color + message + reset + ' ' + (explanation or '')

exports.finish = ->
 n = 0
 errors = []
 for e in arguments
  if e?
   if (typeof e) isnt 'number'
    errors.push e
    n++
   else
    n += e

 if n is 0
  log '(0) error(s)', ['green', 'bold']
 else
  for e in errors
   log "#{e}", 'red'
  log "(#{n}) error(s)", ['red', 'bold']

