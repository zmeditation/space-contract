import assertRevert from "./helpers/assertRevert";
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
  const [creator, hacker, otherOwner] = accounts;
  let proxy = null;
  let registry = null;
  let space = null;

  console.log("   ================ Account Info ==============");
  console.log(accounts);
  console.log("  *** Creator     : ", creator);
  console.log("  *** Hacker      : ", hacker);
  console.log("  *** Other Owner : ", otherOwner);
  console.log("   ============================================");

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

      console.log("   ================= Before Each ==============");
      console.log("   Proxy Address    : ", proxy.address);
      console.log("   Registry Address : ", registry.address);
      console.log("   ============================================");
    });

    it("should upgrade proxy by owner", async () => {
      const { logs } = await proxy.upgradeDelegate(
        registry.address,
        creator,
        params
      );
      await checkUpgradeLog(logs[0], registry.address, creator);

      const currentContract = await space.currentContract();
      currentContract.should.be.equal(registry.address);

      const proxyOwner = await space.proxyOwner();
      proxyOwner.should.be.equal(creator);

      const ownerAddress = await space.owner();
      ownerAddress.should.be.equal(creator);
    });
    it("should thorw if not owner upgrade proxy", async () => {
      await assertRevert(
        proxy.upgradeDelegate(
          registry.address,
          hacker,
          Object.assign({}, params, { from: hacker })
        )
      );
    });
    it("should proxy function call", async () => {
      await proxy.upgradeDelegate(registry.address, creator, params);

      await space.initialize(creator, params);

      const spaceName = await space.name();
      spaceName.should.be.equal("Unicial SPACE");

      await space.assignNewRood(0, 0, accounts[0], params);
    });
  });
});
