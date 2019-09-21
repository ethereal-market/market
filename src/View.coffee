import {h} from '@playframe/playframe'
import NavBar from './components/NavBar'
import Intro from './components/Intro'
import Tokens from './components/Tokens'
import Forms from './components/Forms'
import Book from './components/Book'
import History from './components/History'
import {DOMAIN} from './config'

export default View = (state)=>
  {account, market, tokenA, tokenB, rainbow} = state

  account._.init()
  market._.init()
  tokenA._.init()
  tokenB._.init()
  rainbow._.init()


  market.on_balance_update = debounce(500) =>
    tokenA._.getBalance()
    tokenA._.getAllowance()
    tokenB._.getBalance()
    tokenB._.getAllowance()


  <div class="container d-flex w-100 h-100 p-3 mx-auto flex-column"
    onupdate={=>
      Object.assign document.documentElement.style, rainbow.style
      Object.assign document.body.style, rainbow.style
    }
  >
    {NavBar state}

    <main role="main" class="inner">
      {Intro state}
      {Tokens state}
      {Forms state}
      {Book state}
      {History state}
    </main>

    <footer class="mastfoot mt-auto">
      <div class="inner text-center">
        <small><span class="tabular">{DOMAIN}</span> is not a registered national securities exchange,
          but an <a target="_blank" href="https://github.com/ethereal-market/market">
            autonomous smart contract software program
        </a> running on <a target="_blank" href="https://www.ethereum.org/">
            Ethereum blockchain</a></small>
      </div>
    </footer>
  </div>



_debounce_id = 0
debounce = (time)=>(fn)=>(args...)=>
  clearTimeout _debounce_id
  _debounce_id = setTimeout fn, time, args...
  return
