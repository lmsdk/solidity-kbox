pragma solidity >=0.5.0 <0.6.0;

interface iRelations {

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

    /////////////////////////////////////////////////////////////////////////////
    //                                Storage                                  //
    /////////////////////////////////////////////////////////////////////////////
    /// 地址总数
    function totalAddresses() external view returns (uint);

    /// 根地址
    function rootAddress() external view returns (address);

    /////////////////////////////////////////////////////////////////////////////
    //                                  View                                   //
    /////////////////////////////////////////////////////////////////////////////
    /// 获取我的推荐人，也就是介绍人
    function getIntroducer(address owner) external view returns (address);

    /// 获取推荐列表
    function recommendList(address owner) external view returns (address[] memory);

    /// 查询短推荐码绑定的钱包地址
    function shortCodeToAddress(bytes6 shortCode) external view returns (address);

    /// 查询地址对应的短推荐码
    function addressToShortCode(address addr) external view returns (bytes6);

    /// 查询昵称数据
    function addressToNickName(address addr) external view returns (bytes16);

    ///获取地址所在深度
    function depth(address addr) external view returns (uint);

    /////////////////////////////////////////////////////////////////////////////
    //                                  Write                                  //
    /////////////////////////////////////////////////////////////////////////////
    /// 注册短推荐码，长度限制为6，内容为大写字母+数字
    function registerShortCode(bytes6 shortCode ) external returns (bool);

    /// 更新昵称
    function updateNickName(bytes16 nickName) external;

    /// 新增绑定关系
    function addRelation(address recommer) external returns (AddRelationError);

    /// 绑定推荐人并且生产自己短码同时设置昵称
    function addRelationEx(address recommer, bytes6 shortCode, bytes16 nickname) external returns (AddRelationError);

    /// 数据导入专用方法
    function importRelation(address owner, address recommer, bytes6 shortcode, bytes16 nickname) external;
}
