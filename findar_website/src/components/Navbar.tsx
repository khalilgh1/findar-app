'use client';

import Link from 'next/link';
import { useState } from 'react';

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="fixed top-0 w-full bg-white shadow-md z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16 items-center">
          <div className="flex items-center">
            <Link href="/" className="text-2xl font-bold text-blue-600">
              Findar
            </Link>
          </div>
          
          {/* Desktop Menu */}
          <div className="hidden md:flex space-x-8">
            <Link href="#hero" className="text-gray-700 hover:text-blue-600 transition">
              Home
            </Link>
            <Link href="#features" className="text-gray-700 hover:text-blue-600 transition">
              Features
            </Link>
            <Link href="#about" className="text-gray-700 hover:text-blue-600 transition">
              About
            </Link>
            <Link href="#contact" className="text-gray-700 hover:text-blue-600 transition">
              Contact
            </Link>
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden">
            <button
              onClick={() => setIsOpen(!isOpen)}
              className="text-gray-700 hover:text-blue-600"
            >
              <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                {isOpen ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                )}
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      {isOpen && (
        <div className="md:hidden bg-white border-t">
          <div className="px-2 pt-2 pb-3 space-y-1">
            <Link href="#hero" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
              Home
            </Link>
            <Link href="#features" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
              Features
            </Link>
            <Link href="#about" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
              About
            </Link>
            <Link href="#contact" className="block px-3 py-2 text-gray-700 hover:text-blue-600">
              Contact
            </Link>
          </div>
        </div>
      )}
    </nav>
  );
}
