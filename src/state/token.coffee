import {WBTC_TOKEN, WETH_TOKEN} from "../config"
import {toBigString} from '../util'

export default (web3_wallet)=>(ERC20)=>(market)=>
  decimals = ERC20 and ERC20.methods.decimals().call().then (d)=> +d

  address: ERC20 and ERC20._address
  name: ''
  symbol: ''
  decimals: 0
  balance: 0
  allowance: 0

  inited: false
  loading: true
  minting: false
  approving: false
  canceling: false
  wrapping: false
  unwrapping: false

  _:
    init: ($, state)=>
      if not state.inited
        state.inited = true
        ERC20.methods.name().call().then (name)=> state._ {name}
        ERC20.methods.symbol().call().then (symbol)=> state._ {symbol}
        decimals.then (decimals)=> state._ {decimals}

        if web3_wallet.get_address()
          state._.getBalance()
          state._.getAllowance()
          addEventListener 'focus', state._.getBalance
        else
          decimals.then => state._ loading: false


    getBalance: ($, {_})=>
      _ loading: true
      d = await decimals
      ERC20.methods
        .balanceOf web3_wallet.get_address()
        .call()
        .then (balance)=>
          _ loading: false, balance: parseFloat(balance) / (10 ** d)


    mint: (amount)=>($, {_})=>
      return unless ERC20.Wallet
      _ minting: true
      d = await decimals
      await ERC20.Wallet.methods
        .mint web3_wallet.get_address(), toBigString amount * 10 ** d
        .send from: web3_wallet.get_address()
        .finally => _ minting: false
      _.getBalance()


    getAllowance: ($, state)=>
      state.allowance ?= 0
      d = await decimals
      ERC20.methods
        .allowance(web3_wallet.get_address(), market)
        .call()
        .then (allowance)=>
            state._ allowance: parseFloat(allowance) / (10 ** d)


    approve: (amount)=>($, {_})=>
      return unless ERC20.Wallet
      _ approving: true
      d = await decimals
      await ERC20.Wallet.methods
        .approve market, toBigString amount * 10 ** d
        .send from: web3_wallet.get_address()
        .finally => _ approving: false
      _.getAllowance()


    wrap: ($, {address, _})=>
      return unless ERC20.Wallet and address is WETH_TOKEN
      _ wrapping: true
      balance = parseFloat await web3_wallet.get_balance web3_wallet.get_address()

      await ERC20.Wallet.methods
        .deposit()
        .send
            from: web3_wallet.get_address()
            value: toBigString 0.8 * balance
        .finally => _ wrapping: false
      _.getBalance()


    unwrap: ($, {address, balance, _})=>
      return unless ERC20.Wallet and address is WETH_TOKEN
      _ unwrapping: true

      d = await decimals

      await ERC20.Wallet.methods
        .withdraw toBigString balance * 10 ** d
        .send from: web3_wallet.get_address()
        .finally => _ unwrapping: false
      _.getBalance()

