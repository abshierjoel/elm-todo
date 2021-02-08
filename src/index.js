import { Elm } from './Main.elm';
import './css/main.scss';

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: 'Joel',
});
