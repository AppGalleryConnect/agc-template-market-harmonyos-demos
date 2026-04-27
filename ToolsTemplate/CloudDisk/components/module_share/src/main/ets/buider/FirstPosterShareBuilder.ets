import { ShareKinds, ShareSheetParams, ShareUsefullTimeParam, ShreGetCodeParam } from '../model/Model'
import { firstShareList } from '../constants/Constants'
import { componentSnapshot } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { PosterShare } from '../utils/SystemShare'
import { WxShareViewModel } from '../viewModel/WxShareViewModel'
import { QqShareViewModel } from '../viewModel/QqShareViewModel'
import { PopViewUtils } from '../utils/PopViewUtils'
import { SelectRow } from '../componts/SelectRow'
import { SetGetCodeBuilder } from './SetGetCode'
import { SetUseFullTimeBuilder } from './SetUsefullTime'
import { ShareExtureInfoViewModel } from '../viewModel/ShareExtureInfoViewModel'
import { FileInfo, MockService, PreferenceConstant, PreferenceUtil } from 'common'
import { RandomGenerator } from '../utils/RandomGenerator'

@Builder
export function FirstPosterShareBuilder(params: ShareSheetParams) {
  FirstPosterShare({
    params: params,
  })
}

@ComponentV2
export struct FirstPosterShare {
  @Local shareList: ShareKinds[][] = firstShareList
  @Param posterShare: PosterShare = new PosterShare()
  @Require @Param params: ShareSheetParams
  @Local wxShareViewModel: WxShareViewModel = WxShareViewModel.instance
  @Local qqShareViewModel: QqShareViewModel = QqShareViewModel.instance
  shareExtureInfoVM = new ShareExtureInfoViewModel()
  blockUsefullTime = (id: number, value: string | Resource) => {
    let result = value as Resource
    getContext().resourceManager.getStringValue(result.id)
      .then((values: string) => {
        console.log('11111111----转换结果:', values);
        this.shareExtureInfoVM.usefullTime = values
        this.shareExtureInfoVM.usefullTimeId = id
      })
      .catch((error: Error) => {
        console.error('转换失败:', error);
      });

  }
  blockContent = (value: string) => {
    console.debug(`11111111-----${value}`)
    this.shareExtureInfoVM.randomCode = value
  }

  aboutToAppear(): void {
    // 自动设置提取码开关如果打开,自动设置提取码
    if (PreferenceUtil.getInstance().has(PreferenceConstant.SHARE_LINK_EXTRACTIONCODE_SWITCH)) {
      const value = RandomGenerator.generateSecureRandomString(4)
      this.shareExtureInfoVM.randomCode = value
    }
  }

  build() {
    List() {
      ForEach(this.shareList, (item: ShareKinds[]) => {
        ListItem() {
          Row({ space: 29 }) {
            ForEach(item, (value: ShareKinds) => {
              Column({ space: 8 }) {
                Image($r(value.icon)).width(48).height(48)
                Text(value.name)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_primary'))
              }
              .onClick(() => {
                switch (value.id) {
                  case 'create_poster':
                    try {
                      componentSnapshot.get(this.params.qrCodeInfo.id, ((err: Error, pixmap: image.PixelMap) => {
                        if (err) {
                          return
                        }
                        this.params.onPost(true, pixmap)
                      }))
                    } catch (e) {
                    }
                    break
                  case 'wechat':
                    this.wxShareViewModel.newsWebShare(this.params.qrCodeInfo)
                    break;
                  case 'wechat_feed':
                    this.wxShareViewModel.newsWebShare(this.params.qrCodeInfo)
                    break;
                  case 'qq':
                    this.qqShareViewModel.share(this.params.qrCodeInfo)
                    break
                  case 'system_share':
                    this.posterShare.share(this.params.qrCodeInfo)
                    break
                  case 'copy_link':
                    this.posterShare.copy(this.params.qrCodeInfo)
                    break
                }
                PopViewUtils.closeSheet()
              })
            }, (item: ShareKinds, idx: number) => JSON.stringify(item) + idx)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ top: 20, bottom: 10 })
        }
      }, (item:  ShareKinds[], idx: number) => JSON.stringify(item) + idx)
      ListItem() {
        SelectRow({ title: $r('app.string.usefull_time'), smallTitle: this.shareExtureInfoVM.usefullTime })
          .onClick(() => {
            let params: ShareUsefullTimeParam = {
              blockUsefullTime: this.blockUsefullTime,
              blockUsefullTimeId: this.shareExtureInfoVM.usefullTimeId
            }
            PopViewUtils.showSheet<ShareUsefullTimeParam>(wrapBuilder(SetUseFullTimeBuilder), {
              backgroundColor: $r('sys.color.background_secondary'),
              detents: [SheetSize.FIT_CONTENT],
              showClose: false
            }, params);
          })
      }

      ListItem() {
        SelectRow({
          title: $r('app.string.share_link_auto_code'),
          smallTitle: '',
          isSwitch: true,
          isOpen: PreferenceUtil.getInstance().has(PreferenceConstant.SHARE_LINK_EXTRACTIONCODE_SWITCH),
          blockSwitchResult: (value: boolean) => {
            this.shareExtureInfoVM.autoInputCode = value
            if (value) {
              PreferenceUtil.getInstance().put(PreferenceConstant.SHARE_LINK_EXTRACTIONCODE_SWITCH, true)
            } else {
              PreferenceUtil.getInstance().delete(PreferenceConstant.SHARE_LINK_EXTRACTIONCODE_SWITCH)
            }
          }
        })
      }

      ListItem() {
        SelectRow({ title: $r('app.string.random_code'), smallTitle: this.shareExtureInfoVM.randomCode })
          .onClick(() => {
            let params: ShreGetCodeParam = {
              blockContent: this.blockContent
            }
            PopViewUtils.showSheet<ShreGetCodeParam>(wrapBuilder(SetGetCodeBuilder), {
              backgroundColor: $r('sys.color.background_secondary'),
              detents: [SheetSize.FIT_CONTENT],
              showClose: false
            }, params);
          })
      }
    }
    .padding({ left: 24, right: 24, bottom: 24 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
}