// SPDX-License-Identifier: MIT

// Deployed by Cat Church LLC

/*
MIT License

Copyright (c) 2024 Cat Church LLC (see CCC.meme)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity ^0.8.0;

interface IERC20 {

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

}

contract CCCClassifieds {

    uint256 public offerNonce = 0;

    struct Offer{
        address offereeOrZeroIfOpen;
        uint48 CCC_InMillionths;
        uint48 ETH_InMillionths;
    }
    mapping(address => mapping( uint256 => Offer)) public CCC_Offers;

    mapping(address => mapping( uint256 => Offer)) public ETH_Offers;

    // DEBUG TEST:
    //address public constant _CCCAddress = 0x3127D935C05e43b28600C84b2601f5130E1216f9;
    // PRODUCTION:
    address public constant _CCCAddress = 0x3871F0d0396Dbad8E970C274A7Ed8A2Ffb5B6EC1;
    IERC20 public constant CCCToken = IERC20(_CCCAddress);

    // We use a single event to handle all offer, acceptance, and offer-cancellation
    // because it can be valuable to know the state of available offers in the context of
    // acceptances, and if different events are used then it becomes very (very) difficult to
    // sort the events in chronoligcal order so that the state of available offers is known
    // at the time of any event.  One reason is that a separate query must be done when multiple
    // transactions are in the same block, in order to disambiguate which transactions happened
    // before others in the same block.

    // For an offer: the offeror is the offeror, offereeOrAcceptor is address(0) if an open offer,
    //               and a non-zero address if the offer is a closed offer (only the designated address can accept).
    //               oneIsOfferTwoIsAcceptanceThreeIsCancellation is set to 1 in this case.

    // For an acceptance: the offeror is the offeror, offereeOrAcceptor is the acceptor, and
    //                    oneIsOfferTwoIsAcceptanceThreeIsCancellation is set to 2 in this case.

    // For a cancellation: the offeror is the offeror, offereeOrAcceptor is the acceptor, and
    //                    oneIsOfferTwoIsAcceptanceThreeIsCancellation is set to 3 in this case.

    // We didn't make offerID indexed in the event because
    // its primary use-case is to look back and see when an offer was made, but we know when it was made because we have the block number encoded
    // in the offer ID.  The only thing we lose by making it non-indexed is finding the time when a given offer was accepted.  but searching for
    // a matching offeror (and if closed offer, the offeree) and sifting through all the returned events for the one with the matching offerID in
    // this niche use-case is probably not a big deal.

    // If offer is for CCC (rather than offer being for eth) then offerIsForCCC is true (otherwise it is false).

    // One reason to require offerors and acceptors to be Externally Owned Accounts contracts were allowed (internal account)
    // then when they receive ETH transfer they can have their payable fallback function fail, or simply use ridiculous gas,
    // to DOS or otherwise harm users with spam or high gas failed transactions.  This is due to the peer-to-peer nature of the
    // offer and acceptance (where ETH actually gets sent to the offeree when an offer of CCC is accepted, rather than requiring
    // a separate transaction by the offeror to collect that ETH).
    
    event OfferAcceptanceOrCancellation( address indexed offeror, address indexed offereeOrAcceptor, uint56 offerID, uint48 CCC_InMillionths, uint48 ETH_InMillionths, 
                                         uint8 oneIsOfferTwoIsAcceptanceThreeIsCancellation, bool offerIsForCCC);


    // Contracts are prevented from interfacing with this contract as it helps clearly de-risk reentrency attacks (easier audit).
    // The offer is only valid if the blockchain allows it, i.e. if it has not yet been cancelled or accepted
    function OfferCCC(uint48 CCC_InMillionths, uint48 ETH_InMillionths, address offereeIfNonzero) public {
        require( msg.sender == tx.origin, "EOA only");
        uint256 _amount = uint256(CCC_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        require(_amount != 0, "Can't be 0");

        uint256 _offerID = offerNonce++;
        
        Offer storage thisOfferStorage = CCC_Offers[msg.sender][_offerID];
        Offer memory thisOffer = thisOfferStorage;
        require( thisOffer.CCC_InMillionths == 0 ,"Not empty");
        CCC_Offers[msg.sender][_offerID] = Offer({ offereeOrZeroIfOpen: offereeIfNonzero, CCC_InMillionths: CCC_InMillionths, ETH_InMillionths: ETH_InMillionths});

        // Always change internal state (above) to assume success before calling external functions (below)
        bool sent = CCCToken.transferFrom(msg.sender, address(this), _amount);
        require(sent, "Token transfer failed"); // Impossible since CCC would revert rather than return false, but we put here for best practices.

        emit OfferAcceptanceOrCancellation( msg.sender, offereeIfNonzero, uint56(_offerID), CCC_InMillionths, ETH_InMillionths, 1, true);
    }

    // Don't need to check here if external account since msg.sender is part of indexing to qualify to cancel the offer.
    function CancelOfferedCCC(uint56 offerID) external {
        Offer storage thisOfferStorage = CCC_Offers[msg.sender][offerID];
        Offer memory thisOffer = thisOfferStorage;

        uint256 _amount = uint256(thisOffer.CCC_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        // Require it is not already accepted or cancelled or never made:
        require(_amount != 0 , "No offer");
        delete CCC_Offers[msg.sender][offerID];

        // Always change internal state (above) to assume success before calling external functions (below)
        bool sent = CCCToken.transfer(msg.sender, _amount);
        require(sent, "Token transfer failed"); // Impossible since CCC would revert rather than return false, but we put here for best practices.

        emit OfferAcceptanceOrCancellation( msg.sender, thisOffer.offereeOrZeroIfOpen, offerID, thisOffer.CCC_InMillionths, thisOffer.ETH_InMillionths, 3, true);
    }

    function AcceptCCC(address offeror, uint56 offerID, uint48 CCC_InMillionths, uint48 ETH_InMillionths) external payable {
        require( msg.sender == tx.origin, "EOA only");
        Offer storage thisOfferStorage = CCC_Offers[offeror][offerID];
        Offer memory thisOffer = thisOfferStorage;

        require( uint256(CCC_InMillionths) == thisOffer.CCC_InMillionths, "Bad CCC amt" );
        require( uint256(ETH_InMillionths) == thisOffer.ETH_InMillionths, "Bad ETH amt");

        require((thisOffer.offereeOrZeroIfOpen == address(0)) || (thisOffer.offereeOrZeroIfOpen == msg.sender),"NA");
        uint256 _amount = uint256(thisOffer.CCC_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        

        // Require it is not already accepted or cancelled or never made:
        require(_amount != 0 , "No offer");

        uint256 eth_amount = uint256(thisOffer.ETH_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        require(msg.value == eth_amount, "Wrong ETH amount");
        delete CCC_Offers[offeror][offerID];

        // Always change internal state (above) to assume success before calling external functions (below)
        bool sent = CCCToken.transfer(msg.sender, _amount);
        require(sent, "Token transfer failed"); // Impossible since CCC would revert rather than return false, but we put here for best practices.

        (bool success, ) = offeror.call{value: msg.value}(""); // We use the best practices method of ".call()" despite it being overkill here.
        require(success, "Failed to send Ether");

        emit OfferAcceptanceOrCancellation( offeror, msg.sender, offerID, thisOffer.CCC_InMillionths, thisOffer.ETH_InMillionths, 2, true);
    }


    // The offer is only valid if the blockchain allows it, i.e. if it has not yet been cancelled or accepted
    function OfferETH(uint48 CCC_InMillionths, uint48 ETH_InMillionths, address offereeIfNonzero) external payable {
        require( msg.sender == tx.origin, "EOA only");
        require(uint256(CCC_InMillionths) != 0, "Can't be 0");
        uint256 eth_amount = uint256(ETH_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        require( msg.value == eth_amount, "Wrong ETH");

        uint256 _offerID = offerNonce++;
        
        Offer storage thisOfferStorage = ETH_Offers[msg.sender][_offerID];
        Offer memory thisOffer = thisOfferStorage;
        require( thisOffer.CCC_InMillionths == 0 ,"Not empty"); // Overkill to check this.  Extra care seems warranted.
        ETH_Offers[msg.sender][_offerID] = Offer({ offereeOrZeroIfOpen: offereeIfNonzero, CCC_InMillionths: CCC_InMillionths, ETH_InMillionths: ETH_InMillionths});

        // Always change internal state (above) to assume success before calling external functions (below)
        // No state change required here since ETH is automatically accepted if we don't revert.

        emit OfferAcceptanceOrCancellation( msg.sender, offereeIfNonzero, uint56(_offerID), CCC_InMillionths, ETH_InMillionths, 1, false);
    }

    // Don't need to check here if 
    function CancelOfferedETH(uint56 offerID) external {
        Offer storage thisOfferStorage = ETH_Offers[msg.sender][offerID];
        Offer memory thisOffer = thisOfferStorage;

        // Require it is not already accepted or cancelled or never made:
        require(uint256(thisOffer.CCC_InMillionths) != 0 , "No offer");
        delete ETH_Offers[msg.sender][offerID];

        uint256 eth_amount = uint256(thisOffer.ETH_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.

        // Always change internal state (above) to assume success before calling external functions (below)
        (bool success, ) = msg.sender.call{value: eth_amount}(""); // We use the best practices method of ".call()" despite it being overkill here.
        require(success, "Failed to send Ether");

        emit OfferAcceptanceOrCancellation( msg.sender, thisOffer.offereeOrZeroIfOpen, offerID, thisOffer.CCC_InMillionths, thisOffer.ETH_InMillionths, 3, false);
    }

    function AcceptETH(address offeror, uint56 offerID, uint48 CCC_InMillionths, uint48 ETH_InMillionths) external {
        require( msg.sender == tx.origin, "EOA only");
        Offer storage thisOfferStorage = ETH_Offers[offeror][offerID];
        Offer memory thisOffer = thisOfferStorage;

        require( uint256(CCC_InMillionths) == thisOffer.CCC_InMillionths, "Bad CCC amt" );
        require( uint256(ETH_InMillionths) == thisOffer.ETH_InMillionths, "Bad ETH amt");

        require((thisOffer.offereeOrZeroIfOpen == address(0)) || (thisOffer.offereeOrZeroIfOpen == msg.sender),"NA");
        uint256 _amount = uint256(thisOffer.CCC_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.

        // Require it is not already accepted or cancelled or never made:
        require(_amount != 0 , "No offer");

        //uint256 eth_amount = uint256(thisOffer.ETH_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        //require(msg.value == eth_amount, "Wrong ETH amount");
        delete ETH_Offers[offeror][offerID];

        // Always change internal state (above) to assume success before calling external functions (below)
        bool sent = CCCToken.transferFrom(msg.sender, offeror, _amount);
        require(sent, "Token transfer failed"); // Impossible since CCC would revert rather than return false, but we put here for best practices.

        uint256 eth_amount = uint256(thisOffer.ETH_InMillionths) * 1_000_000_000_000; // 18 zeros means 12 zeros gives millionths.
        (bool success, ) = msg.sender.call{value: eth_amount}(""); // We use the best practices method of ".call()" despite it being overkill here.
        require(success, "Failed to send Ether");

        emit OfferAcceptanceOrCancellation( offeror, msg.sender, offerID, thisOffer.CCC_InMillionths, thisOffer.ETH_InMillionths, 2, false);
    }

}