# 合约API

## 1.载入方式
每一个合约文件被拆分成了`存储`和`实现`两个部分，存储合约一般由Storage结尾，例如关系合约中存储合约为 RelationStorage，实现合约为Relation，而用于生成的操作合约的实力，称为`proxy`,连接方式如下例子：
```javascript
async function KDeployed(storage, implement) {

    /// 用于获取实际操作合约的合约地址
    var contract_storage = artifacts.require(storage);

    /// 用于获取ABI
    var contract_impl = artifacts.require(implement);

    const instance_storage = await contract_storage.deployed();

    return await contract_impl.at(instance_storage.address);
}

const RelationProxy = await KDeployed("RelationsStorage", "Relations");
```

`
即使用【实现】合约的ABI，连接【存储】合约的合约地址，因为【实现】合约是可以替换的。但是【存储】合约不会被替换
`

## 2.模块

### 2.1 环境变量

合约文件位置：`rub/contracts/Env.sol`

存储合约名称：`EnvStorage`

实现合约名称：`Env`

#### 2.1.1 接口定义：

接口名称 | 参数 | 功能 | 返回值类型 | 读写属性
:--- | :---| :--- | :--- | :---
getUint | (uint k) | 获取变量值 | uint | view
setUint | (uint k, uint v) | 设置环境变量值 | void | view KOwnerOnly

#### 2.1.2 Enum定义：

```javascript

```

### 2.2 关系结构

合约文件位置：`rub/contracts/standard/relations/Relations.sol`

存储合约名称：`RelationsStorage`

实现合约名称：`Relations`

#### 2.2.1 接口定义：

接口名称 | 参数 | 功能 | 返回值类型 | 读写属性
:--- | :--- | :--- | :--- | :---
getIntroducer | (address owner) | 获取owner的推荐人 | address | view
recommendList | (address owner) | 获取owner孩子结点列表 | address[] | view
shortCodeToAddress | (bytes6 shortCode) | 根据推荐码获取地址 | address | view
addressToShortCode | (address addr) | 根据地址获取推荐码 | bytes6 | view
addressToNickName | (address addr) | 根据地址获取昵称 | bytes16 | view
depth | (address addr) | 根据地址获取属性结构深度 | uint | view
registerShortCode | (bytes6 shortCode) | 注册推荐码 | bool | write
updateNickName | (bytes16 name) | 更新昵称或者设置昵称 | void | write
addRelation | (address recommer) | 绑定推荐人 | AddRelationError | write
addRelationEx | (address recommer, bytes6 shortCode, bytes16 nickname) | 绑定推荐人同时注册短码和设置昵称 | AddRelationError | write

#### 2.2.2 Enum定义：

```javascript
enum AddRelationError {
    // 0.无错误
    NoError,

    // 1.自己不能作为自己的推荐人
    CannotBindYourSelf,

    // 2.推荐人已绑定，不可修改
    AlreadyBinded,

    // 3.尝试绑定的父级用户未绑定
    ParentUnbinded,

    // 4.短码已被占用
    ShortCodeExisted
}
```
