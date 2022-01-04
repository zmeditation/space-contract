const BigNumber = web3.utils.BN;

const SPACEProxy = artifacts.require("SPACEProxy");
const SPACERegistry = artifacts.require("SPACERegistry");

function checkUpgradeLog(log, newContract, initializedWith) {
  log.event.should.be.eq("Upgrade");
  log.args.newContract.toLowerCase().should.be.equal(newContract.toLowerCase());
  log.args.initializedWith
    .toLowerCase()
    .should.be.equal(initializedWith.toLowerCase());
}

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract("SPACEProxy", (accounts) => {
  console.log(accounts);

  const [creator, hacker, otherOwner] = accounts;

  console.log(creator);
  console.log(hacker);
  console.log(otherOwner);

  const params = {
    gas: 7e6,
    gasPrice: 5e9,
    from: creator,
  };

  describe("upgrade", () => {
    beforeEach(async function () {
      proxy = await SPACEProxy.new(params);
      registry = await SPACERegistry.new(params);
      space = await SPACERegistry.at(proxy.address);

      console.log(proxy.address);
      console.log(registry.address);
      console.log(space.address);
    });

    it("should upgrade proxy by owner", async () => {
      const { logs } = await proxy.upgradeDelegate(
        registry.address,
        creator,
        params
      );
      await checkUpgradeLog(logs[0], registry.address, creator);

      const spaceName = await registry.name();
      console.log(spaceName);

      const currentContract = await proxy.currentContract();
      console.log(currentContract);
    });
    it("should proxy function call", async () => {
      await proxy.upgradeDelegate(registry.address, creator, params);
      await space.initialize(creator, params);

      const spaceName = await space.name();

      console.log(spaceName);

      const { logs } = await space.assignNewRood(0, 0, accounts[0], params);
      console.log(logs);
    });
  });
});
