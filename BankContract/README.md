# Contract with openzeppelin owner
ract-name Bank
   Compiling bank v0.1.0 (/home/ibukun/Desktop/Cairo-Smart-Contracts/BankContract/Scarb.toml)
    Finished release target(s) in 19 seconds
command: declare
class_hash: 0x67450bc5c176b443f884c0a861426c4e9aa00e0e4c6f7c631a4078946d74285
transaction_hash: 0x728a6bc5de9236f6a7248611f3c37d97a38a3c0aa26cd4db68962a369764ffa

ibukun@Ibukun:~/Desktop/Cairo-Smart-Contracts/BankContract$ sncast --url https://free-rpc.nethermind.io/sepolia-juno/ --account ibukun deploy --fee-token strk --class-hash 0x067450bc5c176b443f884c0a861426c4e9aa00e0e4c6f7c631a4078946d74285 --constructor-calldata 0x04a62cf5Bd7300cBc67B1F464357E5a6484267b606C93c80bB5d0BEb81DA1A0a
command: deploy
contract_address: 0x3bc9d8dc47cdc280d9b860b3ea2ada99fa0ac22171c795000bd5fef2fb1ff3
transaction_hash: 0x3383ecded7d7ae8dd772b9e06ed050294bb0f37933f5375b6150df9a781b3ac

# Contract without openzeppelin owner

ibukun@Ibukun:~/Desktop/Cairo-Smart-Contracts/BankContract$ sncast --url https://free-rpc.nethermind.io/sepolia-juno/ --account ibukun declare --fee-token strk --contract-name Bank
   Compiling bank v0.1.0 (/home/ibukun/Desktop/Cairo-Smart-Contracts/BankContract/Scarb.toml)
    Finished release target(s) in 20 seconds
command: declare
class_hash: 0x4b2f83b7b0decddaa9b81b72972f237543be352093829deacae0b1140b69d2b
transaction_hash: 0x1c86ee7ebe9bca7cad58d7de805cb7b1885a6540e191cc1708ed203a4176ef8
ibukun@Ibukun:~/Desktop/Cairo-Smart-Contracts/BankContract$ sncast --url https://free-rpc.nethermind.io/sepolia-juno/ --account ibukun deploy --fee-token eth --class-hash  0x4b2f83b7b0decddaa9b81b72972f237543be352093829deacae0b1140b69d2b
command: deploy
contract_address: 0x2dd7f3723abc383644097696d21c2aee2b3282f12978a27a4586ad7f71f829d
transaction_hash: 0x39929ec4d3c72d039df25c3cb2981aa25957487570ea4b8fb2769b2d1b450bc