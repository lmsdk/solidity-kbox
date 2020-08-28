pragma solidity >=0.5.0 <0.6.0;

import "../../core/k.sol";
import "../../core/library/SafeMath.sol";
import "../relations/interface/IRelations.sol";

import "./interface/IAchievement.sol";

contract Achievement_ValidAddressStorage is KStorage{

    /*
    * @dev 最大统计层级，不宜太大
    */
    uint public eachDeep = 15;

    /*
    * @dev 业绩信息记录表
    */
    mapping(address => AchievementInfo) public achievementInfoMapping;
    struct AchievementInfo {
        /// 直接推荐
        uint direct;
        /// 间接推荐
        uint indirect;
        /// 自身有效
        bool isvaild;
    }

    /**
     * @dev Constructor.
     */
    constructor(
        iRelations _irlts,
        uint _echDeep
    ) public {
        _iRelations = _irlts;
        eachDeep = _echDeep;
    }

    iRelations internal _iRelations;
}

contract Achievement_ValidAddress is iAchievement,Achievement_ValidAddressStorage(iRelations(0x0), 0) {

    using SafeMath for uint;

    function increaseDelegate(address recipient, uint addedValue) external KDelegateMethod returns (bool) {

        /// 不允许重复添加
        if ( achievementInfoMapping[recipient].isvaild ) {
            return true;
        }

        achievementInfoMapping[recipient].isvaild = true;

        achievementInfoMapping[recipient].direct = achievementInfoMapping[recipient].direct.add(addedValue);

        address relationRoot = _iRelations.rootAddress();

        for (
            (address parent, uint d) = (_iRelations.getIntroducer(recipient), 0);
            parent != relationRoot && parent != address(0) && d < eachDeep;
            (d++, parent = _iRelations.getIntroducer(parent))
        ) {
            achievementInfoMapping[parent].indirect = achievementInfoMapping[parent].indirect.add(addedValue);
        }

        return true;
    }

    /// 不支持
    function decreaseDelegate(address, uint) external KDelegateMethod returns (bool) {
        require(false, "UnsupportOpertion");
        return false;
    }

    /// 有效业绩,例如计算收益等
    function achievementOf(address recipient) external view returns (uint) {
        return achievementInfoMapping[recipient].direct;
    }
}
