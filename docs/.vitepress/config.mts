import { defineConfig } from 'vitepress'
import sidebar from './data/sidebar'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Immersive Home",
  description: "A VitePress Site",
  themeConfig: {
    siteTitle: false,
    logo: {
      light: '/logo-dark.png',
      dark: '/logo-light.png'
    },
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Usage', link: '/' },
      { text: 'Development', link: '/development/' },
      { text: 'Reference', link: sidebar['/reference/'][0].items[0].link }
    ],
    search: {
      provider: 'local'
    },
    sidebar,

    socialLinks: [
      { icon: 'github', link: 'https://github.com/nitwel/immersive-home' },
      { icon: 'twitter', link: 'https://twitter.com/immersive_home' },
      { icon: 'discord', link: 'https://discord.gg/QgUnAzNVTx' }
    ]
  }
})
