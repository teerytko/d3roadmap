require ['jquery', 'bootstrap', 'bseditable', 'js/roadmap'],
($, bootstrap, bseditable,  Roadmap) ->

  $(document).ready ->
    console.log "Test"

  elem = $('#example-roadmap')

  roadmap = new Roadmap('#example-roadmap', {
    width: elem.width()
  })

  data = [{
    name: "Test FOOBAR PO"
    startdate: new Date(2014, 8, 1),
    enddate: new Date(2014, 8, 7),
    },
    {
    name: "Product B"
    startdate: new Date(2014, 10, 11),
    enddate: new Date(2014, 10, 18),
    }    
  ]
  roadmap.draw(data)

  $(roadmap).on "select", (e, data) ->
    console.log data

