import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { filePreview } from '@kit.PreviewKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import fileUri from '@ohos.file.fileuri';
import request from '@ohos.request';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = 'File';

export function myRawfileCopy(filetype: string, context: common.UIAbilityContext) {
  try {
    context.resourceManager.getRawFileContent(filetype, (err: BusinessError, data: Uint8Array) => {
      if (err != null) {
        UtilLog.info(TAG, 'open file failed: ' + err.message);
      } else {
        let buffer = data.buffer;
        let sandboxPath = context.cacheDir;
        UtilLog.info(TAG, 'myRawfileCopy path' + sandboxPath);
        let file: fs.File = null!;
        try {
          file = fs.openSync(context.cacheDir + '/' + filetype, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          fs.writeSync(file.fd, buffer);
          UtilLog.info(TAG, 'myRawfileCopy success');
        } catch (err) {
          UtilLog.info(TAG, 'myRawfileCopy error');
        } finally {
          fs.close(file.fd);
        }
      }
    });
  } catch (err) {
    UtilLog.error(TAG, `myRawfile file failed, errCode: ${err.code}, errMessage: ${err.message}`);
  }
}

export function viewPDF(uiContext: UIContext, bookName: string) {
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  try {
    let pdfUrl: string = context.resourceManager.getStringSync($r('app.string.pdf_url').id);
    let time = systemDateTime.getTime();
    let fileName = bookName + time + '文件.pdf';
    downloadFile(pdfUrl, fileName, uiContext);
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    UtilLog.error(TAG, `Invoke downloadTask failed-----, code is ${err.code}, message is ${err.message}`);
  }
}

export function viewFile(fileName: string, filePath: string, uiContext: UIContext) {
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  let promptAction = uiContext.getPromptAction();
  let uri = fileUri.getUriFromPath(filePath);
  filePreview.canPreview(context, uri).then((result) => {
    if (result === true) {
      let fileNames: string[] = fileName.split('.');
      let type = fileNames[fileNames.length-1];
      let mType: string = '';
      switch (type) {
        case 'pdf': {
          mType = 'application/pdf';
          break;
        }
        case 'txt': {
          mType = 'text/plain';
          break;
        }
        case 'png': {
          mType = 'image/png';
          break;
        }
        case 'jpg': {
          mType = 'image/jpeg';
          break;
        }
        case 'docx': {
          mType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        }
        case 'xlsx': {
          mType = 'application/vnd.ms-excel';
          break;
        }
        default: {
          UtilLog.error(TAG, 'Type Is Not Support');
          promptAction.showToast({
            message: '类型不支持'
          });
          return;
        }
      }
      let fileInfo: filePreview.PreviewInfo = {
        title: fileName,
        uri: uri,
        mimeType: mType
      };
      filePreview.openPreview(context, fileInfo).then(() => {
        UtilLog.info(TAG, 'openPreview success');
      }).catch((err: BusinessError) => {
        UtilLog.error(TAG, 'openPreview failed, err = ' + err.message);
      });
    } else {
      promptAction.showToast({
        message: '文件不可预览'
      });
      UtilLog.info(TAG, 'openPreview failed, err = canPreview false');
    }
  }).catch((err: BusinessError) => {
    UtilLog.error(TAG, 'canPreview failed, err = ' + err.message);
  });
}

export function downloadFile(url: string, fileName: string, uiContext: UIContext) {
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  let cacheDir = context.cacheDir;
  let promptAction = uiContext.getPromptAction();
  try {
    let filePath = cacheDir + '/' + fileName;
    let res = fs.accessSync(filePath);
    if (res) {
      UtilLog.info(TAG, 'file exists and viewFile');
      viewFile(fileName, filePath, uiContext);
    } else {
      UtilLog.info(TAG, 'downloadTask1 filesDir============: ' + cacheDir + '/' + fileName);
      request.downloadFile(context, {
        url: url,
        filePath: filePath,
        enableMetered: true
      }).then((downloadTask: request.DownloadTask) => {
        let progressCallback = (receivedSize: number, totalSize: number) => {
          promptAction.showToast({
            message: '下载中..'
          });
          UtilLog.info(TAG, 'download receivedSize: ' + receivedSize + ', totalSize: ' + totalSize);
        };
        downloadTask.on('progress', progressCallback);
        downloadTask.on('complete', async () => {
          const taskInfo = await downloadTask.getTaskInfo();
          UtilLog.info(TAG, 'downloadTask complete,status: ' + taskInfo.status);
          viewFile(fileName, filePath, uiContext);
        });
      }).catch((err: BusinessError) => {
        promptAction.showToast({
          message: err.message
        });
        UtilLog.info(TAG, 'Invoke downloadTask failed-----, message is: ' + err.message);
      });
    }
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    UtilLog.error(TAG, 'Invoke downloadTask failed-----, message is: ' + err.message);
  }
}

export function viewExcel(uiContext: UIContext) {
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  try {
    let fileName = 'file.xlsx';
    let filePath = context.cacheDir + '/' + fileName;
    myRawfileCopy(fileName, context as common.UIAbilityContext);
    viewFile(fileName, filePath, uiContext);
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    UtilLog.error(TAG, `Invoke downloadTask failed-----, code is ${err.code}, message is ${err.message}`);
  }
}

export function viewWord(uiContext: UIContext, bookName: string) {
  let context = uiContext.getHostContext() as common.UIAbilityContext;
  try {
    let pdfUrl: string = context.resourceManager.getStringSync($r('app.string.word_url').id);
    let time = systemDateTime.getTime();
    let fileName = bookName + time + '文件.docx';
    downloadFile(pdfUrl, fileName, uiContext);
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    UtilLog.error(TAG, `Invoke downloadTask failed-----, code is ${err.code}, message is ${err.message}`);
  }
}
