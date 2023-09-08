// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/metatx/MinimalForwarderUpgradeable.sol";

import "./mixins/equippable/TicketingExternalEquip.sol";

/**
 * @title TicketingExternalEquipImpl
 *
 * @notice Implementation of Ticketing external equip module.
 */
contract TicketingExternalEquipImpl is TicketingExternalEquip {
    uint256 private _totalAssets;

    /**
     * @notice Used to initialize the smart contract.
     * @param nestableAddress Address of the Nestable module of external equip composite
     *  @param forwarder_ address of the MinimalForwarderUpgradeable
     */

    function __TicketingExternalEquipImpl_init(
        address nestableAddress,
        MinimalForwarderUpgradeable forwarder_
    ) public initializer {
        __TicketingExternalEquipImpl_init_unchained(
            nestableAddress,
            forwarder_
        );
    }

    /**
     * @notice Used to initialize the smart contract.
     * @param nestableAddress Address of the Nestable module of external equip composite
     *  @param forwarder_ address of the MinimalForwarderUpgradeable
     */
    function __TicketingExternalEquipImpl_init_unchained(
        address nestableAddress,
        MinimalForwarderUpgradeable forwarder_
    ) internal onlyInitializing {
        __TicketingExternalEquip_init(nestableAddress, address(forwarder_));
    }

    /**
     * @notice Used to set the address of the `Nestable` smart contract.
     * @param nestableAddress Address of the `Nestable` smart contract
     */
    function setNestableAddress(
        address nestableAddress
    ) external onlyContractAdmin {
        _setNestableAddress(nestableAddress);
    }

    /**
     * @notice Used to add an asset to a token.
     * @dev If the given asset is already added to the token, the execution will be reverted.
     * @dev If the asset ID is invalid, the execution will be reverted.
     * @dev If the token already has the maximum amount of pending assets (128), the execution will be
     *  reverted.
     * @param tokenId ID of the token to add the asset to
     * @param assetId ID of the asset to add to the token
     * @param replacesAssetWithId ID of the asset to replace from the token's list of active assets
     */
    function addAssetToToken(
        uint256 tokenId,
        uint64 assetId,
        uint64 replacesAssetWithId
    ) public virtual onlyContractAdmin {
        _addAssetToToken(tokenId, assetId, replacesAssetWithId);
    }

    /**
     * @notice Used to add an equippable asset entry.
     * @dev The ID of the asset is automatically assigned to be the next available asset ID.
     * @param equippableGroupId ID of the equippable group
     * @param catalogAddress Address of the `Catalog` smart contract this asset belongs to
     * @param metadataURI Metadata URI of the asset
     * @param partIds An array of IDs of fixed and slot parts to be included in the asset
     * @return The total number of assets after this asset has been added
     */
    function addEquippableAssetEntry(
        uint64 equippableGroupId,
        address catalogAddress,
        string memory metadataURI,
        uint64[] memory partIds
    ) public virtual onlyContractAdmin returns (uint256) {
        unchecked {
            ++_totalAssets;
        }
        _addAssetEntry(
            uint64(_totalAssets),
            equippableGroupId,
            catalogAddress,
            metadataURI,
            partIds
        );
        return _totalAssets;
    }

    /**
     * @notice Used to add a asset entry.
     * @dev The ID of the asset is automatically assigned to be the next available asset ID.
     * @param metadataURI Metadata URI of the asset
     * @return ID of the newly added asset
     */
    function addAssetEntry(
        string memory metadataURI
    ) public virtual onlyContractAdmin returns (uint256) {
        unchecked {
            ++_totalAssets;
        }
        _addAssetEntry(uint64(_totalAssets), metadataURI);
        return _totalAssets;
    }

    /**
     * @notice Used to declare that the assets belonging to a given `equippableGroupId` are equippable into the `Slot`
     *  associated with the `partId` of the collection at the specified `parentAddress`
     * @param equippableGroupId ID of the equippable group
     * @param parentAddress Address of the parent into which the equippable group can be equipped into
     * @param partId ID of the `Slot` that the items belonging to the equippable group can be equipped into
     */
    function setValidParentForEquippableGroup(
        uint64 equippableGroupId,
        address parentAddress,
        uint64 partId
    ) public virtual onlyContractAdmin {
        _setValidParentForEquippableGroup(
            equippableGroupId,
            parentAddress,
            partId
        );
    }

    /**
     * @notice Used to retrieve the total number of assets.
     * @return The total number of assets
     */
    function totalAssets() public view virtual returns (uint256) {
        return _totalAssets;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
