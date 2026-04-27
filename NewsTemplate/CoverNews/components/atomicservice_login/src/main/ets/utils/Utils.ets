export class ApiController {
  unlink: (callback: () => Promise<void>) => void = () => {
  }
}

export function encryptPhone(phone: string) {
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}