require ['jquery', 'bootstrap', 'bseditable', 'd3'],
($, bootstrap, bseditable, d3) ->

  $(document).ready ->
    console.log "Test"
    d3.select("body").transition()
        .style("background-color", "gray");