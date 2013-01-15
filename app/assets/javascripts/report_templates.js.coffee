@reportChangeGroupping = (val) ->
  $(".groupping").hide()
  $(".groupping input").attr "checked", false
  $(".groupping-" + val.replace(".", "-")).show()

  $(".sorting").hide()
  $(".sorting select").attr "disabled", "disabled"
  $(".sorting-" + val.replace(".", "-")).show()
  $(".sorting-" + val.replace(".", "-") + " select").removeAttr "disabled"
  $(".sorting-" + val.replace(".", "-") + " select").chosen allow_single_deselect: true