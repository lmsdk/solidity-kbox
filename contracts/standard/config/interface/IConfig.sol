pragma solidity >=0.5.0 <0.6.0;

interface iConfig {

    function getUint(uint k) external view returns (uint);

    /// 必须控制权限
    function setUint(uint k, uint v) external;
}
