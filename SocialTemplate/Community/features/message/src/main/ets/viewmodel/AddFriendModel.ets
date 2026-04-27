import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  GlobalContext, MockAccountSingleModel, MOCK_ACCOUNT_LIST, PermissionUtil, TCLogger
} from 'common';
import { CreateGroupModel } from './CreateGroupModel';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { SearchContactTypeEnum } from '../utils/MessageEnum';
import { SearchGroupInfoModel } from './SearchGroupInfoModel';
import { SearchContactModel } from './SearchContactModel';
import { MessageGroupInfoModel } from './MessageGroupInfoModel';

const TAG = 'AddFriendModel';

@ObservedV2
export class AddFriendModel extends CreateGroupModel {
  @Trace pageTitle: string = '添加好友';
  @Trace groupList: MessageGroupInfoModel[] = [];
  @Trace localContactList: MockAccountSingleModel[] = MOCK_ACCOUNT_LIST;
  @Trace searchGroupList: SearchGroupInfoModel[] = [];
  @Trace searchContactList: SearchContactModel[] = [];
  @Trace isPhoneInput: boolean = false;

  searchContentChange(content: string) {
    if (content.length === 0) {
      this.searchGroupList = [];
      this.searchContactList = [];
      return;
    }

    this.isPhoneInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(content);
    if (this.isPhoneInput) {
      // 纯数字按照手机号搜索
      this.searchPhone(content);
    } else {
      // 其他字符按照群名称和联系人昵称搜索
      this.searchGroup(content);
      this.searchNickName(content);
    }
  }

  searchGroup(content: string) {
    this.searchGroupList = [];
    for (let index = 0; index < this.groupList.length; index++) {
      const element = this.groupList[index];
      let splits = this.splitSearchContent(element.groupName, content);
      let normalArr = splits[0];
      let lightArr = splits[1];
      if (lightArr.length > 0) {
        let searchGroup = new SearchGroupInfoModel();
        searchGroup.groupId = element.groupId;
        searchGroup.groupName = element.groupName;
        searchGroup.notification = element.notification;
        searchGroup.introduction = element.introduction;
        searchGroup.faceURL = element.faceURL;
        searchGroup.owner = element.owner;
        searchGroup.createTime = element.createTime;
        searchGroup.role = element.role;
        searchGroup.count = element.count;
        searchGroup.memberInfoList = element.memberInfoList;
        searchGroup.memberAvatarList = element.memberAvatarList;
        searchGroup.normalArr = normalArr;
        searchGroup.lightArr = lightArr;
        this.searchGroupList.push(searchGroup);
      }
    }
  }

  splitSearchContent(str: string, searchContent: string) {
    let normalArr: string[] = str.split(searchContent);
    let lightArr: string[] = [];
    if (normalArr.length > 1) {
      for (let index = 0; index < normalArr.length - 1; index++) {
        lightArr.push(searchContent);
      }
    }
    return [normalArr, lightArr]
  }

  searchNickName(content: string) {
    this.searchContactList = [];
    for (let index = 0; index < this.localContactList.length; index++) {
      const element = this.localContactList[index];
      let splits = this.splitSearchContent(element.nickName, content);
      this.pushContact(splits, element, SearchContactTypeEnum.CHAT_TYPE_NICK_NAME);
    }
  }

  searchPhone(content: string) {
    this.searchContactList = [];
    for (let index = 0; index < this.localContactList.length; index++) {
      const element = this.localContactList[index];
      let splits = this.splitSearchContent(element.phone, content);
      this.pushContact(splits, element, SearchContactTypeEnum.CHAT_TYPE_PHONE);
    }
  }

  pushContact(splits: string[][], element: MockAccountSingleModel, searchType: SearchContactTypeEnum) {
    let normalArr = splits[0];
    let lightArr = splits[1];
    if (lightArr.length > 0) {
      let searchContact = new SearchContactModel();
      searchContact.userId = element.userId;
      searchContact.nickName = element.nickName;
      searchContact.phone = element.phone;
      searchContact.avatarUrl = element.avatarUrl;
      searchContact.searchType = searchType;
      searchContact.normalArr = normalArr;
      searchContact.lightArr = lightArr;
      this.searchContactList.push(searchContact);
    }
  }

  async startScanForResult() {
    PermissionUtil.checkPermissions('ohos.permission.CAMERA').then(async (result: boolean) => {
      if (result) {
        if (canIUse('SystemCapability.Multimedia.Scan.Core')) {

          let scanOptions: scanBarcode.ScanOptions = {
            scanTypes: [scanCore.ScanType.ALL],
            enableMultiMode: true,
            enableAlbum: false
          };

          if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
            try {
              let result = await scanBarcode.startScanForResult(GlobalContext.getUIAbilityContext(), scanOptions);
              const memberIds = new Set(this.localContactList.map(item => item.userId));
              if (memberIds.has(result.originalValue)) {
                ChatJumpManager.gotoContactInfo(result.originalValue);
              } else {
                GlobalContext.getUIContext().getPromptAction().showToast({
                  message: '请扫描用户二维码'
                })
              }
            } catch (err) {
            }

            return;
          }
        }

        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '该设备不支持相机功能'
        })
      }

    }).catch((err: BusinessError) => {
      TCLogger.error(TAG, `checkPermissions error: ${JSON.stringify(err)}`);

    })

  }
}