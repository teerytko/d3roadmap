
defaults = {
  width: 480,
  height: 400,
  miniheight: 100,
  minirangeleft: 56,
  minirangeright: 360,
  margin: {top: 20, right: 30, bottom: 30, left: 40},
  lineheight: 20,
  range_back: 14,
  range_forward: 28,
}
extend = (destination, source) ->
  for property in Object.keys(source)
    destination[property] = source[property]
  return destination

class @RoadmapD3
  constructor: (@target, options = {}) ->
    @options = extend(defaults, options)
    self = @
    window.onresize = (e) -> self.update_window(e, self)

  update_window: (e, self) ->
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
    mrange = @get_main_range()
    x1 = @miniXaxis.scale()(mrange[0])
    x2 = @miniXaxis.scale()(mrange[1])
    @minisvg.select(".glasswindow")
      .attr("x", x1)
      .attr("width", x2-x1)


  get_main_range: () ->
    scale = @xAxis.scale()
    mainrange = []
    mainrange.push scale.invert(scale.range()[0])
    mainrange.push scale.invert(scale.range()[1])
    console.log "timerange #{mainrange}"
    return mainrange

  move_to: (x, node) ->
    scale = @zoom.scale()
    @zoom.translate([x*scale, 0])
    # attr("transform", "translate(#{xpos})")
    @zoom.event(node)
    
  resize: (width, height) ->
    @graph.attr("transform", "translate(#{width}, #{height})")

  get_data_range: (data) ->
    return [d3.min(data, (d) -> return new Date(d.startdate) ),
            d3.max(data, (d) -> return new Date(d.enddate) )]

  get_time_range: (back = 7, forward = 7) ->
    # days back and forward
    backtime = new Date
    forwardtime = new Date
    backtime.setDate(backtime.getDate()-back)
    forwardtime.setDate(forwardtime.getDate()+forward)
    return [backtime, forwardtime]

  get_groups: (data) ->
    groups = []
    for item in data
      if item.group not in groups
        groups.push item.group
    groups.sort()
    @groupheight = @height / groups.length
    grouppos = 0
    groupdicts =[]
    for groupname in groups
      group = {
        name : groupname,
        index: grouppos,
        ypos: grouppos*@groupheight,
        height: @groupheight
      }
      groupdicts.push group
      grouppos++
    return groupdicts

  validate_data: (data) ->
    @lastdata = data
    for item in data
      # convert string mode dates to Date objects
      if typeof item.startdate == 'string'
        item.startdate = new Date(item.startdate)
      if typeof item.enddate == 'string'
        item.enddate = new Date(item.enddate)
      if not item.startdate?
        console.log "Item '#{item.name}' has no startdate!"
      if not item.enddate?
        console.log "Item '#{item.name}' has no enddate!"
        # create a default enddate
        item.enddate = new Date(item.startdate)
        item.enddate.setDate(item.enddate.getDate()+7)
      else if item.enddate < item.startdate
        console.log "Item '#{item.name}' enddate < startdate!"
        # create a default enddate
        item.enddate = new Date(item.startdate)
        item.enddate.setDate(item.enddate.getDate()+7)

  create_axis: (rangex, height, width, format = null) ->
    x = d3.time.scale()
        .range([0, width])
    formatWeek = (d) ->
      if not format?
        format = d3.time.format("%U.%w")
      return "Week #{format(d)}"
    axis = d3.svg.axis()
        .scale(x)
        .tickSize(height)
        .tickFormat(formatWeek)

    x.domain(rangex)
    return axis

  draw: (data) ->
    self = @
    @validate_data(data)
    @width = @options.width
    @height = @options.height
    # limit the max number of groups?
    @rangex = @get_time_range(@options.range_back, @options.range_forward)
    @xAxis = @create_axis(@rangex, @height-@options.margin.bottom, @width)
    @groups = @get_groups(data)
    @draw_mini(data)

    @zoom = d3.behavior.zoom()
      .x(@xAxis.scale())
      .scaleExtent([0, 10])
      .on("zoom", () -> self.zoomed());
    
    @svg = d3.select(self.target)
      .append("svg")      
        .attr("width", @width)
        .attr("height", @height)
        .call(@zoom)

    @draw_groups(@groups)

    @graph = @svg.append("g")
    @svg.append("g")
      .attr("class", "x axis")
      .attr("stroke-dasharray", "2,2")
      .call(@xAxis)
    @graph.append("g")
        .attr("transform", "translate(" + 0 + "," + 0 + ")")
    @graph
      .attr("class", "chart")

    @draw_blocks(data)

  draw_groups: (groups) ->
    groupnodes = @svg.selectAll("g").data(groups)
      .enter().append("g")
        .attr("transform", (d) -> "translate(" + 0 + "," + d.ypos + ")" )
    groupnodes.append("rect")
      .attr("class", (d) -> if d.index % 2 == 0 then "group even" else "group odd")
      .attr("width", @width)
      .attr("height", (d) -> d.height)
    groupnodes.append("text")
      .attr("class", "group")
      .attr("dy", "1em" )
      .attr("dx", "1em" )
      .attr("font-size", "2em" )
      .text( (d) -> return d.name )

  get_group: (name) ->
    for group in @groups
      if group.name == name
        return group
    return null

  draw_blocks: (data) ->
    self = @
    now = new Date
    xscale = @xAxis.scale()

    blocks = []
    ylane = 0
    for item in data
      # count the positions of the block
      x1 = xscale(item.startdate)
      x2 = xscale(item.enddate)
      ypos = @get_group(item.group).ypos
      # check possible overlapping blocks
      # and count the offset pos the current block should have
      bpos = 0
      for block in blocks
        if block.item.group == item.group
          # check if the current item is overlapping
          if block.item.startdate <= item.startdate and item.startdate <= block.item.enddate or
          block.item.startdate <= item.enddate and item.enddate <= block.item.enddate
            bpos++

      yoffset = (@options.lineheight+10)*bpos
      block = {
        name: item.name,
        x: x1, 
        y: ypos+yoffset,
        index: bpos,
        height: @options.lineheight, 
        width: x2-x1
        item: item
      }
      blocks.push block
      # Add line for now
    nowx = xscale(now)
    @graph.append("line")
      .attr("x1", nowx)
      .attr("y1", 0)
      .attr("x2", nowx)
      .attr("y2", @height-@options.margin.bottom)
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
      .attr("class", "block")
      .attr("width", (d) -> return d.width )
      .attr("height", (d) -> return d.height )
      .attr("rx", "10" )
    @nodes.append("text")
      #.attr("x", (d) -> return d.width/2 )
      .attr("class", "block")
      .attr("dx", "1em" )
      .attr("dy", "1em" )
      .style("text-anchor", "start")
      .text( (d) -> return d.name )

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

  draw_mini: (data) ->
    self = @
    @minisvg = d3.select(@target)
      .append("svg")
        .attr("width", @width)
        .attr("height", @options.miniheight)
        .attr("class", "miniview")
    rangex = @get_time_range(@options.minirangeleft, @options.minirangeright)

    @miniXaxis = @create_axis(rangex, @options.miniheight-20, @width, d3.time.format("%U"))
    @minisvg.append("g")
      .attr("class", "x axis")
      .attr("stroke-dasharray", "2,2")
      .call(@miniXaxis);

    mrange = @get_main_range()
    x1 = @miniXaxis.scale()(mrange[0])
    x2 = @miniXaxis.scale()(mrange[1])
    @minisvg.append("g")
      .append("rect")
        .attr("class", "glasswindow")
        .attr("fill-opacity", "0.4")
        .attr("x", x1)
        .attr("width", x2-x1)
        .attr("height", @options.miniheight)

    @minisvg.on("click", (d, i) ->
      xpos = d3.mouse(this)[0]
      xtime = self.miniXaxis.scale().invert(xpos)
      mainx = self.xAxis.scale()(xtime)
      zscale = self.zoom.scale()
      mainleft = self.zoom.translate()[0]
      newx = (mainleft - mainx) / zscale
      console.log "#{xpos}, #{zscale}, #{mainleft} #{mainx} #{newx}"
      self.move_to(newx, d3.select(".glasswindow"))
    )