// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../libraries/TicketingErrors.sol";
import "../metatx/ERC2771ContextUpgradeable.sol";

/**
 * @title RBAC (Role-Based Access Control)
 * @dev Stores and provides setters and getters for roles and addresses.
 */
contract Rbac is ERC2771ContextUpgradeable {
    address public contractOwner;
    ERC2771ContextUpgradeable _trustedForwarder;
    mapping(address => bool) contractAdminRole;

    /**
     * @notice Used to anounce the transfer of ownership.
     * @param previousOwner Address of the account that transferred their ownership role
     * @param newOwner Address of the account receiving the ownership role
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event contractAdiminAdded(address indexed operator);
    event contractAdiminRevoked(address indexed operator);

    /**
     * @notice Used to initialize the smart contract.
     * @param ownerAddress owner of the contract
     */
    function __Rbac_init(
        address ownerAddress,
        address forwarder_
    ) internal onlyInitializing {
        __Rbac_init_unchained(ownerAddress, forwarder_);
    }

    /**
     * @notice Used to initialize the smart contract.
     * @param ownerAddress owner of the contract
     */
    function __Rbac_init_unchained(
        address ownerAddress,
        address forwarder_
    ) internal onlyInitializing {
        contractOwner = ownerAddress;
        __ERC2771ContextUpgradeable_init(address(forwarder_));
    }

    /**
     * @notice Allow only to the contract owner
     */
    modifier onlyContractOwner() {
        if (actualOwner() != _msgSender()) revert TicketingNotOwner();
        _;
    }

    /**
     * @notice Allow only to the contract Admin
     */
    modifier onlyContractAdmin() {
        if (contractAdminRole[_msgSender()] != true) revert TicketingNotAdmin();
        _;
    }

    /**
     * @notice Used to add admin
     * @param _adminAddress address
     */
    function addAdminRole(address _adminAddress) public onlyContractOwner {
        contractAdminRole[_adminAddress] = true;
        emit contractAdiminAdded(_adminAddress);
    }

    /**
     * @notice Used to revoke admin
     * @param _adminAddress address
     */
    function revokeAdminRole(address _adminAddress) public onlyContractOwner {
        contractAdminRole[_adminAddress] = false;
        emit contractAdiminRevoked(_adminAddress);
    }

    /**
     * @notice Leaves the contract without owner. Functions using the `onlyContractAdmin` modifier will be disabled.
     * @dev Can only be called by the current owner.
     * @dev Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is
     *  only available to the owner.
     */
    function renounceOwnership() public virtual onlyContractAdmin {
        _transferOwnership(address(0));
    }

    /**
     * @notice Transfers ownership of the contract to a new owner.
     * @dev Can only be called by the current owner.
     * @param newOwner Address of the new owner's account
     */
    function transferOwnership(
        address newOwner
    ) public virtual onlyContractAdmin {
        if (newOwner == address(0)) revert TicketingNewOwnerIsZeroAddress();
        _transferOwnership(newOwner);
    }

    /**
     * @notice Transfers ownership of the contract to a new owner.
     * @dev Internal function without access restriction.
     * @dev Emits ***OwnershipTransferred*** event.
     * @param newOwner Address of the new owner's account
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = contractOwner;
        contractOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @notice Returns the address of the current owner.
     * @return Address of the current owner
     */
    function actualOwner() public view virtual returns (address) {
        return contractOwner;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
