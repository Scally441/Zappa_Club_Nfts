// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//=============================================================//
//                           IMPORTS                           //
//=============================================================//
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";


 /**

 * @title  ERC1155 token with the possibility to pause transfers in a selective way
 * @notice Transfers can be paused for all but some addresses or only for some addresses
 */
abstract contract ERC1155SelectivePausableUpgradeable is
    Initializable,
    PausableUpgradeable,
    ERC1155Upgradeable
{
    //=============================================================//
    //                           STORAGE                           //
    //=============================================================//

    /// Mapping from wallet address to the unpaused status
    /// If true, the wallet can transfer tokens when paused
    mapping(address => bool) public unpausedWallets;
    /// Mapping from wallet address to the paused status
    /// If true, the wallet cannot transfer tokens
    mapping(address => bool) public pausedWallets;

    //=============================================================//
    //                           ERRORS                            //
    //=============================================================//

    /**
     * Error raised if a transfer is made by a paused wallet
     */
    error TransferByPausedWalletError();

    /**
     * Error raised if a transfer is made while paused
     */
    error TransferWhilePausedError();

    //=============================================================//
    //                           EVENTS                            //
    //=============================================================//

    /**
     * Event emitted when a paused wallet status is changed
     */
    event PausedWalletStatusChanged(
        address walletAddress,
        bool status
    );

    /**
     * Event emitted when an unpaused wallet status is changed
     */
    event UnpausedWalletStatusChanged(
        address walletAddress,
        bool status
    );

    //=============================================================//
    //                     INTERNAL FUNCTIONS                      //
    //=============================================================//

    /**
     * Initialize
     */
    function __ERC1155SelectivePausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
        __ERC1155SelectivePausable_init_unchained();
    }

    /**
     * Initialize (unchained)
     */
    function __ERC1155SelectivePausable_init_unchained() internal onlyInitializing {
    }

    /**
     * Set the status of paused wallet `wallet_` to `status_`
     * @param wallet_ Wallet address
     * @param status_ True if wallet cannot transfer tokens, false otherwise
     */
    function _setPausedWallet(
        address wallet_,
        bool status_
    ) internal {
        pausedWallets[wallet_] = status_;

        emit PausedWalletStatusChanged(wallet_, status_);
    }

    /**
     * Set the status of unpaused wallet `wallet_` to `status_`
     * @param wallet_ Wallet address
     * @param status_ True if wallet can transfer tokens when paused, false otherwise
     */
    function _setUnpausedWallet(
        address wallet_,
        bool status_
    ) internal {
        unpausedWallets[wallet_] = status_;

        emit UnpausedWalletStatusChanged(wallet_, status_);
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

        // Revert if paused wallet
        if (pausedWallets[from_]) {
            revert TransferByPausedWalletError();
        }

        // Revert if transfer while paused and wallet is not paused
        if (!unpausedWallets[from_] && paused()) {
            revert TransferWhilePausedError();
        }
    }
}
