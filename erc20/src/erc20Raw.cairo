use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> ByteArray;
    fn get_symbol(self: @TContractState) -> ByteArray;
    fn get_decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}


#[starknet::contract]
pub mod ERC20 {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess
    };

    #[storage]
    pub struct Storage {
        _name: ByteArray,
        _symbol: ByteArray,
        _decimal: u8,
        _total_supply: u256,
        _balances: Map<ContractAddress, u256>,
        _allowances: Map<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Transfer {
        #[key]
        pub from: ContractAddress,
        #[key]
        pub to: ContractAddress,
        pub value: u256
    }

     
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Approval {
        #[key]
        pub owner: ContractAddress,
        #[key]
        pub spender: ContractAddress,
        pub value: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState,name: ByteArray,symbol: ByteArray,decimal: u8) {
        self._name.write(name);
        self._symbol.write(symbol);
        self._decimal.write(decimal)
    }

    #[abi(embed_v0)]
    impl ERC20Impl of super::IERC20<ContractState> {
        fn get_name(self: @ContractState) -> ByteArray {
        
            self._name.read()
        }
        fn get_symbol(self: @ContractState) -> ByteArray {
            self._symbol.read()
        }
    
        fn get_decimals(self: @ContractState) -> u8 {
            self._decimal.read()
        }
    
        fn total_supply(self: @ContractState) -> u256 {
            self._total_supply.read()
        }
    
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self._balances.read(account)
        }
    
        fn allowance(self: @ContractState, owner: ContractAddress, spender:ContractAddress) -> u256 {
            self._allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();
            let mut sender_balance = self._balances.read(caller);

            assert(sender_balance >= amount, 'Insufficient Balance');

            sender_balance = sender_balance - amount;
            self._balances.write(caller, sender_balance);
            let mut recipient_balance = self._balances.read(recipient);
            recipient_balance = recipient_balance + amount;
            self._balances.write(recipient, recipient_balance);

            self.emit(Event::Transfer (Transfer{
                from: caller,
                to: recipient,
                value: amount,
            }));

            true
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            let caller = get_caller_address();
            let mut allowance = self._allowances.read((sender, caller));

            assert(allowance >= amount, 'Allowance Exceeded');

            allowance = allowance - amount;
            self._allowances.write((sender, caller), allowance);

            let mut sender_balance = self._balances.read(sender);
            assert(sender_balance >= amount, 'Insufficient Balance');
            sender_balance = sender_balance - amount;
            self._balances.write(sender, sender_balance);

            let mut recipient_balance = self._balances.read(recipient);
            recipient_balance = recipient_balance + amount;
            self._balances.write(recipient, recipient_balance);

            self.emit(Event::Transfer (Transfer{
                from: caller,
                to: recipient,
                value: amount,
            }));

            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let caller = get_caller_address();

            self._allowances.write((caller, spender), amount);

            self.emit(Event::Approval (Approval{
                owner: caller,
                spender,
                value: amount,
            }));

            true
        }
    }
}