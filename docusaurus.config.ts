import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'GoAB SDK Docs',
  tagline: 'SDKs para experimentos A/B, configurações remotas e pesquisas in-app',
  favicon: 'img/favicon.png',
  headTags: [
    {tagName: 'link', attributes: {rel: 'icon', href: '/img/favicon.ico', sizes: 'any'}},
  ],

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://docs.goab.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'empresago', // Usually your GitHub org/user name.
  projectName: 'docs', // Usually your repo name.
  deploymentBranch: 'gh-pages', // Branch to deploy to

  onBrokenLinks: 'throw',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/goab-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Início',
      logo: {
        alt: 'GoAB SDK Logo',
        src: 'img/Logo.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentação',
        },
        {
          type: 'html',
          position: 'right',
          value: '<a href="/login" class="button button--primary navbar__login-btn">Login</a>',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Plataformas',
          items: [
            {
              label: 'Teste App',
              to: '/teste-app',
            },
            {
              label: 'Survey App',
              to: '/survey',
            },
          ],
        },
        {
          title: 'Recursos',
          items: [
            {
              label: 'API Reference (Teste App)',
              to: '/teste-app',
            },
            {
              label: 'API Reference (Survey App)',
              to: '/survey',
            },
            {
              label: 'Troubleshooting',
              to: '/teste-app',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} GoAB SDK.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
