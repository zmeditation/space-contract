import assertRevert from "./helpers/assertRevert";
import { deployProxy, upgradeProxy } from "@openzeppelin/truffle-upgrades";

const BigNumber = web3.utils.BN;

const EstateRegistry = artifacts.require("EstateRegistry");

import setupUnicialContracts, {
  ESTATE_NAME,
  ESTATE_SYMBOLE,
} from "./helpers/setupUnicialContracts";

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
    gas: 8e6,
    gasPrice: 5e9,
    from: creator,
  };

  beforeEach(async function () {
    const contracts = await setupUnicialContracts(creator, params);
    estate = contracts.estate;

    console.log("   ================= Before Each ==============");
    console.log("   V0 estate    : ", estate.address);
    console.log("   ============================================");
  });

  describe("upgrade", () => {
    it("upgrade version 1", async function () {
      const instance = await upgradeProxy(
        estate.address,
        EstateRegistry,
        params
      );

      console.log("Upgraded", instance.address);
    });
  });

  describe("CHECK NAME", function () {
    it("check estate name", async function () {
      const name = await estate.name();
      name.should.be.equal(ESTATE_NAME);
    });
  });
  describe("CHECK SYMBOLE", function () {
    it("check estate symbol", async function () {
      const symbol = await estate.symbol();
      symbol.should.be.equal(ESTATE_SYMBOLE);
    });
  });
});
