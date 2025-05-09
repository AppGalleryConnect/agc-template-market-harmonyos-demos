interface FunctionResultRet {
  code: number
  desc: string
}

interface FunctionResult {
  idToken: string
  avatar: string
  userName: string
  phoneNumber: string
}

export interface CloudResult {
  ret: FunctionResultRet,
  result: FunctionResult[]
}

export interface CloudFunctionResult {
  result: CloudResult
}