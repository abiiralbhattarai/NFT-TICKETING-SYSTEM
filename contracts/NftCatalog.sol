// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.18;

import "./mixins/access/RbacLock.sol";
import "./mixins/catalog/TicketingCatalog.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title TicketingCatalogImpl
 *
 * @notice Implementation of Ticketing catalog.
 * @dev Contract for storing 'catalog' elements of NFTs to be accessed by instances of TicketingAsset implementing contracts.
 *  This default implementation includes an RbacLock dependency, which allows the deployer to freeze the state of the
 *  catalog contract.
 */
contract NftCatalog is Initializable, RbacLock, TicketingCatalog {
    /**
     * @notice Used to initialize the smart contract.
     * @param metadataURI Base metadata URI of the contract
     * @param forwarder_ address of the MinimalForwarderUpgradeable
     * @param type_ The type of the catalog
     */
    function ___NftCatalog_init(
        string memory metadataURI,
        address forwarder_,
        string memory type_
    ) external initializer {
        __Rbac_init(msg.sender, forwarder_);
        TicketingCatalog.initializeTicketingCatalog(metadataURI, type_);
    }

    /**
     * @notice Used to add a single `Part` to storage.
     * @dev The full `IntakeStruct` looks like this:
     *  [
     *          partID,
     *      [
     *          itemType,
     *          z,
     *          [
     *               permittedCollectionAddress0,
     *               permittedCollectionAddress1,
     *               permittedCollectionAddress2
     *           ],
     *           metadataURI
     *       ]
     *   ]
     * @param intakeStruct `IntakeStruct` struct consisting of `partId` and a nested `Part` struct
     */
    function addPart(
        IntakeStruct calldata intakeStruct
    ) public virtual onlyContractAdmin notLocked {
        _addPart(intakeStruct);
    }

    /**
     * @notice Used to add multiple `Part`s to storage.
     * @dev The full `IntakeStruct` looks like this:
     *  [
     *          partID,
     *      [
     *          itemType,
     *          z,
     *          [
     *               permittedCollectionAddress0,
     *               permittedCollectionAddress1,
     *               permittedCollectionAddress2
     *           ],
     *           metadataURI
     *       ]
     *   ]
     * @param intakeStructs[] An array of `IntakeStruct` structs consisting of `partId` and a nested `Part` struct
     */
    function addPartList(
        IntakeStruct[] calldata intakeStructs
    ) public virtual onlyContractAdmin notLocked {
        _addPartList(intakeStructs);
    }

    /**
     * @notice Used to add multiple `equippableAddresses` to a single catalog entry.
     * @dev Can only be called on `Part`s of `Slot` type.
     * @param partId ID of the `Part` that we are adding the equippable addresses to
     * @param equippableAddresses An array of addresses that can be equipped into the `Part` associated with the `partId`
     */
    function addEquippableAddresses(
        uint64 partId,
        address[] calldata equippableAddresses
    ) public virtual onlyContractAdmin {
        _addEquippableAddresses(partId, equippableAddresses);
    }

    /**
     * @notice Function used to set the new list of `equippableAddresses`.
     * @dev Overwrites existing `equippableAddresses`.
     * @dev Can only be called on `Part`s of `Slot` type.
     * @param partId ID of the `Part`s that we are overwiting the `equippableAddresses` for
     * @param equippableAddresses A full array of addresses that can be equipped into this `Part`
     */
    function setEquippableAddresses(
        uint64 partId,
        address[] calldata equippableAddresses
    ) public virtual onlyContractAdmin {
        _setEquippableAddresses(partId, equippableAddresses);
    }

    /**
     * @notice Sets the isEquippableToAll flag to true, meaning that any collection may be equipped into the `Part` with
     *  this `partId`.
     * @dev Can only be called on `Part`s of `Slot` type.
     * @param partId ID of the `Part` that we are setting as equippable by any address
     */
    function setEquippableToAll(
        uint64 partId
    ) public virtual onlyContractAdmin {
        _setEquippableToAll(partId);
    }

    /**
     * @notice Used to remove all of the `equippableAddresses` for a `Part` associated with the `partId`.
     * @dev Can only be called on `Part`s of `Slot` type.
     * @param partId ID of the part that we are clearing the `equippableAddresses` from
     */
    function resetEquippableAddresses(
        uint64 partId
    ) public virtual onlyContractAdmin {
        _resetEquippableAddresses(partId);
    }

    /**
     * @notice Used to change the Metadata URI of the catalog.
     * @param newMetadataURI Base metadata URI of the contract
     */
    function changeMetadataURI(
        string memory newMetadataURI
    ) public virtual onlyContractAdmin {
        _setMetadataURI(newMetadataURI);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
