import Hero from '@/components/Hero';
import Features from '@/components/Features';
import AboutUs from '@/components/AboutUs';
import ContactUs from '@/components/ContactUs';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';

export default function Home() {
  return (
    <main className="min-h-screen">
      <Navbar />
      <Hero />
      <Features />
      <AboutUs />
      <ContactUs />
      <Footer />
    </main>
  );
}
