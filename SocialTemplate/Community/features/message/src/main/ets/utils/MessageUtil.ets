import { CMChatGroupMemberInfo } from 'instant_messaging';
import { util } from '@kit.ArkTS';

/**
 * 消息工具类
 */
export class MessageUtil {
  /**
   * 解析群成员列表
   * @param memberList 群成员列表
   */
  static parseGroupAvatar(memberList: CMChatGroupMemberInfo[]) {
    let count = 0;
    let groupAvatar: string[][] = [];
    for (let index = 0; index < memberList.length; index++) {
      const element = memberList[index];
      let rowAvatar: string[] = groupAvatar[count] ?? [];
      rowAvatar.push(element.avatarUrl);
      groupAvatar[count] = rowAvatar;

      if (memberList.length < 5) {
        if (memberList.length === 3) {
          if (index === 0) {
            count++;
          }
        }
        if (rowAvatar.length >= 2) {
          count++;
        }
      } else {
        if (memberList.length === 5) {
          if (index === 1) {
            count++;
          }
        } else if (memberList.length === 7) {
          if (index === 0) {
            count++;
          }
        } else if (memberList.length === 8) {
          if (index === 1) {
            count++;
          }
        }
        if (rowAvatar.length >= 3) {
          count++;
        }
      }
      if (index >= 8) {
        break;
      }
    }
    return groupAvatar;
  }

  /*
  * 检查字符串的字节大小是否超出
  * str：待检查的字符串
  * maxLength: 最大字节长度，默认400字节
  * return boolean
  */
  static strOverByteLength(str: string, maxLength: number = 400) {
    let textEncoder = new util.TextEncoder();
    let result: Uint8Array = textEncoder.encodeInto(str);
    if (result.byteLength > maxLength) {
      return true;
    }
    return false;
  }
}