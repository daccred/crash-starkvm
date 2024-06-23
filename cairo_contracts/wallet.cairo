use starknet::ContractAddress;

#[starknet::interface]
pub trait IWallet<TContractState> {
    fn request_funds(ref self: TContractState, address: ContractAddress);
    fn send_funds(ref self: TContractState, receiver: ContractAddress, amount: u256);
    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;
}

#[starknet::contract]
pub mod Wallet {
    use starknet::{ContractAddress, get_caller_address};
    #[storage]
    struct Storage {
        balances: LegacyMap::<ContractAddress, u256>,
    }

    #[abi(embed_v0)]
    impl WalletImpl of super::IWallet<ContractState> {
        fn request_funds(ref self: ContractState, address: ContractAddress) {
            self.balances.write(address, self.balances.read(address) + 100);
        }

        fn send_funds(ref self: ContractState, receiver: ContractAddress, amount: u256) {
            let sender: ContractAddress = get_caller_address();
            let sender_balance: u256 = self.balances.read(sender);
            let receiver_balance: u256 = self.balances.read(receiver);

            assert(sender_balance >= amount, 'INSUFICIENT FUNDS');

            self.balances.write(sender, sender_balance - amount);

            self.balances.write(receiver, receiver_balance + amount);
        }

        fn get_balance(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }
    }
}
