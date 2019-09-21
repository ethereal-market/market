import {app, mount} from '@playframe/playframe'
import View from './View'
import web3_wallet from './data/web3'
import {Market} from './data/Market'
import {TokenA, TokenB} from './data/TokenPair'

import rainbow from './state/rainbow'
import account from './state/account'
import token from './state/token'
import market from './state/market'
import form from './state/form'


web3utils = {Web3Utils..., abi: Web3Abi}


state = app(
  show_intro: not localStorage['hide_intro']
  rainbow: rainbow(),
  web3_wallet: web3_wallet
  account: account()
  market: market(web3utils)(web3_wallet)(Market)(TokenA)(TokenB)
  tokenA: token(web3_wallet)(TokenA)(Market and Market._address)
  tokenB: token(web3_wallet)(TokenB)(Market and Market._address)
  buy_form: form()
  sell_form: form()
)(
  View
)(
  mount document.body
)

