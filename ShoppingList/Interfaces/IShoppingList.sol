pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase {
    uint32 id;
    string name;
    uint32 amount;
    uint64 createdAt;
    bool isPurchased;
    uint32 price;
}

struct PurchasesSummary {
    uint32 paidCount;
    uint32 unpaidCount;
}

interface IShoppingList {
    function shoppingListAdd(string name, uint32 amount) external;
    function shoppingListDelete(uint32 id) external;
    function makePurchase(uint32 id, uint32 price, bool isPurchased) external;
    function getPurchases() external view returns (Purchase[] purchases);
    function getPurchasesSummary() external view returns (PurchasesSummary purchasesSummary);
}
