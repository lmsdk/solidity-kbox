async function KDeploy(deployer, storage, implement, ...parmas) {

    var contract_storage = artifacts.require(storage);
    var contract_impl = artifacts.require(implement);

    await deployer.deploy(contract_storage, ...parmas);
    await deployer.deploy(contract_impl);

    const instance_storage = await contract_storage.deployed();
    const instance_impl = await contract_impl.deployed();

    await instance_storage.SetKImplementAddress(instance_impl.address);

    return await contract_impl.at(instance_storage.address);
}

module.exports = async function(deployer) {

    // 部署运行环境配置
    // const ENVProxy = await KDeploy(deployer, "EnvStorage", "Env");

    // 配置权限
    // await RUBTProxy.addDefaultOperators(MainProxy.address);

    // await RUBTProxy.KAddAuthAddress(MainProxy.address);
    // await ENVProxy.KAddAuthAddress(MainProxy.address);
    // await RelationProxy.KAddAuthAddress(MainProxy.address);
    // await LargeSmallProxy.KAddAuthAddress(MainProxy.address);
};
