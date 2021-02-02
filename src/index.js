import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import './css/main.scss';

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: 'Joel',
});

serviceWorker.unregister();
