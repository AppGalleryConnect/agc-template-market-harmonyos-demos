import fs from '@ohos.file.fs';
import { fileUri } from '@kit.CoreFileKit';

@Builder
export function messageAvatarComponent(type: number, faceURL: string, avatarList: string[][], count: number) {
  // type: 1: 单聊；其他是群聊
  // faceURL: 单聊和已设置的群聊头像
  // avatarList：未设置群聊头像的群成员头像二位数据
  // count：群成员数量
  Column({ space: count > 4 ? 2 : 4 }) {
    if (type === 1) {
      Image(faceURL.startsWith('http') ? faceURL : $r('app.media.' + faceURL))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
    } else {
      if (faceURL.length > 0 && messageAccessSync(faceURL)) {
        Image(faceURL)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Fill)
      } else {
        ForEach(avatarList, (rowAvatar: string[]) => {
          Row({ space: count > 4 ? 2 : 4 }) {
            ForEach(rowAvatar, (avatar: string) => {
              Image($r('app.media.' + avatar))
                .width(count < 5 ? $r('app.float.vp_20') : 40 / 3.0)
                .aspectRatio(1)
                .objectFit(ImageFit.Fill)
            }, (avatar: string, index: number) => avatar + index);
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }, (rowAvatar: string[], index: number) => rowAvatar.join() + index.toString());
      }
    }
  }
  .width($r('app.float.vp_48'))
  .height($r('app.float.vp_48'))
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .backgroundColor($r('app.color.color_F1F3F5'))
  .borderRadius($r('sys.float.corner_radius_level6'))
  .clip(true)
}

export function messageAccessSync(url: string) {
  let isExist: boolean = false;
  try {
    if (url?.startsWith('file:')) {
      url = new fileUri.FileUri(url).path;
    }
    isExist = fs.accessSync(url);
  } catch (error) {
    isExist = false;
  }
  return isExist;
}

export const messageAvatarBuilder: WrappedBuilder<[number, string, string[][], number]> =
  wrapBuilder(messageAvatarComponent);