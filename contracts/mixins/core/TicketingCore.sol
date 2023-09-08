// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "./ITicketingCore.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title TicketingCore
 *
 * @notice Smart contract of the Ticketing core module.
 * @dev This is currently just a passthrough contract which allows for granular editing of base-level ERC721 functions.
 */

contract TicketingCore is ITicketingCore, Initializable {
    /**
     * @notice Version of the @Ticketing-team/evm-contracts package
     * @return Version identifier of the smart contract
     */
    string public constant VERSION = "1.1.0";
    bytes4 public constant Ticketing_INTERFACE = 0x524D524B; // "Ticketing" in ASCII hex

    /**
     * @notice Used to initialize the smart contract.
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     */

    function __TicketingCore_init(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __TicketingCore_init_unchained(name_, symbol_);
    }

    /**
     * @notice It is the initializer function minus the calls to parent initializers. This function can be used to avoid double initialization
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     */
    function __TicketingCore_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /// Token name
    string private _name;

    /// Token symbol
    string private _symbol;

    /**
     * @notice Used to retrieve the collection name.
     * @return Name of the collection
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @notice Used to retrieve the collection symbol.
     * @return Symbol of the collection
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Hook that is called before any token transfer. This includes minting and burning.
     * @dev Calling conditions:
     *
     *  - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be transferred to `to`.
     *  - When `from` is zero, `tokenId` will be minted to `to`.
     *  - When `to` is zero, ``from``'s `tokenId` will be burned.
     *  - `from` and `to` are never zero at the same time.
     *
     *  To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     * @param from Address from which the token is being transferred
     * @param to Address to which the token is being transferred
     * @param tokenId ID of the token being transferred
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @notice Hook that is called after any transfer of tokens. This includes minting and burning.
     * @dev Calling conditions:
     *
     *  - When `from` and `to` are both non-zero.
     *  - `from` and `to` are never zero at the same time.
     *
     *  To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     * @param from Address from which the token has been transferred
     * @param to Address to which the token has been transferred
     * @param tokenId ID of the token that has been transferred
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
