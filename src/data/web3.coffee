import {CDN_WEB3_PROVIDER} from "../config"


_debounce_id = 0
debounce = (time)=>(fn)=>(args...)=>
  clearTimeout _debounce_id
  _debounce_id = setTimeout fn, time, args...
  return

reload = debounce(300) => location.reload()


if window.ethereum
  ethereum.autoRefreshOnNetworkChange = false
  ethereum.on? 'networkChanged', (net)=> check_network net unless net is 'loading'
  ethereum.on? 'accountsChanged', (accounts)=> reload() unless accounts is 'loading'

  web3_instance = if window.Web3
    new Web3 ethereum
  else
    window.web3


else if window.web3
  web3_instance = if window.Web3
    new Web3 web3.currentProvider
  else
    window.web3

  _address = ""
  web3_instance
    .currentProvider
    .publicConfigStore?.on 'update', ({networkVersion, selectedAddress})=>
      check_network networkVersion
      if _address and _address isnt selectedAddress
        reload()
      else
        _address = selectedAddress
else
  console.info 'Error: no web3 wallet found'


web3_instance?.version?.getNetwork (err, net_id) =>
  check_network net_id


check_network = (net_id)=>
  current = localStorage['eth_net_id'] or '1'

  unless current is net_id
    localStorage['eth_net_id'] = net_id
    reload()

export default web3_wallet =
  get_address: if window.ethereum
    => ethereum.selectedAddress or ''
  else if web3_instance
    => web3_instance.eth?.defaultAccount
  else
    =>

  get_balance: (address)=> new Promise (resolve, reject)=>
    resolve '' unless web3_instance?.eth?.getBalance
    web3_instance.eth.getBalance address, (err, data)=>
      if err then reject err else resolve data


eth_net_id = localStorage['eth_net_id'] or '1'
export net_provider = if eth_net_id is '1' # mainnet
  # TODO use cloudflare for calls and infura for subs
  new Web3ProviderWS CDN_WEB3_PROVIDER
else
  window.ethereum or web3_instance?.currentProvider


export wallet_provider = window.ethereum or web3_instance?.currentProvider
