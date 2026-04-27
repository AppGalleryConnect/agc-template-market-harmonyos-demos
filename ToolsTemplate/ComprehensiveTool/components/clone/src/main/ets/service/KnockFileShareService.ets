import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { FileVo } from '../model/FileVo';
import { FileUtil } from '../utils/FileUtil';
import { UtilLog } from '@hw-agconnect/util-log';

// 碰一碰分享
class KnockFileShareService {
  private fileVos: FileVo[] = []

  public setSharedFiles(fileVos: FileVo[]) {
    this.fileVos = fileVos
  }

  // 分享数据
  public shareDataCallback(target: harmonyShare.SharableTarget) {
    if (!this.fileVos || this.fileVos.length === 0) {
      console.log('KnockFileShare  -->  请选择要分享的文件')
      return;
    }
    let shareData: systemShare.SharedData = new systemShare.SharedData(this.getShareRecord(this.fileVos[0]));
    for (let idx = 1; idx < this.fileVos.length; idx++) {
      shareData.addRecord(this.getShareRecord(this.fileVos[idx]));
    }
    try {
      target.share(shareData);
    } catch (err) {
      console.log('分享失败:', JSON.stringify(err));
    }
  }

  public unlinkFiles() {
    if (!this.fileVos) {
      return;
    }
    this.fileVos.forEach(fileVo => {
      FileUtil.deleteSandboxFile(fileVo.uri)
    })
  }

  private getShareRecord(data: FileVo): systemShare.SharedRecord {
    let suffix = '.' + data.uri.split('.').pop();
    // 通过文件扩展名获取 UTD。
    let utd = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(suffix);
    return {
      utd: utd,
      uri: data.uri,
      thumbnailUri: data.thumbnail,
      title: data.name,
      description: data.description
    };
  }
}

const knockFileShareService: KnockFileShareService = new KnockFileShareService()

export function onKnockShareStart() {
  if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
    try {
      harmonyShare.on('knockShare', async (target: harmonyShare.SharableTarget) => {
        knockFileShareService.shareDataCallback(target);
      });
    } catch (e) {
      UtilLog.error(`onKnockShareStart failed: ${JSON.stringify(e)}`);
    }
  }
}

export function onKnockShareEnd() {
  if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
    try {
      harmonyShare.off('knockShare');
    } catch (e) {
      UtilLog.error(`onKnockShareEnd failed ${JSON.stringify(e)}`)
    }
  }
}

export function setKnockSharedFiles(fileVos: FileVo[]) {
  knockFileShareService.setSharedFiles(fileVos)
}