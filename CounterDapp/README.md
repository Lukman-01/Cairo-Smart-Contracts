# Deploying an account

sncast --url https://free-rpc.nethermind.io/sepolia-juno/ account create --name ibukun  --add-profile ibukun

ibukun@Ibukun:~$ cd .starknet_accounts ls -a -1

fund the account

sncast --url https://free-rpc.nethermind.io/sepolia-juno/ account deploy --name ibukun --fee-token eth --max-fee 9999999999999

# Declearing contract account

sncast --url https://free-rpc.nethermind.io/sepolia-juno/ --account ibukun declare --fee-token eth --contract-name Counter

# Deploy contract account

sncast --url https://free-rpc.nethermind.io/sepolia-juno/ --account ibukun deploy --fee-token eth --class-hash 0x23ebf32878c16cdb1172a0b24163eedbb0b6cc9ffef51baabc984dfa0a0cbdd

# Constructor arguments format

When calling a Cairo constructor or any function that accepts different types of arguments, the calldata will depend on the type of each argument. Cairo expects each argument to be passed in a specific way depending on its type.

Here’s how calldata is structured for different argument types:

### 1. **`felt252`**
- **Description**: A `felt252` is a 252-bit field element. It’s the most commonly used data type in Cairo for small integers and hashes.
- **Calldata format**: For each `felt252` argument, you pass a single value.
  - **Example**: `felt252 arg1 = 5` would be passed as `0x5`.

### 2. **`u256`**
- **Description**: A `u256` is a 256-bit unsigned integer, larger than `felt252`. It is passed as two `felt252` values, each representing the high and low 128 bits of the `u256` value.
- **Calldata format**: For each `u256` argument, pass two values: the first for the lower 128 bits, and the second for the upper 128 bits.
  - **Example**: `u256 arg2 = 340282366920938463463374607431768211457` would be split into two parts:
    - `low = 0x1` (lower 128 bits)
    - `high = 0x1` (upper 128 bits)
    - Passed as `0x1 0x1`.

### 3. **Structs**
- **Description**: When passing a struct to a constructor or function, Cairo expects each field in the struct to be passed as separate values.
- **Calldata format**: Flatten the struct into individual `felt252` or `u256` values (depending on the field types).
  - **Example**: For a struct like:
    ```rust
    struct MyStruct {
        field1: felt252,
        field2: u256,
    }
    ```
    With `field1 = 10` and `field2 = 512`, the calldata would be:
    - `0xA 0x200 0x0` (`field1` is `0xA`, and `field2` is split into `low = 0x200` and `high = 0x0`).

### 4. **Arrays (felt252[])**
- **Description**: Arrays are sequences of values, and Cairo expects the length of the array followed by the individual elements.
- **Calldata format**: First pass the length of the array, then the array elements.
  - **Example**: For an array `[5, 10, 15]`, the calldata would be:
    - `0x3 0x5 0xA 0xF` (`0x3` is the length of the array, followed by the array elements).

### 5. **Tuples**
- **Description**: A tuple groups multiple values, similar to a struct but without field names.
- **Calldata format**: Flatten the tuple values in the order they appear.
  - **Example**: For a tuple `(felt252, u256) = (5, 512)`, the calldata would be:
    - `0x5 0x200 0x0` (`5` for the `felt252` and `0x200 0x0` for the `u256`).

### Example Constructor

Suppose we have a constructor like this:
```rust
#[constructor]
fn constructor(ref self: ContractState, first: felt252, second: u256, arr: felt252[], tup: (felt252, u256)) {
    ...
}
```

- `first: felt252`: Single `felt252` value.
- `second: u256`: Two `felt252` values representing the `u256` (low and high bits).
- `arr: felt252[]`: An array of `felt252` values (length followed by the elements).
- `tup: (felt252, u256)`: A tuple with a `felt252` and `u256` (flattened into its components).

### Calldata for Deployment
```bash
sncast deploy \
    --fee-token strk \
    --class-hash 0x... \
    --constructor-calldata 0x5 0x200 0x0 0x3 0x5 0xA 0xF 0x7 0x400 0x1
```

- `0x5`: Value of `first` (`felt252`).
- `0x200 0x0`: Value of `second` (`u256`).
- `0x3 0x5 0xA 0xF`: Array length `3`, followed by values `[5, 10, 15]`.
- `0x7 0x400 0x1`: Tuple with `felt252 = 7` and `u256 = 1024`, split into `low = 0x400` and `high = 0x1`.

# Invoking Contracts
