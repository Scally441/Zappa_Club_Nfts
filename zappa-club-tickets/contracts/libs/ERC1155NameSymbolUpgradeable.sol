// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//=============================================================//
//                            IMPORTS                          //
//=============================================================//
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";


/**

 * @title  ERC1155 token that stores name and symbol
 */
abstract contract ERC1155NameSymbolUpgradeable is
    Initializable,
    ERC1155Upgradeable
{
    //=============================================================//
    //                            STORAGE                          //
    //=============================================================//

    /// Contract name
    string public name;
    /// Contract symbol
    string public symbol;

    //=============================================================//
    //                       PUBLIC FUNCTIONS                      //
    //=============================================================//

    /**
     * Initialize
     * @param name_   Token URI
     * @param symbol_ Token symbol
     */
    function __ERC1155NameSymbolUpgradeable_init(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __ERC1155NameSymbolUpgradeable_init_unchained(name_, symbol_);
    }

    /**
     * Initialize (unchained)
     * @param name_   Token URI
     * @param symbol_ Token symbol
     */
    function __ERC1155NameSymbolUpgradeable_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        name = name_;
        symbol = symbol_;
    }
}
