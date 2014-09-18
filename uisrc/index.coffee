require ['jquery', 'bootstrap', 'bseditable', 'js/roadmap'],
($, bootstrap, bseditable,  Roadmap) ->

  $(document).ready ->
    console.log "Test"

  elem = $('#example-roadmap')

  roadmap = new Roadmap('#example-roadmap', {
    width: elem.width()
  })

  data = [{
    name: "Test FOOBAR PO",
    group: "AAA",
    startdate: new Date(2014, 7, 1),
    enddate: new Date(2014, 7, 7),
    },
    {
    name: "Product B",
    group: "AAA",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 9, 18),
    },    
    {
    name: "Product C",
    group: "AAA",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 9, 18),
    },
    {
    name: "Product D",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 9, 18),
    },
    {
    name: "Product E",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 9, 18),
    },
    {
    name: "Product F",
    startdate: new Date(2014, 8, 11),
    enddate: new Date(2014, 8, 18),
    },
    {
    name: "Product G",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 9, 18),
    },
    {
    name: "Product H",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 10, 18),
    },
    {
    name: "Product I",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 10, 18),
    },
    {
    name: "Product J",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 10, 18),
    },
    {
    name: "Product K",
    startdate: new Date(2014, 7, 11),
    enddate: new Date(2014, 7, 18),
    },
    {
    name: "Product L",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 10, 18),
    },
    {
    name: "Product M",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 10, 18),
    },
    {
    name: "Product N",
    startdate: new Date(2014, 9, 11),
    enddate: new Date(2014, 10, 18),
    },
  ]
  roadmap.draw(data)

  $(roadmap).on "select", (e, data) ->
    d =  data.data
    nodesel = d3.select(data.node)
    console.log d
    roadmap.move_to(-d.x, nodesel)

