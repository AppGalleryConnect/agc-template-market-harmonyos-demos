import { WindowParam } from 'common';
import { BrushMenuContentBuilder } from '../comp/BrushContent';
import { CommonConstants } from './Constant';

/** window路由 */
export const sheetParam: WindowParam = {
  name: CommonConstants.WINDOW_NAME,
  builder: wrapBuilder(BrushMenuContentBuilder),
  attachParam: '',
  align: Alignment.Center,
}