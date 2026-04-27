import { AddFriendTypeEnum } from '../utils/MessageEnum';

export interface AddFriendSingleModel {
  icon: Resource;
  title: ResourceStr;
  subtitle: ResourceStr;
  type: AddFriendTypeEnum;
}