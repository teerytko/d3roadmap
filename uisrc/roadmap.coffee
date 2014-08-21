
define ['jquery','d3', 'js/utils'], ($, d3, utils) ->
  defaults = {
    width: 480,
    height: 400,
    margin: {top: 20, right: 30, bottom: 30, left: 40},
    lineheight: 10
  }

  class RoadmapD3
    constructor: (@target, options = {}) ->
      @options = utils.extend(defaults, options)
      @graph = d3.select(@target)
        .append("svg")
      self = @
      window.onresize = (e) -> self.updateWindow(e, self)

    addAxis: (width, height, rangex) ->
      @x = d3.time.scale()
          .range([0, width])
      formatWeek = (d) ->
        format = d3.time.format("%U.%w")
        return "Week #{format(d)}"
      xAxis = d3.svg.axis()
          .scale(@x)
          .orient("bottom")
          .tickSize(height-@options.margin.top)
          .tickFormat(formatWeek)

      rangex[0] = rangex[0].setDate(rangex[0].getDate()-7)
      rangex[1] = rangex[1].setDate(rangex[1].getDate()+7)
      @x.domain(rangex)
      @graph.append("g")
          .attr("class", "x axis")
          .call(xAxis);
      @graph.selectAll("g").filter( (d) -> return d )
        .classed("minor", true)

    updateWindow: (e, self) ->
      x = $(".chart").parent().width()
      self.options.width=x
      $(self.target).empty()
      self.graph = d3.select(self.target)
        .append("svg")      
      self.draw(self.lastdata)

    draw: (data) ->
      @lastdata = data
      rangex = [d3.min(data, (d) -> return new Date(d.startdate) ),
                d3.max(data, (d) -> return new Date(d.enddate) )]

      @graph
        .attr("class", "chart")
      width = @options.width - @options.margin.left - @options.margin.right
      height = @options.height - @options.margin.top - @options.margin.bottom
      @graph
        .attr("width", width)
        .attr("height", height)
      @addAxis(width, height, rangex)

      blocks = []
      ypos = 10
      for item in data
        x1 = @x(item.startdate)
        x2 = @x(item.enddate)
        block = {
          name: item.name,
          x: x1, 
          y: ypos, 
          height: @options.lineheight, 
          width: x2-x1
        }
        ypos += @options.lineheight+20
        blocks.push block

      # Add roadmap items
      nodes = @graph.selectAll("rect")
        .data(blocks)
          .enter().append("g")
            .attr("class", "node")
            .attr("transform", (d) -> return "translate(" + d.x + "," + d.y + ")" )
      nodes.append("title")
        .text( (d) -> return d.name )
      nodes.append("rect")
        .attr("width", (d) -> return d.width )
        .attr("height", (d) -> return d.height )
      nodes.append("circle")
        .attr("cy", "5" )
        .attr("r", "8" )
        .attr("fill", "#003366" )
      nodes.append("circle")
        .attr("cy", "5" )
        .attr("cx", (d) -> d.width )
        .attr("r", "10" )
        .attr("stroke", "blue" )
        .attr("fill", "#003366" )
        #.attr("rx", "10")
      nodes.append("text")
        #.attr("x", (d) -> return d.width/2 )
        .attr("dy", "2.2em" )
        .style("text-anchor", "start")
        .text( (d) -> return d.name )
        .attr("fill", "black")

      self = @
      nodes.on("click", (d) -> 
        $(self).trigger "select", d
      )

  return RoadmapD3