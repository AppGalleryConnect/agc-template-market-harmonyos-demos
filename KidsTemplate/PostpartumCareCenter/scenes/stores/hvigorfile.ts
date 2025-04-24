import { harTasks } from '@ohos/hvigor-ohos-plugin';

import { hvigor } from '@ohos/hvigor';

import { customPlugin } from '@hw-agconnect/template-plugin';

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
