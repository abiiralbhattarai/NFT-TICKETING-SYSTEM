// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title TicketingCollectionMetadata
 *
 * @notice Smart contract of the Ticketing Collection metadata module.
 */
contract TicketingCollectionMetadata is Initializable {
    string private _collectionMetadata;

    /**
     * @notice Used to initialize the contract with the given metadata.
     * @param collectionMetadata_ The collection metadata with which to initialize the smart contract
     */

    function __TicketingCollectionMetadata_init(
        string memory collectionMetadata_
    ) internal onlyInitializing {
        __TicketingCollectionMetadata_init_unchained(collectionMetadata_);
    }

    /**
     *  @notice It is the initializer function minus the calls to parent initializers. This function can be used to avoid double initialization
     * @param collectionMetadata_ The collection metadata with which to initialize the smart contract
     */
    function __TicketingCollectionMetadata_init_unchained(
        string memory collectionMetadata_
    ) internal onlyInitializing {
        _setCollectionMetadata(collectionMetadata_);
    }

    /**
     * @notice Used to set the metadata of the collection.
     * @param newMetadata The new metadata of the collection
     */
    function _setCollectionMetadata(string memory newMetadata) internal {
        _collectionMetadata = newMetadata;
    }

    /**
     * @notice Used to retrieve the metadata of the collection.
     * @return string The metadata URI of the collection
     */
    function collectionMetadata() public view returns (string memory) {
        return _collectionMetadata;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
