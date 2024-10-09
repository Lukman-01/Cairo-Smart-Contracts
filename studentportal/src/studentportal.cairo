#[starknet::interface]
pub trait IStudentPortal<TContractState> {
    fn register_student(ref self: TContractState, date_of_birth: u32, name: ByteArray, email: ByteArray, state: ByteArray, country: ByteArray) -> u32;

    fn update_student(ref self: TContractState, student_id: u32, date_of_birth: u32, name: ByteArray, email: ByteArray, state: ByteArray, country: ByteArray);

    fn delete_student(ref self: TContractState, student_id: u32);

    fn get_student(self: @TContractState, student_id: u32) -> (u32, ByteArray, ByteArray, ByteArray, ByteArray);
}

#[starknet::contract]
pub mod StudentPortal {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use OwnableComponent::InternalTrait;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, event::EventEmitter, storage::Map};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        student_count: u32,
        students: Map<u32, Student>,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Student {
        date_of_birth: u32,
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
        student_id: u32, 
        name: ByteArray, 
        country: ByteArray 
    }

    #[derive(Drop, starknet::Event)]
    pub struct StudentUpdated { 
        student_id: u32, 
        name: ByteArray, 
        country: ByteArray 
    }

    #[derive(Drop, starknet::Event)]
    pub struct StudentDeleted { 
        student_id: u32 
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.ownable.initializer(initial_owner);
    }

    #[abi(embed_v0)]
    impl StudentPortalImpl of super::IStudentPortal<ContractState> {
        fn register_student(ref self: ContractState, date_of_birth: u32, name: ByteArray, email: ByteArray, state: ByteArray, country: ByteArray) -> u32 {
            assert!(name.len() != 0, "Name is required.");
            assert!(email.len() != 0, "Email is required.");
            assert!(date_of_birth != 0, "Date of birth is required.");

            let student_id = self.student_count.read();
            self.student_count.write(self.student_count.read() + 1);

            let student = Student {
                date_of_birth,
                name,
                email,
                state,
                country,
            };

            self.students.write(student_id, student);

            self.emit(Event::StudentCreated(StudentCreated {
                student_id,
                name,
                country,
            }));

            student_id
        }

        fn update_student(ref self: ContractState, student_id: u32, date_of_birth: u32, name: ByteArray, email: ByteArray, state: ByteArray, country: ByteArray) {
            assert!(self.students(student_id), "Student not found.");
            assert!(name.len() != 0, "Name is required.");
            assert!(email.len() != 0, "Email is required.");
            assert!(date_of_birth != 0, "Date of birth is required.");

            let updated_student = Student {
                date_of_birth,
                name,
                email,
                state,
                country,
            };

            self.students.write(student_id, updated_student);

            self.emit(Event::StudentUpdated(StudentUpdated {
                student_id,
                name,
                country,
            }));
        }

        fn delete_student(ref self: ContractState, student_id: u32) {
            assert!(self.students(student_id), "Student not found.");

            self.students.delete(student_id);

            self.emit(Event::StudentDeleted { student_id });
        }

        fn get_student(self: @ContractState, student_id: u32) -> (u32, ByteArray, ByteArray, ByteArray, ByteArray) {
            assert!(self.students.exists(student_id), "Student not found.");

            let student = self.students.read(student_id);
            (
                student.date_of_birth,
                student.name,
                student.email,
                student.state,
                student.country,
            )
        }
    }
}
