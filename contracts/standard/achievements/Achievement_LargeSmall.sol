pragma solidity >=0.5.0 <0.6.0;

import "../../core/k.sol";
import "../../core/library/SafeMath.sol";
import "../relations/interface/IRelations.sol";

import "./interface/IAchievement.sol";

contract Achievement_LargeSmallStorage is KStorage{

    /*
    * @dev 最大统计层级，不宜太大
    */
    uint public eachDeep = 15;

    /*
    * @dev 业绩信息记录表
    */
    mapping(address => AchievementInfo) public achievementInfoMapping;
    struct AchievementInfo {
        /// 自身
        uint itself;
        /// 最大的一个结点的数值
        uint large;
        /// 其余结点的总和
        uint total;
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

contract Achievement_LargeSmall is iAchievement, Achievement_LargeSmallStorage(iRelations(0x0), 0) {

    using SafeMath for uint;

    /// 重建指定地址的业绩数据
    function _reconstruction(address recipient) internal {

        address[] memory recommendedList = _iRelations.recommendList(recipient);

        AchievementInfo memory newInfo = AchievementInfo(
            achievementInfoMapping[recipient].itself,///itself
            0,///large
            0 ///total
        );

        for ( uint i = 0; i < recommendedList.length; i++ ) {

            uint childValue = achievementInfoMapping[recommendedList[i]].itself;

            newInfo.total = newInfo.total.add(childValue);

            if ( newInfo.large < childValue ) {
                newInfo.large = childValue;
            }
        }

        /// 写入最终结果
        achievementInfoMapping[recipient] = newInfo;
    }

    function increaseDelegate(address recipient, uint addedValue) external KDelegateMethod returns (bool) {

        address relationRoot = _iRelations.rootAddress();

        /// 追加自身业绩
        achievementInfoMapping[recipient].itself = achievementInfoMapping[recipient].itself.add(addedValue);

        /// 处理其他业绩
        for (
            (address child, address parent, uint d) = (recipient, _iRelations.getIntroducer(recipient), 0);
            parent != relationRoot && parent != address(0) && d < eachDeep;
            (d++, child = parent, parent = _iRelations.getIntroducer(child) )
        ) {
            /// 孩子结点的数值
            uint childValue = achievementInfoMapping[child].itself;

            /// 上级直接追加数据
            achievementInfoMapping[parent].itself = achievementInfoMapping[parent].itself.add(addedValue);
            achievementInfoMapping[parent].total = achievementInfoMapping[parent].total.add(addedValue);

            if ( childValue > achievementInfoMapping[parent].large ) {
                achievementInfoMapping[parent].large = childValue;
            }
        }

        return true;
    }

    function decreaseDelegate(address recipient, uint subtractedValue) external KDelegateMethod returns (bool) {

        address relationRoot = _iRelations.rootAddress();

        /// 追加自身业绩
        achievementInfoMapping[recipient].itself = achievementInfoMapping[recipient].itself.sub(subtractedValue);

        /// 处理其他业绩
        for (
            (address child, address parent, uint d) = (recipient, _iRelations.getIntroducer(recipient), 0);
            parent != relationRoot && parent != address(0) && d < eachDeep;
            (d++, child = parent, parent = _iRelations.getIntroducer(child) )
        ) {
            /// 防止越界
            if ( achievementInfoMapping[parent].itself >= subtractedValue ) {
                achievementInfoMapping[parent].itself = achievementInfoMapping[parent].itself.sub(subtractedValue);
            } else {
                achievementInfoMapping[parent].itself = 0;
            }
        }

        return true;
    }

    /// 有效业绩,例如计算收益等
    function achievementOf(address recipient) external view returns (uint) {
        AchievementInfo memory info = achievementInfoMapping[recipient];
        return info.total.sub(info.large);
    }

    /// 获取大区业绩
    function largeAchievementOf(address recipient) external view returns (uint) {
        return achievementInfoMapping[recipient].large;
    }
}
