const BigNumber = web3.utils.BN;

const SPACEProxy = artifacts.require("SPACEProxy");

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
    gasPrice: 21e9,
    from: creator,
  };

  describe("upgrade", () => {
    beforeEach(async function () {
      proxy = await SPACEProxy.new(params);
      console.log(proxy.address);
    });

    it("should upgrade proxy by owner", async () => {});
  });
});
