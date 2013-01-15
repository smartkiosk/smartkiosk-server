$ ->
  $('[title]').qtip
    style: {
      classes: "qtip-dark"
    }
    position: {
      my: 'top left',
      target: 'mouse',
      viewport: $(window),
      adjust: {
        x: 10,  y: 10
      }
    }
    hide: {
      delay: 0,
      effect: false,
      fixed: true
    }
    show: {
      delay: 100,
      effect: false
    }