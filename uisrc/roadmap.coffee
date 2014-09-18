
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
      self = @
      window.onresize = (e) -> self.updateWindow(e, self)

    createAxis: (width, height, rangex) ->
      @x = d3.time.scale()
          .range([0, width])
      formatWeek = (d) ->
        format = d3.time.format("%U.%w")
        return "Week #{format(d)}"
      @xAxis = d3.svg.axis()
          .scale(@x)
          .orient("bottom")
          .tickSize(height-@options.margin.top)
          .tickFormat(formatWeek)

      rangex[0] = rangex[0].setDate(rangex[0].getDate()-7)
      rangex[1] = rangex[1].setDate(rangex[1].getDate()+7)
      @x.domain(rangex)

    updateWindow: (e, self) ->
      x = $(".chart").parent().parent().width()
      self.options.width=x
      $(self.target).empty()
      self.draw(self.lastdata)

    zoomed: () ->
      @svg.select(".x.axis").call(@xAxis)
      # Set the y translation to 0 to prevent panning that dimension
      d3.event.translate[1] = 0
      console.log d3.event.translate
      @graph.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ", 1)")

    move_to: (x, node) ->
      @zoom.translate([x, 0])
      # attr("transform", "translate(#{xpos})")
      @zoom.event(node)
      
    resize: (width, height) ->
      @graph.attr("transform", "translate(#{width}, #{height})")

    getDataRange: (data) ->
      return [d3.min(data, (d) -> return new Date(d.startdate) ),
              d3.max(data, (d) -> return new Date(d.enddate) )]

    getCurrentTimeRange: (back = 7, forward = 7) ->
      # days back and forward
      backtime = new Date
      forwardtime = new Date
      backtime.setDate(backtime.getDate()-back)
      forwardtime.setDate(forwardtime.getDate()+forward)
      return [backtime, forwardtime]

    draw: (data) ->
      self = @
      @lastdata = data
      width = @options.width - @options.margin.left - @options.margin.right
      height = @options.height - @options.margin.top - @options.margin.bottom
      rangex = @getCurrentTimeRange()
      @createAxis(width, height, rangex)
      @zoom = d3.behavior.zoom()
        .x(@x)
        .scaleExtent([0, 10])
        .on("zoom", () -> self.zoomed());
      @svg = d3.select(self.target)
        .append("svg")      
          .attr("width", width)
          .attr("height", height)
          .style("background-color", "lightgray")
          .call(@zoom)
      @svg.append("g")
          .attr("transform", "translate(" + 0 + "," + 0 + ")")
      @svg.append("g")
        .attr("class", "x axis")
        .attr("stroke-dasharray", "2,2")
        .call(@xAxis);
      @graph = @svg.append("g")
      @graph
        .attr("class", "chart")
      @drawBlocks(data)

    drawBlocks: (data) ->
      self = @
      now = new Date
      height = @options.height - @options.margin.top - @options.margin.bottom

      blocks = []
      ylane = 0
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
        # Add line for now
      nowx = @x(now)
      @graph.append("line")
        .attr("x1", nowx)
        .attr("y1", 0)
        .attr("x2", nowx)
        .attr("y2", height-@options.margin.top)
        .attr("stroke", "red")

      # Add roadmap items
      @nodes = @graph.selectAll("rect")
        .data(blocks)
          .enter().append("g")
            .attr("class", "node")
            .attr("transform", (d) -> return "translate(" + d.x + "," + d.y + ")" )
      @nodes.append("title")
        .text( (d) -> return d.name )
      @nodes.append("rect")
        .attr("width", (d) -> return d.width )
        .attr("height", (d) -> return d.height )
      # nodes.append("circle")
      #   .attr("cy", "5" )
      #   .attr("r", "8" )
      #   .attr("fill", "#003366" )
      # nodes.append("circle")
      #   .attr("cy", "5" )
      #   .attr("cx", (d) -> d.width )
      #   .attr("r", "10" )
      #   .attr("stroke", "blue" )
      #   .attr("fill", "#003366" )
      #.attr("rx", "10")
      @nodes.append("text")
        #.attr("x", (d) -> return d.width/2 )
        .attr("dy", "2.2em" )
        .style("text-anchor", "start")
        .text( (d) -> return d.name )
        .attr("fill", "black")

      @nodes.on("mouseover", (d, i) ->
        d3.select(this).select('rect').classed("highlight", true)
      )
      @nodes.on("mouseout", (d, i) ->
        d3.select(this).select('rect').classed("highlight", false)
      )
      @nodes.on("click", (d, i) ->
        node = self.nodes[0][i]
        $(self).trigger "select", {data: d, node: node}
      )
      return

  return RoadmapD3