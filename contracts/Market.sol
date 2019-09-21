pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;


import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";



interface ERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount)
    external returns (bool);
}


contract Market is ReentrancyGuard {
    using SafeMath for uint256;

    uint256 constant public REVEAL_PERIOD = 7; // 7 blocks

    enum SwapType {BUY, SELL}

    // We are going to organize the swap book into a linked list
    struct Swap {
        address wallet;
        uint256 amount;
        uint256 price;
        bytes32 next; // Linked list: id of next priced swap
    }
    // For each trading pair tokenA/tokenB
    // we are going to have 2 buy swap books
    // one for buy swaps and one for sell swaps
    struct SwapBook {
        bytes32 top; // Head of a linked list, id of top priced swap
        mapping(bytes32 => Swap) swaps;
    }
    // bytes32(keccak256(_BaseToken, _QuoteToken)) => SwapBook
    mapping(bytes32 => SwapBook) private buySwapBooks;
    mapping(bytes32 => SwapBook) private sellSwapBooks;


    struct Commit {
        // Commit data
        uint256 block;
        uint256 gasPrice;
        uint256 fee;
        bytes32 next; // Linked list

        // Swap data
        SwapType swapType;
        Swap swap;
    }
    struct CommitBook {
        bytes32 head; // Head of a linked list, id of top priced swap
        bytes32 tail; // Head of a linked list, id of top priced swap
        mapping(bytes32 => Commit) commits;
    }
    // For each trading pair tokenA/tokenB
    // we are going to have a commit/reveal book
    mapping(bytes32 => CommitBook) private commitBooks;


    uint256 private balance = 0; // fees collected


    event SwapCommitted(bytes32 indexed hash);
    event SwapRevealed(bytes32 indexed hash);
    event CommitCleared(bytes32 indexed hash);
    event CommitEvicted(bytes32 indexed hash, string reason);
    event SwapPlaced(address indexed BaseToken, address indexed QuoteToken, SwapType swapType, address indexed wallet, uint256 amount, uint256 price, bytes32 id, bytes32 placedAfter);
    event SwapFilled(address indexed BaseToken, address indexed QuoteToken, SwapType swapType, address indexed maker, address taker, uint256 amount, uint256 price, bytes32 id, bool fully);
    event SwapCanceled(address indexed BaseToken, address indexed QuoteToken, SwapType swapType, address indexed wallet, bytes32 id);


    // Converting base token amount into Quote Token amount
    function tokenToQuoteToken(address _BaseToken, uint256 _tokenAmount, uint256 _price)
    private view returns (uint256) {
        return _tokenAmount.mul(_price).div(10 ** uint256(ERC20(_BaseToken).decimals()));
    }


    function commitSwap(
        address _BaseToken, // token to buy/sell
        address _QuoteToken, // quote token to pay with
        bytes32 _hash
    ) external payable {
        // TODO maybe just do whitelisting?
        // Check if the swap book with reverse pair exists
        require(buySwapBooks[keccak256(abi.encode(_QuoteToken, _BaseToken))].top == bytes32(0), 'Use reverse pair');
        require(sellSwapBooks[keccak256(abi.encode(_QuoteToken, _BaseToken))].top == bytes32(0), 'Use reverse pair');

        CommitBook storage commitBook = commitBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];
        mapping(bytes32 => Commit) storage commits = commitBook.commits;

        require(commits[_hash].block == 0, 'Duplicate commit');

        // Allocating storage with values
        commits[_hash] = Commit(
            block.number,
            tx.gasprice,
            msg.value,
            bytes32(0),
            SwapType.BUY,
            Swap(address(0), 0, 0, bytes32(0)) // TODO separate swap from commit to save storage here
        );

        if (commitBook.head == bytes32(0)) {
            commitBook.head = _hash;
        } else {
            commits[commitBook.tail].next = _hash;
        }
        commitBook.tail = _hash;

        emit SwapCommitted(_hash);

        // TODO count extractable balance
        // require(msg.value >= 1000000 * tx.gasprice, 'Fee is below 1000000 gas');
    }


    // TODO reveal many commits in one TX
    function reveal(
        // TODO do we need to have _blockHash under signature?
        bytes32 _blockHash,
        address _BaseToken, // token to buy/sell
        address _QuoteToken, // quote token to pay with
        SwapType _type, // BUY or SELL
        uint256 _amount, // token or quote token amount
        uint256 _priceLimit, // 0 for market swap
        uint256 _nonce
    ) external {
        bytes32 hash = keccak256(abi.encode(
                msg.sender, _BaseToken, _QuoteToken, _type, _amount, _priceLimit, _nonce));

        Commit storage commit =
            commitBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))].commits[hash];
        require(commit.block != 0, 'Commit not found');
        require(blockhash(commit.block) == _blockHash, 'Invalid block hash');
        require(commit.swap.amount == 0, 'Already revealed');

        commit.swapType = _type;
        commit.swap = Swap(msg.sender, _amount, _priceLimit, bytes32(0));

        emit SwapRevealed(hash);

        // TODO maybe not even put current commit in storage, if it can be processed right away
        _clearSwaps(_BaseToken, _QuoteToken);
    }


    // called manually only in extra cases
    // swaps are processed automatically within reveal method
    function clearSwaps(address _BaseToken, address _QuoteToken)
    external {
        _clearSwaps(_BaseToken, _QuoteToken);
    }

    // TODO processSwaps while committing and revealing
    // TODO submit list of possible _after?
    // TODO: refund 90% of spent gas + refund some deposit + some swap process reward
    function _clearSwaps(address _BaseToken, address _QuoteToken)
    nonReentrant() private {
        CommitBook storage commitBook = commitBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];
        mapping(bytes32 => Commit) storage commits = commitBook.commits;
        bytes32 head = commitBook.head;
        bytes32 commitHash = bytes32(0);
        Commit storage commit = commits[head];
        Swap storage swap = commit.swap;

        // TODO watch gas on fill / place level
        // looping through commits
        while (gasleft() > 100000 && commit.block != 0) {
            if (commit.swap.amount == 0) {
                // Commit is not revealed
                // TODO maybe measure both time and height?
                if (block.number - commit.block > REVEAL_PERIOD) {
                    // Commit is expired
                    commitHash = head;
                    head = commit.next;
                    commit = commits[head];
                    swap = commit.swap;

                    emit CommitEvicted(commitHash, 'Expired');
                    delete commits[commitHash];
                } else {
                    // Waiting to get revealed or expired
                    break;
                }
            } else {
                // Revealed, but not processed
                if (block.number - commit.block > REVEAL_PERIOD * 2) {
                    // This should not happen under normal conditions
                    // Commit is revealed but not processed for too long
                    // Maybe running out of gas or bad ERC20? We have to move on
                    // This will delete all the commits for block that got halted
                    // TODO: separate que for each trading pair,
                    // TODO: so 1 broken ERC20 doesn't halt the whole trading
                    // TODO: try _maybeTransfer try catch approach for calling market methods
                    commitHash = head;
                    head = commit.next;
                    commit = commits[head];
                    swap = commit.swap;

                    emit CommitEvicted(commitHash, 'Expired');
                    delete commits[commitHash];
                } else {
                    // Revealed
                    commitHash = head;
                    if (commit.swapType == SwapType.BUY) {
                        if (swap.price == 0) {
                            // marketBuy
                            if (ERC20(_BaseToken).balanceOf(swap.wallet) >= swap.amount &&
                                ERC20(_QuoteToken).allowance(swap.wallet, address(this)) >= swap.amount
                            ) {
                                emit CommitCleared(commitHash);
                                marketBuy(_BaseToken, _QuoteToken, swap);
                            } else
                                emit CommitEvicted(commitHash, 'Allowance');
                        } else {
                            // limitBuy
                            if (ERC20(_QuoteToken).balanceOf(swap.wallet) >= tokenToQuoteToken(_BaseToken, swap.amount, swap.price) &&
                                ERC20(_QuoteToken).allowance(swap.wallet, address(this)) >= tokenToQuoteToken(_BaseToken, swap.amount, swap.price)
                            ) {
                                emit CommitCleared(commitHash);
                                limitBuy(_BaseToken, _QuoteToken, swap, head, bytes32(0));
                            } else
                                emit CommitEvicted(commitHash, 'Allowance');

                        }
                    } else {
                        if (ERC20(_BaseToken).balanceOf(swap.wallet) >= swap.amount &&
                            ERC20(_BaseToken).allowance(swap.wallet, address(this)) >= swap.amount
                        ) {
                            emit CommitCleared(commitHash);
                            if (swap.price == 0) {
                                // marketSell
                                marketSell(_BaseToken, _QuoteToken, swap);
                            } else {
                                // limitSell
                                limitSell(_BaseToken, _QuoteToken, swap, head, bytes32(0));
                            }
                        } else
                            emit CommitEvicted(commitHash, 'Allowance');
                    }

                    head = commit.next;
                    commit = commits[head];
                    swap = commit.swap;

                    delete commits[commitHash];
                }

            }
        }

        if (head != commitBook.head) {
            commitBook.head = head;
        }
    }


    function marketBuy(
        address _BaseToken, // token to buy
        address _QuoteToken, // token to pay with
        Swap storage _swap
    ) private {
        _fillOffersWithQuoteToken(_BaseToken, _QuoteToken, _swap);
    }


    function limitBuy(
        address _BaseToken, // token to buy
        address _QuoteToken, // token to pay with
        Swap storage _swap,
        bytes32 _hash,
        bytes32 _after
    ) private {
        _fillOffers(_BaseToken, _QuoteToken, _swap);

        if (_swap.amount > 0)
            _placeBid(_BaseToken, _QuoteToken, _swap, _hash, _after);
    }


    function marketSell(
        address _BaseToken, // token to buy
        address _QuoteToken, // quote token to pay with
        Swap storage _swap
    ) private {
        _fillBids(_BaseToken, _QuoteToken, _swap);
    }


    function limitSell(
        address _BaseToken, // token to sell
        address _QuoteToken, // token to get paid with
        Swap storage _swap, // token amount
        bytes32 _hash, // unique hash
        bytes32 _after // optional to skip
    ) private {
        _fillBids(_BaseToken, _QuoteToken, _swap);

        if (_swap.amount > 0)
            _placeOffer(_BaseToken, _QuoteToken, _swap, _hash, _after);
    }


    function _placeBid(
        address _BaseToken, // token to buy
        address _QuoteToken, // token to pay with
        Swap storage _swap, // token amount
        bytes32 _hash, // unique hash
        bytes32 _after  // (optional) to reduce iteration over swaps
                        // ideally hash of the last bid with equal or higher price
    ) private {
        SwapBook storage book = buySwapBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];

        while (_hash == bytes32(0) || book.swaps[_hash].amount > 0)
            // Just in case of improbable hash collision
            _hash = keccak256(abi.encode(_hash, _swap.wallet));

        book.swaps[_hash] = _swap;

        if (_after == bytes32(0) || _swap.price > book.swaps[_after].price) {
            // Starting from top if _after is unset or misplaced
            _after = book.top;
        }

        Swap storage prevBid = book.swaps[_after];

        // if top bid price is higher or equal than offered _price
        if (_swap.price <= prevBid.price) {
            Swap storage nextBid = book.swaps[prevBid.next];

            // Iterating to find a bid with lower price
            while (_swap.price <= nextBid.price) {
                _after = prevBid.next;
                prevBid = nextBid;
                nextBid = book.swaps[prevBid.next];
            }
            // Placing bid before the one with lower price
            _swap.next = prevBid.next;
            prevBid.next = _hash;

        } else {
            // Placing new swap as top if _price is the highest
            _swap.next = book.top;
            book.top = _hash;
            _after = bytes32(0);
        }

        emit SwapPlaced(_BaseToken, _QuoteToken, SwapType.BUY, _swap.wallet, _swap.amount, _swap.price, _hash, _after);

    }


    function _placeOffer(
        address _BaseToken, // to buy
        address _QuoteToken, // to pay with
        Swap storage _swap, // token amount
        bytes32 _hash, // unique hash
        bytes32 _after  // (optional) to reduce iteration over swaps
                        // ideally hash of the last bid with equal or higher price
    ) private {
        // Locating data in storage
        SwapBook storage book = sellSwapBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];

        while (_hash == bytes32(0) || book.swaps[_hash].amount > 0)
            // Just in case of improbable hash collision
            _hash = keccak256(abi.encode(_hash, _swap.wallet));

        book.swaps[_hash] = _swap;

        if (_after == bytes32(0) || _swap.price < book.swaps[_after].price) {
            // Starting from top if _after is unset or misplaced
            _after = book.top;
        }

        Swap storage prevOffer = book.swaps[_after];

        // if lowest ask price is lower or equal than _price
        if (_swap.price >= prevOffer.price && prevOffer.price > 0) {
            Swap storage nextOffer = book.swaps[prevOffer.next];

            // Iterating to find an offer with higher price
            while (_swap.price >= nextOffer.price && nextOffer.price > 0) {
                _after = prevOffer.next;
                prevOffer = nextOffer;
                nextOffer = book.swaps[prevOffer.next];
            }
            // Placing bid before the one with lower price
            _swap.next = prevOffer.next;
            prevOffer.next = _hash;

        } else {
            // Placing new swap as top if _price is the lowest
            _swap.next = book.top;
            book.top = _hash;
            _after = bytes32(0);
        }

        emit SwapPlaced(_BaseToken, _QuoteToken, SwapType.SELL, _swap.wallet, _swap.amount,  _swap.price, _hash, _after);
    }


    function _fillBids(
        address _BaseToken, // token to sell
        address _QuoteToken, // quote token to get paid with
        Swap storage _swap // token amount to spend
    ) private {
        // Locating data in storage
        SwapBook storage book = buySwapBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];
        bytes32 top = book.top;
        Swap storage bid = book.swaps[top];
        uint256 tokenLeft = _swap.amount;

        // Iterating trough swaps TODO watch gas and prevent _swap eviction if not finished
        while (tokenLeft > 0 && bid.price >= _swap.price && bid.amount > 0) {
            if (tokenLeft < bid.amount) {
                if (_maybeTransfer(_QuoteToken, bid.wallet, _swap.wallet, tokenToQuoteToken(_BaseToken, tokenLeft, bid.price))) {
                    // Filling partially
                    bid.amount -= tokenLeft;
                    require(ERC20(_BaseToken).transferFrom(_swap.wallet, bid.wallet, tokenLeft), "BaseToken transfer failed");
                    emit SwapFilled(_BaseToken, _QuoteToken, SwapType.SELL, bid.wallet, _swap.wallet, tokenLeft, bid.price, top, false);
                    tokenLeft = 0;
                } else {
                    // TODO emit Canceled with reason Balance/Allowance
                    emit CommitEvicted(top, 'Allowance');
                    (top, bid) = _getNextAndDelete(book.swaps, top, bid);
                }
            } else {
                if (_maybeTransfer(_QuoteToken, bid.wallet, _swap.wallet, tokenToQuoteToken(_BaseToken, bid.amount, bid.price))) {
                    // Filling bid completely
                    tokenLeft -= bid.amount;
                    // Moving funds
                    require(ERC20(_BaseToken).transferFrom(_swap.wallet, bid.wallet, bid.amount), "BaseToken transfer failed");
                    emit SwapFilled(_BaseToken, _QuoteToken, SwapType.SELL, bid.wallet, _swap.wallet, bid.amount, bid.price, top, true);
                } else {
                    emit CommitEvicted(top, 'Allowance');
                }
                (top, bid) = _getNextAndDelete(book.swaps, top, bid);
            }
        }

        if (top != book.top)
            book.top = top;

        _swap.amount = tokenLeft;
    }


    function _fillOffers(
        address _BaseToken, // token to sell
        address _QuoteToken, // quote token to get paid with
        Swap storage _swap // token amount to spend
    ) private {
        // Locating data in storage
        SwapBook storage book = sellSwapBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];
        bytes32 top = book.top;
        Swap storage offer = book.swaps[top];
        uint256 tokenTransfer = 0;

        // Iterating trough swaps
        while (_swap.amount > tokenTransfer && (offer.price <= _swap.price || _swap.price == 0) && offer.amount > 0) {
            if (_swap.amount - tokenTransfer < offer.amount) {
                if (_maybeTransfer(_BaseToken, offer.wallet, _swap.wallet, _swap.amount - tokenTransfer)) {
                    // Filling offer partially
                    offer.amount -= _swap.amount - tokenTransfer;
                    require(ERC20(_QuoteToken).transferFrom(_swap.wallet, offer.wallet,
                        tokenToQuoteToken(_BaseToken, _swap.amount - tokenTransfer, offer.price)), "QuoteToken transfer failed");
                    emit SwapFilled(_BaseToken, _QuoteToken, SwapType.BUY, offer.wallet, _swap.wallet, _swap.amount - tokenTransfer, offer.price, top, false);
                    // Filled whole swap
                    tokenTransfer = _swap.amount;
                } else {
                    emit CommitEvicted(top, 'Allowance');
                    (top, offer) = _getNextAndDelete(book.swaps, top, offer);
                }
            } else {
                if (_maybeTransfer(_BaseToken, offer.wallet, _swap.wallet, offer.amount)) {
                    // Filling offer completely
                    require(ERC20(_QuoteToken).transferFrom(_swap.wallet, offer.wallet,
                        tokenToQuoteToken(_BaseToken, offer.amount, offer.price)), "QuoteToken transfer failed");
                    emit SwapFilled(_BaseToken, _QuoteToken, SwapType.BUY, offer.wallet, _swap.wallet, offer.amount, offer.price, top, true);
                    tokenTransfer = tokenTransfer.add(offer.amount);
                } else {
                    emit CommitEvicted(top, 'Allowance');
                }
                (top, offer) = _getNextAndDelete(book.swaps, top, offer);
            }
        }

        if (top != book.top)
            book.top = top;

        _swap.amount -= tokenTransfer;
    }


    function _fillOffersWithQuoteToken(
        address _BaseToken, // token to by
        address _QuoteToken, // quote token to pay with
        Swap storage _swap // token amount to spend
    ) private {
        // Locating data in storage
        SwapBook storage book = sellSwapBooks[keccak256(abi.encode(_BaseToken, _QuoteToken))];
        bytes32 top = book.top;
        Swap storage offer = book.swaps[top];
        uint256 quoteTokenAmount = _swap.amount;
        uint256 convertedAmount = 0;

        // Iterating trough swaps
        while (quoteTokenAmount > 0 && offer.amount > 0) {
            // amount of quote token offer asks for
            convertedAmount = tokenToQuoteToken(_BaseToken, offer.amount, offer.price);
            if (quoteTokenAmount < convertedAmount) {

                // amount of token we can fill
                convertedAmount = offer.amount.mul(quoteTokenAmount).div(convertedAmount);
                if (_maybeTransfer(_BaseToken, offer.wallet, _swap.wallet, convertedAmount)) {
                    // Filling partially
                    offer.amount -= convertedAmount;

                    // Moving funds
                    require(ERC20(_QuoteToken).transferFrom(_swap.wallet, offer.wallet,
                        tokenToQuoteToken(_BaseToken, convertedAmount, offer.price)), "QuoteToken transfer failed");

                    emit SwapFilled(_BaseToken, _QuoteToken, SwapType.BUY, offer.wallet, _swap.wallet, convertedAmount, offer.price, top, false);
                    quoteTokenAmount = quoteTokenAmount - tokenToQuoteToken(_BaseToken, convertedAmount, offer.price);
                    break;
                } else {
                    emit CommitEvicted(top, 'Allowance');
                    (top, offer) = _getNextAndDelete(book.swaps, top, offer);
                }
            } else {
                if (_maybeTransfer(_BaseToken, offer.wallet, _swap.wallet, offer.amount)) {

                    // Filling offer completely
                    quoteTokenAmount -= convertedAmount;

                    // Moving funds
                    require(ERC20(_QuoteToken).transferFrom(_swap.wallet, offer.wallet, convertedAmount), "QuoteToken transfer failed");

                    emit SwapFilled(_BaseToken, _QuoteToken, SwapType.BUY, offer.wallet, _swap.wallet, offer.amount, offer.price, top, true);

                } else {
                    emit CommitEvicted(top, 'Allowance');
                }
                (top, offer) = _getNextAndDelete(book.swaps, top, offer);
            }
        }

        if (top != book.top)
            book.top = top;

        _swap.amount = quoteTokenAmount;
    }


    function _getNextAndDelete(
        mapping(bytes32 => Swap) storage _swaps,
        bytes32 _top,
        Swap storage _swap
    ) private returns (bytes32, Swap storage) {
        bytes32 top = _swap.next;
        delete _swaps[_top];
        return (top, _swaps[top]);
    }


    function cancelBuySwap(
        address _BaseToken, // to buy
        address _QuoteToken, // to pay with
        bytes32 _id, // swaps hash
        bytes32 _after  // optional to skip
    ) external {
        _cancelSwap(_BaseToken, _QuoteToken, SwapType.BUY, _id, _after);
    }


    function cancelSellSwap(
        address _BaseToken, // to buy
        address _QuoteToken, // to pay with
        bytes32 _id, // swaps hash
        bytes32 _after  // optional to skip
    ) external {
        _cancelSwap(_BaseToken, _QuoteToken, SwapType.SELL, _id, _after);
    }


    function _cancelSwap(
        address _BaseToken, // to buy
        address _QuoteToken, // to pay with
        SwapType _type, // to pay with
        bytes32 _id, // swaps hash
        bytes32 _after  // (optional) to reduce iteration over swaps
    // ideally hash of the last bid with equal or higher price
    ) private {

        // Locating data in storage
        SwapBook storage book = (_type == SwapType.BUY ?
            buySwapBooks : sellSwapBooks
        )[keccak256(abi.encode(_BaseToken, _QuoteToken))];

        mapping(bytes32 => Swap) storage swaps = book.swaps;
        Swap memory swap = swaps[_id];
        bool willDelete = false;

        if (book.top == _id) {
            book.top = swap.next;
            willDelete = true;
        } else {

            if (_after == bytes32(0) || swaps[_after].price == 0) {
                // Starting from top if _after is unset or misplaced
                _after = book.top;
            }


            // Iterating to find a bid pointing to _id
            Swap storage removeAfter = swaps[_after];
            while (removeAfter.price > 0) {
                if (removeAfter.next == _id) {
                    removeAfter.next = swap.next;
                    willDelete = true;
                    break;
                }
                removeAfter = swaps[removeAfter.next];
            }

        }

        if (willDelete) {
            require(msg.sender == swap.wallet, "Wrong wallet");
            delete swaps[_id];
            emit SwapCanceled(_BaseToken, _QuoteToken, _type, swap.wallet, _id);
        }
    }


    struct SwapData {
        bytes32 id;
        uint256 amount;
        uint256 price;
        address wallet;
    }


    function getSwapBook(
        address _BaseToken, // token to buy
        address _QuoteToken, // quote token to pay with
        SwapType _type,
        uint256 _size, // how many swaps to get
        bytes32 _after // pagination
    )
    external view returns (SwapData[] memory) {
        // TODO: opposite pair guard

        // Locating data in storage
        SwapBook storage book = (_type == SwapType.BUY ?
            buySwapBooks : sellSwapBooks
        )[keccak256(abi.encode(_BaseToken, _QuoteToken))];
        mapping(bytes32 => Swap) storage swaps = book.swaps;
        bytes32 id = _after == bytes32(0) ? book.top : _after;
        Swap storage swap = swaps[id];

        uint256 size = _size;
        SwapData[] memory buySwaps = new SwapData[](size);
        for (uint256 i=0; i < size; i++) {
            if (swap.amount == 0) {
                // end of book
                // trimming buySwaps into a smaller list
                // by resetting the for loop
                buySwaps = new SwapData[](i);
                if (i == 0) return buySwaps;

                id = book.top;
                swap = swaps[id];
                size = i;
                i = 0;
            }
            buySwaps[i] = SwapData(
                id,
                swap.amount,
                swap.price,
                swap.wallet
            );
            id = swap.next;
            swap = swaps[id];
        }
        return buySwaps;
    }


    function _maybeTransfer(address _Token, address _from, address _to, uint256 _amount)
    private returns (bool) {
        (bool success, bytes memory returnData) =
        _Token.call(
            abi.encodePacked(
                ERC20(_Token).transferFrom.selector,
                abi.encode(_from, _to, _amount)
            )
        );

        if (success) {
            return abi.decode(returnData, (bool));
        } else {
            return false;
        }
    }

}


