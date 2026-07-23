import http from '@ohos.net.http'
import util from '@ohos.util'

export interface EventSourceOptions {
  method?: http.RequestMethod
  headers?: Record<string, string>
  body?: string
}

export interface EventSourceEvent {
  data: string
  type?: string
}

interface RequestOptions {
  method: http.RequestMethod
  header: Record<string, string>
  readTimeout: number
  extraData?: string
}

export type EventCallback = (event: EventSourceEvent) => void

export default class EventSource {
  private httpRequest: http.HttpRequest
  private url: string
  private options: EventSourceOptions
  private onmessage: EventCallback | null = null
  private onerror: ((error: Error) => void) | null = null
  private oncomplete: (() => void) | null = null
  private buffer: string = ''
  private isActive: boolean = false
  private decoder: util.TextDecoder = new util.TextDecoder()

  constructor(url: string, options: EventSourceOptions = {}) {
    this.url = url // 请求路径url
    this.options = options // 请求需要的参数信息
    this.httpRequest = http.createHttp() // 调用createHttp()方法，创建一个HttpRequest对象
    this.connect()
  }

  // 封装请求
  private connect() : void {
    this.isActive = true
    const headers: Record<string, string> = this.options.headers ?? {};

    headers['Accept'] = headers['Accept'] ?? 'text/event-stream';
    headers['Cache-Control'] = headers['Cache-Control'] ?? 'no-cache';

    const requestOptions: RequestOptions = {
      method: this.options.method || http.RequestMethod.GET, // 请求方式
      header: headers, // 请求头信息
      readTimeout: 0 // 读取超时时间，默认为60000ms
    }

    // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
    if (this.options.body) {
      requestOptions.extraData = this.options.body
    }

    // 设置数据接收监听,订阅HTTP流式响应数据接收事件
    this.httpRequest.on('dataReceive', (data: ArrayBuffer) => {
      if (!this.isActive) {
        return
      }
      try {
        const chunk = this.decoder.decodeToString(new Uint8Array(data))
        this.processChunk(chunk)
      } catch (e) {
        console.error('EventSource: Failed to decode chunk:', e)
        const error = e instanceof Error ? e : new Error(`Failed to decode chunk: ${e}`)
        this.handleError(error)
      }
    })

    // 发起HTTP网络请求并返回流式响应
    this.httpRequest.requestInStream(
      this.url,
      requestOptions
    ).then((data: number) => {
      try {
        // 处理buffer中剩余的数据（可能没有以换行符结尾）
        this.flushBuffer()
      } catch (e) {
        console.error('EventSource: Unexpected error in flushBuffer:', e)
      } finally {
        // 确保oncomplete总是被调用，即使flushBuffer出错
        if (this.oncomplete) {
          this.oncomplete()
        }
      }
    }).catch((err: Error) => {
      this.handleError(err)
    });
  }

  // 处理返回的数据
  private processChunk(chunk: string) : void {
    this.buffer += chunk
    const lines = this.buffer.split('\n')
    this.buffer = lines[lines.length - 1] || ''

    for (let i = 0; i < lines.length - 1; i++) {
      const line = lines[i]
      if (line.trim() === '') {
        continue
      }
      this.processLine(line)
    }
  }

  // 处理单行数据
  private processLine(line: string) : void {
    // 处理标准SSE格式：data: {...}
    if (line.startsWith('data:')) {
      const data = line.slice(5).trim()
      if (this.onmessage) {
        try {
          this.onmessage({ data })
        } catch (e) {
          // 保留原始错误信息
          console.error('EventSource: Error in message handler:', e)
          const error = e instanceof Error ? e : new Error(String(e))
          // 只通知错误，不关闭连接（让上层决定如何处理）
          if (this.onerror) {
            this.onerror(error)
          }
        }
      }
    }
    // 处理非SSE格式的错误响应（直接JSON格式）
    else if (line.trim().startsWith('{') && line.includes('"error"')) {
      console.warn('EventSource: Received non-SSE error response:', line.trim())
      if (this.onmessage) {
        try {
          this.onmessage({ data: line.trim() })
        } catch (e) {
          console.error('EventSource: Error handling non-SSE error response:', e)
          const error = e instanceof Error ? e : new Error(String(e))
          if (this.onerror) {
            this.onerror(error)
          }
        }
      }
    }
  }

  // 刷新buffer中剩余的数据（连接结束时调用）
  private flushBuffer() : void {
    if (this.buffer && this.buffer.trim() !== '') {
      console.log('EventSource: Flushing remaining buffer:', this.buffer)
      try {
        this.processLine(this.buffer)
      } catch (e) {
        console.error('EventSource: Error flushing buffer:', e)
        const error = e instanceof Error ? e : new Error(String(e))
        if (this.onerror) {
          this.onerror(error)
        }
      } finally {
        this.buffer = ''
      }
    }
  }

  // 处理错误信息回调
  private handleError(error: Error) : void {
    if (this.onerror) {
      this.onerror(error)
    }
    this.close()
  }

  public set onMessage(callback: EventCallback) {
    this.onmessage = callback
  }

  public set onError(callback: (error: Error) => void) {
    this.onerror = callback
  }

  public set onComplete(callback: () => void) {
    this.oncomplete = callback
  }

  // 关闭请求
  public close() : void {
    this.isActive = false
    if (this.httpRequest) {
      // 取消订阅HTTP流式响应数据接收事件
      this.httpRequest.off('dataReceive')
      // 当该请求使用完毕时，调用destroy方法主动销毁
      this.httpRequest.destroy()
    }
  }
}

