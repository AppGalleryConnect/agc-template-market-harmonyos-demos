import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { BookInfo } from '../model/Book';

/*
 * 碰一碰、一抓一放监听
 */
export class ImmersiveListener {
  private static shareBook: BookInfo;
  private static coverFilePath: string;

  public static immersiveListening(book: BookInfo,coverFilePath: string) {
    ImmersiveListener.shareBook = book;
    ImmersiveListener.coverFilePath = coverFilePath;
    // 监听碰一碰
    harmonyShare.on('knockShare', ImmersiveListener.immersiveCallback);
    // 监听一抓一放
    harmonyShare.on('gesturesShare', ImmersiveListener.immersiveCallback);
  }

  public static immersiveDisablingListening() {
    // 取消监听
    harmonyShare.off('knockShare', ImmersiveListener.immersiveCallback);
    harmonyShare.off('gesturesShare', ImmersiveListener.immersiveCallback);
  }

  private static immersiveCallback = (sharableTarget: harmonyShare.SharableTarget) => {

    console.info(`sharebookid is ${ImmersiveListener.shareBook!.id},sharebookcover is ${ImmersiveListener.coverFilePath}`)
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      // todo 指定数据类型
      utd: utd.UniformDataType.HYPERLINK,
      // todo 指定分享内容
      content: `https://linking.xiaobingtang.cn/BookRead?id=${ImmersiveListener.shareBook!.id}`,
      // todo  根据title,description,thumbnailUri会生成不同的卡片模板，具体可参考设置配套的卡片样式。
      thumbnailUri: fileUri.getUriFromPath(ImmersiveListener.coverFilePath),
      title: ImmersiveListener.shareBook!.name,
      description: ImmersiveListener.shareBook!.description
    });
    sharableTarget.share(shareData);
  }
  // public static setCurrentIndex(currentIndex: number) {
  //   ImmersiveListener.vm.dramaInfo!.curIndex = currentIndex
  // }
}
