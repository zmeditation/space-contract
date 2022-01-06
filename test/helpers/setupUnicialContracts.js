export const SPACE_NAME = "Unicial SPACE";
export const SPACE_SYMBOLE = "UNIS";

const EMPTY_ADDRESS = "0x0000000000000000000000000000000000000000";

export default async function setupUnicialContracts(creator) {
  const params = {
    gas: 7e6,
    gasPrice: 1e9,
    from: creator,
  };

  const sentByCreator = { ...params, from: creator };

  const MiniMeToken = artifacts.require("MiniMeToken");
  const SPACERegistry = artifacts.require("SPACERegistry");
  const SPACEProxy = artifacts.require("SPACEProxy");

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

  await space.initialize(creator, sentByCreator);
  await spaceMiniMeToken.changeController(space.address, sentByCreator);
  await space.setSpaceBalanceToken(spaceMiniMeToken.address, sentByCreator);

  return {
    proxy,
    registry,
    space,
  };
}
