export default function AboutUs() {
  return (
    <section id="about" className="py-20 bg-gradient-to-br from-blue-50 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div>
            <div className="inline-block px-4 py-2 bg-blue-100 text-blue-600 rounded-full text-sm font-semibold mb-4">
              ABOUT US
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-6">
              Who We Are
            </h2>
            <p className="text-lg text-gray-700 mb-6">
              We are a passionate team of developers, designers, and real estate enthusiasts dedicated to transforming the property search experience. Founded with a vision to make real estate accessible to everyone, Findar combines innovation with simplicity.
            </p>
            <p className="text-lg text-gray-700 mb-6">
              Our mission is to bridge the gap between property seekers and their dream homes through technology that understands your needs and delivers personalized results.
            </p>
            <div className="space-y-4">
              <div className="flex items-start">
                <div className="flex-shrink-0">
                  <div className="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                  </div>
                </div>
                <div className="ml-4">
                  <h4 className="text-lg font-semibold text-gray-900">Innovation First</h4>
                  <p className="text-gray-600">Constantly evolving to bring you the latest technology</p>
                </div>
              </div>
              <div className="flex items-start">
                <div className="flex-shrink-0">
                  <div className="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                  </div>
                </div>
                <div className="ml-4">
                  <h4 className="text-lg font-semibold text-gray-900">Customer Focused</h4>
                  <p className="text-gray-600">Your satisfaction drives everything we do</p>
                </div>
              </div>
              <div className="flex items-start">
                <div className="flex-shrink-0">
                  <div className="flex items-center justify-center h-12 w-12 rounded-md bg-blue-600 text-white">
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                  </div>
                </div>
                <div className="ml-4">
                  <h4 className="text-lg font-semibold text-gray-900">Trust & Transparency</h4>
                  <p className="text-gray-600">Building lasting relationships through honesty and reliability</p>
                </div>
              </div>
            </div>
          </div>

          {/* Right Content - Team/Company Visual */}
          <div className="relative h-96 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl overflow-hidden shadow-xl">
            <div className="absolute inset-0 flex items-center justify-center text-white text-center p-8">
              <div>
                <svg className="w-32 h-32 mx-auto mb-4 text-white opacity-90" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                <p className="text-xl font-semibold">Dedicated Team</p>
                <p className="text-blue-100 mt-2">Working together to build your future</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
