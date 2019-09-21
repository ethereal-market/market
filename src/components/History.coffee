import {h} from '@playframe/playframe'
import {toFixed} from '../util'

export default ({web3_wallet, market, tokenA, tokenB, my_history_only, _})=>
  my_history =
    market.history.filter(({maker, taker})=>
      maker.toLowerCase() is web3_wallet.get_address() or
      taker.toLowerCase() is web3_wallet.get_address()
    ) or []

  history = my_history_only and my_history or market.history


  <div class="row my-5">
    <div class="col-lg-12">
      <h5 class="text-center">
        <div class="custom-control custom-switch d-inline-block">
          <input type="checkbox"
                 class="custom-control-input"
                 id="history-switch"
                 onchange={(e)=> _ my_history_only: e.target.checked}
          />
          <label class="custom-control-label" for="history-switch"
                 style={opacity: my_history_only and 1 or .5}
          >
            <span class="badge badge-dark">
              {my_history.length}
            </span>
            <span class="text">MY</span>
          </label>
        </div>
        <span style={opacity: my_history_only and .5 or 1}> SWAP HISTORY
          { if market.loading_history
            <span class="spinner-grow spinner-grow-sm position-absolute ml-2"></span>
          }
        </span>
      </h5>
      <div class="scroller rounded-top">
        <table class="table table-dark table-striped table-hover table-sm">
          <thead>
          <tr>
            <th class="text-center d-none d-md-table-cell"><small>
              TYPE
            </small></th>
            <th class="text-right"><small>
              PRICE <span class="tabular">{tokenB.symbol}</span>
            </small></th>
            <th class="text-right"><small>
              AMOUNT <span class="tabular">{tokenA.symbol}</span>
            </small></th>
            <th class="text-right"><small>
              AMOUNT <span class="tabular">{tokenB.symbol}</span>
            </small></th>
            <th class="text-right d-none d-sm-table-cell"><small>
              SUM <span class="tabular">{tokenB.symbol}</span>
            </small></th>
          </tr>
          </thead>
          <tbody>
          { unless history.length
            <tr><td class="text-center text-white-50" colSpan="5">
              <small>{ if market.loading_history
                  'Loading...'
                else if my_history_only
                  "You haven't swapped yet"
                else
                 'No swaps happened yet'
              }</small>
            </td></tr>
          }
          { sum = 0; history[0...100].map ({swapType, price, amount, maker, taker})=>
            <tr class={if web3_wallet.get_address()
              if web3_wallet.get_address() is taker.toLowerCase()
                if swapType is 'BUY'
                  'bg-dark-success'
                else
                  'bg-dark-warning'
              else if web3_wallet.get_address() is maker.toLowerCase()
                if swapType is 'BUY'
                  'bg-dark-warning'
                else
                  'bg-dark-success'
            }>
              <td class="tabular text-center d-none d-md-table-cell #{
                      if swapType is 'BUY' then 'text-success' else 'text-warning'
                    }"><small>
                { if my_history_only
                    if web3_wallet.get_address() is taker.toLowerCase()
                      swapType
                    else if web3_wallet.get_address() is maker.toLowerCase()
                      if swapType is 'BUY'
                        'SELL'
                      else
                        'BUY'
                  else
                    swapType
                }
              </small></td>
              <td class="tabular text-right #{
                      if swapType is 'BUY' then 'text-success' else 'text-warning'
                    }"><small>
                {toFixed(price, tokenB.decimals)}
              </small></td>
              <td class="tabular text-right"><small>
                {toFixed(amount, tokenA.decimals)}
              </small></td>
              <td class="tabular text-right"><small>
                {toFixed(price * amount, tokenB.decimals)}
              </small></td>
              <td class="tabular text-right d-none d-sm-table-cell"><small>
                {toFixed(sum += price * amount, tokenB.decimals)}
              </small></td>
            </tr>
          }
          </tbody>
        </table>
      </div>
    </div>
  </div>
