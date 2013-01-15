@chosenify = (entry) ->
  entry.chosen
    allow_single_deselect: true
    no_results_text: "<%= I18n.t('active_admin.not_found') %>"

$ -> 
  chosenify $(".chosen")

  $("form.formtastic .inputs .has_many").click ->
    $(".chosen").chosen
      allow_single_deselect: true
      no_results_text: "<%= I18n.t('active_admin.not_found') %>"