#[starknet::interface]
pub trait IStudentPortal<TContractState> {
    fn registerStudent(ref self: TContractState,_dateOfBirth: u8,_name: felt252,_email: felt252,_state: felt252,_country: felt252) -> u8;

    fn updateStudent(ref self: TContractState,_studentId: u8, _dateOfBirth: u8,_name: felt252,_email: felt252,_state: felt252,_country: felt252);

    fn deleteStudent(ref self: TContractState, _studentId: u8);

    fn getStudent(self: @TContractState, _studentId: u8) -> (u8, felt252, felt252, felt252, felt252);
}

pub mod Errors {
    pub const NOT_OWNER: felt252 = 'not_owner';
    pub const NAME_REQUIRED: felt252 = 'name_required';
    pub const EMAIL_REQUIRED: felt252 = 'email_required';
    pub const DOB_REQUIRED: felt252 = 'dob_required';
    pub const STUDENT_NOT_FOUND: felt252 = 'student_not_found';
}

#[starknet::contract]
pub mod StudentPortal {

    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use OwnableComponent::InternalTrait;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, event::EventEmitter,storage::Map};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        studentcount: u32,
        students: Map<u8, Student>,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Student {
        dateOfBirth: u8,
        name: felt252,
        email: felt252,
        state: felt252,
        country: felt252
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        StudentCreated: StudentCreated,
        StudentUpdated: StudentUpdated,
        StudentDeleted: StudentDeleted,
        #[flat]
        OwnableEvent: OwnableComponent::Event, 
    }

    #[derive(Drop, starknet::Event)]
    pub struct StudentCreated { 
        student_id: u8, 
        name: felt252, 
        country: felt252 
    }

    #[derive(Drop, starknet::Event)]
    pub struct StudentUpdated { 
        student_id: u8, 
        name: felt252, 
        country: felt252 
    }

    #[derive(Drop, starknet::Event)]
    pub struct StudentDeleted { 
        student_id: u8 
    }


    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.ownable.initializer(initial_owner);
    }

    #[abi(embed_v0)]
    impl StudentPortalImpl of super::IStudentPortal<ContractState> {
        
    }
}
