import {h} from '@playframe/playframe'
import {toFixed} from '../util'

export default ({my_bids_only, my_offers_only, market, tokenA, tokenB, web3_wallet, _})=>
  my_bids =
    market.bids.filter(({wallet})=> wallet.toLowerCase() is web3_wallet.get_address()) or []

  my_offers =
    market.offers.filter(({wallet})=> wallet.toLowerCase() is web3_wallet.get_address()) or []

  bids = if my_bids_only then my_bids else market.bids
  offers = if my_offers_only then my_offers else market.offers

  <div class="row my-5">
    <div class="col-lg-6 my-4">
      <h5 class="text-center">
        <div class="custom-control custom-switch d-inline-block">
          <input type="checkbox"
              class="custom-control-input"
              id="buy-book-switch"
              onchange={(e)=> _ my_bids_only: e.target.checked}
          />
          <label class="custom-control-label" for="buy-book-switch"
              style={opacity: my_bids_only and 1 or .5}
          >
            <span class="badge badge-dark">
              {my_bids.length}
            </span>
            MY
          </label>
        </div>
        <span style={opacity: my_bids_only and .5 or 1}> BUY COMMITS
          { if market.loading_book
            <span class="spinner-grow spinner-grow-sm position-absolute ml-2"></span>
          }
        </span>
      </h5>
      <div class="scroller rounded-top">
        <table class="table table-dark table-striped table-hover table-sm">
          <thead>
          <tr>
            <th class="text-right"><small>
              PRICE
            </small></th>
            <th class="text-right tabular"><small>
              {tokenA.symbol}
            </small></th>
            <th class="text-right tabular"><small>
              {tokenB.symbol}
            </small></th>
            <th class="text-right d-none d-md-table-cell" style={width:'25%'}><small>
              { if my_bids_only
                  'ACTION'
                else
                  'SUM'
              }
              { unless my_bids_only
                <span class="tabular"> {tokenB.symbol}</span>}
            </small></th>
          </tr>
          </thead>
          <tbody>
          { unless bids.length
            <tr><td class="text-center text-white-50" colSpan="5">
              <small>{ if market.loading_book
                  'Loading...'
                else if my_bids_only
                  "You don't have any commits in this book"
                else
                  'There are no commits in this book'
              }</small>
            </td></tr>
          }
          { sum = 0; bids[0...100].map (bid)=>
            {id, price, amount, wallet} = bid
            <tr class="#{'bg-dark-success' if web3_wallet.get_address() is wallet.toLowerCase()}">
              <td class="tabular text-right text-success"><small>
                {toFixed(price, tokenB.decimals)}
              </small></td>
              <td class="tabular text-right"><small>
                {toFixed(amount, tokenA.decimals)}
              </small></td>
              <td class="tabular text-right"><small>
                {toFixed(price * amount, tokenB.decimals)}
              </small></td>
              <td class="tabular text-right d-none d-md-table-cell">
                { if my_bids_only
                  if bid.canceling
                    [
                      <span class="spinner-grow spinner-grow-sm text-dark"></span>
                      <span class="spinner-grow spinner-grow-sm text-dark"></span>
                      <span class="spinner-grow spinner-grow-sm text-dark"></span>
                    ]
                  else
                    <button class="btn btn-dark btn-sm xs rounded-pill" href="#"
                            onclick={(e)=> e.preventDefault(); market._.cancel_bid bid}
                    >
                      CANCEL
                    </button>
                else
                  <small>{toFixed(sum += price * amount, tokenB.decimals)}</small>
                }
              </td>
            </tr>
          }
          </tbody>
        </table>
      </div>
    </div>
    <div class="col-lg-6 my-4">
      <h5 class="text-center">
        <div class="custom-control custom-switch d-inline-block">
          <input type="checkbox"
              class="custom-control-input"
              id="sell-book-switch"
              onchange={(e)=> _ my_offers_only: e.target.checked}
          />
          <label class="custom-control-label" for="sell-book-switch"
              style={opacity: my_offers_only and 1 or .5}
          >
            <span class="badge badge-dark">
              {my_offers.length}
            </span>
            MY
          </label>
        </div>
        <span style={opacity: my_offers_only and .5 or 1}> SELL COMMITS
          { if market.loading_book
            <span class="spinner-grow spinner-grow-sm position-absolute ml-2"></span>
          }
        </span>
      </h5>
      <div class="scroller rounded-top">
        <table class="table table-dark table-striped table-hover table-sm">
          <thead>
          <tr>
            <th class="text-right"><small>
              PRICE
            </small></th>
            <th class="text-right tabular"><small>
              {tokenA.symbol}
            </small></th>
            <th class="text-right tabular"><small>
              {tokenB.symbol}
            </small></th>
            <th class="text-right d-none d-md-table-cell" style={width:'25%'}><small>
              { if my_offers_only
                'ACTION'
              else
                'SUM'
              }
              { unless my_offers_only
                <span class="tabular"> {tokenB.symbol}</span>}
            </small></th>
          </tr>
          </thead>
          <tbody>
          { unless offers.length
            <tr><td class="text-center text-white-50" colSpan="5">
              <small>{ if market.loading_book
                'Loading...'
              else if my_offers_only
                "You don't have any commits in this book"
              else
                'There are no commits in this book'
              }</small>
            </td></tr>
          }
          {  sum = 0; offers[0...100].map (offer)=>
            {id, price, amount, wallet} = offer
            <tr class="#{'bg-dark-warning' if web3_wallet.get_address() is wallet.toLowerCase()}">
              <td class="tabular text-right text-warning"><small>
                {toFixed(price, tokenB.decimals)}
              </small></td>
              <td class="tabular text-right"><small>
                {toFixed(amount, tokenA.decimals)}
              </small></td>
              <td class="tabular text-right"><small>
                {toFixed(price * amount, tokenB.decimals)}
              </small></td>
              <td class="tabular text-right d-none d-md-table-cell">
                { if my_offers_only
                  if offer.canceling
                    [
                      <span class="spinner-grow spinner-grow-sm text-dark"></span>
                      <span class="spinner-grow spinner-grow-sm text-dark"></span>
                      <span class="spinner-grow spinner-grow-sm text-dark"></span>
                    ]
                  else
                    <button class="btn btn-dark btn-sm xs rounded-pill" href="#"
                            onclick={(e)=> e.preventDefault(); market._.cancel_offer offer}
                    >
                      CANCEL
                    </button>
                else
                  <small>{toFixed(sum += price * amount, tokenB.decimals)}</small>
                }
              </td>
            </tr>
          }
          </tbody>
        </table>
      </div>
    </div>
  </div>
