pragma solidity >=0.5.0 <0.6.0;

import "../../core/k.sol";
import "../../core/library/SafeMath.sol";

import "./interface/IAchievement.sol";

contract Achievement_AssertStorage is KStorage {

    /*
    * @dev 进入数值的倍数，increaseDelegate中v参数需要乘算该值
    */
    uint public multiple = 3;

    /*
    * @dev 业绩信息记录表
    */
    mapping(address => AchievementInfo) public achievementInfoMapping;
    struct AchievementInfo {
        /// 总量
        uint total;
    }

    /**
     * @dev Constructor.
     */
    constructor(
        uint _multiple
    ) public {
        multiple = _multiple;
    }
}

contract Achievement_Assert is iAchievement,Achievement_AssertStorage(0) {

    using SafeMath for uint;

    function increaseDelegate(address recipient, uint addedValue) external KDelegateMethod returns (bool) {
        achievementInfoMapping[recipient].total = achievementInfoMapping[recipient].total.add(addedValue.mul(multiple));
        return true;
    }

    /// 不支持
    function decreaseDelegate(address recipient, uint subtractedValue) external KDelegateMethod returns (bool) {
        achievementInfoMapping[recipient].total = achievementInfoMapping[recipient].total.sub(subtractedValue);
    }

    /// 有效业绩,例如计算收益等
    function achievementOf(address recipient) external view returns (uint) {
        return achievementInfoMapping[recipient].total;
    }
}
