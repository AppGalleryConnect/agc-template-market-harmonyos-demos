import { AppStorageV2 } from '@kit.ArkUI';
import { CustomWindowModel } from './WindowModel';
import { FontModel } from './FontModel';
import { BreakpointModel } from './BreakpointModel';
import { CustomConfigModel } from './CustomConfigModel';
import { CustomPageModifier, CustomScrollModifier } from '../common/CustomModifier';

/**
 * 所有ViewModel的基类，支持UI动态观测WindowModel.ets
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace configInfo: CustomConfigModel = AppStorageV2.connect(CustomConfigModel, () => new CustomConfigModel())!
  @Trace windowModel: CustomWindowModel = AppStorageV2.connect(CustomWindowModel, () => new CustomWindowModel())!;
  @Trace fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace scrollModifier: CustomScrollModifier = new CustomScrollModifier();
  @Trace pageModifier: CustomPageModifier = new CustomPageModifier();
}