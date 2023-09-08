// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../interfaces/standards/composableNft/IERC6220.sol";
import "../../interfaces/standards/composableNft/ITicketingExternalEquip.sol";
import "../../interfaces/standards/composableNft/ITicketingNestableExternalEquip.sol";

import "./TicketingNestable.sol";

/**
 * @title TicketingNestableExternalEquip
 *
 * @notice Smart contract of the Ticketing Nestable External Equippable module.
 * @dev This is a TicketingNestable smart contract with external `Equippable` smart contract for space saving purposes. It is
 *  expected to be deployed along an instance of `TicketingExternalEquip`. To make use of the equippable module with this
 *  contract, the `_setEquippableAddress` function has to be exposed and used to set the corresponding equipment
 *  contract after deployment. Consider using `RbacLock` to lock the equippable address after deployment.
 */
contract TicketingNestableExternalEquip is
    ITicketingNestableExternalEquip,
    TicketingNestable
{
    address private _equippableAddress;

    /**
     * @notice Initializes the contract by setting a `name` and a `symbol` of the token collection.
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     */

    function __TicketingNestableExternalEquip_init(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __TicketingNestableExternalEquip_init_unchained(name_, symbol_);
    }

    /**
     *  @notice It is the initializer function minus the calls to parent initializers. This function can be used to avoid double initialization
     *  @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     */
    function __TicketingNestableExternalEquip_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __TicketingNestable_init(name_, symbol_);
    }

    /**
     * @inheritdoc IERC165Upgradeable
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(IERC165Upgradeable, TicketingNestable)
        returns (bool)
    {
        return
            interfaceId == type(ITicketingNestableExternalEquip).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc TicketingNestable
     */
    function _transferChild(
        uint256 tokenId,
        address to,
        uint256 destinationId,
        uint256 childIndex,
        address childAddress,
        uint256 childId,
        bool isPending,
        bytes memory data
    ) internal virtual override {
        if (!isPending) {
            _requireMinted(tokenId);
            if (
                IERC6220(_equippableAddress).isChildEquipped(
                    tokenId,
                    childAddress,
                    childId
                )
            ) revert TicketingMustUnequipFirst();
        }

        super._transferChild(
            tokenId,
            to,
            destinationId,
            childIndex,
            childAddress,
            childId,
            isPending,
            data
        );
    }

    /**
     * @notice Used to set the address of the `Equippable` smart contract.
     * @dev Emits ***EquippableAddressSet*** event.
     * @param equippable Address of the `Equippable` smart contract
     */
    function _setEquippableAddress(address equippable) internal virtual {
        address oldAddress = _equippableAddress;
        _equippableAddress = equippable;
        emit EquippableAddressSet(oldAddress, equippable);
    }

    /**
     * @inheritdoc ITicketingNestableExternalEquip
     */
    function getEquippableAddress() external view virtual returns (address) {
        return _equippableAddress;
    }

    /**
     * @notice Use to Deposit the balance of different tokens
     * @param _amount amount of the token
     * @param _token address of the token
     */

    /**
     * @inheritdoc ITicketingNestableExternalEquip
     */
    function isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) external view virtual returns (bool) {
        return _isApprovedOrOwner(spender, tokenId);
    }

    /**
     * @inheritdoc TicketingNestable
     */
    function _cleanApprovals(uint256 tokenId) internal virtual override {
        IERC5773(_equippableAddress).approveForAssets(address(0), tokenId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
