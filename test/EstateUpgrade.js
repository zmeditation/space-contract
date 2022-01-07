import assertRevert from "./helpers/assertRevert";
import { deployProxy, upgradeProxy } from "@openzeppelin/truffle-upgrades";

const BigNumber = web3.utils.BN;

const EstateRegistry = artifacts.require("EstateRegistry");

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract("EstateUpgrade", (accounts) => {
  const [creator, hacker, otherOwner] = accounts;
  let estate = null;

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
      estate = await deployProxy(EstateRegistry, [5], params);
      // estate = await EstateRegistry.new(params);

      console.log("   ================= Before Each ==============");
      console.log("   V0 estate    : ", estate.address);
      console.log("   ============================================");
    });

    it("upgrade version 1", async function () {
      // console.log(estate.address);
      await estate.increase(params);
      await estate.increase(params);
      const instance = await upgradeProxy(
        estate.address,
        EstateRegistry,
        params
      );

      const value = await instance.x();
      console.log("Upgraded", instance.address);
      console.log("Value: ", value);
    });
  });
});
