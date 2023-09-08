// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/MinimalForwarderUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./mixins/utils/TicketingTokenURI.sol";
import "./mixins/royalty/TicketingRoyalties.sol";
import "./mixins/utils/TicketingMintingUtils.sol";
import "./mixins/utils/TicketingCollectionMetadata.sol";
import "./mixins/nestable/TicketingNestableExternalEquip.sol";
import "./interfaces/standards/composableNft/ITicketingInitData.sol";
import "./mixins/chainLinkUpgradeable/ChainLinkClientUpgradeable.sol";

error TicketingWrongValueSent();
error TicketingMintZero();
error AlreadyClaimed();
error InvalidProof();

/**
 * @title TicketingNestableExternalEquipImpl
 *
 * @notice Implementation of Ticketing nestable external equip module.
 */
contract TicketingNestableExternalEquipImpl is
    ChainLinkClientUpgradeable,
    ITicketingInitData,
    TicketingMintingUtils,
    TicketingCollectionMetadata,
    TicketingRoyalties,
    TicketingTokenURI,
    TicketingNestableExternalEquip
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using Chainlink for Chainlink.Request;
    address private _equippableAddress;
    event RequestIsTaskCompleted(bytes32 indexed requestId, uint256 result);

    //Chainlink External Adapters
    bytes32 private jobId;
    uint256 private fee;

    mapping(bytes32 => uint256) nftId;
    //to record the jobcomplete status according to nftid on 0 and 1
    // 0 for not complete and 1 for complete
    mapping(uint256 => uint256) public jobCompleteStatus;

    // merkle root for claiming Nft
    bytes32 public nftClaimMerkleRoot;

    // merkle root for claiming reward Nft
    bytes32 public nftRewardClaimMerkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private nftclaimedBitMap;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private rewardclaimedBitMap;

    /**
     * @notice Used to notify listeners that the token is being transferred.
     * @param index index of the user's address in the merkle tree
     * @param account Address to which to mint the token
     * @param numToMint Number of tokens to mint
     */
    event ClaimedNft(uint256 index, address account, uint256 numToMint);

    /**
     * @notice Used to notify listeners that the token is being transferred.
     * @param index  index in merkleroot
     * @param nftaddress Address of the collection smart contract of the token into which to mint the child token
     * @param numToMint Number of tokens to mint
     * @param destinationId ID of the token into which to mint the new child token
     */
    event ClaimedReward(
        uint256 index,
        address nftaddress,
        uint256 numToMint,
        uint256 destinationId
    );

    /**
     * @notice Used to initialize the smart contract.
     * @dev The full `InitData` looks like this:
     *  [
     *      erc20TokenAddress,
     *      tokenUriIsEnumerable,
     *      royaltyRecipient,
     *      royaltyPercentageBps,
     *      maxSupply,
     *      pricePerMint
     *  ]
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     * @param collectionMetadata_ The collection metadata URI
     * @param tokenURI_ The base URI of the token metadata
     * @param nftClaimMerkleRoot_ merkle root of claiming Nft
     * @param  nftRewardClaimMerkleRoot_ merkle root of claiming reward
     * @param forwarder_ address of the MinimalForwarderUpgradeable
     * @param data The `InitData` struct containing additional initialization data
     */
    function __TicketingNestableExternalEquipImpl_init(
        address equippableAddress_,
        string memory name_,
        string memory symbol_,
        string memory collectionMetadata_,
        string memory tokenURI_,
        bytes32 nftClaimMerkleRoot_,
        bytes32 nftRewardClaimMerkleRoot_,
        MinimalForwarderUpgradeable forwarder_,
        InitData memory data
    ) public initializer {
        __TicketingNestableExternalEquipImpl_init_unchained(
            equippableAddress_,
            name_,
            symbol_,
            collectionMetadata_,
            tokenURI_,
            nftClaimMerkleRoot_,
            nftRewardClaimMerkleRoot_,
            forwarder_,
            data
        );
    }

    /**
     * @notice It is the initializer function minus the calls to parent initializers. This function can be used to avoid double initialization
     * @param name_ Name of the token collection
     * @param symbol_ Symbol of the token collection
     * @param collectionMetadata_ The collection metadata with which to initialize the smart contract
     * @param tokenURI_ Metadata URI to apply to all tokens, either as base or as full URI for every token
     * @param nftClaimMerkleRoot_ merkle root of claiming Nft
     * @param  nftRewardClaimMerkleRoot_ merkle root of claiming reward
     * @param forwarder_ address of the MinimalForwarderUpgradeable
     * @param data contains different data
     */
    function __TicketingNestableExternalEquipImpl_init_unchained(
        address equippableAddress_,
        string memory name_,
        string memory symbol_,
        string memory collectionMetadata_,
        string memory tokenURI_,
        bytes32 nftClaimMerkleRoot_,
        bytes32 nftRewardClaimMerkleRoot_,
        MinimalForwarderUpgradeable forwarder_,
        InitData memory data
    ) internal onlyInitializing {
        __TicketingMintingUtils_init(data.maxSupply, data.pricePerMint);
        __TicketingCollectionMetadata_init(collectionMetadata_);
        __TicketingRoyalties_init_unchained(
            data.royaltyRecipient,
            data.royaltyPercentageBps
        );
        __TicketingTokenURI_init(tokenURI_, data.tokenUriIsEnumerable);
        __TicketingNestableExternalEquip_init(name_, symbol_);
        __Rbac_init(_msgSender(), address(forwarder_));
        __ChainLinkClientUpgradeable_init();
        _equippableAddress = equippableAddress_;
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        fee = 0;
        nftClaimMerkleRoot = nftClaimMerkleRoot_;
        nftRewardClaimMerkleRoot = nftRewardClaimMerkleRoot_;
    }

    /**
     * @notice Use for setting and updating the Chainlink Oracle and Job Id
     * @param oracleAddress it the address of operator contract
     * @param jobIds It is id of the job
     */
    function setOracleandJob(
        address oracleAddress,
        string memory jobIds
    ) public onlyContractAdmin {
        setChainlinkOracle(oracleAddress);
        jobId = stringToBytes32(jobIds);
    }

    /**
     * @notice Used to check if the nft is claimed or not
     */

    function isNftClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = nftclaimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /**
     * @notice Used to set the Nft Claim status
     */
    function _setNftClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        nftclaimedBitMap[claimedWordIndex] =
            nftclaimedBitMap[claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    /**
     * @notice Used to claim the desired number of tokens to the specified address.
     * @param account Address to which to mint the token
     * @param numToMint Number of tokens to mint
     * @param merkleProof it is the merkle proof
     */

    function claimNft(
        uint256 index,
        address account,
        uint256 numToMint,
        bytes32[] calldata merkleProof
    ) external payable {
        if (isNftClaimed(index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, numToMint));
        if (!MerkleProof.verify(merkleProof, nftClaimMerkleRoot, node))
            revert InvalidProof();

        // Mark it claimed and send the token.
        _setNftClaimed(index);
        mint(account, numToMint);

        emit ClaimedNft(index, account, numToMint);
    }

    /**
     * @notice Used to mint the desired number of tokens to the specified address.
     * @dev The `data` value of the `_safeMint` method is set to an empty value.
     * @dev Can only be called while the open sale is open.
     * @param to Address to which to mint the token
     * @param numToMint Number of tokens to mint
     * @return The ID of the first token to be minted in the current minting cycle
     */
    function mint(
        address to,
        uint256 numToMint
    ) internal virtual notLocked returns (uint256) {
        (uint256 nextToken, uint256 totalSupplyOffset) = _preMint(numToMint);

        for (uint256 i = nextToken; i < totalSupplyOffset; ) {
            _safeMint(to, i, "");
            unchecked {
                ++i;
            }
        }

        return nextToken;
    }

    /**
     * @notice function to check if the task is completed by the nft holder
     * @param taskId id of the task
     * @param tokenId id of the nft
     */

    function isTaskCompleted(
        string memory taskId,
        string memory tokenId
    )
        public
        onlyApprovedOrDirectOwner(stringToUint(tokenId))
        returns (bytes32 requestId)
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillData.selector
        );

        req.add("taskId", taskId); // Chainlink nodes 1.0.0 and later support this format
        req.add("nftId", tokenId); // Chainlink nodes 1.0.0 and later support this format

        requestId = sendChainlinkRequest(req, fee);
        nftId[requestId] = stringToUint(tokenId);
    }

    function fulfillData(
        bytes32 _requestId,
        uint256 _result
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestIsTaskCompleted(_requestId, _result);
        uint256 nftTokenId = nftId[_requestId];
        jobCompleteStatus[nftTokenId] = _result;
    }

    /**
     * @notice Used to check if the reward is claimed or not
     */

    function isRewardClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = rewardclaimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /**
     * @notice Used to set the reward Claim status
     */
    function _setRewardClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        rewardclaimedBitMap[claimedWordIndex] =
            rewardclaimedBitMap[claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    /**
     * @notice Used to claim the desired number of tokens to the specified address.
     * @param index  index in merkleroot
     * @param nftaddress Address of the collection smart contract of the token into which to mint the child token
     * @param numToMint Number of tokens to mint
     * @param destinationId ID of the token into which to mint the new child token
     * @param merkleProof it is the merkle proof
     */

    function claimReward(
        uint256 index,
        address nftaddress,
        uint256 numToMint,
        uint256 destinationId,
        bytes32[] calldata merkleProof
    ) external payable onlyApprovedOrDirectOwner(destinationId) {
        if (isRewardClaimed(index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(
            abi.encodePacked(index, nftaddress, numToMint, destinationId)
        );
        if (!MerkleProof.verify(merkleProof, nftRewardClaimMerkleRoot, node))
            revert InvalidProof();

        // Mark it claimed and send the token.
        _setRewardClaimed(index);
        nestMint(nftaddress, numToMint, destinationId);

        emit ClaimedReward(index, nftaddress, numToMint, destinationId);
    }

    /**
     * @notice Used to mint a desired number of child tokens to a given parent token.
     * @dev The `data` value of the `_safeMint` method is set to an empty value.
     * @dev Can only be called while the open sale is open.
     * @param to Address of the collection smart contract of the token into which to mint the child token
     * @param numToMint Number of tokens to mint
     * @param destinationId ID of the token into which to mint the new child token
     * @return The ID of the first token to be minted in the current minting cycle
     */
    function nestMint(
        address to,
        uint256 numToMint,
        uint256 destinationId
    ) internal virtual notLocked returns (uint256) {
        if (jobCompleteStatus[destinationId] <= 0) revert TaskNotCompleted();
        (uint256 nextToken, uint256 totalSupplyOffset) = _preMint(numToMint);

        for (uint256 i = nextToken; i < totalSupplyOffset; ) {
            _nestMint(to, i, destinationId, "");
            unchecked {
                ++i;
            }
        }

        return nextToken;
    }

    /**
     * @notice Used to calculate the token IDs of tokens to be minted.
     * @param numToMint Amount of tokens to be minted
     * @return The ID of the first token to be minted in the current minting cycle
     * @return The ID of the last token to be minted in the current minting cycle
     */
    function _preMint(uint256 numToMint) private returns (uint256, uint256) {
        if (numToMint == uint256(0)) revert TicketingMintZero();
        if (numToMint + _nextId > _maxSupply) revert TicketingMintOverMax();

        uint256 mintPriceRequired = numToMint * _pricePerMint;
        if (mintPriceRequired != msg.value) revert TicketingWrongValueSent();

        uint256 nextToken = _nextId + 1;
        unchecked {
            _nextId += numToMint;
            _totalSupply += numToMint;
        }
        uint256 totalSupplyOffset = _nextId + 1;

        return (nextToken, totalSupplyOffset);
    }

    /**
     * @notice Used to set the address of the `Equippable` smart contract.
     * @param equippable Address of the `Equippable` smart contract
     */
    function setEquippableAddress(
        address equippable
    ) public virtual onlyContractAdmin {
        //TODO: should we add a check if passed address supports ITicketingNestableExternalEquip
        _setEquippableAddress(equippable);
    }

    // ------------------- WITHDRAW AND DEPOSIT --------------

    /**
     * @notice Use to Deposit the balance of different tokens
     * @param _amount amount of the token
     * @param _token address of the token
     */
    function deposit(uint _amount, address _token) public payable {
        IERC20Upgradeable(_token).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }

    /**
     * @notice Use to Withdraw the balance of different tokens
     *@param _token address of the token
     */
    function withdraw(address _token) public onlyContractAdmin {
        uint amount = IERC20Upgradeable(_token).balanceOf(address(this));

        IERC20Upgradeable(_token).safeTransferFrom(
            address(this),
            msg.sender,
            amount
        );
    }

    /**
     * @inheritdoc TicketingRoyalties
     */
    function updateRoyaltyRecipient(
        address newRoyaltyRecipient
    ) public virtual override onlyContractAdmin {
        _setRoyaltyRecipient(newRoyaltyRecipient);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (to == address(0)) {
            unchecked {
                _totalSupply -= 1;
            }
        }
    }

    /**
     * @notice Use to convert string to Uint256
     *@param s string parameter
     */
    function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 resultUint = 0;
        for (uint256 i = 0; i < b.length; i++) {
            require(
                uint8(b[i]) >= 48 && uint8(b[i]) <= 57,
                "Invalid character"
            );
            resultUint = resultUint * 10 + (uint256(uint8(b[i])) - 48);
        }
        return resultUint;
    }

    /**
     * @notice Use to convert string to byte32
     *@param source string parameter
     */
    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 results) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            results := mload(add(source, 32))
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
