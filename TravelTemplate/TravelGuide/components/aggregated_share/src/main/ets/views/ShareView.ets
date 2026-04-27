import { AppStorageV2, componentSnapshot } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UnifiedSharePanel } from '../components/UnifiedSharePanel'
import { PosterSharePanel } from '../components/PosterSharePanel'
import { Screenshot } from '../screenshot/Screenshot';
import { SystemShareUtils } from '../utils/SystemShareUtils';
import { WXShareUtils } from '../utils/WXShareUtils';
import { ShareViewData } from '../common/ShareParams';
import { CommonConstants } from '../common/Constants';
import { posterShareList, unifiedShareList } from '../common/PanelData';
import { Logger } from '../common/Logger';
import { ShareConfigModel } from '../model/ShareConfigModel';
import { clearCache } from '../utils/FileUtils';

@Builder
export function shareViewBuilder(params: ShareViewData) {
  ShareView({
    data: params,
  })
}

const TAG = 'ShareView';

@ComponentV2
export struct ShareView {
  @Param data: ShareViewData = new ShareViewData();
  @Local configModel: ShareConfigModel = AppStorageV2.connect(ShareConfigModel, () => new ShareConfigModel())!;
  @Local systemShare: SystemShareUtils = SystemShareUtils.instance;
  @Local wxShare: WXShareUtils = WXShareUtils.instance;
  @Local sharePosterShow: boolean = false;
  @Local pixmap: image.PixelMap | undefined = undefined;

  aboutToAppear(): void {
    AppStorage.setOrCreate('cacheFiles', []);
    this.systemShare.init(this.data);
    this.systemShare.onKnockShare();
    this.wxShare.registerOnWXRespCallback(this.data);
    this.configModel.registerWindowBottomPadding();
  }

  aboutToDisappear(): void {
    this.systemShare.offKnockShare();
    this.wxShare.unregisterOnWXRespCallback();
    this.configModel.unRegisterWindowBottomPadding();
    this.clearCacheFiles();
  }

  @Monitor('data.sheetType')
  onSheetTypeChange() {
    this.configModel.sheetType = this.data.sheetType ?? SheetType.BOTTOM;
  }

  generatePixelmap() {
    const id = this.data.extComponentId ? this.data.extComponentId : CommonConstants.DEFAULT_SNAPSHOT_ID;
    try {
      componentSnapshot.get(id, ((err: BusinessError, pixmap: image.PixelMap) => {
        if (err) {
          Logger.error(TAG, `componentSnapshot get ${id} fail, error: ` + JSON.stringify(err));
          return;
        }
        this.pixmap = pixmap;
        this.sharePosterShow = true;
      }))
    } catch (err) {
    }
  }

  clearCacheFiles() {
    const files: string[] = AppStorage.get('cacheFiles') ?? [];
    clearCache(files);
  }

  @Computed
  get getUnifiedShareList() {
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
    Column() {
      Row() {
        Text(this.sheetTitle)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(56)
      .padding({
        left: CommonConstants.PADDING_L,
        right: 88,
      })

      Scroll() {
        Column() {
          if (this.showUnifiedPanel) {
            UnifiedSharePanel({
              shareList: this.getUnifiedShareList,
              data: this.data,
              pixmap: this.pixmap,
              showPoster: () => {
                this.generatePixelmap();
              },
            })
          }

          if (this.sharePosterShow) {
            PosterSharePanel({
              shareList: this.getPosterShareList,
              data: this.data,
              pixmap: this.pixmap,
            })
          }
        }
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })

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
}