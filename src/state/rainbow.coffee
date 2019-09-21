export default =>
  colors: colors = [
    [35, 51, 51]
    [35, 51, 47]
    [36, 51, 35]
    [35, 51, 49]
    [40, 51, 35]
    [40, 51, 38]
  ]
  those: [0, 1, 0, 3]
  stage: 0
  speed: 0.01

  inited: false
  active: true

  _:
    init: ($, state)=>
      unless state.inited
        state.inited = true
        state._.calc()

    destroy: ($, state)=>
      state.active = false

    calc: ($, state)=>
      return unless state.active

      if window.requestIdleCallback
        setTimeout (=>
          requestIdleCallback state._.calc), 100
      else
        setTimeout state._.calc, 1000

      {random, round} = Math
      {colors, those, stage, speed} = state

      state.style = backgroundImage: "linear-gradient(to left,
      rgb(#{
        round colors[those[0]][0] * (1 - stage) + colors[those[1]][0] * stage
      }, #{
        round colors[those[0]][1] * (1 - stage) + colors[those[1]][1] * stage
      }, #{
        round colors[those[0]][2] * (1 - stage) + colors[those[1]][2] * stage
      }) , rgb(#{
        round colors[those[2]][0] * (1 - stage) + colors[those[3]][0] * stage
      }, #{
        round colors[those[2]][1] * (1 - stage) + colors[those[3]][1] * stage
      }, #{
        round colors[those[2]][2] * (1 - stage) + colors[those[3]][2] * stage
      }))"

      if (state.stage += speed) >= 1
        state.stage -= 1
        those[0] = those[1]
        those[2] = those[3]
        those[1] = (random() * colors.length) | 0
        those[3] = (random() * colors.length) | 0

      return

