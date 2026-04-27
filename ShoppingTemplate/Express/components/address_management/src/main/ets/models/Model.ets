// 文件信息
export interface FileInfo {
  filePath: string,
  fileName: string
}

// 振幅数据
@ObservedV2
export class MyAmplitude {
  @Trace amplitude: number = 0;

  constructor(amplitude: number = 0) {
    this.amplitude = amplitude;
  }
}