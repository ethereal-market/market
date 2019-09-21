import {abi, networks as tokenANetworks} from '../../build/contracts/ERC20MintableA'
import {networks as tokenBNetworks} from '../../build/contracts/ERC20MintableB'
import WETH9_ABI from './WETH9.abi'
import {net_provider, wallet_provider} from "./web3"
import {WBTC_TOKEN, WETH_TOKEN} from "../config"


eth_net_id = localStorage['eth_net_id'] or '1'
eth_net_id = '1' unless tokenANetworks[eth_net_id]

if eth_net_id is '1'
  # https://weth.io/
  token_A_address = WETH_TOKEN
  token_A_abi = WETH9_ABI
  # https://www.wbtc.network/
  token_B_address = WBTC_TOKEN
  token_B_abi = abi
else
  token_A_address = tokenANetworks[eth_net_id].address
  token_A_abi = abi
  token_B_address = tokenBNetworks[eth_net_id].address
  token_B_abi = abi


export TokenA = window.TokenA = new Web3EthContract token_A_abi, token_A_address
TokenA.setProvider net_provider


export TokenB = window.TokenB = new Web3EthContract token_B_abi, token_B_address
TokenB.setProvider net_provider


if wallet_provider
  TokenA.Wallet = TokenAWallet = new Web3EthContract token_A_abi, token_A_address
  TokenAWallet.setProvider wallet_provider

  TokenB.Wallet = TokenBWallet = new Web3EthContract token_B_abi, token_B_address
  TokenBWallet.setProvider wallet_provider

