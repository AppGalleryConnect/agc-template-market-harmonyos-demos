import { storageStatistics } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import { RouterModule } from 'lib_foundation';
import { BaseViewModel, contextUtil, Logger, toastUtil } from 'module_base';

@ObservedV2
export class SettingPageVM extends BaseViewModel {
  private static _instance: SettingPageVM;
  @Trace public size: number = 0
  @Trace isLogin: boolean = false

  public static get instance() {
    if (!SettingPageVM._instance) {
      SettingPageVM._instance = new SettingPageVM();
    }
    return SettingPageVM._instance;
  }

  public async logout() {
    this.userInfoModel.isLogin = false
    RouterModule.pop()
  }

  public async getCacheSize() {
    try {
      const bundleStats = await storageStatistics.getCurrentBundleStats()
      this.size = bundleStats.cacheSize //单位默认是B
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }

  // 3.清除缓存数据
  async clearCache() {
    contextUtil.getUiContext()?.showAlertDialog(
      {
        title: '温馨提示',
        message: '缓存清除后不可恢复！',
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        gridCount: 4,
        offset: { dx: 0, dy: -20 },
        primaryButton: {
          value: '取消',
          action: () => {
          },
        },
        secondaryButton: {
          enabled: true,
          defaultFocus: true,
          style: DialogButtonStyle.HIGHLIGHT,
          value: '确定',
          action: () => {
            //用户点击确定后执行删除缓存逻辑
            let cacheDir = contextUtil.getContext()?.cacheDir;
            let fileList = fs.listFileSync(cacheDir) //获取缓存总目录下所有文件信息
            //循环依次判断如果待删除的缓存文件存在就执行删除操作
            fileList.forEach((item: string) => {
              let dirPath = cacheDir + '/' + item;
              // 判断是否为文件夹
              let isDirectory: boolean = false;
              try {
                isDirectory = fs.statSync(dirPath).isDirectory();
              } catch (e) {
                console.error(JSON.stringify(e));
              }
              if (isDirectory) {
                fs.rmdirSync(dirPath);
              } else {
                fs.unlink(dirPath).then(() => {
                  console.info('remove file succeed');
                }).catch((err: Error) => {
                  console.error('remove file failed with error message: ' + err.message);
                });
              }
            })
            toastUtil.showToast('清除成功！')
            this.getCacheSize()
          },
        },
      },
    )
  }
}
