import {h} from '@playframe/playframe'
import {DOMAIN} from '../config'

export default ({show_intro, show_menu, market, account, web3_wallet, _})=>
  <header class="masthead mb-auto">
    <div class="inner">
      <a class="navbar-brand tabular"
           style={fontWeight: 100, cursor: 'pointer'}
           onclick={(e)=>
             e.preventDefault()
             _ show_intro: !show_intro
             if show_intro
               localStorage['hide_intro'] = true
             else
               delete localStorage['hide_intro']
           }
      >
        <img class="d-inline-block mr-3" src="ethereal-192.png"
             style={height: '3rem', width: '3rem'} />
        <div class="d-inline-block position-absolute">
          <span class="ethereal">{DOMAIN}</span>
          <br/>
          <sup class="d-none d-lg-inline"><small>{market.address}</small></sup>
        </div>
      </a>
      <nav class="nav nav-masthead justify-content-center">
        { if account.isSignedIn
            <div class="nav-item dropdown #{'show' if show_menu}">
              <a class="nav-link dropdown-toggle text-right" href="##"
                 onclick={(e)=> e.preventDefault(); _ show_menu: !show_menu}>
                <span class="ethereal">{ account.name }</span>
                <br/>
                <small class="tabular d-inline-block text-truncate" style={maxWidth: '80vw'}>
                 {if web3_wallet.get_address()
                   web3_wallet.get_address()}
                 {unless web3_wallet.get_address()
                    "Please connect your #{
                      window.ethereum and ethereum.isMetaMask and 'Metamask ' or ''
                    }Wallet"}
                </small>
              </a>
              <div class="#{'show' if show_menu} dropdown-menu dropdown-menu-right w-100 text-right">
                { if window.ethereum and not web3_wallet.get_address() and ethereum.enable
                    [
                      <a class="dropdown-item tabular"
                         href="#"
                         onclick={(e)=> e.preventDefault(); ethereum.enable().then => location.reload()}
                      >
                        Connect your Wallet
                      </a>
                      <div class="dropdown-divider"></div>
                    ]
                }
                <a class="dropdown-item tabular" target="_blank"
                   href="https://browser.blockstack.org/profiles"
                >
                  {account.username.replace /\..*\..*$/i, ''
                  }<small>.id.blockstack</small>
                </a>
                <div class="dropdown-divider"></div>
                <a class="dropdown-item" href="#" onclick={(e)=>
                    e.preventDefault()
                    account._.signout()
                }>
                  Sign out
                </a>
              </div>
            </div>
          else if account.userSession
            <a class="nav-link" href="#" onclick={(e)=>
              e.preventDefault()
              account._.signin()
            }>Sign in with Blockstack</a>
        }
      </nav>
    </div>
  </header>

