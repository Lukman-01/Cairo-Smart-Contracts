import { useState, useMemo } from 'react';
import WalletBar from './WalletBar';
import { useAccount, useContract, useSendTransaction } from "@starknet-react/core";
import abi from "../abi/abi.json";

export default function App() {
  const [activeTab, setActiveTab] = useState('account');
  const [name, setName] = useState('');
  const [age, setAge] = useState('');

  const contractAddress = "0x2dd7f3723abc383644097696d21c2aee2b3282f12978a27a4586ad7f71f829d";
  const { address: userAddress } = useAccount();
  console.log(userAddress);
  console.log(contractAddress)

  const { contract } = useContract({
    abi,
    address: contractAddress,
  });
  
  const ageBigInt = BigInt(age);
  const byteArray = function(){
    
  }

  const calls = useMemo(() => {
    if (!contract) return [];
    return [contract.populate("createAccount", [name, ageBigInt])];

  }, [contract, userAddress, name, age]);

  const { send: writeAsync, data: writeData } = useSendTransaction({
    calls,
  });

  const handleSubmit = async (event) => {
    event.preventDefault();
    console.log("Form submitted with name", name, "and age", age);
    if (writeAsync) {
      writeAsync();
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 to-indigo-200 p-4">
      <div className="container mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8 text-indigo-800 drop-shadow-md">
          DBank - Decentralized Banking
        </h1>
        <WalletBar />
        <div className="w-full max-w-3xl mx-auto bg-white rounded-xl shadow-2xl overflow-hidden">
          <div className="flex bg-indigo-600 text-white">
            {['account', 'deposit', 'withdraw', 'transfer', 'balance'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`flex-1 py-3 px-4 text-center capitalize transition-colors ${
                  activeTab === tab
                    ? 'bg-indigo-800 font-semibold'
                    : 'hover:bg-indigo-700'
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          <div className="p-6">
            {activeTab === 'account' && (
              <div>
                <h2 className="text-2xl font-semibold mb-4 text-indigo-800">Create Account</h2>
                <p className="text-gray-600 mb-4">Set up your new bank account here.</p>
                <div className="space-y-4">
                  <div>
                    <label htmlFor="name" className="block text-sm font-medium mb-1 text-indigo-700">
                      Name
                    </label>
                    <input
                      type="text"
                      id="name"
                      className="w-full p-2 border border-indigo-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="John Doe"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                    />
                  </div>
                  <div>
                    <label htmlFor="age" className="block text-sm font-medium mb-1 text-indigo-700">
                      Age
                    </label>
                    <input
                      type="number"
                      id="age"
                      className="w-full p-2 border border-indigo-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="18"
                      value={age}
                      onChange={(e) => setAge(e.target.value)}
                    />
                  </div>
                  <button 
                  className="w-full bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700 transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                  onClick={handleSubmit}
                  >
                    Create Account
                  </button>
                </div>
              </div>
            )}

            {activeTab === 'deposit' && (
              <div>
                <h2 className="text-2xl font-semibold mb-4 text-indigo-800">Deposit Funds</h2>
                <p className="text-gray-600 mb-4">Add money to your account.</p>
                <div className="space-y-4">
                  <div>
                    <label htmlFor="deposit-amount" className="block text-sm font-medium mb-1 text-indigo-700">
                      Amount
                    </label>
                    <input
                      type="number"
                      id="deposit-amount"
                      className="w-full p-2 border border-indigo-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="0.00"
                    />
                  </div>
                  <button className="w-full bg-green-600 text-white py-2 rounded-md hover:bg-green-700 transition-colors focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2">
                    Deposit
                  </button>
                </div>
              </div>
            )}

            {activeTab === 'withdraw' && (
              <div>
                <h2 className="text-2xl font-semibold mb-4 text-indigo-800">Withdraw Funds</h2>
                <p className="text-gray-600 mb-4">Withdraw money from your account.</p>
                <div className="space-y-4">
                  <div>
                    <label htmlFor="withdraw-amount" className="block text-sm font-medium mb-1 text-indigo-700">
                      Amount
                    </label>
                    <input
                      type="number"
                      id="withdraw-amount"
                      className="w-full p-2 border border-indigo-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="0.00"
                    />
                  </div>
                  <button className="w-full bg-red-600 text-white py-2 rounded-md hover:bg-red-700 transition-colors focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2">
                    Withdraw
                  </button>
                </div>
              </div>
            )}

            {activeTab === 'transfer' && (
              <div>
                <h2 className="text-2xl font-semibold mb-4 text-indigo-800">Transfer Funds</h2>
                <p className="text-gray-600 mb-4">Send money to another account.</p>
                <div className="space-y-4">
                  <div>
                    <label htmlFor="recipient" className="block text-sm font-medium mb-1 text-indigo-700">
                      Recipient Address
                    </label>
                    <input
                      type="text"
                      id="recipient"
                      className="w-full p-2 border border-indigo-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="0x..."
                    />
                  </div>
                  <div>
                    <label htmlFor="transfer-amount" className="block text-sm font-medium mb-1 text-indigo-700">
                      Amount
                    </label>
                    <input
                      type="number"
                      id="transfer-amount"
                      className="w-full p-2 border border-indigo-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="0.00"
                    />
                  </div>
                  <button className="w-full bg-yellow-600 text-white py-2 rounded-md hover:bg-yellow-700 transition-colors focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2">
                    Transfer
                  </button>
                </div>
              </div>
            )}

            {activeTab === 'balance' && (
              <div>
                <h2 className="text-2xl font-semibold mb-4 text-indigo-800">Account Balance</h2>
                <p className="text-gray-600 mb-4">View your current balance.</p>
                <p className="text-4xl font-bold mb-4 text-indigo-600">0.00 ETH</p>
                <button className="w-full bg-indigo-100 text-indigo-800 py-2 rounded-md hover:bg-indigo-200 transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
                  Refresh Balance
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}