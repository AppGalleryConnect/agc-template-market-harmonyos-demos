import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constants';
import { ShareKinds, ShareViewData } from '../common/ShareParams';
import { ShareContentType, ShareWay } from '../common/ShareEnum';
import { CustomScrollModifier } from '../common/Styles';
import { ShareConfigModel } from '../model/ShareConfigModel';
import { PanelItem } from './PanelItem';

@ComponentV2
export struct UnifiedSharePanel {
  @Require @Param data: ShareViewData;
  @Require @Param shareList: ShareKinds[][];
  @Event showPoster: () => void = () => {
  };
  @Local windowModel: ShareConfigModel = AppStorageV2.connect(ShareConfigModel, () => new ShareConfigModel())!;
  @Local scrollModifier: CustomScrollModifier = new CustomScrollModifier();

  @Computed
  get filteredShareList(): ShareKinds[][] {
    if (this.data.shareType === ShareContentType.IMAGE) {
      return this.shareList.map(floor => floor.filter(v => v.kindId !== ShareWay.COPY_TO_PASTEBOARD));
    }
    return this.shareList;
  }

  build() {
    Column() {
      Column() {
        ForEach(this.filteredShareList, (item: ShareKinds[], index: number) => {
          Scroll() {
            Row({ space: CommonConstants.PADDING_S }) {
              ForEach(item, (value: ShareKinds) => {
                PanelItem({
                  value: value,
                  data: this.data,
                  showPoster: () => {
                    this.showPoster();
                  },
                })
              }, (value: ShareKinds) => value.kindId)
            }
            .padding({
              left: CommonConstants.PADDING_L,
              right: CommonConstants.PADDING_L,
            })
          }
          .attributeModifier(this.scrollModifier)

          Divider()
            .visibility(index !== this.shareList.length - 1 ? Visibility.Visible : Visibility.None)
            .padding({
              left: CommonConstants.PADDING_L,
              right: CommonConstants.PADDING_L,
              top: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_M,
            })
        }, (item: ShareKinds[]) => JSON.stringify(item))
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        top: CommonConstants.PADDING_M,
        bottom: CommonConstants.PADDING_M,
      })

      Column() {
        Button('取消')
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.data.closeSheet();
          })
      }
      .padding({
        left: CommonConstants.PADDING_L,
        right: CommonConstants.PADDING_L,
        top: CommonConstants.PADDING_S,
        bottom: this.windowModel.sheetType === SheetType.BOTTOM ? CommonConstants.PADDING_S : 0,
      })
    }
  }
}