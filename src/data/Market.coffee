import {abi, networks} from '../../build/contracts/Market'
import {net_provider, wallet_provider} from "./web3"

eth_net_id = localStorage['eth_net_id'] or '1'
eth_net_id = '1' unless networks[eth_net_id]


export Market = window.Market = new Web3EthContract abi, networks[eth_net_id].address
Market.setProvider net_provider


if wallet_provider
  Market.Wallet = MarketWallet = new Web3EthContract abi, networks[eth_net_id].address
  MarketWallet.setProvider wallet_provider


getBlockNumber = new Web3Method
  name: 'getBlockNumber',
  call: 'eth_blockNumber',
  params: 0,
  outputFormatter: Web3Utils.hexToNumber

getBlockNumber.setRequestManager Market._requestManager

getBlockNumber.attachToObject Market
