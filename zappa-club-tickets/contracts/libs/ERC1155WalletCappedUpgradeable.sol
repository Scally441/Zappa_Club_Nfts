// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//=============================================================//
//                           IMPORTS                           //
//=============================================================//
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";


/**

 * @title  ERC1155 token with the possibility to limit the maximum number of token owned by each wallet
 */
abstract contract ERC1155WalletCappedUpgradeable is
    Initializable,
    ERC1155Upgradeable
{
    //=============================================================//
    //                         STRUCTURES                          //
    //=============================================================//

    /// Data for wallet maximum number of tokens
    struct WalletMaxTokens {
        uint256 maxTokens;
        bool isSet;
    }

    //=============================================================//
    //                           STORAGE                           //
    //=============================================================//

    /// Mapping from wallet address to the maximum number of ownable tokens for a specified token ID
    mapping(address => mapping(uint256 => WalletMaxTokens)) public walletsMaxTokens;
    /// Default maximum number of tokens if address is not in the mapping
    mapping(uint256 => WalletMaxTokens) public defaultWalletMaxTokens;

    //=============================================================//
    //                           ERRORS                            //
    //=============================================================//

    /**
     * Error raised if default wallet maximum number of tokens is reached
     */
    error DefaultWalletMaxTokensReachedError(
        uint256 maxValue
    );

    /**
     * Error raised if specific wallet maximum number of tokens is reached
     */
    error WalletMaxTokensReachedError(
        uint256 maxValue
    );

    //=============================================================//
    //                           EVENTS                            //
    //=============================================================//

    /**
     * Event emitted when default maximum number of tokens is changed
     */
    event DefaultMaxTokensChanged(
        uint256 tokenId,
        uint256 oldValue,
        uint256 newValue
    );

    /**
     * Event emitted when maximum number of tokens for a wallet is changed
     */
    event WalletMaxTokensChanged(
        address walletAddress,
        uint256 tokenId,
        uint256 oldValue,
        uint256 newValue
    );

    //=============================================================//
    //                     INTERNAL FUNCTIONS                      //
    //=============================================================//

    /**
     * Initialize
     */
    function __ERC1155WalletCapped_init() internal onlyInitializing {
        __ERC1155WalletCapped_init_unchained();
    }

    /**
     * Initialize (unchained)
     */
    function __ERC1155WalletCapped_init_unchained() internal onlyInitializing {
    }

    /**
     * Set the maximum number of token `tokenId_` for the wallet `wallet_` to `maxTokens_`
     * @param wallet_    Wallet address
     * @param tokenId_   Token ID
     * @param maxTokens_ Maximum number of tokens
     */
    function _setWalletMaxTokens(
        address wallet_,
        uint256 tokenId_,
        uint256 maxTokens_
    ) internal {
        uint256 old_value = walletsMaxTokens[wallet_][tokenId_].maxTokens;

        WalletMaxTokens storage wallet_max_tokens = walletsMaxTokens[wallet_][tokenId_];
        wallet_max_tokens.isSet = true;
        wallet_max_tokens.maxTokens = maxTokens_;

        emit WalletMaxTokensChanged(wallet_, tokenId_, old_value, maxTokens_);
    }

    /**
     * Set the default wallet maximum number of token `tokenId_` to `maxTokens_`
     * @param tokenId_   Token ID
     * @param maxTokens_ Maximum number of tokens
     */
    function _setDefaultWalletMaxTokens(
        uint256 tokenId_,
        uint256 maxTokens_
    ) internal {
        uint256 old_value = defaultWalletMaxTokens[tokenId_].maxTokens;

        WalletMaxTokens storage wallet_max_tokens = defaultWalletMaxTokens[tokenId_];
        wallet_max_tokens.isSet = true;
        wallet_max_tokens.maxTokens = maxTokens_;

        emit DefaultMaxTokensChanged(tokenId_, old_value, maxTokens_);
    }

    //=============================================================//
    //                    OVERRIDDEN FUNCTIONS                     //
    //=============================================================//

    /**
     * See {ERC1155-_beforeTokenTransfer}
     */
    function _beforeTokenTransfer(
        address operator_,
        address from_,
        address to_,
        uint256[] memory ids_,
        uint256[] memory amounts_,
        bytes memory data_
    ) internal virtual override {
        super._beforeTokenTransfer(operator_, from_, to_, ids_, amounts_, data_);

        // Do not check address zero (in case of burning)
        if (to_ == address(0)) {
            return;
        }

        for (uint256 i = 0; i < ids_.length; i++) {
            uint256 id = ids_[i];
            uint256 new_balance = balanceOf(to_, id) + amounts_[i];

            WalletMaxTokens storage wallet_max_tokens = walletsMaxTokens[to_][id];
            if (wallet_max_tokens.isSet && new_balance > wallet_max_tokens.maxTokens) {
                revert WalletMaxTokensReachedError(wallet_max_tokens.maxTokens);
            } else if (defaultWalletMaxTokens[id].isSet && new_balance > defaultWalletMaxTokens[id].maxTokens) {
                revert DefaultWalletMaxTokensReachedError(defaultWalletMaxTokens[id].maxTokens);
            }
            // If defaultWalletMaxTokens is not set, it'll mean infinite tokens
        }
    }
}
