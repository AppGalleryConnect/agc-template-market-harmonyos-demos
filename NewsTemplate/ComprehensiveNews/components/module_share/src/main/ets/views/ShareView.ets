import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationAttribute } from '@kit.UIDesignKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { UnifiedSharePanel } from '../components/UnifiedSharePanel'
import { PosterSharePanel } from '../components/PosterSharePanel'
import { Screenshot } from '../screenshot/Screenshot';
import { SystemShareUtils } from '../utils/SystemShareUtils';
import { WXShareUtils } from '../utils/WXShareUtils';
import { ShareViewData } from '../common/ShareParams';
import { CommonConstants } from '../common/Constants';
import { posterShareList, unifiedShareList, unifiedImageShareList } from '../common/PanelData';
import { ShareConfigModel } from '../model/ShareConfigModel';
import {
  saveImgToSandbox,
  isSandboxPath,
  downloadImage,
  isNetPath,
  saveToSandbox,
  isBase64Path,
  base64ToSandbox,
} from '../utils/FileUtils';
import { ShareContentType } from '../common/ShareEnum';

@Builder
export function shareViewBuilder(params: ShareViewData) {
  ShareView({
    data: params,
  })
}

const TAG = '[ShareView]';

@ComponentV2
export struct ShareView {
  @Param data: ShareViewData = new ShareViewData();
  @Local configModel: ShareConfigModel = AppStorageV2.connect(ShareConfigModel, () => new ShareConfigModel())!;
  @Local systemShare: SystemShareUtils = SystemShareUtils.instance;
  @Local wxShare: WXShareUtils = WXShareUtils.instance;
  @Local sharePosterShow: boolean = false;

  async aboutToAppear(): Promise<void> {
    AppStorage.setOrCreate('cacheFiles', []);
    await this.loadImage();
    this.systemShare.init(this.getUIContext(), this.data);
    if (this.data.enableKnockShare) {
      this.systemShare.onKnockShare();
    }
    if (this.data.enableGestureShare) {
      this.systemShare.onGestureShare();
    }
    this.wxShare.registerOnWXRespCallback(this.data);
    this.configModel.registerWindowBottomPadding(this.getUIContext());
  }

  aboutToDisappear(): void {
    UtilLog.debug(TAG, 'aboutToDisappear');
  }

  @Monitor('data.sheetType')
  onSheetTypeChange() {
    this.configModel.sheetType = this.data.sheetType ?? SheetType.BOTTOM;
  }

  generatePixelmap() {
    const id = this.data.extComponentId ? this.data.extComponentId : CommonConstants.DEFAULT_SNAPSHOT_ID;
    this.getUIContext()
      .getComponentSnapshot()
      .get(id)
      .then((async pixmap => {
        this.sharePosterShow = true;
        this.data.imageUri = await saveImgToSandbox(this.getUIContext(), pixmap);
      }))
      .catch((err: BusinessError) => {
        UtilLog.error(TAG, `componentSnapshot get ${id} fail, error: ` + JSON.stringify(err));
      })
  }

  async loadImage() {
    if (this.data.shareType === ShareContentType.IMAGE && this.data.imageUrl) {
      try {
        if (typeof this.data.imageUrl === 'string') {
          if (isSandboxPath(this.data.imageUrl)) {
            this.data.imageUri = this.data.imageUrl
            return;
          }
          if (isNetPath(this.data.imageUrl)) {
            const buffer = await downloadImage(this.data.imageUrl);
            this.data.imageUri = await saveToSandbox(this.getUIContext(), buffer);
            return;
          }
          if (isBase64Path(this.data.imageUrl)) {
            this.data.imageUri = await base64ToSandbox(this.getUIContext(), this.data.imageUrl);
            return;
          }
          this.data.imageUri = this.data.imageUrl;
        } else {
          this.data.imageUri = await saveImgToSandbox(this.getUIContext(), this.data.imageUrl);
        }
      } catch (e) {
        UtilLog.error(TAG, `loadImage failed, error: ${JSON.stringify(e)}`);
      }
    }
  }

  @Computed
  get getUnifiedShareList() {
    if (this.data.shareType === ShareContentType.IMAGE) {
      return unifiedImageShareList
        .map(floor => floor.filter(v => !this.data.excludedAbilities.includes(v.kindId)))
        .filter(floor => floor.length);
    }
    return unifiedShareList
      .map(floor => floor.filter(v => !this.data.excludedAbilities.includes(v.kindId)))
      .filter(floor => floor.length);
  }

  @Computed
  get getPosterShareList() {
    return posterShareList.filter(v => !this.data.excludedAbilities.includes(v.kindId));
  }

  @Computed
  get showUnifiedPanel() {
    return !this.data.directPoster && !this.sharePosterShow;
  }

  @Computed
  get sheetTitle() {
    return this.sharePosterShow ? this.data.posterSheetTitle : this.data.sheetTitle;
  }

  build() {
    HdsNavigation() {
      Column() {
        Scroll() {
          Column() {
            Blank().height(64)
            if (this.showUnifiedPanel) {
              UnifiedSharePanel({
                shareList: this.getUnifiedShareList,
                data: this.data,
                showPoster: () => {
                  this.generatePixelmap();
                },
              })
            }

            if (this.sharePosterShow) {
              PosterSharePanel({
                shareList: this.getPosterShareList,
                data: this.data,
              })
            }
          }
        }
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        Screenshot({
          data: this.data,
        })
          .position({ left: -2000, bottom: 0 })
          .visibility(Visibility.Hidden)
          .accessibilityGroup(true)
          .accessibilityLevel('no')
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        top: CommonConstants.PADDING_S,
        bottom: this.configModel.bottomPadding,
      })
      .onAppear(() => {
        if (this.data.directPoster) {
          setTimeout(() => {
            this.generatePixelmap();
          }, 100)
        }
      })
    }
    .height('auto')
    .titleBar({
      content: {
        title: { mainTitle: this.sheetTitle },
      },
    })
    .titleMode(HdsNavigationTitleMode.MODAL)
  }
}