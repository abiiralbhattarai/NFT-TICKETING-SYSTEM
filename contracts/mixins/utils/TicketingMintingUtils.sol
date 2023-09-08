// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../access/RbacLock.sol";
import "../../libraries/TicketingErrors.sol";

/**
 * @title TicketingMintingUtils
 *
 * @notice Smart contract of the Ticketing minting utils module.
 * @dev This smart contract includes the top-level utilities for managing minting and implements RbacLock by default.
 * @dev Max supply-related and pricing variables are immutable after deployment.
 */
contract TicketingMintingUtils is Initializable, RbacLock {
    uint256 internal _nextId;
    uint256 internal _totalSupply;
    uint256 internal _maxSupply;
    uint256 internal _pricePerMint;

    /**
     * @notice Initializes the smart contract with a given maximum supply and minting price.
     * @param maxSupply_ The maximum supply of tokens to initialize the smart contract with
     * @param pricePerMint_ The minting price to initialize the smart contract with, expressed in the smallest
     *  denomination of the native currency of the chain to which the smart contract is deployed to
     */

    function __TicketingMintingUtils_init(
        uint256 maxSupply_,
        uint256 pricePerMint_
    ) internal onlyInitializing {
        __TicketingMintingUtils_init_unchained(maxSupply_, pricePerMint_);
    }

    /**
     *  @notice It is the initializer function minus the calls to parent initializers. This function can be used to avoid double initialization
     * @param maxSupply_ The maximum supply of tokens to initialize the smart contract with
     * @param pricePerMint_ The minting price to initialize the smart contract with, expressed in the smallest
     *  denomination of the native currency of the chain to which the smart contract is deployed to
     */
    function __TicketingMintingUtils_init_unchained(
        uint256 maxSupply_,
        uint256 pricePerMint_
    ) internal onlyInitializing {
        _maxSupply = maxSupply_;
        _pricePerMint = pricePerMint_;
    }

    /**
     * @notice Used to verify that the sale of the given token is still available.
     * @dev If the maximum supply is reached, the execution will be reverted.
     */
    modifier saleIsOpen() {
        _checkSaleIsOpen();
        _;
    }

    /**
     * @inheritdoc RbacLock
     */
    function setLock() public virtual override onlyContractAdmin {
        super.setLock();
        _maxSupply = _totalSupply;
    }

    /**
     * @notice Used to retrieve the total supply of the tokens in a collection.
     * @return The number of tokens in a collection
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Used to retrieve the maximum supply of the collection.
     * @return The maximum supply of tokens in the collection
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @notice Used to retrieve the price per mint.
     * @return The price per mint of a single token expressed in the lowest denomination of a native currency
     */
    function pricePerMint() public view returns (uint256) {
        return _pricePerMint;
    }

    /**
     * @notice Used to withdraw the minting proceedings to a specified address.
     * @dev This function can only be called by the owner.
     * @param to Address to receive the given amount of minting proceedings
     * @param amount The amount to withdraw
     */
    function withdrawRaised(
        address to,
        uint256 amount
    ) external onlyContractAdmin {
        _withdraw(to, amount);
    }

    /**
     * @notice Used to withdraw the minting proceedings to a specified address.
     * @param _address Address to receive the given amount of minting proceedings
     * @param _amount The amount to withdraw
     */
    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    /**
     * @notice Used to verify that the sale is still open.
     * @dev In case the maximum supply of the collection is reached, the execution is reverted.
     */
    function _checkSaleIsOpen() private view {
        if (_nextId >= _maxSupply) revert TicketingMintOverMax();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
