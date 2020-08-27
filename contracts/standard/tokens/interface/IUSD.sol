pragma solidity >=0.5.0 <0.6.0;

interface iUSD {

    function totalSupply() external view returns (uint);

    function balanceOf(address who) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    /// USDT 中下面三个方法没有返回值，如果不按照这个ABI，USDT合约调用会revert
    function transfer(address to, uint value) external;

    function approve(address spender, uint value) external;

    function transferFrom(address from, address to, uint value) external;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
