import {toBigString} from '../util'

SWAP_TYPE =
  '0': 'BUY'
  '1': 'SELL'

export default (utils)=>(web3_wallet)=>(Market)=>(TokenA)=>(TokenB)=>
  {abi, keccak256, toBN} = utils
  decimalsA = TokenA and TokenA.methods.decimals().call().then (d)=> +d
  decimalsB = TokenB and TokenB.methods.decimals().call().then (d)=> +d


  address: Market and Market._address
  last_price: 0
  volume: 0

  on_balance_update: =>

  # TODO persistent storage
  commits__hash: {}
  buy_commits: []
  sell_commits: []
  clearance_subscription: null
  eviction_subscription: null

  bids__id: {}
  bids: []
  offers__id: {}
  offers: []

  history: []
  history__swap_hash: {}
  history__event_id: {}
  history_subscription: null

  blocks: {} # TODO get blocks time for history

  inited: false
  loading_book: true
  loading_history: true

  _:
    init: ($, state)=>
      if not state.inited and Market and Market.getBlockNumber
        state.inited = true
        block_number = await new Promise (resolve, reject)=>
          Market.getBlockNumber (error, result)=>
            if error
              reject error
            else
              resolve result

        state._.getSwapBook block_number
        state._.getHistory block_number
        # TODO do it only after commits are restored from local storage
        state._.getCommitClearance block_number


    destroy: ($, state)=>
      state.history_subscription?.unsubscribe()
      state.clearance_subscription?.unsubscribe()
      state.eviction_subscription?.unsubscribe()


    getCommitClearance: (block_number, state)=>
      clearance_subscription: Market.events.CommitCleared fromBlock: block_number - 11,
          (error, {returnValues: {hash}})=>
            if error
              console.error error
            else
              if commit = state.commits__hash[hash]
                commit.clearing = false
                commit.cleared = true
                state._ {}
            return

      eviction_subscription: Market.events.CommitEvicted fromBlock: block_number - 11,
          (error, {returnValues: {hash}})=>
            if error
              console.error error
            else
              if commit = state.commits__hash[hash]
                commit.clearing = false
                commit.evicted = true
                state._ {}
            return


    getHistory: (block_number, state)=>
      state._ loading_history: true
      dA = await decimalsA
      dB = await decimalsB

      events = await Market.getPastEvents 'SwapFilled',
        filter:
          Token: TokenA._address
          quoteToken: TokenB._address
        fromBlock: block_number - 6000 * 30 # 30 days
        toBlock: block_number



      history__swap_hash = {}
      history__event_id = {}
      history = []

      unwrap = ({removed, blockHash, transactionHash, logIndex, returnValues: {id, swapType, price, amount, maker, taker}})=>
        eventId = [blockHash, transactionHash, logIndex].join ''
        if removed
          if old_item = history__event_id[eventId]
            history__swap_hash[id] = history__event_id[eventId] = undefined
            history.splice history.indexOf(old_item), 1
        else if !history__event_id[eventId]
          if web3_wallet.get_address() in [maker, taker]
            state.on_balance_update?()
          history.unshift history__swap_hash[id] = history__event_id[eventId] = {
            swapType: SWAP_TYPE[swapType]
            price: parseFloat(price) / 10 ** dB
            amount: parseFloat(amount) / 10 ** dA
            id
            eventId
            blockHash
            maker
            taker
          }
        return

      events.forEach unwrap


      state._ {
        loading_history: false
        history
        history__swap_hash
        history__event_id
        history_subscription: Market.events.SwapFilled fromBlock: block_number + 1,
          (error, event)=>
            if error
              console.error error
            else
              unwrap event
              state._ {}
      }


    getSwapBook: (block_number, state)=>
      state._ loading_book: true
      dA = await decimalsA
      dB = await decimalsB

      bids__id = {}
      offers__id = {}
      bids = []
      offers = []

      fill__event_id = {}

      # TODO retrieve my commits that far from 200 in book, or save them in Gaia storage

      # TODO use cloudflare for calls and infura for subs
      await Promise.all [
        Market.methods
        .getSwapBook(
          TokenA._address
          TokenB._address
          0
          200
          '0x0'
        )
        .call undefined, block_number
        .then (swaps)=>
          state._
            bids__id: bids__id
            bids: bids = swaps.map (swap)=>
              {id, price, amount} = swap
              swap.price = parseFloat(price) / 10 ** dB
              swap.amount = parseFloat(amount) / 10 ** dA
              bids__id[id] = swap
      ,
        Market.methods
        .getSwapBook(
          TokenA._address
          TokenB._address
          1
          200
          '0x0'
        )
        .call undefined, block_number
        .then (swaps)=>
          state._
            offers__id: offers__id
            offers: offers = swaps.map (swap)=>
              {id, price, amount} = swap
              swap.price = parseFloat(price) / 10 ** dB
              swap.amount = parseFloat(amount) / 10 ** dA
              offers__id[id] = swap
      ]

      state._ {
        loading_book: false
        placed_subscription: Market.events.SwapPlaced
          filter: BaseToken: TokenA._address, QuoteToken: TokenB._address
          fromBlock: block_number + 1
        , (error, {removed, returnValues: {id, swapType, wallet, amount, price, placedAfter}})=>
            if error
              console.error error
            else
              # TODO removed
              swaps__id = if +swapType is 0 then bids__id else offers__id
              swaps = if +swapType is 0 then bids else offers

              return if swaps__id[id]

              if placedAfter is '0x0000000000000000000000000000000000000000000000000000000000000000'
                swap = {id, swapType, wallet}
                swap.price = parseFloat(price) / 10 ** dB
                swap.amount = parseFloat(amount) / 10 ** dA
                swaps__id[id] = swap
                swaps.unshift swap
                state._ {}
              else if placeAfter = swaps__id[placedAfter]
                swap = {id, swapType, wallet}
                swap.price = parseFloat(price) / 10 ** dB
                swap.amount = parseFloat(amount) / 10 ** dA
                swaps__id[id] = swap
                index = swaps.indexOf placeAfter
                swaps.splice index + 1, 0, swap
                state._ {}
            return

        filled_subscription: Market.events.SwapFilled
          filter: BaseToken: TokenA._address, QuoteToken: TokenB._address
          fromBlock: block_number + 1
        , (error, {removed, blockHash, transactionHash, logIndex, returnValues: {id, swapType, amount, fully}})=>
            eventId = [blockHash, transactionHash, logIndex].join ''
            if error
              console.error error
            else unless fill__event_id[eventId]
              fill__event_id[eventId] = true

              # TODO removed
              swaps__id = if +swapType is 1 then bids__id else offers__id
              swaps = if +swapType is 1 then bids else offers

              if swap = swaps__id[id]
                if fully # fully filled
                  index = swaps.indexOf swap
                  swaps.splice index, 1
                  swaps__id[id] = undefined
                else
                  swap.amount -= parseFloat(amount) / 10 ** dA
                state._ {}
            return

        canceled_subscription: Market.events.SwapCanceled
          filter: BaseToken: TokenA._address, QuoteToken: TokenB._address
          fromBlock: block_number + 1
        , (error, {removed, returnValues: {id, swapType,}})=>
            if error
              console.error error
            else
              # TODO removed
              swaps__id = if +swapType is 0 then bids__id else offers__id
              swaps = if +swapType is 0 then bids else offers

              if swap = swaps__id[id]
                index = swaps.indexOf swap
                swaps.splice index, 1
                swaps__id[id] = undefined
                state._ {}
            return
      }


    limitBuy: ({token, quoteToken, amount, price}, state)=>
      commit = {
        wallet: web3_wallet.get_address(),
        token, quoteToken,
        swapType: 0, # BUY
        amountString: toBigString(amount * 10 ** await decimalsA),
        priceString: toBigString(price * 10 ** await decimalsB),
        nonce: Date.now()
      }

      hash = keccak256 abi.encodeParameters [
        'address', 'address', 'address',
        'uint256', 'uint256', 'uint256', 'uint256'
      ], Object.values commit

      commit.hash = hash
      commit.amount = amount
      commit.price = price

      state.buy_commits.push state.commits__hash[hash] = commit
      state._ {} # trigger update
      state._.commitSwap commit
        .then ({blockHash})=>
          commit.blockHash = blockHash
          state._ {}
        .catch (e)=>
          state.buy_commits.splice state.buy_commits.indexOf(commit), 1
          state._ {}
          Promise.reject e



    limitSell: ({token, quoteToken, amount, price}, state)=>
      commit = {
        wallet: web3_wallet.get_address(),
        token, quoteToken,
        swapType: 1, # SELL
        amountString: toBigString(amount * 10 ** await decimalsA),
        priceString: toBigString(price * 10 ** await decimalsB),
        nonce: Date.now()
      }

      hash = keccak256 abi.encodeParameters [
        'address', 'address', 'address',
        'uint256', 'uint256', 'uint256', 'uint256'
      ], Object.values commit

      commit.hash = hash
      commit.amount = amount
      commit.price = price

      state.sell_commits.push state.commits__hash[hash] = commit
      state._ {} # trigger update
      state._.commitSwap commit
        .then ({blockHash})=>
          commit.blockHash = blockHash
          state._ {}
        .catch (e)=>
          state.sell_commits.splice state.sell_commits.indexOf(commit), 1
          state._ {}
          Promise.reject e


    commitSwap: (commit)=>
      return unless Market.Wallet
      Market.Wallet.methods
        .commitSwap commit.token, commit.quoteToken, commit.hash
        .send from: web3_wallet.get_address()
        .then (commit)=>
          console.log {commit}
          commit


    reveal: (commit)=>($, state)=>
      return unless Market.Wallet
      [wallet, token, quoteToken, swapType,
        amount, price, nonce] = Object.values commit

      commit.revealing = true

      Market.Wallet.methods
        .reveal(commit.blockHash, token, quoteToken, swapType.toString(),
          amount, price, nonce)
        .send from: web3_wallet.get_address(), gas: 400000
        .then (reveal)=>
          console.log {reveal}
          commit.revealing = false
          commit.revealed = true
          commit.clearing = true
          state._ {}
          reveal
        .catch =>
          commit.revealing = false
          state._ {}

      state._ {}
      return


    execute: ($, state)=>
      return unless Market.Wallet
      Market.Wallet.methods
        .executeSwaps TokenA._address, TokenB._address
        .send from: web3_wallet.get_address(), gas: 400000
        .then (executed)=>
          console.log {executed}
          executed
        .catch (e)=>
          console.error e
          Promise.reject e


    cancel_bid: (bid, state)=>
      return unless Market.Wallet
      bid.canceling = true
      state._ {}
      Market.Wallet.methods
        .cancelBuySwap TokenA._address, TokenB._address, bid.id, '0x0'
        .send from: web3_wallet.get_address()
        .then (canceled)=>
          console.log {canceled}
          canceled
        .catch (e)=>
          console.error e
          bid.canceling = false
          state._ {}
          Promise.reject e


    cancel_offer: (offer, state)=>
      return unless Market.Wallet
      offer.canceling = true
      state._ {}
      Market.Wallet.methods
        .cancelSellSwap TokenA._address, TokenB._address, offer.id, '0x0'
        .send from: web3_wallet.get_address()
        .then (canceled)=>
          console.log {canceled}
          canceled
        .catch (e)=>
          console.error e
          offer.canceling = false
          state._ {}
          Promise.reject e
