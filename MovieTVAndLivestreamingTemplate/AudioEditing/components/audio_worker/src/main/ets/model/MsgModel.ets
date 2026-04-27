export enum ACTION {
  START = 'start',
  END = 'end',
  COMPUTE_AMPLITUDES = 'amplitudes'
}

export interface MsgRes {
  status: 0 | -1, //0是成功，-1是失败
  msg: string,
  workerId: number,
  data?: string
}


export interface MsgBody {
  action: ACTION
  workerId: number
  params?: string
}

export interface AmpParamBody {
  bytesPerFrame: number
  sampleRate: number
  pcmPath: string
  size: number
  channelLayout: number
  bytesPerSample: number
}