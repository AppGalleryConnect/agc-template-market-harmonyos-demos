import { getInstance } from '../common/CommonRoute';
import { FileUtil } from '../utils/FileUtil';
import { common } from '@kit.AbilityKit';
import { FileType } from '../common/Constant';
import { FileDetail, FileVo } from '../model/FileVo';
import { fileIo as fs } from '@kit.CoreFileKit';
import { setKnockSharedFiles } from '../service/KnockFileShareService';

@ObservedV2
export class AirdropPageVM {
  private static _instance: AirdropPageVM
  @Trace context: common.UIAbilityContext | null = null
  @Trace selectedFiles: FileVo[] = []
  @Trace fileNumMap: Map<FileType, number> = new Map<FileType, number>();
  @Trace imageFileDetail: FileDetail = {
    size: '0B',
    count: 0,
  }
  @Trace videoFileDetail: FileDetail = {
    size: '0B',
    count: 0,
  }
  @Trace documentFileDetail: FileDetail = {
    size: '0B ',
    count: 0,
  }

  public static get instance() {
    if (!AirdropPageVM._instance) {
      AirdropPageVM._instance = new AirdropPageVM();
    }
    return AirdropPageVM._instance;
  }

  init() {
    this.clear()
    const param = getInstance().getParamByName('AirdropPage')[0] as string[]
    this.handleFiles(param)
  }

  clear() {
    this.selectedFiles = []
    this.fileNumMap = new Map<FileType, number>()
    this.imageFileDetail = {
      size: '0B ',
      count: 0,
    }
    this.videoFileDetail = {
      size: '0B ',
      count: 0,
    }
    this.documentFileDetail = {
      size: '0B ',
      count: 0,
    }
  }

  // 文件处理
  async handleFiles(filePath: string[]) {
    const classifyFiles = FileUtil.classifyFiles(filePath)
    if (classifyFiles.images.length > 0) {
      this.imageFileDetail = await this.handleFilesDetail(classifyFiles.images, FileType.IMAGE)
    }
    if (classifyFiles.documents.length > 0) {
      this.documentFileDetail = await this.handleFilesDetail(classifyFiles.documents, FileType.DOCUMENT)
    }
    if (classifyFiles.videos.length > 0) {
      this.videoFileDetail = await this.handleFilesDetail(classifyFiles.videos, FileType.VIDEO)
    }
    setKnockSharedFiles(this.selectedFiles)
  }

  async handleFilesDetail(filePath: string[], fileType: FileType): Promise<FileDetail> {
    if (!this.context) {
      return {
        size: '0B',
        count: 0,
      }
    }
    let size = 0
    let count = filePath.length
    for (let i = 0; i < filePath.length; i++) {
      let fileVo = await FileUtil.getFileInfo(filePath[i], fileType)
      if (!fileVo) {
        continue;
      }
      let res = await FileUtil.copyToSandbox(this.context, filePath[i], fileVo.name)
      let sandboxPath = 'file://' + this.context.abilityInfo.bundleName + res
      size = size + fs.statSync(res).size
      fileVo.uri = sandboxPath;
      this.selectedFiles.push(fileVo)
    }
    let num = this.fileNumMap.get(FileType.IMAGE) ?? 0
    this.fileNumMap.set(FileType.IMAGE, num + filePath.length)

    return {
      size: FileUtil.formatFileSize(size),
      count,
    }
  }
}
