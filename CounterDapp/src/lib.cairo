#[starknet::interface]
trait ICounter <TContractState> {
    fn get_count (self: @TContractState) -> u32;
    fn set_count (ref self: TContractState,  amount: u32);
}

#[starknet::contract]
mod Counter {
    #[storage]
    struct Storage {
        count: u32,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {

        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }

        fn set_count(ref self: ContractState, amount: u32) {
            let current_count: u32 = self.get_count();
            self.count.write(current_count + amount);
        }
    }
}