#[starknet::interface]
pub trait IMessage<TContractState> {
    fn send_message(ref self: TContractState, message: ByteArray);
    fn get_message(self: @TContractState) -> ByteArray;
}

#[starknet::contract]
pub mod Message {
    use starknet::{ContractAddress, get_caller_address};
    #[storage]
    struct Storage {
        messages: LegacyMap::<ContractAddress, ByteArray>,
    }

    #[abi(embed_v0)]
    impl MessageImpl of super::IMessage<ContractState> {
        fn send_message(ref self: ContractState, message: ByteArray) {
            let caller: ContractAddress = get_caller_address();
            self.messages.write(caller, message);
        }

        fn get_message(self: @ContractState) -> ByteArray {
            let caller: ContractAddress = get_caller_address();
            self.messages.read(caller)
        }
    }
}
