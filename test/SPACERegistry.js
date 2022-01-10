const BigNumber = web3.utils.BN;
import { load } from "babel-register/lib/cache";
import { use } from "chai";
import assertRevert from "./helpers/assertRevert";
const MiniMeToken = artifacts.require("MiniMeToken");
const NONE = "0x0000000000000000000000000000000000000000";

import createEstateFull from "./helpers/createEstateFull";

import setupUnicialContracts, {
  SPACE_NAME,
  SPACE_SYMBOLE,
} from "./helpers/setupUnicialContracts";

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract("SPACERegistry", (accounts) => {
  const [creator, user, anotherUser, operator, hacker] = accounts;

  console.log("   ================ Account Info ==============");
  console.log(accounts);
  console.log("  *** Creator      : ", creator);
  console.log("  *** Hacker       : ", hacker);
  console.log("  *** User         : ", user);
  console.log("  *** Another user : ", anotherUser);
  console.log("  *** Operator     : ", operator);

  console.log("   ============================================");

  let contracts = null;
  let estate = null;
  let space = null;

  const params = {
    gas: 7e6,
    gasPrice: 1e9,
    from: creator,
  };
  const sentByUser = { ...params, from: user };
  const sentByCreator = { ...params, from: creator };
  const sentByOperator = { ...params, from: operator };
  const sentByAnotherUser = { ...params, from: anotherUser };
  const sentByHacker = { ...params, from: hacker };

  async function createEstate(xs, ys, owner, sendParams) {
    return createEstateFull(contracts, xs, ys, owner, "", sendParams);
  }

  beforeEach(async function () {
    contracts = await setupUnicialContracts(creator, params);
    space = contracts.space;
    estate = contracts.estate;

    await space.authorizeDeploy(creator, sentByCreator);
    await space.assignNewRood(0, 1, user, sentByCreator);
    await space.assignNewRood(0, 2, user, sentByCreator);
  });

  //   describe("CHECK TOTAL SUPPLY", function () {
  //     it("check a total supply equivalent with initial supply", async function () {
  //       const totalSupply = await space.totalSupply();
  //       web3.utils.fromWei(totalSupply, "wei").should.be.equal("2");
  //     });
  //     it("check a total supply that increases after creating a new SPACE", async function () {
  //       let totalSupply = await space.totalSupply();
  //       web3.utils.fromWei(totalSupply, "wei").should.be.equal("2");
  //       await space.assignNewRood(300, 900, anotherUser, sentByCreator);
  //       totalSupply = await space.totalSupply();
  //       web3.utils.fromWei(totalSupply, "wei").should.be.equal("3");
  //     });
  //   });

  //   describe("CHECK SYMBOL", function () {
  //     it("check a space symbol", async function () {
  //       const symbol = await space.symbol();
  //       symbol.should.be.equal(SPACE_SYMBOLE);
  //     });
  //   });

  //   describe("CHECK NAME", function () {
  //     it("check space name", async function () {
  //       const name = await space.name();
  //       name.should.be.equal(SPACE_NAME);
  //     });
  //   });

  //   describe("CREATE NEW ROOD", function () {
  //     describe("Create one at a time", function () {
  //       it("only allows the creator to assign roods", async function () {
  //         await assertRevert(space.assignNewRood(3, 5, user, sentByAnotherUser));
  //       });
  //       it("allows the creator to assign roods", async function () {
  //         await space.assignNewRood(900, 900, user, sentByCreator);
  //         const owner = await space.ownerOfSpace(900, 900);
  //         owner.should.be.equal(user);
  //       });
  //     });
  //     describe("Create multiple rood at a time", function () {
  //       describe("successfully registers 10 roods", async function () {
  //         const x = [];
  //         const y = [];
  //         const count = 1;
  //         for (let i = 5; x.length < count; i++) {
  //           x.push(i);
  //         }
  //         for (let j = -100; y.length < count; j++) {
  //           y.push(j);
  //         }

  //         let assetIds;

  //         before(async function () {
  //           await space.assignMultipleRoods(x, y, anotherUser, sentByCreator);
  //           assetIds = await space.tokensOf(anotherUser);
  //         });

  //         for (let i = 0; i < x.length; i++) {
  //           it(
  //             `works for ${x[i]},${y[i]}`,
  //             ((i) => async () => {
  //               const registeredId = await space.encodeTokenId(x[i], y[i]);
  //               web3.utils
  //                 .fromWei(registeredId, "wei")
  //                 .should.be.equal(web3.utils.fromWei(assetIds[i], "wei"));
  //             })(i)
  //           );
  //         }
  //       });
  //     });
  //   });

  // describe("SPACE GETTER FUNCTIONS", function () {
  //   // describe("ownerOfSpace", function () {
  //   //   it("gets the owner of a rood of Space", async function () {
  //   //     const owner = await space.ownerOfSpace(0, 1);
  //   //     owner.should.be.equal(user);
  //   //   });
  //   // });

  //   // describe("ownerOfSpaceMany", function () {
  //   //   it("gets the owners of a list of roods", async function () {
  //   //     await space.assignNewRood(0, 5, anotherUser, sentByCreator);
  //   //     const owners = await space.ownerOfSpaceMany([0, 0, 0], [1, 2, 5]);

  //   //     owners[0].should.be.equal(user);
  //   //     owners[1].should.be.equal(user);
  //   //     owners[2].should.be.equal(anotherUser);
  //   //   });
  //   // });

  //   describe("spaceOf", function () {
  //     it("gets the rood coordinates for a certain owner", async function () {
  //       await space.spaceOf(user);
  //       // console.log(x[0]);
  //       // web3.utils.fromWei(x[0], "wei").should.be.equal("0");
  //       // web3.utils.fromWei(x[1], "wei").should.be.equal("0");
  //       // web3.utils.fromWei(y[0], "wei").should.be.equal("1");
  //       // web3.utils.fromWei(y[1], "wei").should.be.equal("2");
  //     });
  //   });
  // });

  describe("TRANSFER SPACE TO ESTATE", function () {
    let estateId;

    beforeEach(async function () {
      const estateAddr = await space.estateRegistry();
      console.log("   Real Estate Address: ", estate.address);
      console.log("   Estate Address     : ", estateAddr);
      await space.assignMultipleRoods([3], [3], creator, sentByCreator);
      estateId = await createEstate([3], [3], user, sentByCreator);

      console.log("   Estate token ID    : ", estateId);
    });

    describe("transferSpaceToEstate", function () {
      it("should not transfer the SPACE to an Estate if it is not owned by the sender", async function () {
        await space.assignMultipleRoods([4], [4], operator, sentByCreator);
        await assertRevert(
          space.transferSpaceToEstate(4, 4, estateId, sentByOperator)
        );
      });

      it("transfers SPACE to an Estate if it is called by owner", async function () {
        await space.transferSpaceToEstate(0, 1, estateId, sentByUser);

        let result = await space.spaceOf(estate.address);
        const xEstate = result["0"];
        const yEstate = result["1"];

        result = await space.spaceOf(user);
        const xNewUser = result["0"];
        const yNewUser = result["1"];

        web3.utils.fromWei(xEstate[0], "wei").should.be.equal("3");
        web3.utils.fromWei(xEstate[1], "wei").should.be.equal("0");
        web3.utils.fromWei(yEstate[0], "wei").should.be.equal("3");
        web3.utils.fromWei(yEstate[1], "wei").should.be.equal("1");

        xEstate.length.should.be.equal(2);
        yEstate.length.should.be.equal(2);

        web3.utils.fromWei(xNewUser[0], "wei").should.be.equal("0");
        web3.utils.fromWei(yNewUser[0], "wei").should.be.equal("2");

        xNewUser.length.should.be.equal(1);
        yNewUser.length.should.be.equal(1);
      });
    });
  });
});
