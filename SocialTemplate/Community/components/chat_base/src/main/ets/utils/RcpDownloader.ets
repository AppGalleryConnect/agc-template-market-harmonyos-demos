import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

// 下载
export class RcpDownloader {
  private session: rcp.Session | null = null;
  private filePath: string = '';

  constructor(context: common.UIAbilityContext) {
    this.filePath = `${context.cacheDir}/downloads`
    this.ensureDirectory();
  }

  // 初始化下载任务
  async startDownload(url: string, fileName: string): Promise<rcp.Response> {
    // 创建了一个安全配置对象，其中remoteValidation设置为'skip'，表示将跳过远程验证。
    const securityConfig: rcp.SecurityConfiguration = {
      remoteValidation: 'skip'
    }
    this.session = rcp.createSession({
      requestConfiguration: {
        transfer: { timeout: { connectMs: 6000, transferMs: 6000, inactivityMs: 6000 } },
        security: securityConfig
      }
    });
    const fullPath = `${this.filePath}/${fileName}`;
    let downloadToFile: rcp.DownloadToFile ={
      kind: 'file',
      file: fullPath
    }
    return this.session.downloadToFile(url, downloadToFile)
  }

  // 创建下载目录
  private ensureDirectory(): void {
    if (!fs.accessSync(this.filePath)) {
      fs.mkdirSync(this.filePath);
    }
  }
}