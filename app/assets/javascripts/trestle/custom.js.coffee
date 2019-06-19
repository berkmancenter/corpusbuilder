#= require_tree ./

setup_summary_matrices = ->
  $('.summary_matrix').each (i, el) ->
    new window.SummaryMatrix(el)

setup_reload_if_processing_measurement = ->
  measurement_status = $('#edit_accuracy_measurement .measurement-status').data('status')

  switch measurement_status
    when null then return
    when undefined then return
    when 'ready' then return
    when 'error' then return
    else
      do_reload = ->
        Turbolinks.visit(location.toString())
      setTimeout(do_reload, 3000)

document.addEventListener 'turbolinks:load', ->
  console.log('Turbolinks load')
  setup_reload_if_processing_measurement()
  setup_summary_matrices()
