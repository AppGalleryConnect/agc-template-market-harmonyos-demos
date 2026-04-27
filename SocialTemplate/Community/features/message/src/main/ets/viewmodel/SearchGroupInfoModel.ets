import { MessageGroupInfoModel } from './MessageGroupInfoModel';

@ObservedV2
export class SearchGroupInfoModel extends MessageGroupInfoModel {
  @Trace lightArr: string[] = [];
  @Trace normalArr: string[] = [];
}