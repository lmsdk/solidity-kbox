pragma solidity >=0.5.0 <0.6.0;

interface iProfit {

    enum CycleType {
        Every, /// 及时生产周期，每次调用API都可能会生产收益
        TimeInterval, /// 按照间隔时间为周期
        Deadline /// 直到到达最后时间一次性获得的周期
    }

    /*
    * @dev 获取计算周期
    */
    function cycle() external view returns (CycleType);

    /*
    * @dev 返回true则会使用计算逻辑计算收益,主要是根据周期判断
    */
    function shoudProfit(address realSender) external view returns (bool);

    /*
    * @dev 真实计算收益,只返回计算结果，不处理资产,在只能合约中所有的收益都应该由sender开始自下而上处理
    * @return recipients 获得确切收益地址列表
    * @return profits 获得的收益数值
    */
    function calculationProfit(address realSender, uint time, uint v) external view returns (address[] memory recipients, uint[] memory profits);
}
