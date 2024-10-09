import { useState, useEffect } from 'react';
import './App.css';
import WalletBar from "./WalletBar.jsx";
import { useReadContract, useContract, useAccount } from "@starknet-react/core";
import abi from "./abi/abi.json";

function App() {
  const [count, setCount] = useState(0);
  const [newCount, setNewCount] = useState("");

  const contractAddress = "0x180093214030faef0885dd14ab35bd062471c6a2c3916c08073a0c4a4d2bb1f";

  // Fetch the current count from the contract
  const { data: readData, refetch: dataRefetch } = useReadContract({
    functionName: "get_count",
    args: [],
    abi: abi,
    address: contractAddress,
    watch: true,
    refetchInterval: 1000
  });

  // Refetch the count when readData changes
  useEffect(() => {
    if (readData && Array.isArray(readData)) {
      setCount(readData[0].toString());
    }
  }, [readData]);

  // Get the contract object
  const { contract } = useContract({
    abi: abi,
    address: contractAddress,
  });

  // Get the connected account
  const { account } = useAccount();

  // Handle the form submission to set the new count
  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!account) {
      console.error("No wallet connected");
      return;
    }

    try {
      // Invoke the set_count function using the connected account
      const response = await account.execute({
        contractAddress: contractAddress,
        entrypoint: "set_count",
        calldata: [parseInt(newCount)],
      });
      console.log("Transaction submitted: ", response);

      // Refetch the count after the transaction completes
      dataRefetch();
    } catch (error) {
      console.error("Error setting the count: ", error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center px-4">
      <WalletBar />
      <div className="bg-white rounded-lg shadow-md p-6 w-full max-w-md">
        <h1 className="text-2xl font-bold text-center text-gray-800 mb-6">Smart Contract Counter</h1>

        <div className="space-y-6">
          <div className="flex justify-center">
            <button
              className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline transition duration-300 ease-in-out"
              onClick={() => dataRefetch()}
            >
              Get Current Count
            </button>
          </div>

          <div className="text-center">
            <span className="text-3xl font-bold text-gray-700">
              {readData?.toString()}
            </span>
          </div>

          <form onSubmit={handleSubmit} className="flex space-x-2">
            <input
              type="number"
              value={newCount}
              onChange={(e) => setNewCount(e.target.value)}
              placeholder="Enter new count"
              className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            />
            <button
              type="submit"
              className="bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline transition duration-300 ease-in-out"
            >
              Set Count
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default App;
