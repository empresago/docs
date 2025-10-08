import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<'svg'>> | string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Fácil de Usar',
    Svg: require('@site/static/img/metric_image.svg').default,
    description: (
      <>
        SDK simples e intuitivo para implementar experimentos A/B em seus aplicativos Android e iOS.
        Integração rápida com apenas algumas linhas de código.
      </>
    ),
  },
  {
    title: 'Configuração Remota',
    Svg: require('@site/static/img/variants_image.png').default,
    description: (
      <>
        Altere configurações do seu app remotamente sem precisar de novas versões.
        Controle total sobre parâmetros e funcionalidades.
      </>
    ),
  },
  {
    title: 'Análise Avançada',
    Svg: require('@site/static/img/audience_image.svg').default,
    description: (
      <>
        Dashboard completo com métricas e análises dos seus experimentos.
        Tome decisões baseadas em dados reais dos usuários.
      </>
    ),
  },
];

function Feature({title, Svg, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        {typeof Svg === 'string' ? (
          <img src={Svg} className={styles.featureSvg} alt={title} />
        ) : (
          <Svg className={styles.featureSvg} role="img" />
        )}
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
