import type {ReactNode} from 'react';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type GuiaItem = {
  title: string;
  to: string;
  description: ReactNode;
};

const GuiaList: GuiaItem[] = [
  {
    title: 'Pesos automáticos',
    to: '/pesos-automaticos',
    description: (
      <>
        Deixe a GoAB mover o tráfego para a variante que está convertendo melhor. Entenda o
        ciclo de ajuste e a estatística por trás: probabilidade de ser a melhor, degraus e
        limites.
      </>
    ),
  },
];

export default function HomepageGuias(): ReactNode {
  return (
    <section className={styles.guias}>
      <div className="container">
        <Heading as="h2" className="text--center">
          Guias e conceitos
        </Heading>
        <p className="text--center">
          Explicações sobre como recursos da plataforma funcionam por dentro.
        </p>
        <div className={styles.cards}>
          {GuiaList.map(({title, to, description}) => (
            <Link key={to} to={to} className={styles.card}>
              <Heading as="h3">{title}</Heading>
              <p>{description}</p>
              <span className={styles.cta}>Ler o guia →</span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
