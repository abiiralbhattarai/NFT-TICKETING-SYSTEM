// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "../core/TicketingCore.sol";
import "./IERC6454beta.sol";
import "../../libraries/TicketingErrors.sol";

/**
 * @title TicketingSoulbound
 *
 * @notice Smart contract of the Ticketing Soulbound module.
 */
abstract contract TicketingSoulbound is IERC6454beta, TicketingCore {
    /**
     * @notice Hook that is called before any token transfer. This includes minting and burning.
     * @dev This is a hook ensuring that all transfers of tokens are reverted if the token is soulbound.
     * @dev The only exception of transfers being allowed is when the tokens are minted or when they are being burned.
     * @param from Address from which the token is originating (current owner of the token)
     * @param to Address to which the token would be sent
     * @param tokenId ID of the token that would be transferred
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (!isTransferable(tokenId, from, to))
            revert TicketingCannotTransferSoulbound();

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function isTransferable(
        uint256,
        address from,
        address to
    ) public view virtual returns (bool) {
        return ((from == address(0) || // Exclude minting
            to == address(0)) && from != to); // Exclude Burning // Besides the obvious transfer to self, if both are address 0 (general transferability check), it returns false
    }

    /**
     * @inheritdoc IERC165Upgradeable
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return interfaceId == type(IERC6454beta).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
