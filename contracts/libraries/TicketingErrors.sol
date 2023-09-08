// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

/// @title TicketingErrors
/// @notice A collection of errors used in the Ticketing suite
/// @dev Errors are kept in a centralised file in order to provide a central point of reference and to avoid error
///  naming collisions due to inheritance

/// Attempting to grant the token to 0x0 address
error ERC721AddressZeroIsNotaValidOwner();
/// Attempting to grant approval to the current owner of the token
error ERC721ApprovalToCurrentOwner();
/// Attempting to grant approval when not being owner or approved for all should not be permitted
error ERC721ApproveCallerIsNotOwnerNorApprovedForAll();
/// Attempting to get approvals for a token owned by 0x0 (considered non-existent)
error ERC721ApprovedQueryForNonexistentToken();
/// Attempting to grant approval to self
error ERC721ApproveToCaller();
/// Attempting to use an invalid token ID
error ERC721InvalidTokenId();
/// Attempting to mint to 0x0 address
error ERC721MintToTheZeroAddress();
/// Attempting to manage a token without being its owner or approved by the owner
error ERC721NotApprovedOrOwner();
/// Attempting to mint an already minted token
error ERC721TokenAlreadyMinted();
/// Attempting to transfer the token from an address that is not the owner
error ERC721TransferFromIncorrectOwner();
/// Attempting to safe transfer to an address that is unable to receive the token
error ERC721TransferToNonReceiverImplementer();
/// Attempting to transfer the token to a 0x0 address
error ERC721TransferToTheZeroAddress();
/// Attempting to grant approval of assets to their current owner
error TicketingApprovalForAssetsToCurrentOwner();
/// Attempting to grant approval of assets without being the caller or approved for all
error TicketingApproveForAssetsCallerIsNotOwnerNorApprovedForAll();
/// Attempting to incorrectly configue a Catalog item
error TicketingBadConfig();
/// Attempting to set the priorities with an array of length that doesn't match the length of active assets array
error TicketingBadPriorityListLength();
/// Attempting to add an asset entry with `Part`s, without setting the `Catalog` address
error TicketingCatalogRequiredForParts();
/// Attempting to transfer a soulbound (non-transferrable) token
error TicketingCannotTransferSoulbound();
/// Attempting to accept a child that has already been accepted
error TicketingChildAlreadyExists();
/// Attempting to interact with a child, using index that is higher than the number of children
error TicketingChildIndexOutOfRange();
/// Attempting to find the index of a child token on a parent which does not own it.
error TicketingChildNotFoundInParent();
/// Attempting to pass collaborator address array and collaborator permission array of different lengths
error TicketingCollaboratorArraysNotEqualLength();
/// Attempting to register a collection that is already registered
error TicketingCollectionAlreadyRegistered();
/// Attempting to manage or interact with colleciton that is not registered
error TicketingCollectionNotRegistered();
/// Attempting to equip a `Part` with a child not approved by the Catalog
error TicketingEquippableEquipNotAllowedByCatalog();
/// Attempting to use ID 0, which is not supported
/// @dev The ID 0 in Ticketing suite is reserved for empty values. Guarding against its use ensures the expected operation
error TicketingIdZeroForbidden();
/// Attempting to interact with an asset, using index greater than number of assets
error TicketingIndexOutOfRange();
/// Attempting to reclaim a child that can't be reclaimed
error TicketingInvalidChildReclaim();
/// Attempting to interact with an end-user account when the contract account is expected
error TicketingIsNotContract();
/// Attempting to interact with a contract that had its operation locked
error TicketingLocked();
/// Attempting to add a pending child after the number of pending children has reached the limit (default limit is 128)
error TicketingMaxPendingChildrenReached();
/// Attempting to add a pending asset after the number of pending assets has reached the limit (default limit is
///  128)
error TicketingMaxPendingAssetsReached();
/// Attempting to burn a total number of recursive children higher than maximum set
/// @param childContract Address of the collection smart contract in which the maximum number of recursive burns was reached
/// @param childId ID of the child token at which the maximum number of recursive burns was reached
error TicketingMaxRecursiveBurnsReached(address childContract, uint256 childId);
/// Attempting to mint a number of tokens that would cause the total supply to be greater than maximum supply
error TicketingMintOverMax();
/// Attempting to mint a nested token to a smart contract that doesn't support nesting
error TicketingMintToNonTicketingNestableImplementer();
/// Attempting to pass complementary arrays of different lengths
error TicketingMismachedArrayLength();
/// Attempting to transfer a child before it is unequipped
error TicketingMustUnequipFirst();
/// Attempting to nest a child over the nestable limit (current limit is 100 levels of nesting)
error TicketingNestableTooDeep();
/// Attempting to nest the token to own descendant, which would create a loop and leave the looped tokens in limbo
error TicketingNestableTransferToDescendant();
/// Attempting to nest the token to a smart contract that doesn't support nesting
error TicketingNestableTransferToNonTicketingNestableImplementer();
/// Attempting to nest the token into itself
error TicketingNestableTransferToSelf();
/// Attempting to interact with an asset that can not be found
error TicketingNoAssetMatchingId();
/// Attempting to manage an asset without owning it or having been granted permission by the owner to do so
error TicketingNotApprovedForAssetsOrOwner();
/// Attempting to interact with a token without being its owner or having been granted permission by the
///  owner to do so
/// @dev When a token is nested, only the direct owner (NFT parent) can mange it. In that case, approved addresses are
///  not allowed to manage it, in order to ensure the expected behaviour
error TicketingNotApprovedOrDirectOwner();
/// Attempting to manage a collection without being the collection's collaborator
error TicketingNotCollectionCollaborator();
/// Attemting to manage a collection without being the collection's issuer
error TicketingNotCollectionIssuer();
/// Attempting to manage a collection without being the collection's issuer or collaborator
error TicketingNotCollectionIssuerOrCollaborator();
/// Attempting to compose an asset wihtout having an associated Catalog
error TicketingNotComposableAsset();
/// Attempting to unequip an item that isn't equipped
error TicketingNotEquipped();
/// Attempting to interact with a management function without being the smart contract's owner
error TicketingNotOwner();
/// Attempting to interact with a function without being the owner or contributor of the collection
error TicketingNotOwnerOrContributor();
/// Attempting to manage a collection without being the specific address
error TicketingNotSpecificAddress();
/// Attempting to manage a token without being its owner
error TicketingNotTokenOwner();
/// Attempting to transfer the ownership to the 0x0 address
error TicketingNewOwnerIsZeroAddress();
/// Attempting to assign a 0x0 address as a contributor
error TicketingNewContributorIsZeroAddress();
/// Attemtping to use `Ownable` interface without implementing it
error TicketingOwnableNotImplemented();
/// Attempting an operation requiring the token being nested, while it is not
error TicketingParentIsNotNFT();
/// Attempting to add a `Part` with an ID that is already used
error TicketingPartAlreadyExists();
/// Attempting to use a `Part` that doesn't exist
error TicketingPartDoesNotExist();
/// Attempting to use a `Part` that is `Fixed` when `Slot` kind of `Part` should be used
error TicketingPartIsNotSlot();
/// Attempting to interact with a pending child using an index greater than the size of pending array
error TicketingPendingChildIndexOutOfRange();
/// Attempting to add an asset using an ID that has already been used
error TicketingAssetAlreadyExists();
/// Attempting to equip an item into a slot that already has an item equipped
error TicketingSlotAlreadyUsed();
/// Attempting to equip an item into a `Slot` that the target asset does not implement
error TicketingTargetAssetCannotReceiveSlot();
/// Attempting to equip a child into a `Slot` and parent that the child's collection doesn't support
error TicketingTokenCannotBeEquippedWithAssetIntoSlot();
/// Attempting to compose a NFT of a token without active assets
error TicketingTokenDoesNotHaveAsset();
/// Attempting to determine the asset with the top priority on a token without assets
error TicketingTokenHasNoAssets();
/// Attempting to accept or transfer a child which does not match the one at the specified index
error TicketingUnexpectedChildId();
/// Attempting to reject all pending assets but more assets than expected are pending
error TicketingUnexpectedNumberOfAssets();
/// Attempting to reject all pending children but children assets than expected are pending
error TicketingUnexpectedNumberOfChildren();
/// Attempting to accept or reject an asset which does not match the one at the specified index
error TicketingUnexpectedAssetId();
/// Attempting an operation expecting a parent to the token which is not the actual one
error TicketingUnexpectedParent();
/// Attempting not to pass an empty array of equippable addresses when adding or setting the equippable addresses
error TicketingZeroLengthIdsPassed();
/// Attempting to set the royalties to a value higher than 100% (10000 in base points)
error TicketingRoyaltiesTooHigh();
/// Attempting to nest mint without the completion of the task
error TaskNotCompleted();
/// Attempting to call the function by the address which is not the contract admin
error TicketingNotAdmin();
/// Attempting to call the function by the address which is not the user
error TicketingNotUser();
