$(document).ready ->
  # $('.debug').click (e) ->
  #   $el = $(e.target)
  #   $tr = $el.parents('tr')
  #   $tr.next().toggle()
  #   $tr.toggleClass('debugged')
  #   false
  $('.job-row').click (e) ->
    $el = $(e.target)
    return true if $el.hasClass('job-action')
    $tr = $el.parents('tr')
    $tr.next().toggle()
    $tr.toggleClass('debugged')
    false