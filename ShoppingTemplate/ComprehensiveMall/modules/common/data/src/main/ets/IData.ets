import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';

import { GlobalStateMgr } from './model/GlobalStateMgr';
import { Persistence } from './model/Persistence';

export class IData {

  public readonly global: GlobalStateMgr = AppStorageV2.connect(
    GlobalStateMgr,
    'GlobalStateMgr',
    () => new GlobalStateMgr()
  )!;

  public readonly local: Persistence = PersistenceV2.connect(Persistence, 'Persistence', () => new Persistence())!;
}
