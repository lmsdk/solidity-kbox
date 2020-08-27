pragma solidity >=0.5.0 <0.6.0;

import "../../core/k.sol";
import "../../core/library/SafeMath.sol";
import "./interface/IConfig.sol";

contract ConfigStorage is KStorage {
    mapping(uint => uint) internal _kvmapping;
}

contract Config is iConfig, ConfigStorage {

    function getUint(uint k) external view returns (uint) {
        return _kvmapping[k];
    }

    /// 必须控制权限
    function setUint(uint k, uint v) external KOwnerOnly {
        _kvmapping[k] = v;
    }
}
