/** @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    files: ["*.html", "./src/**/*.rs"],
    transform: {
      rs: (content) => content.replace(/(?:^|\s)class:/g, ' '),
    },
  },

  theme: {
    colors: {
      white: '#f1f9ec',
      black: '#080b04',
      primary: '#2c4bd5',
      secondary: '#6a2f73',
      accent: '#ba5699'
    }
  },
  plugins: [],
}

