const Market = artifacts.require("Market");

const ERC20MintableA = artifacts.require("ERC20MintableA");
const ERC20MintableB = artifacts.require("ERC20MintableB");

module.exports = function(deployer) {
  deployer.deploy(Market);
  deployer.deploy(ERC20MintableA);
  deployer.deploy(ERC20MintableB);
};
