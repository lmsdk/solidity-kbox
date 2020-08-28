pragma solidity >=0.5.0 <0.6.0;

import "./library/NearestValue.sol";
import "./library/SafeMath.sol";

/// @title 合约主权限控制
contract KOwnerable {

    /// @dev 可以访问定义为KAPIMethod方法的地址列表
    address[] internal _authAddress;

    /// @notice 具备Owner权限的地址列表
    address[] public KContractOwners;

    /// @dev 防重入锁
    bool private _call_locked;

    constructor() public {
        KContractOwners.push(msg.sender);
    }

    /// @notice 获取当前可以访问合约API方法的地址列表
    function KAuthAddresses() external view returns (address[] memory) {
        return _authAddress;
    }

    /// @notice 增加一个授权地址
    /// @param auther 需要增加授权的地址
    function KAddAuthAddress(address auther) external KOwnerOnly {
        _authAddress.push(auther);
    }

    /// @notice 移除某个授权地址
    /// @param auther 需要移除的授权地址
    function KDelAuthAddress(address auther) external KOwnerOnly {
        for (uint i = 0; i < _authAddress.length; i++) {
            if (_authAddress[i] == auther) {
                for (uint j = 0; j < _authAddress.length - 1; j++) {
                    _authAddress[j] = _authAddress[j+1];
                }
                delete _authAddress[_authAddress.length - 1];
                _authAddress.pop();
                return ;
            }
        }
    }

    /// @notice 使用该修饰符修饰的函数只能允许 KContractOwners 列表中的地址进行调用
    modifier KOwnerOnly() {
        bool exist = false;
        for ( uint i = 0; i < KContractOwners.length; i++ ) {
            if ( KContractOwners[i] == msg.sender ) {
                exist = true;
                break;
            }
        }
        require(exist); _;
    }

    /// @notice 使用该修饰，禁止合约作为msg.sender，粗暴的防御DAO攻击,一般用于external payable类型的接口方法
    modifier KRejectContractCall() {
        uint256 size;
        address payable safeAddr = msg.sender;
        assembly {size := extcodesize(safeAddr)}
        require( size == 0, "Sender Is Contract" );
        _;
    }

    /// @dev 若接口方法为external payable，则必须使用KDAODefense修饰，防止重入攻击
    modifier KDAODefense() {
        require(!_call_locked, "DAO_Warning");
        _call_locked = true;
        _;
        _call_locked = false;
    }

    /// @notice 使用该修改器生命对应的方法需要授权才可以调用
    modifier KDelegateMethod() {
        bool exist = false;
        for (uint i = 0; i < _authAddress.length; i++) {
            if ( _authAddress[i] == msg.sender ) {
                exist = true;
                break;
            }
        }
        require(exist, "NotAuth"); _;
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 */
contract KPausable is KOwnerable {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool public paused;

    /**
     * @dev Initialize the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier KWhenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier KWhenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function Pause() public KOwnerOnly KWhenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function Unpause() public KOwnerOnly KWhenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
}

/// @notice 数据持久化分层
/// @dev 所有需要存储的Storage遍历都必须包含在KStorage的派生类中
contract KStorage is KPausable {

    /// @notice 当前逻辑代码合约地址
    address public KImplementAddress;

    /// @notice 更换逻辑代码合约地址
    function SetKImplementAddress(address impl) external KOwnerOnly {
        KImplementAddress = impl;
    }

    /// @notice 合约调用转发
    function () external {
        address impl_address = KImplementAddress;
        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(sub(gas(), 10000), impl_address, 0x0, calldatasize(), 0, 0)
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
            case 0 {
                revert(0, retSz)
            }
            default {
                return(0, retSz)
            }
        }
    }
}

contract KStoragePayable is KPausable {

    /// @notice 当前逻辑代码合约地址
    address public KImplementAddress;

    /// @notice 更换逻辑代码合约地址
    function SetKImplementAddress(address impl) external KOwnerOnly {
        KImplementAddress = impl;
    }

    /// @notice 合约调用转发
    function () external payable {
        address impl_address = KImplementAddress;
        assembly {

            /// 若没有附带data信息，说明很可能能是直接对该合约进行ether转账
            if eq(calldatasize(), 0) {
                return(0, 0)
            }

            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(gas(), impl_address, 0x0, calldatasize(), 0, 0)
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
            case 0 {
                revert(0, retSz)
            }
            default {
                return(0, retSz)
            }
        }
    }
}
