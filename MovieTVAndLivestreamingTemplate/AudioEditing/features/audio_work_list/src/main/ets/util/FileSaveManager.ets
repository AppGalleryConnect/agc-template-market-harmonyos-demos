import { fileIo } from '@kit.CoreFileKit'
import { picker } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

const TAG = 'FileSaveManager'

/**
 * 文件保存管理类
 * 负责将音频文件保存到手机
 */
export class FileSaveManager {
  private context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  /**
   * 保存音频文件到手机
   * @param sourcePath 源文件路径
   * @param fileName 文件名（含扩展名，如 "音乐.mp3"）
   * @returns 是否保存成功
   */
  async saveAudioToPhone(sourcePath: string, fileName: string): Promise<boolean> {
    let srcFile: fileIo.File | null = null
    let desFile: fileIo.File | null = null

    try {

      // 创建文档保存选择器
      const documentSaveOptions = new picker.DocumentSaveOptions()
      documentSaveOptions.newFileNames = [fileName]
      
      const documentPicker = new picker.DocumentViewPicker(this.context)
      
      // 打开保存对话框，让用户选择保存位置
      const uris = await documentPicker.save(documentSaveOptions)
      
      if (!uris || uris.length === 0) {
        return false
      }

      const destUri = uris[0]

      // 打开源文件和目标文件
      srcFile = fileIo.openSync(sourcePath, fileIo.OpenMode.READ_ONLY)
      desFile = fileIo.openSync(destUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)

      // 使用 copyFileSync 直接复制文件，保持原始格式
      fileIo.copyFileSync(srcFile.fd, desFile.fd)

      return true
    } catch (error) {
      return false
    } finally {
      // 关闭文件
      if (srcFile) {
        try {
          fileIo.closeSync(srcFile)
        } catch (e) {
        }
      }
      if (desFile) {
        try {
          fileIo.closeSync(desFile)
        } catch (e) {
        }
      }
    }
  }

  /**
   * 检查是否有文件访问权限
   */
  async checkPermission(): Promise<boolean> {
    try {
      // 文档选择器不需要额外权限
      return true
    } catch (error) {
      return false
    }
  }
}
