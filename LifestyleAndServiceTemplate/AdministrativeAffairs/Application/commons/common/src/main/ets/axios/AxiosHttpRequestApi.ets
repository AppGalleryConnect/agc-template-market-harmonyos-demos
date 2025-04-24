import request from './AxiosHttpRequest';

const getBaseUrl = ''

export const createAuthProduct = <T, U>(data: T, config?: U) => {
  const url = `${getBaseUrl}/auth-product`;
  return request.post<T>(url, data, config);
};