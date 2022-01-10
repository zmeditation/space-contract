import { deployProxy } from "@openzeppelin/truffle-upgrades";

export const SPACE_NAME = "Unicial SPACE";
export const SPACE_SYMBOLE = "UNIS";

export const ESTATE_NAME = "Unicial Estate";
export const ESTATE_SYMBOLE = "UNIE";

const EMPTY_ADDRESS = "0x0000000000000000000000000000000000000000";

export default async function setupUnicialContracts(creator) {
  const params = {
    gas: 8e6,
    gasPrice: 1e9,
    from: creator,
  };

  const sentByCreator = { ...params, from: creator };

  const MiniMeToken = artifacts.require("MiniMeToken");
  const SPACERegistry = artifacts.require("SPACERegistry");
  const SPACEProxy = artifacts.require("SPACEProxy");
  const EstateRegistry = artifacts.require("EstateRegistry");

  const spaceMiniMeToken = await MiniMeToken.new(
    EMPTY_ADDRESS,
    EMPTY_ADDRESS,
    0,
    SPACE_NAME,
    18,
    SPACE_SYMBOLE,
    false,
    params
  );

  const registry = await SPACERegistry.new(params);
  const proxy = await SPACEProxy.new(params);
  const space = await SPACERegistry.at(proxy.address);

  await proxy.upgradeDelegate(registry.address, creator, params);

  const estate = await deployProxy(
    EstateRegistry,
    [ESTATE_NAME, ESTATE_SYMBOLE, space.address],
    params
  );

  await space.initialize(creator, sentByCreator);
  await space.setEstateRegistry(estate.address, sentByCreator);

  await spaceMiniMeToken.changeController(space.address, sentByCreator);
  await space.setSpaceBalanceToken(spaceMiniMeToken.address, sentByCreator);

  return {
    proxy,
    registry,
    space,
    estate,
  };
}
