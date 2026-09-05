import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    {
      type: 'category',
      label: 'Pesquisa In-App',
      collapsed: false,
      items: [
        {
          type: 'category',
          label: 'Android',
          items: [
            'android-survey/intro',
            {
              type: 'category',
              label: 'Início Rápido',
              items: [
                'android-survey/getting-started',
                'android-survey/initialization',
              ],
            },
            'android-survey/api-reference',
          ],
        },
        {
          type: 'category',
          label: 'iOS',
          items: [
            'ios-survey/intro',
            {
              type: 'category',
              label: 'Início Rápido',
              items: [
                'ios-survey/getting-started',
                'ios-survey/initialization',
              ],
            },
            'ios-survey/api-reference',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'Testes A/B',
      collapsed: false,
      items: [
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
            'android/api-reference',
            'android/use-cases',
            'android/flow-examples',
            {
              type: 'category',
              label: 'Suporte',
              items: ['android/troubleshooting'],
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
            'ios/api-reference',
            'ios/use-cases',
            'ios/flow-examples',
            {
              type: 'category',
              label: 'Suporte',
              items: ['ios/troubleshooting'],
            },
          ],
        },
      ],
    },
  ],
};

export default sidebars;
