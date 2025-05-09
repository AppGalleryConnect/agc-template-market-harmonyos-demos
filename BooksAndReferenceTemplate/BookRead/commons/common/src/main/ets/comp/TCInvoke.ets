import { Constants, TData } from '../constant/Constants';
import { FileUtils } from '../utils/FileUtils';


interface MockModel {
  path: string,
  method: string,
  data: TData
}

// 云函数触发类
export class TCInvoke {
  private functionName: string = '';
  private connectorName: string = '';
  private apiName: string = '';
  private isDebug: string = '';
  private isMock: boolean = false;
  private mockData: TData = ''; // mock 文件在 rawfile 目录下

  public init(functionName: string, connectorName: string, apiName: string, isDebug: string) {
    this.functionName = functionName;
    this.connectorName = connectorName;
    this.apiName = apiName;
    this.isDebug = isDebug;
  }

  public initMock(mockFile: string) {
    this.isMock = true;
    this.mockData = JSON.parse(FileUtils.readRawfile(mockFile));
  }

  public async get<T>(path: string, body?: TData, header?: TData, params?: TData): Promise<T> {
    return this.invoke<T>(Constants.HTTP_GET, path, body, header, params);
  }

  public async post<T>(path: string, body?: TData, header?: TData, params?: TData): Promise<T> {
    return this.invoke<T>(Constants.HTTP_POST, path, body, header, params);
  }

  public async put<T>(path: string, body?: TData, header?: TData, params?: TData): Promise<T> {
    return this.invoke<T>(Constants.HTTP_PUT, path, body, header, params);
  }

  public async delete<T>(path: string, body?: TData, header?: TData, params?: TData): Promise<T> {
    return this.invoke<T>(Constants.HTTP_DELETE, path, body, header, params);
  }

  private async invoke<T>(method: string, path: string, body?: TData, header?: TData, params?: TData): Promise<T> {
    return this.invokeMock<T>(method, path, body, header, params);
  }

  private async invokeMock<T>(method: string, path: string, body?: TData, header?: TData,
    params?: TData): Promise<TData> {
    return this.mockData[path];
  }
}