// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//=============================================================//
//                           IMPORTS                           //
//=============================================================//
import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC1155Upgradeable.sol";


/**

 * @title  IERC4906 interface for ERC1155
 * @dev    Added since not present for IERC1155 in openzeppelin release
 */
interface IERC4906Upgradeable is
    IERC165Upgradeable,
    IERC1155Upgradeable
{
    //=============================================================//
    //                           EVENTS                            //
    //=============================================================//

    /**
     * This event emits when the metadata of a token is changed.
     * So that the third-party platforms such as NFT market could
     * timely update the images and related attributes of the NFT.
     */
    event MetadataUpdate(
        uint256 tokenId
    );

    /**
     * This event emits when the metadata of a range of tokens is changed.
     * So that the third-party platforms such as NFT market could
     * timely update the images and related attributes of the NFTs.
     */
    event BatchMetadataUpdate(
        uint256 fromTokenId,
        uint256 toTokenId
    );
}
