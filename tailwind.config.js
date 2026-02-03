/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './gallery.html', './news.html'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Noto Sans KR"', 'sans-serif'],
        serif: ['"Nanum Myeongjo"', 'serif'],
      },
      colors: {
        brand: {
          green: '#2F5233',
          'green-dark': '#1e3a21',
          light: '#F4F9F4',
          accent: '#B1D8B7',
          sand: '#EFEBE2',
          cream: '#FDFCFA',
        },
      },
      animation: {
        float: 'float 6s ease-in-out infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'scroll-hint': 'scrollHint 2s ease-in-out infinite',
      },
      keyframes: {
        float: { '0%, 100%': { transform: 'translateY(0px)' }, '50%': { transform: 'translateY(-20px)' } },
        scrollHint: { '0%, 100%': { transform: 'translateY(0)', opacity: '1' }, '50%': { transform: 'translateY(10px)', opacity: '0.5' } },
      },
    },
  },
  plugins: [],
};
