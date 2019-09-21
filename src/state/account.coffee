export default =>
  userSession: null
  isSignedIn: false
  name: ''
  username: ''

  inited: false

  _:
    init: ($, state)=>
      unless state.inited
        state.inited = true
        if window.blockstack
          state._.init_blockstack()
        else
          addEventListener 'load', state._.init_blockstack


    init_blockstack: ($, state)=>
      userSession = state._.setUserSession()
      if userSession.isUserSignedIn()
        state._.setUserData userSession.loadUserData()
      else if userSession.isSignInPending()
        userSession.handlePendingSignIn()
          .then (userData)=>
            if location.search
              window.location = location.origin
            else
              state._.setUserData userData
      return


    setUserSession: ($, state)=>
      appConfig = new blockstack.AppConfig
      state.userSession = new blockstack.UserSession appConfig: appConfig


    setUserData: (userData, state)=>
      state.userData = userData
      state.person = person = new blockstack.Person userData.profile
      state.isSignedIn = state.userSession.isUserSignedIn()
      state.name = person and person.name() or userData and
        userData.username.replace '.id.blockstack', ''
      state.username = userData and userData.username


    signin: ($, state)=>
      state.userSession.redirectToSignIn()

    signout: ($, state)=>
      state.userSession.signUserOut()
      window.location = window.location.origin
