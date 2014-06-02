window.app =
  ready: ->
    $('body').on('change', '#role_tutee, #role_tutor', app.render_form)
    $('.best_in_place').best_in_place()
    $('#datepicker input').datepicker({})
    $('.attachinary-input').attachinary()
  render_form: ->
    $('#tutor_form').slideToggle()
    $('#tutee_form').slideToggle()

$(document).ready(app.ready)
