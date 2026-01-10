'use client';
import { useState } from 'react';

export default function Features() {
  const features = [
    {
      title: 'Advanced Search',
      description: 'Find your perfect property using powerful filters including location, price range, number of bedrooms, bathrooms, property type, and more. Our intelligent search helps you discover exactly what you\'re looking for.',
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      ),
      gradient: 'from-blue-500 to-cyan-500',
    },
    {
      title: 'Save Favorites',
      description: 'Bookmark properties that catch your eye and create your personal collection. Access your saved listings anytime, compare options, and never lose track of properties you love.',
      icon: (
        <svg className="w-12 h-12" fill="currentColor" viewBox="0 0 24 24">
          <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
        </svg>
      ),
      gradient: 'from-rose-500 to-pink-500',
    },
    {
      title: 'Property Listings',
      description: 'List your properties with ease. Upload multiple photos, add detailed descriptions, set your price, and reach thousands of potential buyers or renters instantly.',
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
      ),
      gradient: 'from-emerald-500 to-teal-500',
    },
    {
      title: 'Real-time Updates',
      description: 'Stay informed with instant notifications about new listings matching your criteria, price changes, and important updates. Never miss an opportunity.',
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
      ),
      gradient: 'from-amber-500 to-orange-500',
    },
    {
      title: 'Direct Contact',
      description: 'Connect directly with property owners and agents through our secure messaging system. Schedule viewings, ask questions, and negotiate deals seamlessly.',
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
        </svg>
      ),
      gradient: 'from-purple-500 to-indigo-500',
    },
    {
      title: 'Verified Listings',
      description: 'Browse with confidence through our verified listings from trusted real estate professionals. Every property is checked for authenticity and accuracy.',
      icon: (
        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
      ),
      gradient: 'from-green-500 to-emerald-500',
    },
  ];

  const [activeFeature, setActiveFeature] = useState(0);

  return (
    <section id="features" className="py-24 bg-gradient-to-b from-white to-blue-50">
      <div className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <div className="inline-block px-4 py-2 bg-blue-100 text-blue-600 rounded-full text-sm font-semibold mb-4">
            FEATURES
          </div>
          <h2 className="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
            Everything You Need in One App
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Findar provides all the tools you need for a seamless real estate experience
          </p>
        </div>

        {/* Feature Detail Slider */}
        <div className="bg-white rounded-3xl shadow-2xl overflow-hidden relative">
          <div className="grid grid-cols-1 lg:grid-cols-2">
            {/* Screenshot Side */}
            <div className={`bg-gradient-to-br ${features[activeFeature].gradient} p-16 flex items-center justify-center relative overflow-hidden min-h-[600px]`}>
              {/* Decorative background elements */}
              <div className="absolute -top-20 -left-20 w-64 h-64 bg-white/20 rounded-full blur-3xl" />
              <div className="absolute -bottom-20 -right-20 w-64 h-64 bg-white/20 rounded-full blur-3xl" />
              
              {/* Phone mockup */}
              <div className="relative z-10">
                <div className="w-80 h-[640px] bg-gray-900 rounded-[3rem] shadow-2xl p-3 relative">
                  {/* Phone notch */}
                  <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-40 h-6 bg-gray-900 rounded-b-3xl z-10" />
                  
                  {/* Screen */}
                  <div className="w-full h-full bg-white rounded-[2.5rem] overflow-hidden flex items-center justify-center relative">
                    <div className={`w-full h-full bg-gradient-to-br ${features[activeFeature].gradient} opacity-10 flex items-center justify-center`}>
                      <div className="text-gray-400 scale-150">
                        {features[activeFeature].icon}
                      </div>
                    </div>
                    
                    {/* Placeholder text */}
                    <div className="absolute bottom-8 text-center">
                      <p className="text-gray-500 text-sm">Feature Screenshot</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Content Side */}
            <div className="p-16 flex flex-col justify-center">
              {/* Icon */}
              <div className={`w-24 h-24 bg-gradient-to-br ${features[activeFeature].gradient} rounded-2xl flex items-center justify-center text-white mb-8 shadow-xl`}>
                {features[activeFeature].icon}
              </div>
              
              <h3 className="text-5xl font-bold text-gray-900 mb-8">
                {features[activeFeature].title}
              </h3>
              
              <p className="text-2xl text-gray-600 leading-relaxed mb-10">
                {features[activeFeature].description}
              </p>

              {/* Navigation */}
              <div className="space-y-6">
                {/* Progress dots */}
                <div className="flex space-x-3">
                  {features.map((_, index) => (
                    <button
                      key={index}
                      onClick={() => setActiveFeature(index)}
                      className={`h-3 rounded-full transition-all duration-300 ${
                        index === activeFeature 
                          ? 'w-16 bg-gradient-to-r ' + features[activeFeature].gradient
                          : 'w-3 bg-gray-300 hover:bg-gray-400'
                      }`}
                    />
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Navigation Buttons */}
          <button
            onClick={() => setActiveFeature((prev) => (prev === 0 ? features.length - 1 : prev - 1))}
            className="absolute left-4 top-1/2 transform -translate-y-1/2 w-14 h-14 rounded-full bg-white shadow-xl hover:shadow-2xl flex items-center justify-center transition-all hover:scale-110 z-20"
          >
            <svg className="w-7 h-7 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button
            onClick={() => setActiveFeature((prev) => (prev === features.length - 1 ? 0 : prev + 1))}
            className="absolute right-4 top-1/2 transform -translate-y-1/2 w-14 h-14 rounded-full bg-white shadow-xl hover:shadow-2xl flex items-center justify-center transition-all hover:scale-110 z-20"
          >
            <svg className="w-7 h-7 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>

        {/* Call to Action */}
        <div className="mt-16 text-center">
          <button className="bg-gradient-to-r from-blue-600 to-cyan-600 text-white px-10 py-4 rounded-full font-semibold text-lg hover:from-blue-700 hover:to-cyan-700 transform hover:scale-105 transition-all duration-300 shadow-lg hover:shadow-xl">
            Explore All Features
          </button>
        </div>
      </div>
    </section>
  );
}
