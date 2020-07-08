import {h} from '@playframe/playframe'
import {DOMAIN} from '../config'

export default ({show_intro, _})=>
  return unless show_intro
  <div class="jumbotron bg-dark my-5">
    <div class="text-right">
      <h1 class="display-1 d-none d-md-block mb-5">
        the most secure
        <br/>token exchange
        <br/>on the planet
      </h1>
      <h4 class="display-5 d-none d-md-block">
        fully <span class="tabular">decentralized</span>
      </h4>
      <h3 class="display-4">
        priced p2p token swaps
      </h3>
    </div>
    <div class="row">
      <div class="col-lg">
        <hr class="my-4"/>
        <p class="lead">
          Secure ERC20 token swapping means you are protected from
          things like front running, high-frequency trading or transaction reordering.
          It is ensured by a cryptographic commit/reveal process:
          <ul>
            <li>Unique but random looking hash corresponding to your swap
              is getting committed to reserve your spot in the market execution order.</li>

            <li>Reveals are submitted 3 - 5 blocks after commits. Reveals are price-matched and executed
              in the same order as commits came in. Swap confirmation time would take only
              3 - 5 blocks longer than a regular Ethereum transaction (about 30 - 60 seconds longer).
              If someone decides not to reveal their commit, market would hold execution
              of that swap pair for 7 blocks before evicting such commit. This round would take
              7 blocks to clear (2 minutes).
            </li>

            <li>There is no maker/taker commission but there will be a fixed fee (disabled for now)
              to commit a swap: {1e6.toLocaleString()} gas paid in ETH.
              This is required to prevent spamming and demotivate gas price manipulation.
              The fee is about $0.50 to submit a slow commit and goes up
              as you increase your gas price.</li>

            <li>Your tokens are kept in your wallet all the time and swapped directly
              into counter-party wallet when matching counter-commit appears.
              If tokens are not present in your wallet at such moment, your commit gets evicted.
            </li>

          </ul>
        </p>
      </div>
      <div class="col-lg">
        <hr class="my-4"/>
        <p class="lead">
          Full decentralization:
          <ul>
            <li>
              <a target="_blank" href="https://blockstack.org/technology">
                Blockstack authentication and storage
              </a> for user accounts and private data.</li>

            <li>Secure IPFS site hosting with
              <a target="_blank" href="https://www.cloudflare.com/distributed-web-gateway/">Cloudflare distributed web gateway</a>.</li>

            <li>All market functionality is implemented in
              an autonomous smart-contract on Ethereum blockchain.
              This includes  commit/reveal book, buy/sell swap request books, price matching engine
              and wallet to wallet clearance.
            </li>

            <li>
              Pure peer to peer swapping. Tokens are never held in custody,
              they are transferred directly from wallet to wallet.
            </li>

            <li>
              This app communicates only with Blockstack and Ethereum blockchains.
              No backend servers, no user tracking, no cookies.
            </li>

            <li>Open source: you can inspect the source code on
              <a href="https://github.com/ethereal-market/market">Github</a>.</li>

            <li><span class="tabular">{DOMAIN}</span> is
              a cryptographically secure sorted message board.
              Each message represents an intent to swap one token for another.
              When you reveal your intent and matching counter-intent already exists on that board,
              your reveal is allowing you to take tokens from that counter-wallet and
              transfer your tokens instead.
            </li>
          </ul>
        </p>
      </div>

    </div>
    <hr class="my-4"/>
    <p class="lead">
      This is Mainnet public beta:
      <ul>
        <li>Make sure you have installed Metamask browser extension or using any
          other Web3 compatible wallet.</li>

        <li>If you are on the phone you can use Cipher Browser, Coinbase wallet or other</li>

        <li>You are able to buy and sell Wrapped Ether (WETH) for Wrapped Bitcoin (WBTC)</li>

        <li>You can convert ETH to WETH by simply wrapping it</li>

        <li>Add token addresses to you Wallet to see it appear there</li>

        <li>If you have Ropsten or Kovan ETH you can select
          Ropsten or Kovan Test Network in your wallet.</li>

        <li>Please approve market to swap tokens for you.</li>

        <li>Submit your first commit and then reveal it to start swapping.</li>

        <li>When you commit or reveal and wallet pops up,
          remember set the gas price and pick average or fast TX time.</li>
      </ul>
    </p>
    <hr class="my-4"/>
    <button class="btn btn-dark btn-lg float-right"
            onclick={=>
              _ show_intro: false
              localStorage['hide_intro'] = true
              setTimeout (=> scrollTo 0, 0), 33
            }
    >
      Happy swapping!
    </button>
  </div>
