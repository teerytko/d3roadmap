
define ['d3', 'js/utils'], (d3, utils) ->
  defaults = {
    width: 480,
    height: 400
  }

  class RoadmapD3
    constructor: (@target, options = {}) ->
      @options = utils.extend(options, defaults)
      @graph = d3.select(@target)
        .append("svg")
    draw: () ->
      @graph
        .attr("width", @options.width)
        .attr("height", @options.height)

  return RoadmapD3