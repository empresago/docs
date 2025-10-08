import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  // Sidebar principal para documentação do GoAB SDK
  tutorialSidebar: [
    {
      type: 'category',
      label: 'Android',
      items: [
        'android/intro',
        {
          type: 'category',
          label: 'Início Rápido',
          items: [
            'android/getting-started',
            'android/initialization',
          ],
        },
        {
          type: 'category',
          label: 'Referência',
          items: [
            'android/api-reference',
            'android/use-cases',
            'android/flow-examples',
          ],
        },
        {
          type: 'category',
          label: 'Suporte',
          items: [
            'android/troubleshooting',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'iOS',
      items: [
        'ios/intro',
        {
          type: 'category',
          label: 'Início Rápido',
          items: [
            'ios/getting-started',
            'ios/initialization',
          ],
        },
        {
          type: 'category',
          label: 'Referência',
          items: [
            'ios/api-reference',
            'ios/use-cases',
            'ios/flow-examples',
          ],
        },
        {
          type: 'category',
          label: 'Suporte',
          items: [
            'ios/troubleshooting',
          ],
        },
      ],
    },
  ],
};

export default sidebars;
