pragma ton-solidity >= 0.35.0;

interface IMultisig {
    function submitTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        bool fullBalance,
        TvmCell payload)
    external returns (uint64 transId);
}