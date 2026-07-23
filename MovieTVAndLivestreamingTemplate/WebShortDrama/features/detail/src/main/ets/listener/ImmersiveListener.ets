import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { ShortDramaDetailListVM } from '../viewmodels/ShortDramaDetailListVM';
import { fileUri } from '@kit.CoreFileKit';

/*
 * 碰一碰监听
 */
export class ImmersiveListener {
  private static vm: ShortDramaDetailListVM = ShortDramaDetailListVM.instance;
  private static filePath: string = ''

  public static immersiveListening(filePath: string) {
    ImmersiveListener.filePath = filePath
    // 监听碰一碰
    harmonyShare.on('knockShare', ImmersiveListener.immersiveCallback);
    harmonyShare.on('gesturesShare', ImmersiveListener.immersiveCallback);
  }

  public static immersiveDisablingListening() {
    // 取消监听
    harmonyShare.off('knockShare', ImmersiveListener.immersiveCallback);
    harmonyShare.off('gesturesShare', ImmersiveListener.immersiveCallback);
  }

  private static immersiveCallback = (sharableTarget: harmonyShare.SharableTarget) => {

    let shareData: systemShare.SharedData = new systemShare.SharedData({
      // todo 指定数据类型
      utd: utd.UniformDataType.HYPERLINK,
      // todo 指定分享内容
      content: `https://linking.xiaobingtang.cn/DramaDetail?id=${ImmersiveListener.vm.dramaInfo.id}&index=${ImmersiveListener.vm.dramaInfo.curIndex}`,
      // todo  根据title,description,thumbnailUri会生成不同的卡片模板，具体可参考设置配套的卡片样式。
      thumbnailUri: fileUri.getUriFromPath(ImmersiveListener.filePath),
      title: ImmersiveListener.vm.dramaInfo.name,
      description: ImmersiveListener.vm.dramaInfo.description
    });
    sharableTarget.share(shareData);
  }

  public static setCurrentIndex(currentIndex: number) {
    ImmersiveListener.vm.dramaInfo!.curIndex = currentIndex
  }
}
