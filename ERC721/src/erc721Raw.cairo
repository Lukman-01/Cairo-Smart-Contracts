use starknet::ContractAddress;

#[starknet::interface]
pub trait ERC721ABI<TContractState>{
    fn name(self: @TContractState) -> ByteArray;
    fn symbol(self: @TContractState) -> ByteArray;
    fn token_uri(self: @TContractState, token_id: u256) -> ByteArray;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TContractState, owner: ContractAddress, operator: ContractAddress) -> bool;
}

#[starknet::contract]
pub mod ERC721{

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess
    };
    
    #[storage]
    pub struct Storage {
        _name: ByteArray,
        _symbol: ByteArray,
        _owners: Map<u256, ContractAddress>,
        _balances: Map<ContractAddress, u256>,
        _token_approvals: Map<u256, ContractAddress>,
        _operator_approvals: Map<(ContractAddress, ContractAddress), bool>,
        _base_uri: ByteArray
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
    }

    /// Emitted when `token_id` token is transferred from `from` to `to`.
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Transfer {
        #[key]
        pub from: ContractAddress,
        #[key]
        pub to: ContractAddress,
        #[key]
        pub token_id: u256
    }

    /// Emitted when `owner` enables `approved` to manage the `token_id` token.
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Approval {
        #[key]
        pub owner: ContractAddress,
        #[key]
        pub approved: ContractAddress,
        #[key]
        pub token_id: u256
    }

    /// Emitted when `owner` enables or disables (`approved`) `operator` to manage
    /// all of its assets.
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ApprovalForAll {
        #[key]
        pub owner: ContractAddress,
        #[key]
        pub operator: ContractAddress,
        pub approved: bool
    }

    #[abi(embed_v0)]
    impl ERC721Impl of super::ERC721ABI<ContractState> {

        fn name(self: @ContractState) -> ByteArray {
            self._name.read()
        }

        fn symbol(self: @ContractState) -> ByteArray {
            self._symbol.read()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self._base_uri.read()  // You may append the token_id to create dynamic URIs
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self._balances.read(account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self._owners.read(token_id)
        }

        fn transfer_from(
            ref self: ContractState, 
            from: ContractAddress, 
            to: ContractAddress, 
            token_id: u256
        ) {
            let caller = get_caller_address();

            assert!(caller == from || self.get_approved(token_id) == caller || self.is_approved_for_all(from, caller), "Not authorized to transfer");

            self._owners.write(token_id, to);
            self._balances.write(from, self._balances.read(from) - 1);
            self._balances.write(to, self._balances.read(to) + 1);

            self.emit(Event::Transfer(Transfer{from: ContractAddress, to: ContractAddress, token_id: u256}))

        }

        fn safe_transfer_from(
            ref self: ContractState, 
            from: ContractAddress, 
            to: ContractAddress, 
            token_id: u256, 
            _data: Span<felt252>
        ) {
            self.transfer_from(from, to, token_id);

        }

        fn approve(
            ref self: ContractState, 
            to: ContractAddress, 
            token_id: u256
        ) {
            let owner = self.owner_of(token_id);
            let caller = get_caller_address();

            assert!(caller == owner || self.is_approved_for_all(owner, caller), "Caller is not owner nor approved");

            self._token_approvals.write(token_id, to);

            // Emit Approval event
            Approval { 
                owner, 
                approved: to, 
                token_id 
            }.emit();
        }

        fn set_approval_for_all(
            ref self: ContractState, 
            operator: ContractAddress, 
            approved: bool
        ) {
            let owner = get_caller_address();
            self._operator_approvals.write((owner, operator), approved);

            // Emit ApprovalForAll event
            ApprovalForAll { 
                owner, 
                operator, 
                approved 
            }.emit();
        }

        fn get_approved(
            self: @ContractState, 
            token_id: u256
        ) -> ContractAddress {
            self._token_approvals.read(token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, 
            owner: ContractAddress, 
            operator: ContractAddress
        ) -> bool {
            self._operator_approvals.read((owner, operator))
        }
    }

}