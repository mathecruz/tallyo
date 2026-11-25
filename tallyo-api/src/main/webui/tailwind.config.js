/** @type {import('tailwindcss').Config} */
import PrimeUI from "tailwindcss-primeui";

module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {
      colors: {
        brand: {
          blue: "#0F5FFF",
          "blue-dark": "#0B4FDB",
          green: "#12B886",
          navy: "#2B3350",
          "gray-light": "#B9BCC8",
          "gray-mid": "#9A9DA8",
        },
      },
      fontFamily: {
        sans: ["Gilroy", "Poppins", "Montserrat", "system-ui", "sans-serif"],
      },
    },
  },
  plugins: [PrimeUI],
};
