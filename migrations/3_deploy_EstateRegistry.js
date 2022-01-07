const EstateRegistry = artifacts.require("EstateRegistry");
const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer) {
  console.log("\n3_deploy_EstateRegistry_contract");
  console.log("============================\n");
  // deployer.deploy(EstateRegistry);
  const instance = await deployProxy(EstateRegistry, [42], {
    deployer,
    initializer: "initialize",
  });
  console.log("deployed", instance.address);
};
