
define ['jquery','d3', 'js/utils'], ($, d3, utils) ->
  defaults = {
    width: 480,
    height: 400
    margin: {top: 20, right: 30, bottom: 30, left: 40}

  }

  class RoadmapD3
    constructor: (@target, options = {}) ->
      @options = utils.extend(defaults, options)
      @graph = d3.select(@target)
        .append("svg")
      self = @
      window.onresize = (e) -> self.updateWindow(e, self)

    addAxis: (width, height) ->
      @x = d3.time.scale()
          .range([0, width])
      formatWeek = (d) ->
        format = d3.time.format("%U")
        return "Week #{format(d)}"
      xAxis = d3.svg.axis()
          .scale(@x)
          .orient("bottom")
          .tickSize(height-@options.margin.top)
          .tickFormat(formatWeek)

      d1 = new Date()
      d2 = new Date()
      d2 = d2.setDate(d2.getDate()-60)
      @x.domain([d2, d1])
      @graph.append("g")
          .attr("class", "x axis")
          .call(xAxis);
      @graph.selectAll("g").filter( (d) -> return d )
        .classed("minor", true)

    updateWindow: (e, self) ->
      x = $(".chart").parent().width() || g.clientWidth$(".chart").parent().width();
      self.options.width=x
      $(self.target).empty()
      self.graph = d3.select(self.target)
        .append("svg")      
      self.draw()

    draw: () ->
      nodes = [{x: 30, y: 50},
               {x: 50, y: 80},
               {x: 90, y: 120}]
      @graph
        .attr("class", "chart")
      width = @options.width - @options.margin.left - @options.margin.right
      height = @options.height - @options.margin.top - @options.margin.bottom
      @graph
        .attr("width", width)
        .attr("height", height)
      @addAxis(width, height)
      @graph.selectAll("circle.nodes")
           .data(nodes)
           .enter()
           .append("svg:circle")
           .attr("cx", (d) -> return d.x )
           .attr("cy", (d) -> return d.y )
           .attr("r", "10px")
           .attr("fill", "black")
           .on("mouseover", () -> d3.select(this).style("fill", "green"))
           .on("mouseout", () -> d3.select(this).style("fill", "black"))

  return RoadmapD3