// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "./IERC6220.sol";

/**
 * @title ITicketingExternalEquip
 *
 * @notice Interface smart contract of the Ticketing external equippable module.
 */
interface ITicketingExternalEquip is IERC6220 {
    /**
     * @notice Used to notify listeners of a new `Nestable` associated  smart contract address being set.
     * @dev When initially setting the `Nestable` smart contract address, the `old` value should equal `0x0` address.
     * @param old Previous `Nestable` smart contract address
     * @param new_ New `Nestable` smart contract address
     */
    event NestableAddressSet(address old, address new_);

    /**
     * @notice Returns the Equippable contract's corresponding nestable address.
     * @return Address of the Nestable module of the external equip composite
     */
    function getNestableAddress() external view returns (address);
}
