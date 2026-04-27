export class AppInfo {
  bundleName: string;
  versionCode: number;
  versionName: string;
  targetName: string;
  productName: string;
  buildModeName: string;
  isDebug: boolean;
  clientId: string;

  isProduct(): boolean {
    throw new Error('Method not implemented.');
  }

  isMirror(): boolean {
    throw new Error('Method not implemented.');
  }
}
