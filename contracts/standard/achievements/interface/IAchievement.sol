pragma solidity >=0.5.0 <0.6.0;

/*
* @dev 业绩记录抽象接口
*/
interface iAchievement {

    /// 必须使用 KDelegateMethod 修改器
    function increaseDelegate(address recipient, uint addedValue) external returns (bool);

    /// 必须使用 KDelegateMethod 修改器
    function decreaseDelegate(address recipient, uint subtractedValue) external returns (bool);

    function achievementOf(address recipient) external view returns (uint);
}
