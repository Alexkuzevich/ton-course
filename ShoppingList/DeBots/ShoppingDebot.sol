pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./AShoppingListDebot.sol";
import "../ShoppingList/ShoppingList.sol";
import "../Interfaces/IShoppingList.sol";

contract ShoppingDebot is AShoppingListDebot{

    uint32 m_itemPrice;
    uint32 m_itemId;

    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}, {}, {} (unpaid/paid/total) purchases",
                    purchasesSummary.unpaidCount,
                    purchasesSummary.paidCount,
                    purchasesSummary.paidCount + purchasesSummary.unpaidCount
            ),
            sep,
            [
                MenuItem("Show purchases list","",tvm.functionId(getShoppingList)),
                MenuItem("Delete item from shopping list","",tvm.functionId(shoppingListDelete)),
                MenuItem("Pay for an item from your shopping list","",tvm.functionId(makePurchase))
            ]
        );
    }

    function getShoppingList(uint32 item) public view {
        item = item;
        optional(uint256) none;
        IShoppingList(m_address).getPurchases{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: none,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(_getShoppingList),
                onErrorId: 0
            }();
    }

    function _getShoppingList(Purchase[] purchases) public {
        if(purchases.length > 0) {
            Terminal.print(0, "Shopping list: ");
            for (uint32 i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string purchased;
                if (purchase.isPurchased) {
                    purchased = 'YES';
                } else {
                    purchased = 'NO';
                }
                Terminal.print(0, format("{}) {} in amount of {}. Is it bought? - {}, price: {}, added at {}", purchase.id,  purchase.name, purchase.amount, purchased, purchase.price, purchase.createdAt));
            }
        }
        else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function shoppingListDelete(uint32 item) public {
        item = item;
        if (purchasesSummary.paidCount + purchasesSummary.unpaidCount > 0) {
            Terminal.input(tvm.functionId(_shoppingListDelete), "Enter number of an item in the shopping list: ", false);
        } else {
            Terminal.print(0, "Unfortunately the entered number isn't found in the shopping list");
            _menu();
        }
    }

    function _shoppingListDelete(string item) public view {
        (uint256 num,) = stoi(item);
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).shoppingListDelete{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }

    function makePurchase(uint32 item) public {
        item = item;
        if (purchasesSummary.paidCount + purchasesSummary.unpaidCount > 0) {
            Terminal.input(tvm.functionId(_makePurchase), "Enter number of an item in the shopping list: ", false);
        } else {
            Terminal.print(0, "Unfortunately you have no items in your shopping list");
            _menu();
        }
    }

    function _makePurchase(string item) public {
        (uint256 num,) = stoi(item);
        m_itemId = uint32(num);

        Terminal.input(tvm.functionId(__makePurchase), "Enter the price of an item: ", false);
    }

    function __makePurchase(string item) public view {
        bool purchased;
        if (item == "YES") {
            purchased = true;
        }
        else if (item == "NO") {
            purchased = false;
        }
        else tvm.functionId(onError);
        optional(uint256) pubkey = 0;
        IShoppingList(m_address).makePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_itemId, m_itemPrice, purchased);
    }


    function _getPurchasesSummary(uint32 callBackId) public override view {
        optional(uint256) none;
        IShoppingList(m_address).getPurchasesSummary{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: callBackId,
            onErrorId: 0
        }();
    }

    function setPurchasesSummary(PurchasesSummary _purchasesSummary) public override {
        purchasesSummary = _purchasesSummary;
        _menu();
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping DeBot";
        version = "v1.0";
        publisher = "Alexander Kuzevich";
        key = "Shopping List manager";
        author = "Alexander Kuzevich";
        support = address(0);
        hello = "Hey, I'm a Shopping DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

}
