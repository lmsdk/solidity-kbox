pragma solidity >=0.5.0 <0.6.0;

import "./core/k.sol";
import "./standard/tokens/ERC777_1Token.sol";

/// 资产发行总量为1EE保证充足
contract RubAssertStorage is ERC777_1TokenStorage("Rub Assert Token", "RUBT", 18, 100000000000000000 * 10 ** 18) {

}

contract RubAssert is iERC777_1Interface, ERC777_1Token, RubAssertStorage {

    /// 屏蔽普通地址的转账功能，和操作员授权功能，合约内部使用operatorSend来转移资产
    function send(address, uint, bytes calldata) external {
        require(false, "NotSupported");
    }

    function transferFrom(address, address, uint) external KWhenNotPaused returns (bool) {
        require(false, "NotSupported");
    }

    function transfer(address, uint) external KWhenNotPaused returns (bool) {
        require(false, "NotSupported");
    }

    function authorizeOperator(address) external {
        require(false, "NotSupported");
    }
}
