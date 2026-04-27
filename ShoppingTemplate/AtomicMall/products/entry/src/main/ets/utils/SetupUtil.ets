import { Want } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import {
  CustomShareModel,
  ProductInfoPageParam,
  RouterMap,
  routerStack,
  SHARE_PAGE_MAP,
  SystemShareInfo
} from 'lib_foundation';

export class SetupUtil {
  public static navInfo?: NavPathInfo;

  public static handleWant(want: Want) {
    // todo: 实现自定义AppLinking解析
    let uri = want?.uri;
    let params = want?.parameters?.orgScanCode as string | undefined
    if (uri && params) {
      const productId = params.split('productId=')[1] || null;
      if (productId) {
        SetupUtil.navInfo = {
          name: RouterMap.PRODUCT_INFO,
          param: { productId } as ProductInfoPageParam,
        };
        return;
      }
    }
  }

  public static jumpToTarget() {
    console.log(JSON.stringify(SetupUtil.navInfo));
    if (!SetupUtil.navInfo) {
      return;
    }
    routerStack.pushPath(SetupUtil.navInfo);
    SetupUtil.navInfo = undefined;
  }

  public static onShare(wantParams: Record<string, Object>) {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = routerStack.getAllPathName();
    let showShareMenu = false;
    if (currentName.length && SHARE_PAGE_MAP.includes(currentName[currentName.length-1])) {
      showShareMenu = true;
    }
    const shareParams: SystemShareInfo = {
      showShareMenu,
      title: '商城元服务分享',
      description: '商城元服务分享',
      parameters: {} as CustomShareModel,
    };
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;
    if (instance.productId) {
      const pageParams: CustomShareModel = {
        id: instance.id,
        pageName: instance.pageName,
        productId: instance.productId,
        productTitle: instance.productTitle,
      };
      shareParams.title = pageParams.productTitle;
      shareParams.parameters = pageParams;
    }

    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }
}