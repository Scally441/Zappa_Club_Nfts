// SPDX-License-Identifier: MIT

//
// Zappa Club (https://zappaclub.io/)
//
//                             8888888888888
//                            88888o8888888o88888
//                          888o88888888o8888o88888
//                        888888888888o88888888888888
//                       8888o88             888888888
//                      88888888             88888o888
//                      8888888              888888o888
//                     888888                 8o8888888
//                    88 888 ,*8888o, ,o8888*, 8888 88 8
//                   8888888 '`(0))`~ ~`((0)`' 8888888 8
//                   8888888l  `'` `; ;` `'`   88888888 8
//                    88 8888       ; d;       8888888 88
//                    8888888       ( 7,       8888 888  8
//                   88888888      @@@@@@      888888888 8
//                   8 88888o   ,@@@@@@@@@, , o8888888  88
//                  88888888`o  @@;~^~^~;@@ 0;`8 8888888
//                  8888 88 8`v    `@@@`    o`88888 888 8
//                  88888888  `;,        ,;o`8 88888888 8
//                   8 8888     `o,  ,;,;o` 888888 88 8
//                   8888 88      ``'''`     88 8888888 8
//                  88888888                  8 8888 8888
//                  8888888                    88  888888
//                                                  888888
//                                                  888888
//
//     =================================================                   Frank Zappa 1940 - 1993

pragma solidity ^0.8.0;

//=============================================================//
//                            IMPORTS                          //
//=============================================================//
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./libs/ERC1155AutoIdUpgradeable.sol";
import "./libs/ERC1155MultipleURIStorageUpgradeable.sol";
import "./libs/ERC1155NameSymbolUpgradeable.sol";
import "./libs/ERC1155SelectivePausableUpgradeable.sol";
import "./libs/ERC1155WalletCappedUpgradeable.sol";

contract ZappaClubTickets is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ERC1155Upgradeable,
    ERC1155AutoIdUpgradeable,
    ERC1155MultipleURIStorageUpgradeable,
    ERC1155NameSymbolUpgradeable,
    ERC1155SelectivePausableUpgradeable,
    ERC1155WalletCappedUpgradeable
{
    //=============================================================//
    //                           CONSTANTS                         //
    //=============================================================//

    /// NFT name
    string constant private NFT_NAME = "Zappa Club Tickets";
    /// NFT symbol
    string constant private NFT_SYMBOL = "ZCTK";

    //=============================================================//
    //                           ERRORS                            //
    //=============================================================//

    /**
     * Error raised if minting by ID a not existent token
     * @param tokenId Token ID
     */
    error NotExistentTokenMintError(
        uint256 tokenId
    );

    /**
     * Error raised if airdropping zero tokens
     */
    error ZeroTokensAirdropError();

    /**
     * Error raised if burning zero tokens
     */
    error ZeroTokensBurnError();

    /**
     * Error raised if minting zero tokens
     */
    error ZeroTokensMintError();

    //=============================================================//
    //                             EVENTS                          //
    //=============================================================//

    /**
     * Event emitted when a single token is minted
     * @param to      Target address
     * @param tokenId Token ID
     * @param amount  Token amount
     */ 
    event SingleTokenMinted(
        address to,
        uint256 tokenId,
        uint256 amount
    );

    /**
     * Event emitted when multiple tokens are minted
     * @param to           Target address
     * @param startTokenId Start token IDs
     * @param tokenNum     Number of tokens
     * @param amounts      Token amounts
     */
    event MultipleTokensMinted(
        address to,
        uint256 startTokenId,
        uint256 tokenNum,
        uint256[] amounts
    );

    /**
     * Event emitted when tokens are airdropped
     * @param tos     Target addresses
     * @param tokenId Token ID
     * @param amount  Token amount
     */ 
    event TokensAirdropped(
        address[] tos,
        uint256 tokenId,
        uint256 amount
    );

    /**
     * Event emitted when a single token is burned
     * @param from    Target address
     * @param tokenId Token ID
     * @param amount  Token amount
     */
    event SingleTokenBurned(
        address from,
        uint256 tokenId,
        uint256 amount
    );

    /**
     * Event emitted when a multiple tokens are burned
     * @param from     Destination address
     * @param tokenIds Token IDs
     * @param amounts  Token amounts
     */
    event MultipleTokensBurned(
        address from,
        uint256[] tokenIds,
        uint256[] amounts
    );

    //=============================================================//
    //                          CONSTRUCTOR                        //
    //=============================================================//

    /**
     * Constructor
     * @dev Disable initializer for implementation contract
     */
    constructor() {
        _disableInitializers();
    }

    //=============================================================//
    //                       PUBLIC FUNCTIONS                      //
    //=============================================================//

    /**
     * Initialize
     * @param baseURI_ Base URI
     */
    function init(
        string memory baseURI_
    ) public initializer {
        __ERC1155AutoId_init();
        __ERC1155NameSymbolUpgradeable_init(NFT_NAME, NFT_SYMBOL);
        __ERC1155MultipleURIStorage_init(baseURI_);
        __ERC1155SelectivePausable_init();
        __ERC1155WalletCapped_init();

        __ERC1155_init("");
        __Ownable_init();
    }

    //
    // Mint/Burn
    //

    /**
     * Mint `amount_` tokens to `to_`
     * @param to_     Receiver address
     * @param amount_ Token amount
     */
    function mintTo(
        address to_,
        uint256 amount_
    ) public onlyOwner {
        if (amount_ == 0) {
            revert ZeroTokensMintError();
        }

        _mintTo(to_, amount_, "");

        emit SingleTokenMinted(to_, totalSupply() - 1, amount_);
    }

    /**
     * Mint `amount_` tokens of token ID `tokenId_` to `to_` (token ID `tokenId_` shall be already minted)
     * @param to_      Receiver address
     * @param tokenId_ Token ID
     * @param amount_  Token amount
     */
    function mintToById(
        address to_,
        uint256 tokenId_,
        uint256 amount_
    ) public onlyOwner {
        if (amount_ == 0) {
            revert ZeroTokensMintError();
        }
        if ((totalSupply() == 0) || (tokenId_ > totalSupply())) {
            revert NotExistentTokenMintError(tokenId_);
        }

        _mint(to_, tokenId_, amount_, "");

        emit SingleTokenMinted(to_, tokenId_, amount_);
    }

    /**
     * Mint `amounts_` of different tokens to `to_`
     * @param to_      Receiver address
     * @param amounts_ Amount for each token
     */
    function mintBatchTo(
        address to_,
        uint256[] memory amounts_
    ) public onlyOwner {
        uint256 tokens_num = amounts_.length;
        for (uint256 i = 0; i < tokens_num; i++) {
            if (amounts_[i] == 0) {
                revert ZeroTokensMintError();
            }
        }

        _mintBatchTo(to_, amounts_, "");

        emit MultipleTokensMinted(to_, totalSupply() - tokens_num, tokens_num, amounts_);
    }

    /**
     * Airdrop a single token to each of the `receivers_`
     * @param receivers_ Receiver addresses
     */
    function airdropSingle(
        address[] calldata receivers_
    ) public onlyOwner {
        uint256 amount = receivers_.length;
        if (amount == 0) {
            revert ZeroTokensAirdropError();
        }

        uint256 token_id = _currentTokenId();
        for (uint256 i = 0; i < amount; i++) {
            _mint(receivers_[i], token_id, 1, "");
        }
        _incrementTokenId();

        emit TokensAirdropped(receivers_, token_id, amount);
    }

    /**
     * Airdrop a single token with ID `tokenId_` to each of the `receivers_`
     * @param receivers_ Receiver addresses
     * @param tokenId_   Token ID
     */
    function airdropSingleById(
        address[] calldata receivers_,
        uint256 tokenId_
    ) public onlyOwner {
        uint256 amount = receivers_.length;
        if (amount == 0) {
            revert ZeroTokensAirdropError();
        }

        if ((totalSupply() == 0) || (tokenId_ > totalSupply())) {
            revert NotExistentTokenMintError(tokenId_);
        }

        for (uint256 i = 0; i < amount; i++) {
            _mint(receivers_[i], tokenId_, 1, "");
        }

        emit TokensAirdropped(receivers_, tokenId_, amount);
    }

    /**
     * Burn `amount_` tokens of token `id_` from `from_`
     * @param from_   Target address
     * @param id_     Token ID
     * @param amount_ Token amount
     */
    function burn(
        address from_,
        uint256 id_,
        uint256 amount_
    ) public onlyOwner {
        if (amount_ == 0) {
            revert ZeroTokensBurnError();
        }

        _burn(from_, id_, amount_);

        emit SingleTokenBurned(from_, id_, amount_);
    }

    /**
     * Burn `amounts_` tokens of token `ids_` from `from_`
     * @param from_    Target address
     * @param ids_     Token IDs
     * @param amounts_ Token amounts
     */
    function burnBatch(
        address from_,
        uint256[] memory ids_,
        uint256[] memory amounts_
    ) public onlyOwner {
        for (uint256 i = 0; i < amounts_.length; i++) {
            if (amounts_[i] == 0) {
                revert ZeroTokensBurnError();
            }
        }

        _burnBatch(from_, ids_, amounts_);

        emit MultipleTokensBurned(from_, ids_, amounts_);
    }

    //
    // URIs management
    //

    /**
     * Set base URI to `baseUri_`
     * @param baseUri_ URI
     */
    function setBaseURI(
        string memory baseUri_
    ) public onlyOwner notEmptyURI(baseUri_) {
        _setBaseURI(baseUri_);
        _updateEntireCollectionMetadata();
    }

    /**
     * Set contract URI to `contractURI_`
     * @param contractURI_ Contract URI
     */
    function setContractURI(
        string memory contractURI_
    ) public onlyOwner notEmptyURI(contractURI_) {
        _setContractURI(contractURI_);
    }

    /**
     * Set URI of token ID `tokenId_` to `tokenURI_`
     * @param tokenId_  Token ID
     * @param tokenURI_ Token URI
     */
    function setTokenURI(
        uint256 tokenId_,
        string memory tokenURI_
    ) public onlyOwner notEmptyURI(tokenURI_) {
        _setTokenURI(tokenId_, tokenURI_);
    }

    /**
     * Reset URI of token ID `tokenId_` (empty string)
     * @param tokenId_ Token ID
     */
    function resetTokenURI(
        uint256 tokenId_
    ) public onlyOwner {
        _resetTokenURI(tokenId_);
    }

    /**
     * Freeze URI
     */
    function freezeURI() public onlyOwner {
        _freezeURI();
    }

    //
    // Maximum tokens per wallet management
    //

    /**
     * Set the maximum number of token `tokenId_` for the wallet `wallet_` to `maxTokens_`
     * @param wallet_    Wallet address
     * @param tokenId_   Token ID
     * @param maxTokens_ Maximum number of tokens
     */
    function setWalletMaxTokens(
        address wallet_,
        uint256 tokenId_,
        uint256 maxTokens_
    ) public onlyOwner {
        _setWalletMaxTokens(wallet_, tokenId_, maxTokens_);
    }

    /**
     * Set the default wallet maximum number of token `tokenId_` to `maxTokens_`
     * @param tokenId_   Token ID
     * @param maxTokens_ Maximum number of tokens
     */
    function setDefaultWalletMaxTokens(
        uint256 tokenId_,
        uint256 maxTokens_
    ) public onlyOwner {
        _setDefaultWalletMaxTokens(tokenId_, maxTokens_);
    }

    //
    // Pause management
    //

    /**
     * Set the status of paused wallet `wallet_` to `status_`
     * @param wallet_ Wallet address
     * @param status_ True if wallet cannot transfer tokens, false otherwise
     */
    function setPausedWallet(
        address wallet_,
        bool status_
    ) public onlyOwner {
        _setPausedWallet(wallet_, status_);
    }

    /**
     * Set the status of unpaused wallet `wallet_` to `status_`
     * @param wallet_ Wallet address
     * @param status_ True if wallet can transfer tokens when paused, false otherwise
     */
    function setUnpausedWallet(
        address wallet_,
        bool status_
    ) public onlyOwner {
        _setUnpausedWallet(wallet_, status_);
    }

    /**
     * Pause token transfers
     */
    function pauseTransfers() public onlyOwner {
        _pause();
    }

    /**
     * Unpause token transfers
     */
    function unpauseTransfers() public onlyOwner {
        _unpause();
    }

    //=============================================================//
    //                    OVERRIDDEN FUNCTIONS                     //
    //=============================================================//

    /**
     * Restrict upgrade to owner
     * See {UUPSUpgradeable-_authorizeUpgrade}
     */
    function _authorizeUpgrade(
        address newImplementation_
    ) internal override onlyOwner {
    }

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
    ) internal virtual override(ERC1155WalletCappedUpgradeable, ERC1155SelectivePausableUpgradeable, ERC1155Upgradeable) {
        super._beforeTokenTransfer(operator_, from_, to_, ids_, amounts_, data_);
    }

    /**
     * See {ERC1155-uri}
     */
    function uri(
        uint256 tokenId_
    ) public view virtual override(ERC1155MultipleURIStorageUpgradeable, ERC1155Upgradeable) returns (string memory) {
        return super.uri(tokenId_);
    }
}    