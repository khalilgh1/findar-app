'use client';

import Image from 'next/image';

export default function Hero() {
  return (
    <section id="hero" className="pt-20 bg-gradient-to-br from-blue-50 to-blue-100 min-h-screen flex items-center">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-6">
              Find Your Dream Property with <span className="text-blue-600">Findar</span>
            </h1>
            <p className="text-lg sm:text-xl text-gray-700 mb-8">
              Discover, buy, rent, and sell properties with ease. Findar is your ultimate real estate companion, bringing the best listings right to your fingertips.
            </p>
            <button className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-lg text-lg font-semibold transition shadow-lg hover:shadow-xl flex items-center space-x-3">
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M17.6,9.48l1.84-3.18c0.16-0.31,0.04-0.69-0.26-0.85c-0.29-0.15-0.65-0.06-0.83,0.22l-1.88,3.24 c-2.86-1.21-6.08-1.21-8.94,0L5.65,5.67c-0.19-0.29-0.58-0.38-0.87-0.2C4.5,5.65,4.41,6.01,4.56,6.3L6.4,9.48 C3.3,11.25,1.28,14.44,1,18h22C22.72,14.44,20.7,11.25,17.6,9.48z M7,15.25c-0.69,0-1.25-0.56-1.25-1.25 c0-0.69,0.56-1.25,1.25-1.25S8.25,13.31,8.25,14C8.25,14.69,7.69,15.25,7,15.25z M17,15.25c-0.69,0-1.25-0.56-1.25-1.25 c0-0.69,0.56-1.25,1.25-1.25s1.25,0.56,1.25,1.25C18.25,14.69,17.69,15.25,17,15.25z"/>
              </svg>
              <span>Download for Android</span>
            </button>
          </div>

          {/* Right Content - App Screenshots */}
          <div className="relative">
            <div className="relative z-10 bg-white rounded-2xl shadow-2xl p-6">
              <div className="aspect-[9/19] bg-gray-200 rounded-lg overflow-hidden">
                <div className="w-full h-full flex items-center justify-center text-gray-500">
                  {/* Placeholder for app screenshot */}
                  <p className="text-center px-4">App Screenshot Placeholder</p>
                </div>
              </div>
            </div>
            {/* Decorative elements */}
            <div className="absolute -top-6 -right-6 w-72 h-72 bg-blue-200 rounded-full opacity-50 blur-3xl"></div>
            <div className="absolute -bottom-6 -left-6 w-72 h-72 bg-blue-300 rounded-full opacity-50 blur-3xl"></div>
          </div>
        </div>
      </div>
    </section>
  );
}
