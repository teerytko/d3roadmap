extend = (destination, source) ->
  for property in Object.keys(source)
    destination[property] = source[property]
  return destination

exports = module.exports = {extend: extend}