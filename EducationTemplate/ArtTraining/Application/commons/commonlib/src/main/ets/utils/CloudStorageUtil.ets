import { cloudCommon, cloudStorage } from '@kit.CloudFoundationKit';
import fs from '@ohos.file.fs';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { Logger } from './Logger';
import auth from '@hw-agconnect/auth';
import { promptAction } from '@kit.ArkUI';
import { WindowUtil } from './WindowUtil';

const TAG = '[CloudStorageUtil]';

enum ErrorCode {
  EXIST_USER = 1210005,
}

export class CloudStorageUtil {
  private static _authProvider: cloudCommon.AuthProvider = auth.getAuthProvider();
  private static _storageBucket: cloudStorage.StorageBucket = cloudStorage.bucket();
  private static _isAuthValid: boolean = false;

  // 认证服务登录
  private static async _authSignIn() {
    try {
      const signInResult = await auth.signIn({
        autoCreateUser: true,
        credentialInfo: {
          kind: 'hwid',
        },
      });
      CloudStorageUtil._isAuthValid = true;
      Logger.info(TAG, `signInHwid success. result: ${signInResult.getUser().getUid()}`);
    } catch (error) {
      if (error.code === ErrorCode.EXIST_USER) {
        Logger.info(TAG, 'already sign in a user');
        CloudStorageUtil._isAuthValid = true;
      }
      Logger.error(TAG, `signInHwid error, Code: ${error.code}, message: ${error.message}`);
    } finally {
      if (CloudStorageUtil._isAuthValid) {
        CloudStorageUtil._authProvider = auth.getAuthProvider();
        cloudCommon.init({
          authProvider: CloudStorageUtil._authProvider,
        });
      } else {
        promptAction.showToast({ message: '华为账号认证服务异常，云存储服务不可用' });
      }
    }
  }

  // 初始化云存储实例
  public static async initBucket() {
    const canUse = canIUse('SystemCapability.DeviceCloudGateway.CloudFoundation');
    if (!canUse) {
      Logger.warn('this device cannot use SystemCapability.DeviceCloudGateway.CloudFoundation');
      return;
    }
    if (!CloudStorageUtil._isAuthValid) {
      await CloudStorageUtil._authSignIn();
    }
  }

  // 上传文件
  public static async upload(fileUri: string, callback?: (url: string, isSuccess?: boolean) => void) {
    if (!CloudStorageUtil._isAuthValid) {
      return Promise.reject();
    }
    let fileName = fileUri.split('/').pop() as string;
    Logger.info(TAG, `file name ${fileName}`);
    let cacheFile = `${Date.now()}_${fileName}`;
    Logger.info(TAG, `cacheFile ${cacheFile}`);
    let cacheFilePath = getContext().cacheDir + '/' + cacheFile;
    let cloudPath: string = `user-upload/${Date.now()}_${fileName}`;
    let srcFile: fs.File | null = null;
    let dstFile: fs.File | null = null;
    try {
      srcFile = fs.openSync(fileUri);
      dstFile = fs.openSync(cacheFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(srcFile.fd, dstFile.fd);
    } catch (e) {
      Logger.info(TAG, `copy file failed ${e.message}`);
      Promise.reject(e);
    } finally {
      if (srcFile) {
        fs.closeSync(srcFile);
      }
      if (dstFile) {
        fs.closeSync(dstFile);
      }
    }
    return CloudStorageUtil._storageBucket.uploadFile(WindowUtil.context, {
      localPath: cacheFile, // 本地文件路径，context.cacheDir目录下的文件
      cloudPath, // 云侧路径
    })
      .then((task: request.agent.Task) => {
        task.on('progress', (progress) => {
          Logger.info(TAG, `on progress ${JSON.stringify(progress)}`);
        });
        task.on('completed', async (progress) => {
          Logger.info(TAG, `on completed ${JSON.stringify(progress)}`);
          CloudStorageUtil._deleteCacheFile(cacheFilePath);
          const downloadUrl = await CloudStorageUtil._storageBucket.getDownloadURL(cloudPath);
          callback?.(downloadUrl);
        });
        task.on('failed', (progress) => {
          Logger.error(TAG, `on failed ${JSON.stringify(progress)}`);
          CloudStorageUtil._deleteCacheFile(cacheFilePath);
          callback?.('', false);
        });
        task.on('response', (response) => {
          Logger.info(TAG, `on response ${JSON.stringify(response)}`);
        });

        task.start((err: BusinessError) => {
          if (err) {
            Logger.error(TAG, `Failed to start the uploadFile task, Code: ${err.code}, message: ${err.message}`);
          } else {
            Logger.info(TAG, 'Succeeded in starting a uploadFile task.');
          }
        });
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `uploadFile failed, Code: ${err.code}, message: ${err.message}`);
      });

  }

  // 删除上传时的缓存文件
  private static _deleteCacheFile(fileUri: string) {
    try {
      fs.unlinkSync(fileUri);
      Logger.info(TAG, 'delete cache file success');
    } catch (err) {
      Logger.error(TAG, `delete cache file failed,uri:${fileUri},error:` + err);
    }
  }
}