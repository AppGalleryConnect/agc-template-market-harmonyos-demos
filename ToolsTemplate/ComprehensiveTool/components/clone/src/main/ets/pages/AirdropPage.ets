import { common } from '@kit.AbilityKit';
import { FileDetail, FileVo } from '../model/FileVo';
import { onKnockShareEnd, onKnockShareStart } from '../service/KnockFileShareService';
import { AirdropPageVM } from '../viewmodel/AirdropPageVM';


@ComponentV2
struct AirdropPage {
  vm: AirdropPageVM = AirdropPageVM.instance
  @Local selectedFiles: FileVo[] = []
  @Local context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.vm.context = this.context
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        if (this.vm.imageFileDetail.count !== 0) {
          this.titleBuilder('图片', this.vm.imageFileDetail)
        }
        if (this.vm.videoFileDetail.count !== 0) {
          this.titleBuilder('视频', this.vm.videoFileDetail)
        }
        if (this.vm.documentFileDetail.count !== 0) {
          this.titleBuilder('文档', this.vm.documentFileDetail)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('发送文件')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
    .onHidden(() => {
      // 移除碰一碰监听
      onKnockShareEnd()
    })
    .onShown(() => {
      // 添加碰一碰监听
      onKnockShareStart()
    })
  }

  @Builder
  titleBuilder(title: string, fileDetail: FileDetail) {
    Row() {
      Image($r('app.media.clone_contact'))
        .width(48)
        .height(48)
        .margin({ left: 12, right: 12 })
      Column() {
        Text() {
          Span(title)
          Span(`(${fileDetail.count}/${fileDetail.count})`)
        }
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 2 })

        Text() {
          Span('大小：')
          Span(`${fileDetail.size}`)
        }
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}


@Builder
export function AirdropPageBuilder() {
  AirdropPage()
}