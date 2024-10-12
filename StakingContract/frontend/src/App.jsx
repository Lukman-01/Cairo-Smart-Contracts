import { useState } from 'react';
import WalletBar from './WalletBar';
import { useAccount, useContract, useSendTransaction } from "@starknet-react/core";
//import abi from "../abi/abi.json";

export default function StakingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4 sm:px-6 lg:px-8">
      <WalletBar/>
      <div className="max-w-3xl mx-auto bg-white rounded-2xl shadow-xl overflow-hidden">
        <div className="px-6 py-8">
          <h1 className="text-4xl font-extrabold text-center text-blue-900 mb-8">Staking Dashboard</h1>

          <div className="space-y-10">
            {/* Admin Section */}
            <section className="border-b border-blue-200 pb-8">
              <h2 className="text-2xl font-semibold mb-6 text-blue-800">Admin Controls</h2>
              <div className="space-y-6">
                <div>
                  <label htmlFor="rewardDuration" className="block text-sm font-medium text-blue-700 mb-2">Set Reward Duration</label>
                  <div className="flex rounded-md shadow-sm">
                    <input type="number" name="rewardDuration" id="rewardDuration" className="flex-1 min-w-0 block w-full px-3 py-2 rounded-l-md border-2 border-blue-300 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Duration in seconds" />
                    <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-r-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors duration-200">Set</button>
                  </div>
                </div>
                <div>
                  <label htmlFor="rewardAmount" className="block text-sm font-medium text-blue-700 mb-2">Set Reward Amount</label>
                  <div className="flex rounded-md shadow-sm">
                    <input type="number" name="rewardAmount" id="rewardAmount" className="flex-1 min-w-0 block w-full px-3 py-2 rounded-l-md border-2 border-blue-300 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Amount" />
                    <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-r-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors duration-200">Set</button>
                  </div>
                </div>
              </div>
            </section>

            {/* User Staking Section */}
            <section className="border-b border-blue-200 pb-8">
              <h2 className="text-2xl font-semibold mb-6 text-blue-800">Staking</h2>
              <div className="space-y-6">
                <div>
                  <label htmlFor="stakeAmount" className="block text-sm font-medium text-blue-700 mb-2">Stake Tokens</label>
                  <div className="flex rounded-md shadow-sm">
                    <input type="number" name="stakeAmount" id="stakeAmount" className="flex-1 min-w-0 block w-full px-3 py-2 rounded-l-md border-2 border-blue-300 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Amount to stake" />
                    <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-r-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors duration-200">Stake</button>
                  </div>
                </div>
                <div>
                  <label htmlFor="withdrawAmount" className="block text-sm font-medium text-blue-700 mb-2">Withdraw Tokens</label>
                  <div className="flex rounded-md shadow-sm">
                    <input type="number" name="withdrawAmount" id="withdrawAmount" className="flex-1 min-w-0 block w-full px-3 py-2 rounded-l-md border-2 border-blue-300 focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Amount to withdraw" />
                    <button className="inline-flex items-center px-4 py-2 border border-transparent rounded-r-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors duration-200">Withdraw</button>
                  </div>
                </div>
              </div>
            </section>

            {/* Rewards Section */}
            <section>
              <h2 className="text-2xl font-semibold mb-6 text-blue-800">Rewards</h2>
              <div className="space-y-6">
                <div className="bg-blue-50 p-6 rounded-lg border-2 border-blue-200">
                  <p className="text-lg text-blue-800">Your Unclaimed Rewards: <span className="font-bold text-2xl">0.00</span></p>
                </div>
                <button className="w-full inline-flex justify-center items-center px-6 py-3 border border-transparent rounded-md shadow-sm text-lg font-medium text-white bg-yellow-500 hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500 transition-colors duration-200">
                  Claim Rewards
                </button>
              </div>
            </section>
          </div>
        </div>
      </div>
    </div>
  )
}