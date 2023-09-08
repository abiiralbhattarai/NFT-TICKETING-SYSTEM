// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "../access/Rbac.sol";
import "../equippable/TicketingEquippable.sol";
import "../soulbound/TicketingSoulbound.sol";
import "../../libraries/TicketingLib.sol";
import "../../libraries/TicketingErrors.sol";
import "./TicketingMintingUtils.sol";
import "./TicketingTokenURI.sol";

/**
 * @title TicketingRenderUtils
 *
 * @notice Smart contract of the Ticketing render utils module.
 * @dev Extra utility functions for Ticketing contracts.
 */
contract TicketingRenderUtils {
    /**
     * @notice Structure used to represent the extended NFT.
     * @return tokenMetadataUri Metadata URI of the specified token
     * @return directOwner Address of the direct owner of the token (smart contract if the token is nested, otherwise
     *  EOA)
     * @return rootOwner Address of the root owner
     * @return activeAssetCount Number of active assets present on the token
     * @return pendingAssetcount Number of pending assets on the token
     * @return priorities The array of priorities of the active asset
     * @return maxSupply The maximum supply of the collection the specified token belongs to
     * @return totalSupply The total supply of the collection the specified token belongs to
     * @return issuer Address of the issuer of the token's collection
     * @return name Name of the collection the token belongs to
     * @return symbol Symbol of the collection the token belongs to
     * @return activeChildrenNumber Number of active child tokens of the given token (only account for direct child
     *  tokens)
     * @return pendingChildrenNumber Number of pending child tokens of the given token (only account for direct child
     *  tokens)
     * @return isSoulbound Boolean value signifying whether the token is soulbound or not
     * @return hasMultiAssetInterface Boolean value signifying whether the toke supports MultiAsset interface
     * @return hasNestingInterface Boolean value signifying whether the toke supports Nestable interface
     * @return hasEquippableInterface Boolean value signifying whether the toke supports Equippable interface
     */
    struct ExtendedNft {
        string tokenMetadataUri;
        address directOwner;
        address rootOwner;
        uint256 activeAssetCount;
        uint256 pendingAssetCount;
        uint64[] priorities;
        uint256 maxSupply;
        uint256 totalSupply;
        address issuer;
        string name;
        string symbol;
        uint256 activeChildrenNumber;
        uint256 pendingChildrenNumber;
        bool isSoulbound;
        bool hasMultiAssetInterface;
        bool hasNestingInterface;
        bool hasEquippableInterface;
    }

    /**
     * @notice Used to get a list of existing token IDs in the range between `pageStart` and `pageSize`.
     * @dev It is not optimized to avoid checking IDs out of max supply nor total supply, since this is not meant to be
     *  used during transaction execution; it is only meant to be used as a getter.
     * @dev The resulting array might be smaller than the given `pageSize` since no-existent IDs are not included.
     * @param target Address of the collection smart contract of the given token
     * @param pageStart The first ID to check
     * @param pageSize The number of IDs to check
     * @return page An array of IDs of the existing tokens
     */
    function getPaginatedMintedIds(
        address target,
        uint256 pageStart,
        uint256 pageSize
    ) public view returns (uint256[] memory page) {
        uint256[] memory tmpIds = new uint[](pageSize);
        uint256 found;
        for (uint256 i = 0; i < pageSize; ) {
            try IERC721Upgradeable(target).ownerOf(pageStart + i) returns (
                address
            ) {
                tmpIds[i] = pageStart + i;
                unchecked {
                    found += 1;
                }
            } catch {
                // do nothing
            }
            unchecked {
                ++i;
            }
        }
        page = new uint256[](found);
        uint256 actualIndex;
        for (uint256 i = 0; i < pageSize; ) {
            if (tmpIds[i] != 0) {
                page[actualIndex] = tmpIds[i];
                unchecked {
                    ++actualIndex;
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Used to get extended information about a specified token.
     * @dev The full `ExtendedNft` struct looks like this:
     *  [
     *      tokenMetadataUri,
     *      directOwner,
     *      rootOwner,
     *      activeAssetCount,
     *      pendingAssetCount
     *      priorities,
     *      maxSupply,
     *      totalSupply,
     *      issuer,
     *      name,
     *      symbol,
     *      activeChildrenNumber,
     *      pendingChildrenNumber,
     *      isSoulbound,
     *      hasMultiAssetInterface,
     *      hasNestingInterface,
     *      hasEquippableInterface
     *  ]
     * @param tokenId ID of the token for which to retireve the `ExtendedNft` struct
     * @param targetCollection Address of the collection to which the specified token belongs to
     * @return data The `ExtendedNft` struct containing the specified token's data
     */
    function getExtendedNft(
        uint256 tokenId,
        address targetCollection
    ) public view returns (ExtendedNft memory data) {
        TicketingEquippable target = TicketingEquippable(targetCollection);
        data.hasMultiAssetInterface = target.supportsInterface(
            type(IERC5773).interfaceId
        );
        data.hasNestingInterface = target.supportsInterface(
            type(IERC6059).interfaceId
        );
        data.hasEquippableInterface = target.supportsInterface(
            type(IERC6220).interfaceId
        );
        if (data.hasNestingInterface) {
            (data.directOwner, , ) = target.directOwnerOf(tokenId);
            data.activeChildrenNumber = target.childrenOf(tokenId).length;
            data.pendingChildrenNumber = target
                .pendingChildrenOf(tokenId)
                .length;
        }
        if (data.hasMultiAssetInterface) {
            data.activeAssetCount = target.getActiveAssets(tokenId).length;
            data.pendingAssetCount = target.getPendingAssets(tokenId).length;
            data.priorities = target.getActiveAssetPriorities(tokenId);
        }
        if (target.supportsInterface(type(IERC6454beta).interfaceId)) {
            data.isSoulbound = !IERC6454beta(targetCollection).isTransferable(
                tokenId,
                address(0),
                address(0)
            );
        }
        data.rootOwner = target.ownerOf(tokenId);
        if (data.directOwner == address(0x0)) {
            data.directOwner = data.rootOwner;
        }
        data.name = target.name();
        try
            IERC721MetadataUpgradeable(targetCollection).tokenURI(tokenId)
        returns (string memory metadataUri_) {
            data.tokenMetadataUri = metadataUri_;
        } catch {
            // Retain default value
        }
        try TicketingMintingUtils(targetCollection).totalSupply() returns (
            uint256 totalSupplly_
        ) {
            data.totalSupply = totalSupplly_;
        } catch {
            // Retain default value
        }
        try TicketingMintingUtils(targetCollection).maxSupply() returns (
            uint256 maxSupplly_
        ) {
            data.maxSupply = maxSupplly_;
        } catch {
            // Retain default value
        }
        try Rbac(targetCollection).actualOwner() returns (address issuer_) {
            data.issuer = issuer_;
        } catch {
            // Retain default value
        }
        data.symbol = target.symbol();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
