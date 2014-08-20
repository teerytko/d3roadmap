require ['jquery', 'bootstrap', 'bseditable', 'js/roadmap'],
($, bootstrap, bseditable,  Roadmap) ->

  $(document).ready ->
    console.log "Test"

  roadmap = new Roadmap('#example-roadmap', {
  })

  roadmap.draw()