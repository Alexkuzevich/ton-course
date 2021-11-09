pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../Interfaces/IShoppingList.sol";

contract ShoppingList is IShoppingList{
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 101 - No sender key
     * 102 - purchase not found
     */

    modifier onlyOwner() {
        require(m_ownerPubkey != 0, 101);
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_count;
    uint256 m_ownerPubkey;
    mapping(uint32 => Purchase) m_purchases;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function shoppingListAdd(string name, uint32 amount) public override onlyOwner {
        m_count++;
        m_purchases[m_count] = Purchase(m_count, name, amount, now, false, 0);
    }

    function shoppingListDelete(uint32 id) public override onlyOwner {
        require(m_purchases.exists(id), 102);
        delete m_purchases[id];
        m_count--;
    }

    function makePurchase(uint32 id, uint32 price, bool isPurchased) public override onlyOwner {
        optional(Purchase) purchase = m_purchases.fetch(id);
        require(purchase.hasValue(), 102);
        Purchase thisPurchase = purchase.get();
        thisPurchase.isPurchased = isPurchased;
        thisPurchase.price = price;
        m_purchases[id] = thisPurchase;
    }

    function getPurchases() public view override returns (Purchase[] purchases) {
        string name;
        uint32 amount;
        uint64 createdAt;
        bool isPurchased;
        uint32 price;

        for((uint32 id, Purchase purchase) : m_purchases) {
            name = purchase.name;
            amount = purchase.amount;
            createdAt = purchase.createdAt;
            isPurchased = purchase.isPurchased;
            price = purchase.price;
            purchases.push(Purchase(id, name, amount, createdAt, isPurchased, price));
       }
    }

    function getPurchasesSummary() public view override returns (PurchasesSummary purchasesSummary) {
        uint32 paidCount;
        uint32 unpaidCount;

        for((, Purchase purchase) : m_purchases) {
            if  (purchase.isPurchased) {
                paidCount ++;
            } else {
                unpaidCount ++;
            }
        }
        purchasesSummary = PurchasesSummary( paidCount, unpaidCount);
    }
}