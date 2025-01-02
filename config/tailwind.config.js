const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/models/**/*.rb',
    './app/views/**/*.{erb,haml,html,slim}',
    'config/locales/**/*.yml'
  ],
  theme: {
    fontFamily: {
      mincho: ['游ゴシック体', 'Yu Gothic', 'YuGothic', 'ヒラギノ角ゴシック Pro', 'Hiragino Kaku Gothic Pro', 'メイリオ', 'Meiryo', 'Osaka', 'ＭＳ Ｐゴシック', 'MS PGothic', 'sans-serif'],
    },
    extend: {
      fontFamily: {
        sans: ['Noto Sans JP', 'ui-sans-serif', 'system-ui', 'Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {
    extend: {
      textColor: ['visited'],
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
