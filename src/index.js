import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import './css/main.scss';

const app = Elm.Main.init({
  node: document.getElementById('root'),
});

app.ports.setTheme.subscribe((isDark) => {
  console.log('it be clicked!');
});

serviceWorker.unregister();
