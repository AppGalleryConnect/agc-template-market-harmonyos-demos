import { TipsDialog } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { FontModel, fp2pxUtil } from 'base_common';
import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Observed
class PushDataImp implements PushData {
  pushContent: ResourceStr
  time: string
  read: boolean

  constructor(pushContent: ResourceStr, time: string, read: boolean) {
    this.pushContent = pushContent;
    this.time = time;
    this.read = read;
  }
}

interface PushData {
  pushContent: ResourceStr
  time: string
  read: boolean
}

@ComponentV2
export struct PushKit {
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  i: number = 1
  @Local pushData: Array<PushDataImp> = []
  @Param curBreakpoint: string = 'sm'
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel,
    () => new FontModel(this.getUIContext().getHostContext() as common.UIAbilityContext))!;
  dialogControllerImage: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      title: '温馨提示',
      content: '您确定将全部未读消息标记为已读？',
      primaryButton: {
        value: '取消',
        action: () => {
          this.dialogControllerImage.close()
        },
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          for (let index = 0; index < this.pushData.length; index++) {
            let tempData: PushDataImp = this.pushData[index]
            tempData.read = true
            this.pushData.splice(index, 1, tempData)
          }
          this.dialogControllerImage.close()
        }
      },
      onCheckedChange: () => {
        console.info('Callback when the checkbox is clicked')
      },
    }),
  })
  @Local unreadMessage: number = 0
  @Event backPop: () => void = () => {
  }

  aboutToAppear(): void {
    for (let y = 0; y < 6; y++) {
      this.pushData.push(new PushDataImp($r('app.string.system_message_content'), this.i + '小时前', false))
      this.i++
    }
    if (AppStorage.get('pushData') as PushDataImp !== undefined) {
      let pushData1: PushData = AppStorage.get('pushData') as PushData
      let data2: PushDataImp = new PushDataImp(pushData1.pushContent, pushData1.time, pushData1.read)
      this.pushData.unshift(data2)
      this.unreadMessage++
    }

  }

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .height('40vp')
            .width('40vp')
            .margin({ right: '8vp' })
            .onClick(() => {
              this.backPop()
            })

          Text('系统消息')
            .fontSize(fp2pxUtil(20))
            .fontWeight(FontWeight.Bold)
        }

        Image($r('app.media.ic_public_read'))
          .height('40vp')
          .width('40vp')
          .margin({ left: 96 })
          .onClick(() => {
            this.dialogControllerImage.open()
          })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)

      List() {
        ForEach(this.pushData, (item: PushDataImp, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.ic_ring'))
                  .width(40)
                  .height(40)
                  .margin({ top: 4 })

                Column() {
                  Row() {
                    Text('系统消息').fontWeight(400).fontSize(this.fontModel.getFg(16))
                  }
                  .height(22)

                  Row() {
                    Text(item.time).fontSize(this.fontModel.getFg(12)).fontColor($r('sys.color.font_tertiary'))
                    if (!item.read) {
                      Image($r('app.media.red_dot')).width(8).height(8).margin({ left: 4 })
                    }
                  }
                  .height(18)
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 8 })
              }
              .margin({ top: 4 })

              Divider()
                .vertical(false)
                .width('100%')
                .margin({ top: 10.5 })

              Row() {
                Text(item.pushContent)
                  .fontSize(this.fontModel.getFg(16))
                  .fontWeight(400)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .margin({ top: 10 })
            }

            .alignItems(HorizontalAlign.Start)
          }
          .onAppear(() => {
            try {
              item.read = true
              this.pushData.splice(index, 1, item)
              //减少角标
              this.unreadMessage--
              notificationManager.setBadgeNumber(this.unreadMessage)
            } catch (e) {
              console.error('Failed to setBadgeNumber. Cause: ' + JSON.stringify(e))
            }
          })
          .margin({ top: 8 })
        }, (item: PushDataImp) => new Date().toString())
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .width(this.curBreakpoint === 'lg' ? '70%' : '100%')
    }
    .margin({ top: this.windowTopHeight })
    .padding({ bottom: 32 + this.windowTopHeight, left: 12, right: 12 })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
  }
}