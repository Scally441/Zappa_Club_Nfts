// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//=============================================================//
//                           IMPORTS                           //
//=============================================================//
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";


/**
 
 * @title  ERC1155 token with automatic token ID handling
 * @notice Token ID is automatically incremented when minting a new one
 */
abstract contract ERC1155AutoIdUpgradeable is
    Initializable,
    ERC1155Upgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    //=============================================================//
    //                           STORAGE                           //
    //=============================================================//

    /// Current token ID
    CountersUpgradeable.Counter private _nextTokenId;

    //=============================================================//
    //                      PUBLIC FUNCTIONS                       //
    //=============================================================//

    /**
     * Get total token supply
     * @return Total token supply
     */
    function totalSupply() public view returns (uint256) {
        return _nextTokenId.current();
    }

    //=============================================================//
    //                     INTERNAL FUNCTIONS                      //
    //=============================================================//

    /**
     * Initialize
     */
    function __ERC1155AutoId_init() internal onlyInitializing {
        __ERC1155AutoId_init_unchained();
    }

    /**
     * Initialize (unchained)
     */
    function __ERC1155AutoId_init_unchained() internal onlyInitializing {
    }

    /**
     * Get current token ID
     * @return Current token ID
     */
    function _currentTokenId() internal view returns (uint256) {
        return _nextTokenId.current();
    }

    /**
     * Increment token ID
     */
    function _incrementTokenId() internal {
        _nextTokenId.increment();
    }

    /**
     * Mint `amount_` tokens to `to_`
     * @param to_     Receiver address
     * @param amount_ Token amount
     * @param data_   Data if the receiver is a contract
     */
    function _mintTo(
        address to_,
        uint256 amount_,
        bytes memory data_
    ) internal virtual {
        uint256 currentTokenId = _nextTokenId.current();
        _nextTokenId.increment();
        _mint(to_, currentTokenId, amount_, data_);
    }

    /**
     * Mint `amounts_` of different tokens to `to_`
     * @param to_      Receiver address
     * @param amounts_ Token amounts
     * @param data_    Data if the receiver is a contract
     */
    function _mintBatchTo(
        address to_,
        uint256[] memory amounts_,
        bytes memory data_
    ) internal virtual {
        // Build IDs array
        uint256[] memory ids = new uint256[](amounts_.length);
        for (uint256 i = 0; i < amounts_.length; i++) {
            ids[i] = _nextTokenId.current();
            _nextTokenId.increment();
        }

        _mintBatch(to_, ids, amounts_, data_);
    }
}
