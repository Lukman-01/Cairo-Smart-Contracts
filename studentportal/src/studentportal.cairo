use starknet::ByteArray;
pub mod Errors {
    use starknet::ByteArray;
    pub fn NOT_OWNER() -> ByteArray {
        ByteArray::from_felt252s("not_owner".encode())
    }
    
    pub fn NAME_REQUIRED() -> ByteArray {
        ByteArray::from_felt252s("name_required".encode())
    }

    pub fn EMAIL_REQUIRED() -> ByteArray {
        ByteArray::from_felt252s("email_required".encode())
    }

    pub fn DOB_REQUIRED() -> ByteArray {
        ByteArray::from_felt252s("dob_required".encode())
    }

    pub fn STUDENT_NOT_FOUND() -> ByteArray {
        ByteArray::from_felt252s("student_not_found".encode())
    }
}


#[starknet::interface]
pub trait IStudentPortal<TContractState> {
    fn registerStudent(ref self: TContractState,_dateOfBirth: u8,_name: ByteArray,_email: ByteArray,_state: ByteArray,_country: ByteArray) -> u8;

    fn updateStudent(ref self: TContractState,_studentId: u8, _dateOfBirth: u8,_name: ByteArray,_email: ByteArray,_state: ByteArray,_country: ByteArray);

    fn deleteStudent(ref self: TContractState, _studentId: u8);

    fn getStudent(self: @TContractState, _studentId: u8) -> (u8, ByteArray, ByteArray, ByteArray, ByteArray);
}

#[starknet::contract]
pub mod StudentPortal {

    use super::Errors;
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
        name: ByteArray,
        email: ByteArray,
        state: ByteArray,
        country: ByteArray
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
        name: ByteArray, 
        country: ByteArray 
    }

    #[derive(Drop, starknet::Event)]
    pub struct StudentUpdated { 
        student_id: u8, 
        name: ByteArray, 
        country: ByteArray 
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
    fn registerStudent(ref self: ContractState,_dateOfBirth: u8,_name: ByteArray,_email: ByteArray,_state: ByteArray,_country: ByteArray) -> u8 {

        assert(_name.len() != 0, Errors::NAME_REQUIRED());
        assert(_email.len() != 0, Errors::EMAIL_REQUIRED());
        assert(_date_of_birth != 0, Errors::DOB_REQUIRED());

        let student_id = self.studentcount.read() as u8;
        self.studentcount.write(self.studentcount.read() + 1);

        let student = Student {
            dateOfBirth: _dateOfBirth,
            name: _name,
            email: _email,
            state: _state,
            country: _country,
        };

        self.students.write(student_id, student);

        self.emit(Event::StudentCreated(StudentCreated {
            student_id,
            name: _name,
            country: _country,
        }));

        student_id
    }

    fn update_student(
        ref self: ContractState,
        _student_id: u8,
        _dateOfBirth: u8,
        _name: ByteArray,
        _email: ByteArray,
        _state: ByteArray,
        _country: ByteArray,
    ) {
        // Ensure that student exists
        assert(self.students.exists(_student_id), Errors::STUDENT_NOT_FOUND());

        // Ensure that the fields are valid
        assert(_name.len() != 0, Errors::NAME_REQUIRED());
        assert(_email.len() != 0, Errors::EMAIL_REQUIRED());
        assert(_dateOfBirth != 0, Errors::DOB_REQUIRED());

        // Read the student and update details
        let student = self.students.read(_student_id);
        let updated_student = Student {
            dateOfBirth: _dateOfBirth,
            name: _name,
            email: _email,
            state: _state,
            country: _country,
        };

        self.students.write(_student_id, updated_student);


        self.emit(Event::StudentUpdated(StudentUpdated {
            student_id: _student_id,
            name: _name,
            country: _country,
        }));
    }

    fn delete_student(ref self: ContractState, _student_id: u8) {

        assert(self.students.exists(_student_id), Errors::STUDENT_NOT_FOUND());

        self.students.delete(_student_id);

        self.emit(Event::StudentDeleted { student_id: _student_id });
    }

    fn get_student(self: @ContractState, _student_id: u8) -> (u8, ByteArray, ByteArray, ByteArray, ByteArray) {
        
        assert(self.students.exists(_student_id), Errors::STUDENT_NOT_FOUND());

        let student = self.students.read(_student_id);
        return (
            student.dateOfBirth,
            student.name,
            student.email,
            student.state,
            student.country,
        );
    }
}

}
