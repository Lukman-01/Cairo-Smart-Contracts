#[starknet::interface]
trait ITodolist<TContractState> {
    fn createTodo(ref self: TContractState, title: felt252, description: felt252) -> bool;
    fn getTodos(self: @TContractState) -> Array<Todo>;
    fn getTodo(self: @TContractState, index: u8) -> Todo;
    fn updateStatus(ref self: TContractState, index: u8, isDone: bool) -> bool;
}

#[starknet::contract]
pub mod TodoList {
    use starknet::ContractAddress;
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::array::ArrayTrait;
    use core::array::Array;
    use core::LegacyMap;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        todolist: LegacyMap::<u8, Todo>,
        todoId: u8,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Todo {
        id: u8,
        title: felt252,
        description: felt252,
        isDone: bool,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl Todolist of super::ITodolist<ContractState> {
        fn createTodo(ref self: ContractState, title: felt252, description: felt252) -> bool {
            let id = self.todoId.read();
            let currentId = id + 1;
            self._addTodo(currentId, title, description);
            self.todoId.write(currentId);
            true
        }

        fn updateStatus(ref self: ContractState, index: u8, isDone: bool) -> bool {
            // Read the existing Todo item
            let mut todo = self.todolist.read();
            // Update the isDone status
            todo.isDone = isDone;
            // Write the updated Todo back to storage
            self.todolist.write(index, todo);
            true
        }

        fn getTodos(self: @ContractState) -> Array<Todo> {
            let mut todos = ArrayTrait::new();
            let count = self.todoId.read();
            let mut index: u8 = 1;

            while index <= count {
                let todo = self.todolist.read(index);
                todos.append(todo);
                index += 1;
            }

            todos
        }

        fn getTodo(self: @ContractState, index: u8) -> Todo {
            self.todolist.read(index)
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn _addTodo(ref self: ContractState, id: u8, title: felt252, description: felt252) {
            let todo = Todo {
                id,
                title,
                description,
                isDone: false,
            };
            self.todolist.write(id, todo);
        }
    }
}
