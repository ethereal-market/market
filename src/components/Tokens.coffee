import {h} from '@playframe/playframe'
import {WBTC_TOKEN, WETH_TOKEN} from "../config"
import {toFixed} from '../util'

export default ({tokenA, tokenB, web3_wallet})=>
  <div class="row my-5 text-right">
    <div class="col-md-6 my-3 card border-0">
      <div class="card-body">
        <h5 class="text-center">
          {tokenB.name or ' '}
          { if tokenB.loading
            <span class="spinner-grow spinner-grow-sm position-absolute ml-2" />}
        </h5>
        { if tokenB.address is WBTC_TOKEN
          <a target="_blank" href="https://www.wbtc.network/">wbtc.network</a>
        }
        <div class="my-1">
          <small class="tabular text-break">{tokenB.address}</small>
        </div>
        <hr/>
        <div class="row my-1">
          <div class="col-5"><small>BALANCE</small></div>
          <div class="col-7 tabular">
            {toFixed(tokenB.balance or 0, tokenB.decimals)}
            <span class="d-md-none d-lg-inline"> {tokenB.symbol}</span>
          </div>
        </div>
        <div class="row my-1">
          <div class="col-5"><small>SWAP LIMIT</small></div>
          <div class="col-7 tabular">
            {toFixed(tokenB.allowance or 0, tokenB.decimals)}
            <span class="d-md-none d-lg-inline"> {tokenB.symbol}</span>
          </div>
        </div>
        <hr/>
        <div class="btn-group btn-group-sm my-1 float-right">
          { unless tokenB.address is WBTC_TOKEN
            <button class="btn btn-outline-secondary"
                    disabled={not web3_wallet.get_address() or tokenB.minting}
                    onclick={tokenB._.mint 1000}>
              { if tokenB.minting
                <span class="spinner-grow spinner-grow-sm mr-2"></span>
              }
              MINT
            </button>
          }
          <button class="btn btn-outline-secondary"
                  disabled={not web3_wallet.get_address() or tokenB.approving}
                  onclick={tokenB._.approve tokenB.balance}>
            { if tokenB.approving
              <span class="spinner-grow spinner-grow-sm mr-2"></span>
            }
            APPROVE SWAPS
          </button>
        </div>
      </div>
    </div>
    <div class="col-md-6 my-3 card border-0">
      <div class="card-body">
        <h5 class="text-center">
          {tokenA.name or ' '}
          { if tokenB.loading
            <span class="spinner-grow spinner-grow-sm position-absolute ml-2" />}
        </h5>
        { if tokenA.address is WETH_TOKEN
          [
            <a class="mr-4" target="_blank" href="https://0x.org/portal/weth">
              <span class="tabular">0</span>x/weth
            </a>
            <a target="_blank" href="https://weth.io/">weth.io</a>
          ]
        }
        <div class="my-1">
          <small class="tabular text-break">{tokenA.address}</small>
        </div>
        <hr/>
        <div class="row my-1">
          <div class="col-5"><small>BALANCE</small></div>
          <div class="col-7 tabular">
            {toFixed(tokenA.balance or 0, tokenA.decimals)}
            <span class="d-md-none d-lg-inline"> {tokenA.symbol}</span>
          </div>
        </div>
        <div class="row my-1">
          <div class="col-5"><small>SWAP LIMIT</small></div>
          <div class="col-7 tabular">
            {toFixed(tokenA.allowance or 0, tokenA.decimals)}
            <span class="d-md-none d-lg-inline"> {tokenA.symbol}</span>
          </div>
        </div>
        <hr/>
        <div class="btn-group btn-group-sm my-1 float-right">
          { unless tokenA.address is WETH_TOKEN
              <button class="btn btn-outline-secondary"
                      disabled={not web3_wallet.get_address() or tokenA.minting}
                      onclick={tokenA._.mint 1000}>
                { if tokenA.minting
                  <span class="spinner-grow spinner-grow-sm mr-2"></span>
                }
                MINT
              </button>
          }
          { if tokenA.address is WETH_TOKEN
            [
              <button class="btn btn-outline-secondary"
                      disabled={not web3_wallet.get_address() or tokenA.wrapping}
                      onclick={tokenA._.wrap}>
                { if tokenA.wrapping
                  <span class="spinner-grow spinner-grow-sm mr-2"></span>
                }
                WRAP ETH
              </button>
              <button class="btn btn-outline-secondary"
                      disabled={not web3_wallet.get_address() or tokenA.unwrapping}
                      onclick={tokenA._.unwrap}>
                { if tokenA.unwrapping
                  <span class="spinner-grow spinner-grow-sm mr-2"></span>
                }
                UNWRAP
              </button>
            ]
          }
          <button class="btn btn-outline-secondary"
                  disabled={not web3_wallet.get_address() or tokenA.approving}
                  onclick={tokenA._.approve tokenA.balance}>
            { if tokenA.approving
              <span class="spinner-grow spinner-grow-sm mr-2"></span>
            }
            APPROVE SWAPS
          </button>
        </div>
      </div>
    </div>
  </div>
