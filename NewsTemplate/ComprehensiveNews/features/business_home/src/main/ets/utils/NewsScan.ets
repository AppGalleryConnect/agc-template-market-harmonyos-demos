import { Want } from '@kit.AbilityKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NewsEnum, RouterToNews, GlobalContextUtils, Logger, RouterParams } from 'lib_common';
import { BaseNewsServiceApi } from 'lib_news_api';

const TAG = '[NewsScan]';

export class NewsScan {
  /**
   * 开启扫描
   */
  public scan(): void {
    // 定义扫码参数options
    const options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true,
    };
    try {
      scanBarcode.startScanForResult(GlobalContextUtils.globalContext, options)
        .then(async (result: scanBarcode.ScanResult) => {
          // 识别网页链接场景
          if (result.originalValue.startsWith('http')) {
            this.startBrowsableAbility(result.originalValue);
            return;
          }
          // 解析码值结果跳转应用服务页
          const resultParams: Record<string, string | NewsEnum> = JSON.parse(result.originalValue)
          if (!resultParams?.newsId) {
            GlobalContextUtils.showToast({ message: '扫码错误，仅支持模板内文章、视频、动态海报生成的二维码' });
            return;
          }
          // 如果查询不到数据，提示用户
          const news = await BaseNewsServiceApi.queryNews(resultParams.newsId as string);
          if (!news) {
            GlobalContextUtils.showToast({ message: '未查询到该内容' });
            return;
          }

          // 跳转新闻详情页
          const routerParams: RouterParams<null> = {
            'newsId': resultParams?.newsId,
            'type': resultParams?.type ?? NewsEnum.Article,
          } as Record<string, string>
          RouterToNews.pushToNewsDetails(routerParams);
        })
        .catch((error: BusinessError) => {
          let message: string = ''
          if (error.code === 1000500002) {
            // 用户取消扫码
            message = '取消扫码';
          } else {
            message = '扫码错误';
          }
          GlobalContextUtils.showToast({ message: message });
          Logger.error(TAG, `Failed to get ScanResult with options. Code:${error.code}, message: ${error.message}`);
        });
    } catch (error) {
      GlobalContextUtils.showToast({ message: '扫码错误' })
      Logger.error(TAG, `Failed to start the scanning service. Code:${error.code}, message: ${error.message}`);
    }
  }

  /**
   * 拉起浏览器
   * @param url
   */
  public startBrowsableAbility(url: string): void {
    const want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url,
      parameters: {
        'ohos.ability.params.showDefaultPicker': true,
      },
    };

    GlobalContextUtils.globalUIAbilityContext.startAbility(want)
      .then(() => {
        Logger.debug(TAG, 'Start browsableAbility successfully.');
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }
}