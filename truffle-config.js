var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 5000000
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(process.env.MNEMONIC, `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`);
      },
      network_id: '3'
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(process.env.MNEMONIC, `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`);
      },
      network_id: '42',
      gasPrice: 10000000000
    },
    main: {
      provider: function() {
        return new HDWalletProvider(process.env.MNEMONIC, `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`);
      },
      network_id: '1',
      gasPrice: 10000000000
    }
  },
  compilers: {
    solc: {
      settings: {
        optimizer: {
          enabled: true,
          runs: 1e9
        },
      }
    }
  }
};
