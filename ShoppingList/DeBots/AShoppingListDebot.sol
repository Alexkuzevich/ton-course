pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./base/Debot.sol";
import "./base/Terminal.sol";
import "./base/Menu.sol";
import "./base/AddressInput.sol";
import "./base/ConfirmInput.sol";
import "./base/Upgradable.sol";
import "./base/Sdk.sol";
import "../ShoppingList/ShoppingList.sol";
import "../Interfaces/AShoppingList.sol";
import "../Interfaces/IShoppingList.sol";
import "../Interfaces/IMultisig.sol";

abstract contract AShoppingListDebot is Debot, Upgradable{

    bytes m_icon;
    TvmCell m_ShoppingListCode; // contract code
    TvmCell m_ShoppingListData; // contract data
    TvmCell m_ShoppingListStateInit; // contract StateInit
    PurchasesSummary purchasesSummary; // Statistics of paid and unpaid purchases
    address m_address;  // contract address
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial contract balance


    function setShoppingListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_ShoppingListCode = code;
        m_ShoppingListData = data;
        m_ShoppingListStateInit = tvm.buildStateInit(m_ShoppingListCode, m_ShoppingListData);
    }

    function onSuccess() virtual public view {
        _getPurchasesSummary(tvm.functionId(setPurchasesSummary));
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Hey! I'll help you with managing your purchases!\nPlease enter your public key",false);
    }
    
    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a shopping list ...");
            TvmCell deployState = tvm.insertPubkey(m_ShoppingListStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your shopping list contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            _getPurchasesSummary(tvm.functionId(setPurchasesSummary));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your shopping list contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        IMultisig(m_msigAddress).submitTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(m_address, INITIAL_BALANCE, false, false, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfContractIsInitialized), m_address);
    }

    function checkIfContractIsInitialized(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
            TvmCell deployState = tvm.insertPubkey(m_ShoppingListStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: deployState,
                call: {AShoppingList, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        sdkError;
        exitCode;
        deploy();
    }

    function _getPurchasesSummary(uint32 callBackId) virtual public view {
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

    function setPurchasesSummary(PurchasesSummary _purchasesSummary) virtual public {
        purchasesSummary = _purchasesSummary;
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function getDebotInfo() virtual public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "ShoppingList DeBot";
        version = "v1.0";
        publisher = "Alexander Kuzevich";
        key = "Shopping List manager";
        author = "Alexander Kuzevich";
        support = address(0);
        hello = "Hey, I'm a Shopping List DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
}