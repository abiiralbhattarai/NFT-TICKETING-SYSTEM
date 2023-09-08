// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../../libraries/TicketingErrors.sol";

/**
 * @title TicketingRoyalties
 *
 * @notice Smart contract of the Ticketing Royalties module.
 */
abstract contract TicketingRoyalties is Initializable, IERC2981Upgradeable {
    address private _royaltyRecipient;
    uint256 private _royaltyPercentageBps;

    /**
     * @notice Used to initiate the smart contract.
     * @dev `royaltyPercentageBps` is expressed in basis points, so 1 basis point equals 0.01% and 500 basis points
     *  equal 5%.
     * @param royaltyRecipient Address to which royalties should be sent
     * @param royaltyPercentageBps The royalty percentage expressed in basis points
     */

    function __TicketingRoyalties_init(
        address royaltyRecipient,
        uint256 royaltyPercentageBps
    ) internal onlyInitializing {
        __TicketingRoyalties_init_unchained(
            royaltyRecipient,
            royaltyPercentageBps
        );
    }

    /**
     *  @notice It is the initializer function minus the calls to parent initializers. This function can be used to avoid double initialization
     * @param royaltyRecipient Address to which royalties should be sent
     * @param royaltyPercentageBps The royalty percentage expressed in basis points
     */
    function __TicketingRoyalties_init_unchained(
        address royaltyRecipient,
        uint256 royaltyPercentageBps
    ) internal onlyInitializing {
        _setRoyaltyRecipient(royaltyRecipient);
        if (royaltyPercentageBps >= 10000) revert TicketingRoyaltiesTooHigh();
        _royaltyPercentageBps = royaltyPercentageBps;
    }

    /**
     * @notice Used to update recipient of royalties.
     * @dev Custom access control has to be implemented to ensure that only the intended actors can update the
     *  beneficiary.
     * @param newRoyaltyRecipient Address of the new recipient of royalties
     */
    function updateRoyaltyRecipient(
        address newRoyaltyRecipient
    ) external virtual;

    /**
     * @notice Used to update the royalty recipient.
     * @param newRoyaltyRecipient Address of the new recipient of royalties
     */
    function _setRoyaltyRecipient(address newRoyaltyRecipient) internal {
        _royaltyRecipient = newRoyaltyRecipient;
    }

    /**
     * @notice Used to retrieve the recipient of royalties.
     * @return Address of the recipient of royalties
     */
    function getRoyaltyRecipient() public view virtual returns (address) {
        return _royaltyRecipient;
    }

    /**
     * @notice Used to retrieve the specified royalty percentage.
     * @return The royalty percentage expressed in the basis points
     */
    function getRoyaltyPercentage() public view virtual returns (uint256) {
        return _royaltyPercentageBps;
    }

    /**
     * @notice Used to retrieve the information about who shall receive royalties of a sale of the specified token and
     *  how much they will be.
     * @param tokenId ID of the token for which the royalty info is being retrieved
     * @param salePrice Price of the token sale
     * @return receiver The beneficiary receiving royalties of the sale
     * @return royaltyAmount The value of the royalties recieved by the `receiver` from the sale
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    )
        external
        view
        virtual
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royaltyRecipient;
        royaltyAmount = (salePrice * _royaltyPercentageBps) / 10000;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
