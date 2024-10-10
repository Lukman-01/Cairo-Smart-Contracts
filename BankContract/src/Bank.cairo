use starknet::{ContractAddress};

#[starknet::interface]
trait IBank<TContractState> {
    fn createAccount(ref self: TContractState, name:ByteArray, age:u8) -> u256;
    fn deposit(ref self: TContractState, amount: u256);
    fn transfer(ref self: TContractState,to:ContractAddress, amount:u256);
    fn withdraw(ref self: TContractState,_amount:u256);
    fn withdrawEther(ref self: TContractState,amount:u256);
}

#[starknet::contract]
mod  Bank{

    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use OwnableComponent::InternalTrait;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, get_caller_address, event::EventEmitter, storage::Map};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        usercount:u256,
        users:Map<ContractAddress, User>,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct User {
        balance: u256,
        name: ByteArray,
        age: u8,
        hasRegistered: bool,
    }

    mod Errors {
        const AlreadyRegistered: felt252 = 'Invalid owner';
        const NotRegistered: felt252 = 'Invalid Token';
        const InsufficientBalance: felt252 = 'UnAuthorized caller';
        const DepositTooLow: felt252 = 'Insufficient balance';
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AccountCreated: AccountCreated,
        DepositMade: DepositMade,
        TransferMade: TransferMade,
        WithdrawalMade: WithdrawalMade,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AccountCreated { 
        #[key]
        user:ContractAddress,
        name: ByteArray,
        age: u8 
    }

    #[derive(Drop, starknet::Event)]
    pub struct DepositMade { 
        #[key]
        user: ContractAddress, 
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    pub struct TransferMade { 
        #[key]
        from: ContractAddress, 
        to: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    pub struct WithdrawalMade { 
        #[key]
        user: ContractAddress, 
        amount: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.ownable.initializer(initial_owner);
    }

    #[abi(embed_v0)]
    impl BankImpl of super::IBank<ContractState> {
        fn createAccount(ref self: ContractState, name:ByteArray, age:u8) -> u256{
            let caller = get_caller_address();
            assert(self.users.read(caller).hasRegistered, Errors::AlreadyRegistered);

            let user_name = name.clone();
            let user_age = age.clone();

            let userlet = User {
                balance: 0,
                name,
                age,
                hasRegistered: true
            };

            self.users.write(caller, userlet);
            self.emit(Event::AccountCreated(AccountCreated{
                user: caller,
                name:user_name,
                age:user_age
            }));

            let usercount = self.usercount.read();
            self.usercount.write(usercount + 1);
            usercount

        }

        fn deposit(ref self: ContractState, amount: u256) {
            assert(amount > 0, Errors::DepositTooLow);
            let caller = get_caller_address();
            let mut user = self.users.read(caller);
            assert(user.hasRegistered, Errors::NotRegistered);

            user.balance += amount;
            self.users.write(caller, user);

            self.emit(Event::DepositMade(DepositMade {
                user: caller,
                amount
            }));
        }

        fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            let mut from_user = self.users.read(caller);
            assert(from_user.hasRegistered, Errors::NotRegistered);
            assert(from_user.balance >= amount, Errors::InsufficientBalance);

            let mut to_user = self.users.read(to);
            assert(to_user.hasRegistered, Errors::NotRegistered);

            from_user.balance -= amount;
            to_user.balance += amount;

            self.users.write(caller, from_user);
            self.users.write(to, to_user);

            self.emit(Event::TransferMade(TransferMade {
                from: caller,
                to,
                amount
            }));
        }

        fn withdraw(ref self: ContractState, _amount: u256) {
            let caller = get_caller_address();
            let mut user = self.users.read(caller);
            assert(user.hasRegistered, Errors::NotRegistered);
            assert(user.balance >= _amount, Errors::InsufficientBalance);

            user.balance -= _amount;
            self.users.write(caller, user);

            self.emit(Event::WithdrawalMade(WithdrawalMade {
                user: caller,
                amount:_amount
            }));

            
        }

        fn withdrawEther(ref self: ContractState, amount: u256) {
    
            self.withdraw(amount);
        }

    }

}
