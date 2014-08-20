
define ['d3'],
(d3) ->
  create_graph = (graphelem) -> 
    type = (d) ->
      d.value = +d.value
      return d

    margin = {top: 20, right: 30, bottom: 30, left: 40}
    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1)

    y = d3.scale.linear()
        .range([height, 0])

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")

    chart = d3.select(graphelem)
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    d3.tsv "/testdata.tsv", type, (error, data) ->
      x.domain(data.map( (d) -> return d.name ))
      y.domain([0, d3.max(data, (d) -> return d.value )])

      chart.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis);

      chart.append("g")
          .attr("class", "y axis")
          .call(yAxis)

      chart.selectAll(".bar")
          .data(data)
        .enter().append("rect")
          .attr("class", "bar")
          .attr("x", (d) -> return x(d.name))
          .attr("y", (d) -> return y(d.value) )
          .attr("height", (d) -> return height - y(d.value) )
          .attr("width", x.rangeBand())
    
  return create_graph