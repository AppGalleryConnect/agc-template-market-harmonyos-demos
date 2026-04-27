import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { subjectSegmentation } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import {
  LoadingStatus,
  routerStack,
  RouterMap,
  GlobalStateMgr,
  iData,
  WindowUtil,
  BreakpointSystem,
  BreakpointTypeEnum,
  PushUtil,
  PermissionUtil,
  ProductInfoPageParam,
  ProductSearchResultsPageParam,
} from 'lib_foundation';
import { CategoryItem } from 'lib_network';
import { CustomScanOptions, ScanRouterMap } from 'module_product_scan';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { PreloadUtil } from '../utils/PreloadUtil';

const TAG: string = '[HomePageVM]';

@ObservedV2
export class HomePageVM {
  public readonly global: GlobalStateMgr = iData.global;
  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;
  @Trace
  public refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  @Trace
  public isRefreshing: boolean = false;
  @Trace
  bannerList: string[] = [];
  @Trace
  categoryList: CategoryItem[] = [];
  @Trace
  searchList: string[] = [];
  @Trace
  currentSearchStr: string = '';

  @Computed
  get isTablet() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG;
  }

  public onRefreshStateChange(state: RefreshStatus): void {
    this.refreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.loadHomePage();
    }
  }

  public async loadHomePage(): Promise<void> {
    this.loadingStatus = LoadingStatus.LOADING;
    try {
      const res = await PreloadUtil.getPreloadData();
      if (res?.code === 0) {
        this.categoryList = res.categoryList;
        this.searchList = res.searchList;
        this.bannerList = res.bannerList;
        this.currentSearchStr = res.searchList[0];
      }
      this.loadingStatus = LoadingStatus.SUCCESS;
    } catch (e) {
      this.loadingStatus = LoadingStatus.FAIL;
    }
    this.isRefreshing = false;
    PermissionUtil.requestNotificationPermission(() => {
      // push能力测试
      PushUtil.pushMessageMock();
    });
  }

  public jumpToCategoryPage(id: string) {
    routerStack.pushPathByName(RouterMap.PRODUCT_CATEGORY, id);
  }

  public jumpToScanPage() {
    routerStack.pushPath({
      name: ScanRouterMap.CUSTOM_SCAN_PAGE,
      param: {
        enableMultiMode: true,
        enableAlbum: true,
        handleScanResult: (url: string) => {
          const id = url.split('/').pop();
          if (id) {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_INFO,
              param: { productId: id } as ProductInfoPageParam,
            });
          } else {
            WindowUtil.toast('未识别到有效商品，请重新扫描');
          }
        },
        handlePhotoResult: (uri: string | PixelMap) => {
          if (typeof uri === 'string') {
            this._readFileToPixelMap(uri).then((res) => {
              if (res) {
                this._getSegmentationImage(res);
              }
            });
          } else {
            this._getSegmentationImage(uri);
          }
        },
      } as CustomScanOptions,
    });
  }

  public jumpToSearchPage(uiContext: UIContext, snapShotComponentId: string) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(uiContext, snapShotComponentId, 9);
    const param: Record<string, Object | undefined> = {
      'snapShotId': snapShotComponentId,
      'longTakeTransitionParam': longTakeTransitionParam,
      'defaultSearch': this.currentSearchStr,
    };
    routerStack.pushPath({
      name: RouterMap.PRODUCT_SEARCH,
      param,
    });
  }

  private _getSegmentationImage(pixelMap: PixelMap) {
    if (!pixelMap) {
      return;
    }
    let visionInfo: subjectSegmentation.VisionInfo = {
      pixelMap,
    };
    let config: subjectSegmentation.SegmentationConfig = {
      maxCount: 1,
      enableSubjectDetails: true,
      enableSubjectForegroundImage: true,
    };
    subjectSegmentation
      .doSegmentation(visionInfo, config)
      .then((data: subjectSegmentation.SegmentationResult) => {
        if (data.fullSubject && data.fullSubject.foregroundImage) {
          const searchImg = data.fullSubject.foregroundImage;
          routerStack.pushPath({
            name: RouterMap.PRODUCT_SEARCH_RESULTS,
            param: {
              searchImg,
            } as ProductSearchResultsPageParam,
          });
        } else {
          Logger.warn(TAG, 'No foreground image in segmentation result');
          WindowUtil.toast('未识别到有效主体，请重新拍摄或选择图片');
        }
      })
      .catch((error: BusinessError) => {
        Logger.error(
          TAG,
          `Image segmentation failed errCode: ${error.code}, errMessage: ${error.message}`,
        );
        WindowUtil.toast('未识别到有效主体，请重新拍摄或选择图片');
      });
  }

  private _readFileToPixelMap(uri: string): Promise<image.PixelMap | undefined> {
    return new Promise((resolve, reject) => {
      let file: fileIo.File | undefined = undefined;
      try {
        file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
        const imageSource: image.ImageSource = image.createImageSource(file.fd);
        const pixelMap: image.PixelMap = imageSource.createPixelMapSync();
        resolve(pixelMap);
      } catch (e) {
        reject(e);
      } finally {
        if (file) {
          fileIo.closeSync(file);
        }
      }
    });
  }
}
