require ['jquery', 'bootstrap', 'bseditable', 'js/roadmap'],
($, bootstrap, bseditable,  Roadmap) ->

  $(document).ready ->
    console.log "Test"

  elem = $('#example-roadmap')

  roadmap = new Roadmap('#example-roadmap', {
    width: elem.width()
  })

  roadmap.draw()

  window.resize ()