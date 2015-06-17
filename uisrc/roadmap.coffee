
defaults = {
  width: 480,
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

# Using this algorithm to get the weekNumber
# and match it to what Outlook uses
Date.prototype.getWeekNumber = ->
    d = new Date(+this)
    d.setHours(0,0,0)
    d.setDate(d.getDate()+4-(d.getDay()||7))
    return Math.ceil((((d-new Date(d.getFullYear(),0,1))/8.64e7)+1)/7) + 1

class OrderedDict
  constructor: (@keyname) ->
    @order = []
    @data = {}

  append: (item) ->
    id = item[@keyname]
    @data[id] = item
    if id not in @order
      @order.push id

  insert: (index, item) ->
    id = item[@keyname]
    if id in @order
        index = @order.indexOf id
        @order.splice(index, 1)
    @data[id] = item
    @order.splice(index, 0, id)

  keys: () ->
    # Get a list of the keys in order
    (id for id in @order)

  list: () ->
    # Get a list of the items in order
    (@data[id] for id in @order)

  get: (id) ->
    @data[id]

  has: (id) ->
    id in @order

  pop: (id) ->
    item = @data[id]
    @remove(id)
    item

  top: () ->
    return @data[@order[@order.length-1]]

  remove: (id) ->
    index = @order.indexOf(id)
    if index == -1
      throw Error("item #{id} not found!")
    else
      @order.splice(index, 1)
      delete @data[id]

  empty: (id) ->
    @order = []
    @data = {}


class Group
  constructor: (@name) ->
    @projects = new OrderedDict("name")
    @y = 0
    @height = 0

  add_project: (project) ->
    @projects.append(project)

  max_layers: () ->
    overlaps = []
    for prj in @projects.list()
      overlaps.push prj.overlapcount 
    return Math.max.apply(null, overlaps)


class Project
  constructor: (@name, @group, @data) ->
    @start = @data.startdate
    @end = @data.enddate
    @overlapcount = 0

  overlaps: (other) ->
    if other.start <= @start and @start <= other.end \
    or other.start <= @end and @end <= other.end
      return true

class RoadmapModel
  constructor: () ->
    @groups = new OrderedDict("name")

  add_data: (data) ->
    for item in data
      if item.group not in @groups.keys()
        @groups.append(new Group(item.group))
      group = @groups.get(item.group)
      project = new Project(item.name, group, item)
      console.log "Adding project #{item.name}"
      group.add_project(project)
    @groups.order.sort()

  calculate: () ->
    # calculate the group overlaps
    for group in @groups.list()
      projects = group.projects.list()
      for i in [0..projects.length-1]
        project = projects[i]
        for j in [0..i]
          other = projects[j]
          if project != other
            if project.overlaps(other)
              project.overlapcount++

  debug: () ->
    for group in @groups.list()
      console.log "Group: #{group.name}, max_layers #{group.max_layers()}"
      for project in group.projects.list()
        console.log "  Prj: #{project.name}"

  get_group_dicts: (groups) ->
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

  add_blocks: (data, xscale, height, lineheight) ->
    blocks = []
    # count the positions of the blocks
    for item in data
      x1 = xscale(item.startdate)
      x2 = xscale(item.enddate)
      group = @get_group(item.group)
      bpos = 0
      block = {
        name: item.name,
        x: x1, 
        y: group.ypos,
        gpos: group.index
        height: lineheight, 
        width: x2-x1
        item: item
      }
      blocks.push block
    return blocks

  create_model: (data) ->
    @add_data(data)
    #@get_group_dicts(@groups)
    #return @count_blocks(data, xscale, @height-@options.margin.bottom, @options.lineheight)

class @RoadmapD3
  constructor: (@target, options = {}) ->
    @options = extend(defaults, options)
    @model = new RoadmapModel()
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

  create_axis: (rangex, height, width, formatWeek = null) ->
    x = d3.time.scale()
        .range([0, width])
    if not formatWeek?
      formatWeek = (d) ->
        if d.getDay() == 0
          return "Week #{d.getWeekNumber()}"
        else
          df =  d3.time.format("%a")
          return "#{df(d)}"
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
    @xAxis = @create_axis(@rangex, 5, @width)
    xscale = @xAxis.scale()
    # calculate data for the elements to show    
    @model.create_model(data)
    @model.calculate()
    @model.debug()
    
    @draw_mini(@model)
    @zoom = d3.behavior.zoom()
      .x(@xAxis.scale())
      .scaleExtent([0, 10])
      .on("zoom", () -> self.zoomed());
    
    @svg = d3.select(self.target)
      .append("svg")      
        .attr("width", @width)
        .call(@zoom)

    background = @svg.append("g")
      .attr("class", "background")
    @graph = @svg.append("g")
      .attr("class", "chart")
    captions = @svg.append("g")
      .attr("class", "captions")


    @draw_groups(@graph, @model, xscale)
    nodes = @graph.selectAll('.node')
    @add_node_events(nodes)
    backheight = background[0][0].getBBox().height
    chartheight = @graph[0][0].getBBox().height
    @height = backheight + @options.margin.bottom
    captions.append("g")
      .attr("class", "x axis")
      .attr("stroke-dasharray", "2,2")
      .attr("transform", "translate(" + 0 + "," + backheight + ")")
      .call(@xAxis)
    @svg.attr("height", @height)

    # Add line for now
    now = new Date
    nowx = xscale(now)
    @graph.append("line")
      .attr("stroke-dasharray", "2,2")
      .attr("x1", nowx)
      .attr("y1", 0)
      .attr("x2", nowx)
      .attr("y2", backheight)
      .attr("stroke", "red")


  draw_groups: (graph, model, xscale) ->
    groups = model.groups.list()
    for i in [0..groups.length-1]
      group = groups[i]
      group.index = i
      groupgraph = graph.append('g')
      for project in group.projects.list()
        block = @get_block(project, xscale)
        @draw_block(groupgraph, block, @options.lineheight)
      if i > 0
        prevgroup = groups[i-1]
        group.y = prevgroup.y + prevgroup.height
      else
        group.y = 0
      group.height = groupgraph[0][0].getBBox().height+10
      groupgraph.attr("transform", "translate(" + 0 + "," + group.y + ")" )

    background = @svg.select('.background')
    captions = @svg.select('.captions')
    background.selectAll("g.group")
      .data(groups)
        .enter().append("g")
          .attr("class", "group")
          .attr("transform", (d) -> "translate(" + 0 + "," + d.y + ")" )
          .append("rect")
            .attr("class", (d) -> if d.index % 2 == 0 then "group even" else "group odd")
            #.attr("fill-opacity", "0.4")
            .attr("width", @width)
            .attr("height", (d) -> d.height)
    captions.selectAll("g.group")
      .data(groups)
        .enter().append("g")
          .attr("class", "group")
          .attr("transform", (d) -> "translate(" + 0 + "," + d.y + ")" )
          .append("text")
            .attr("class", "group")
            .attr("dy", "1em" )
            .attr("dx", "1em" )
            .attr("font-size", "2em" )
            .text( (d) -> return d.name )
    return

  get_block: (prj, xscale) ->
    x1 = xscale(prj.start)
    x2 = xscale(prj.end)
    block = {
      name: prj.name,
      x: x1,
      y: 5,
      layer: prj.overlapcount
      width: x2-x1,
      prj: prj
    }

  draw_block: (graph, block, lineheight) ->
    self = @
    node = graph.append("g")
      .attr("class", "node")
    node.append("title")
      .text( block.name )
    node.append("rect")
      .attr("class", "block")
      .attr("width", block.width )
      .attr("height", lineheight )
      .attr("rx", "10" )
    node.append("text")
      .attr("class", "block")
      .attr("dx", "1em" )
      .attr("dy", "1em" )
      .text( block.name )
    # Check possible overlaps
    node[0][0].__data__ = block
    box = node[0][0].getBBox()
    for g in graph.selectAll('g')[0]
      if g.__data__ != block
        gbox = g.getBBox()
        x1 = block.x
        x2 = block.x + box.width
        if g.__data__.x <= x1 and x1 <= g.__data__.x+gbox.width \
        or g.__data__.x <= x2 and x2 <= g.__data__.x+gbox.width
          newy = g.__data__.y + gbox.height
          if newy >= block.y
            block.y = newy
    node.attr("transform", "translate(" + block.x + "," + block.y + ")" )
    return

  count_mini_blocks: (model, xscale, height) ->
    blocks = []
    # count the positions of the blocks
    for group in model.groups.list()
      for prj in group.projects.list()
        x1 = xscale(prj.start)
        x2 = xscale(prj.end)
        block = {
          name: prj.name,
          x: x1,
          y: 8,
          layer: prj.overlapcount
          width: x2-x1,
          prj: prj
        }
        blocks.push block
    return blocks

  draw_blocks: (graph, blocks, lineheight) ->
    self = @
    #@blocks = blocks
    # Add roadmap items (blocks)
    #blockheight = 0
    for d in blocks
      node = graph.append("g")
        .attr("class", "node")
      node.append("title")
        .text( d.name )
      node.append("rect")
        .attr("class", "block")
        .attr("width", d.width )
        .attr("height", lineheight )
        .attr("rx", "10" )
      node.append("text")
        #.attr("x", (d) -> return d.width/2 )
        .attr("class", "block")
        .attr("dx", "1em" )
        .attr("dy", "1em" )
        .text( d.name )
      # Check possible overlaps
      node[0][0].__data__ = d
      box = node[0][0].getBBox()
      for g in graph.selectAll('g')[0]
        if g.__data__ != d
          gbox = g.getBBox()
          x1 = d.x
          x2 = d.x + box.width
          if g.__data__.x <= x1 and x1 <= g.__data__.x+gbox.width \
          or g.__data__.x <= x2 and x2 <= g.__data__.x+gbox.width
            newy = g.__data__.y + gbox.height
            if newy >= d.y
              d.y = newy
      node.attr("transform", "translate(" + d.x + "," + d.y + ")" )
    return

  add_node_events: (nodes) ->
    self = this
    nodes.on("mouseover", (d, i) ->
      d3.select(this).select('rect').classed("highlight", true)
    )
    nodes.on("mouseout", (d, i) ->
      d3.select(this).select('rect').classed("highlight", false)
    )
    nodes.on("click", (d, i) ->
      node = nodes[0][i]
      d3.select('.selected').classed('selected', false)
      d3.select(node).select('rect').classed('selected', true)
      $(self).trigger "select", {data: d, node: node}

    )  
    return

  draw_mini: (model) ->
    self = @
    @minisvg = d3.select(@target)
      .append("svg")
        .attr("width", @width)
        .attr("height", @options.miniheight)
        .attr("class", "miniview")
    rangex = @get_time_range(@options.minirangeleft, @options.minirangeright)
    formatMiniWeek = (d) ->
      return "Week #{d.getWeekNumber()}"

    @miniXaxis = @create_axis(rangex, @options.miniheight-20, @width, formatMiniWeek)
    @minisvg.append("g")
      .attr("class", "x axis")
      .attr("stroke-dasharray", "2,2")
      .call(@miniXaxis);

    mrange = @get_main_range()
    x1 = @miniXaxis.scale()(mrange[0])
    x2 = @miniXaxis.scale()(mrange[1])
    viewdrag = d3.behavior.drag()
    view = @minisvg.append("g")
      .append("rect")
        .attr("class", "glasswindow")
        .attr("fill-opacity", "0.4")
        .attr("x", x1)
        .attr("width", x2-x1)
        .attr("height", @options.miniheight)
        .call(viewdrag)

    graph = @minisvg.append("g")
    xscale = @miniXaxis.scale()
    blocks = @count_mini_blocks(model, xscale, @options.miniheight-@options.margin.bottom)
    nodes = @draw_blocks(graph, blocks, 3)
    move_window = () ->
      xpos = d3.mouse(this)[0]
      xtime = self.miniXaxis.scale().invert(xpos)
      mainx = self.xAxis.scale()(xtime)
      zscale = self.zoom.scale()
      mainleft = self.zoom.translate()[0]
      newx = (mainleft - mainx) / zscale
      console.log "#{xpos}, #{zscale}, #{mainleft} #{mainx} #{newx}"
      self.move_to(newx, d3.select(".glasswindow"))

    # mouse event handlers
    viewdrag.on "drag", move_window
    @minisvg.on "click", move_window


