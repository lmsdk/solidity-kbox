pragma solidity >=0.5.0 <0.6.0;

import "../../../core/k.sol";

import "../../relations/interface/IRelations.sol";
import "../../achievements/Achievement_ValidAddress.sol";

import "./interface/IProfit.sol";

/*
* 推荐奖励，依赖 Achievement_ValidAddress
*/
contract Profit_IntroduceStorage is KStorage {

    /// @dev 定义每个层级获得的奖励比例
    uint[] public proportions = [
        0.30 szabo, 0.20 szabo, 0.10 szabo, 0.05 szabo, 0.05 szabo,
        0.05 szabo, 0.05 szabo, 0.05 szabo, 0.05 szabo, 0.05 szabo,
        0.05 szabo, 0.05 szabo, 0.05 szabo, 0.10 szabo, 0.20 szabo
    ];

    uint public allProfitVaildCount = 6;

    iRelations internal _iRelations;
    Achievement_ValidAddress internal _iAchievement;

    /**
     * @dev Constructor.
     */
    constructor(
        iRelations _irlts,
        Achievement_ValidAddress _iacvt,
        uint[] memory _props
    ) public {
        _iRelations = _irlts;
        _iAchievement = _iacvt;
        proportions = _props;
    }
}

contract Profit_Introduce is iProfit, Profit_IntroduceStorage(iRelations(0x0), Achievement_ValidAddress(0x0), new uint[](0)) {

    /*
    * @dev 获取计算周期
    */
    function cycle() external view returns (CycleType) {
        return CycleType.Every;
    }

    /*
    * @dev 返回true则会使用计算逻辑计算收益,主要是根据周期判断
    */
    function shoudProfit(address) external view returns (bool) {
        return true;
    }

    /*
    * @dev 真实计算收益,只返回计算结果，不处理资产,在只能合约中所有的收益都应该由sender开始自下而上处理
    * @return recipients 获得确切收益地址列表
    * @return profits 获得的收益数值
    */
    function calculationProfit(address realSender, uint, uint v) external view returns (address[] memory recipients, uint[] memory profits) {

        recipients = new address[](proportions.length);
        profits = new uint[](profits.length);

        address relationRoot = _iRelations.rootAddress();

        for (
            (address parent, uint d) = (_iRelations.getIntroducer(realSender), 0);
            parent != relationRoot && parent != address(0) && d < proportions.length;
            (parent = _iRelations.getIntroducer(parent), d++)
        ) {
            /// 判断对应的parent层级是否可以获得奖励
            uint parentVaildAddress = _iAchievement.achievementOf(parent);
            if ( parentVaildAddress >= allProfitVaildCount ||
                 parentVaildAddress >= d
            ) {
                recipients[d] = parent;
                profits[d] = v * proportions[d] / 1 szabo;
            }
        }
    }

    /// 无视其他条件直接计算最大层级奖励
    function calculationProfitAll(address realSender, uint v) external view returns (address[] memory recipients, uint[] memory profits) {

        recipients = new address[](proportions.length);
        profits = new uint[](profits.length);

        address relationRoot = _iRelations.rootAddress();

        for (
            (address parent, uint d) = (_iRelations.getIntroducer(realSender), 0);
            parent != relationRoot && parent != address(0) && d < proportions.length;
            (parent = _iRelations.getIntroducer(parent), d++)
        ) {
            /// 判断对应的parent层级是否可以获得奖励
            recipients[d] = parent;
            profits[d] = v * proportions[d] / 1 szabo;
        }
    }
}
