import { useState } from 'react'
import './App.css'
import WalletBar from "./WalletBar.jsx";
function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center px-4">
      <WalletBar />
      <div className="bg-white rounded-lg shadow-md p-6 w-full max-w-md">
        <h1 className="text-2xl font-bold text-center text-gray-800 mb-6">Smart Contract Counter</h1>
        
        <div className="space-y-6">
          <div className="flex justify-center">
            <button
              className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline transition duration-300 ease-in-out"
            >
              Get Current Count
            </button>
          </div>
          
          <div className="text-center">
            <span className="text-3xl font-bold text-gray-700">
              0
            </span>
          </div>
          
          <div className="flex space-x-2">
            <input
              type="number"
              placeholder="Enter new count"
              className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            />
            <button
              className="bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline transition duration-300 ease-in-out"
            >
              Set Count
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
