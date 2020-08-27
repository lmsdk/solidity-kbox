pragma solidity >=0.5.0 <0.6.0;

import "../../core/k.sol";
import "../../core/library/SafeMath.sol";
import "./interface/IRelations.sol";

contract RelationsStorage is KStorage {

    // 根地址
    address public rootAddress = address(0xdead);

    // 地址总数
    uint public totalAddresses;

    // 上级检索
    mapping (address => address) internal _recommerMapping;

    // 下级检索-直推
    mapping (address => address[]) internal _recommerList;

    // 短推荐码
    mapping (bytes6 => address) internal _shortCodeMapping;

    // 地址转换短码
    mapping (address => bytes6) internal _addressShotCodeMapping;

    // 昵称数据
    mapping (address => bytes16) internal _nickenameMapping;

    // 深度记录
    mapping (address => uint) internal _depthMapping;
}

contract Relations is iRelations, RelationsStorage {
    /////////////////////////////////////////////////////////////////////////////
    //                                  View                                   //
    /////////////////////////////////////////////////////////////////////////////
    /// 获取我的推荐人，也就是介绍人
    function getIntroducer(address owner ) external view returns (address) {
        return _recommerMapping[owner];
    }

    /// 获取推荐列表
    function recommendList(address owner) external view returns (address[] memory) {
        return (_recommerList[owner]);
    }

    /// 查询短推荐码绑定的钱包地址
    function shortCodeToAddress(bytes6 shortCode) external view returns (address) {
        return _shortCodeMapping[shortCode];
    }

    /// 查询地址对应的短推荐码
    function addressToShortCode(address addr) external view returns (bytes6) {
        return _addressShotCodeMapping[addr];
    }

    /// 查询昵称数据
    function addressToNickName(address addr) external view returns (bytes16) {
        return _nickenameMapping[addr];
    }

    function depth(address addr) external view returns (uint) {
        return _depthMapping[addr];
    }

    /////////////////////////////////////////////////////////////////////////////
    //                                  Write                                  //
    /////////////////////////////////////////////////////////////////////////////
    /// 注册短推荐码，长度限制为6，内容为大写字母+数字
    function registerShortCode(bytes6 shortCode) external returns (bool) {

        /// 1.短码是否已被申请
        if ( _shortCodeMapping[shortCode] != address(0x0) ) {
            return false;
        }

        /// 2.用户是否已经拥有一个短码
        if ( _addressShotCodeMapping[msg.sender] != bytes6(0x0) ) {
            return false;
        }

        // 推荐短码未被占用，并且对应地址暂未持有短码
        _shortCodeMapping[shortCode] = msg.sender;
        _addressShotCodeMapping[msg.sender] = shortCode;

        return true;
    }

    /// 更新昵称
    function updateNickName(bytes16 name) external {
        _nickenameMapping[msg.sender] = name;
    }

    function addRelation(address recommer) external returns (AddRelationError) {

        /// 自己不能作为自己的推荐人
        if ( recommer == msg.sender ) {
            return AddRelationError.CannotBindYourSelf;
        }

        /// 若已经绑定推荐人，不允许修改
        if ( _recommerMapping[msg.sender] != address(0x0) ) {
            return AddRelationError.AlreadyBinded;
        }

        /// 如果即将绑定的推荐人本身没有绑定上级，不允许绑定（防止出现循环绑定）
        if ( recommer != rootAddress && _recommerMapping[recommer] == address(0x0) ) {
            return AddRelationError.ParentUnbinded;
        }

        totalAddresses++;

        /// 绑定直推
        _recommerMapping[msg.sender] = recommer;
        _recommerList[recommer].push(msg.sender);

        /// 写入深度
        _depthMapping[msg.sender] = _depthMapping[recommer] + 1;

        return AddRelationError.NoError;
    }

    /// 绑定推荐人并且生产自己短码同时设置昵称
    function addRelationEx(address recommer, bytes6 shortCode, bytes16 nickname) external returns (AddRelationError) {

        /// 1.短码是否已被申请
        if ( _shortCodeMapping[shortCode] != address(0x0) ) {
            return AddRelationError.ShortCodeExisted;
        }

        /// 2.用户是否已经拥有一个短码
        if ( _addressShotCodeMapping[msg.sender] != bytes6(0x0) ) {
            return AddRelationError.ShortCodeExisted;
        }

        /// 3.自己不能作为自己的推荐人
        if ( recommer == msg.sender )  {
            return AddRelationError.CannotBindYourSelf;
        }

        /// 4.若已经绑定推荐人，不允许修改
        if ( _recommerMapping[msg.sender] != address(0x0) ) {
            return AddRelationError.AlreadyBinded;
        }

        /// 5.如果即将绑定的推荐人本身没有绑定上级,而且不是根地址,不允许绑定（防止出现循环绑定）
        if ( recommer != rootAddress && _recommerMapping[recommer] == address(0x0) ) {
            return AddRelationError.ParentUnbinded;
        }

        /// 累加数量
        totalAddresses++;

        /// 推荐短码未被占用，并且对应地址暂未持有短码
        _shortCodeMapping[shortCode] = msg.sender;
        _addressShotCodeMapping[msg.sender] = shortCode;
        _nickenameMapping[msg.sender] = nickname;

        /// 绑定直推
        _recommerMapping[msg.sender] = recommer;
        _recommerList[recommer].push(msg.sender);

        /// 写入深度
        _depthMapping[msg.sender] = _depthMapping[recommer] + 1;

        return AddRelationError.NoError;
    }

    /// 数据导入
    function importRelation(address owner, address recommer, bytes6 shortcode, bytes16 nickname) external KOwnerOnly {

        /// 累加数量
        totalAddresses++;

        /// 设置短码
        _shortCodeMapping[shortcode] = owner;
        _addressShotCodeMapping[owner] = shortcode;
        _nickenameMapping[owner] = nickname;

        /// 绑定直推
        _recommerMapping[owner] = recommer;
        _recommerList[recommer].push(owner);

        /// 写入深度
        _depthMapping[owner] = _depthMapping[recommer] + 1;
    }
}
