import {h} from '@playframe/playframe'
import {toFixed} from '../util'

export default ({,account, market, buy_form, sell_form, tokenA, tokenB, web3_wallet})=>
  # TODO form validation
  # TODO check token balance and allowance before committing
  # TODO reset form after submission?
  <div class="row">
    <div class="col-md-6 my-5">
      <h5 class="text-center">COMMIT TO BUY</h5>
      <form
        class="card border-0"
        onsubmit={(e)=>
          e.preventDefault()
          market._.limitBuy
            token: tokenA.address
            quoteToken: tokenB.address
            amount: buy_form.values.amount
            price: buy_form.values['price limit']
          }>
        <div class="card-body pb-0">
          {TokenInput buy_form, tokenB, 'price limit', 'total', 'buy'}
          {TokenInput buy_form, tokenA, 'amount', 'total', 'buy'}
          <hr/>
          {TokenInput buy_form, tokenB, 'total', 'amount', 'buy'}
          <hr/>
          <button
            disabled={not account.isSignedIn || not web3_wallet.get_address()}
            type="submit" class="btn btn-block btn-outline-success rounded-pill text-right"
          >
            { if account.isSignedIn
                <span>
                  <span class="d-none d-sm-inline d-md-none d-lg-inline">COMMIT TO </span>
                  BUY
                  <small class="tabular">
                    {' '}{toFixed(buy_form.values.amount, tokenA.decimals)}{' '}
                  </small><small class="tabular"> {tokenA.symbol}</small>
                  {<br/> if buy_form.values.total or buy_form.values.total is 0}
                  <span class="#{'d-none d-sm-inline d-md-none' if buy_form.values.total} d-lg-inline">{' FOR '}</span>
                  {'TOTAL ' if buy_form.values.total}
                  <small class="tabular">
                    {' '}{toFixed(buy_form.values.total, tokenB.decimals)}{' '}
                  </small><small class="tabular"> {tokenB.symbol}</small>
                </span>
            else
              'SIGN IN TO COMMIT'
            }
          </button>
        </div>

        { market.buy_commits.map (order)=>
          {amount, price, blockHash, revealing, revealed, clearing, cleared, evicted} = order
          <div class="btn-group btn-group-sm mt-1" style={opacity: (cleared or evicted) and .7 or 1}>
            <button disabled class="btn text-light">
              <span class="text-success tabular">{toFixed(price, tokenB.decimals)}</span>
              <span class="tabular"> × {toFixed(amount, tokenA.decimals)}</span>
            </button>
            { if blockHash and not (revealing or revealed or cleared or evicted)
                <button type="button" class="btn btn-outline-success rounded-pill"
                        style={flex: 3}
                        onclick={market._.reveal order}>
                  REVEAL
                </button>
            }
            { if not (cleared or evicted) and ((not blockHash) or revealing or clearing)
                <button disabled class="btn"
                        style={flex: 3}
                        onclick={market._.reveal order}>
                  <div class="progress border border-success rounded-pill">
                    <div class="progress-bar progress-bar-striped progress-bar-animated bg-success"
                         style="width: #{ clearing and 75 or revealing and 50 or 25 }%"></div>
                  </div>
                </button>
            }
            { if cleared
              <button disabled class="btn text-light">
                CLEARED
              </button>
            }
            { if evicted
              <button disabled class="btn text-danger">
                EVICTED
              </button>
            }
          </div>
        }
      </form>
    </div>
    <div class="col-md-6 my-5">
      <h5 class="text-center">COMMIT TO SELL</h5>
      <form class="card border-0" onsubmit={(e)=>
            e.preventDefault()
            market._.limitSell
              token: tokenA.address
              quoteToken: tokenB.address
              amount: sell_form.values.amount
              price: sell_form.values['price limit']
          }>
        <div class="card-body pb-0">
          {TokenInput sell_form, tokenB, 'price limit', 'total', 'sell'}
          {TokenInput sell_form, tokenA, 'amount', 'total', 'sell'}
          <hr/>
          {TokenInput sell_form, tokenB, 'total', 'amount', 'sell'}
          <hr/>
          <button
            disabled={not account.isSignedIn || not web3_wallet.get_address()}
            type="submit" class="btn btn-block btn-outline-warning rounded-pill text-right"
          >
            { if account.isSignedIn
              <span>
                <span class="d-none d-sm-inline d-md-none d-lg-inline">COMMIT TO </span>
                SELL
                <small class="tabular">
                  {' '}{toFixed(sell_form.values.amount, tokenA.decimals)}{' '}
                </small><small class="tabular"> {tokenA.symbol}</small>
                  {<br/> if sell_form.values.total or sell_form.values.total is 0}
                  <span class="#{'d-none d-sm-inline d-md-none' if sell_form.values.total} d-lg-inline">{' FOR '}</span>
                  {'TOTAL ' if sell_form.values.total}
                  <small class="tabular">
                    {toFixed(sell_form.values.total, tokenB.decimals)}{' '}
                  </small><small class="tabular"> {tokenB.symbol}</small>
              </span>
            else
              'SIGN IN TO COMMIT'
            }
          </button>
        </div>

        { market.sell_commits.map (order)=>
          {amount, price, blockHash, revealing, revealed, clearing, cleared, evicted} = order
          <div class="btn-group btn-group-sm mt-1" style={opacity: (cleared or evicted) and .7 or 1}>
            <button disabled class="btn text-light">
              <span class="text-warning tabular">{toFixed(price, tokenB.decimals)}</span>
              <span class="tabular"> × {toFixed(amount, tokenA.decimals)}</span>
            </button>
            { if blockHash and not (revealing or revealed or cleared or evicted)
              <button type="button" class="btn btn-outline-warning rounded-pill"
                      style={flex: 3}
                      onclick={market._.reveal order}>
                REVEAL
              </button>
            }
            { if not (cleared or evicted) and ((not blockHash) or revealing or clearing)
              <button disabled class="btn"
                      style={flex: 3}
                      onclick={market._.reveal order}>
                <div class="progress border border-warning rounded-pill">
                  <div class="progress-bar progress-bar-striped progress-bar-animated bg-warning"
                       style="width: #{ clearing and 75 or revealing and 50 or 25 }%"></div>
                </div>
              </button>
            }
            { if cleared
              <button disabled class="btn text-light">
                CLEARED
              </button>
            }
            { if evicted
              <button disabled class="btn text-danger">
                EVICTED
              </button>
            }
          </div>
        }
      </form>
    </div>
  </div>



_debounce_id = 0
debounce = (time)=>(fn)=>(args...)=>
  clearTimeout _debounce_id
  _debounce_id = setTimeout fn, time, args...
  return

stop_bounce = (fn)=>(args...)=>
  clearTimeout _debounce_id
  fn args...


TokenInput = (form, token, field, adjust, prefix)=>
  <div class="form-group row">
    <label
        class="col-sm-3 col-md-12 col-lg-3 col-form-label text-right text-nowrap text-uppercase"
        for="#{prefix}_#{field.replace /\s+/g, '_'}">
      <small>{field}</small>
    </label>

    <div class="col-sm-9 col-md-12 col-lg-9 input-group">
      <input
        class="form-control text-right"
        type="text"
        inputmode="decimal"
        id="#{prefix}_#{field.replace /\s+/g, '_'}"
        placeholder={toFixed 0, token.decimals}
        required
        pattern="[0-9]*.?[0-9]*"
        title="Please enter your desired number"
        autocomplete="off"
        onchange={stop_bounce form._.readNumberAndAdjust(field)(adjust)(token.decimals)}
        onkeyup={debounce(166) form._.readNumberAndAdjust(field)(adjust)(token.decimals)}
        oncreate={form._.updateInputValue(field)(token.decimals)}
        onupdate={form._.updateInputValue(field)(token.decimals)}
      />
      <div class="input-group-append">
        <div class="input-group-text bg-dark text-white-50 tabular">{token.symbol}</div>
      </div>
    </div>
  </div>
