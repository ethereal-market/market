const path = require('path')

module.exports = {
  mode: "production",
  entry: './src/web3-eth-contract.js',
  output: {
    path: path.resolve(__dirname, 'public'),
    filename: 'web3-eth-contract.js'
  }
};
