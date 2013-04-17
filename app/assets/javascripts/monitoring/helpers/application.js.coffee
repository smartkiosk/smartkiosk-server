Joosy.helpers 'Application', ->

  @hardwareError = (device, terminal) ->
    code = terminal["#{device}_error"]
    return "" unless code?

    errors  = I18n.t("smartkiosk.hardware.#{device}.errors")
    message = if errors[code] then errors[code] else "#{I18n.t("smartkiosk.unlocalized")}"

    if code < 1000
      "<span class='badge badge-important'>#{code}: #{message}</span>"
    else
      "<span class='badge'>#{code}: #{message}</span>"