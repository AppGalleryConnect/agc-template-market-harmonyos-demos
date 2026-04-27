import { BaseRequest, BaseResponse, HttpMethod } from "@agctemplate/utils";
import { HttpHandler } from "../handler/HttpHandler";

export interface MethodInput {
  path: string; // 方法路径
  needLogin?: boolean; // 是否依赖登录
}

function methodImpl(method: HttpMethod, input: MethodInput, target: any, key: string,
  descriptor: PropertyDescriptor): PropertyDescriptor {
  if (!target.ReqMap) {
    target.ReqMap = new Map<string, BaseRequest>();
  }
  let baseRequest: BaseRequest = target.ReqMap.get(key);
  if (!baseRequest) {
    baseRequest = new BaseRequest();
  }
  baseRequest.method = method;
  baseRequest.path = input.path;
  target.ReqMap.set(key, baseRequest);

  descriptor.value = function (...args: any[]): Promise<BaseResponse<any>> {
    let request: BaseRequest = target.ReqMap.get(key);
    if (request?.bodyIndex !== undefined) {
      request.body = args[request.bodyIndex]
    }
    if (request?.queryIndex !== undefined) {
      request.query = args[request.queryIndex]
    }
    if (request?.headersIndex !== undefined) {
      request.headers = args[request.headersIndex]
    }
    if (target.getDomain && request) {
      request.host = target.getDomain();
    }
    return HttpHandler.sendRequest(request, input.needLogin);
  };
  return descriptor;
}

export function GET(input: MethodInput): (target: any, key: string,
  descriptor: PropertyDescriptor) => PropertyDescriptor {
  return function (
      target: any,
      key: string,
      descriptor: PropertyDescriptor
  ) {
    return methodImpl('GET', input, target, key, descriptor);
  };
}

export function PUT(input: MethodInput): (target: any, key: string,
  descriptor: PropertyDescriptor) => PropertyDescriptor {
  return function (
      target: any,
      key: string,
      descriptor: PropertyDescriptor
  ) {
    return methodImpl('PUT', input, target, key, descriptor);
  };
}

export function POST(input: MethodInput): (target: any, key: string,
  descriptor: PropertyDescriptor) => PropertyDescriptor {
  return function (
      target: any,
      key: string,
      descriptor: PropertyDescriptor
  ) {
    return methodImpl('POST', input, target, key, descriptor);
  };
}

export function DELETE(input: MethodInput): (target: any, key: string,
  descriptor: PropertyDescriptor) => PropertyDescriptor {
  return function (
      target: any,
      key: string,
      descriptor: PropertyDescriptor
  ) {
    return methodImpl('DELETE', input, target, key, descriptor);
  };
}

export function Body(target: any, key: string, index: number): void {
  if (!target.ReqMap) {
    target.ReqMap = new Map<string, BaseRequest>();
  }
  let baseRequest: BaseRequest = target.ReqMap.get(key);
  if (!baseRequest) {
    baseRequest = new BaseRequest();
  }
  baseRequest.bodyIndex = index;
  target.ReqMap.set(key, baseRequest);
}

export function Query(target: any, key: string, index: number): void {
  if (!target.ReqMap) {
    target.ReqMap = new Map<string, BaseRequest>();
  }
  let baseRequest: BaseRequest = target.ReqMap.get(key);
  if (!baseRequest) {
    baseRequest = new BaseRequest();
  }
  baseRequest.queryIndex = index;
  target.ReqMap.set(key, baseRequest);
}

export function Header(target: any, key: string, index: number): void {
  if (!target.ReqMap) {
    target.ReqMap = new Map<string, BaseRequest>();
  }
  let baseRequest: BaseRequest = target.ReqMap.get(key);
  if (!baseRequest) {
    baseRequest = new BaseRequest();
  }
  baseRequest.headersIndex = index;
  target.ReqMap.set(key, baseRequest);
}
