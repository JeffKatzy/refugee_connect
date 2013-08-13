window.app =
  ready: ->
    $('body').on('change', '#role_tutee, #role_tutor', app.render_form)
  render_form: ->
    $('#tutor_form').slideToggle()
    $('#tutee_form').slideToggle()

$(document).ready(app.ready)
